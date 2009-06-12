# by http://gist.github.com/57458

def gem(name, options = {})
  puts "adding gem #{name}"

  sentinel = '  # config.gem "aws-s3", :lib => "aws/s3"'
  gems_code = "config.gem '#{name}'"

  if options.any?
    opts = options.inject([]) {|result, h| result << [":#{h[0]} => '#{h[1]}'"] }.join(", ")
    gems_code << ", #{opts}"
  end

  in_root do
    gsub_file 'config/environment.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
      "#{match}\n  #{gems_code}"
    end
  end
end

# Same syntax as the "file" method, but for appending to an existing file
def file_append(filename, data = nil, &block)
  puts "appending to file #{filename}"
  dir, file = [File.dirname(filename), File.basename(filename)]

  inside(dir) do
    File.open(file, "a") do |f|
      if block_given?
        f.write(block.call)
      else
        f.write(data)
      end
    end
  end
end

# adds .gitignore files to any empty child directories so that
# they can be tracked by git
def touch_gitignore(path = '.')
  Dir[File.join(File.expand_path(path), '**')].each do |file|
    if File.directory?(file) && File.basename(file) != 'tmp'
      touch_gitignore(file)
      if Dir[File.join(file, '*')].empty?
        run "touch #{File.join(file, '.gitignore')}"
      end
    end
  end  
end


# Setup basic Rails app

SUDO_CMD = yes?("Does gem installation require sudo on your system? (yes/no)") ? "sudo" : ""

run "rm public/index.html"
run "rm public/favicon.ico"
run "rm public/images/*"
run "rm README"
file 'README.markdown', <<-TEXT
App Name
========

This is the app README.
TEXT
run "cp config/database.yml config/database.yml.example"

file ".gitignore", <<-TEXT
.DS_Store
/log/*.log
/tmp/*
/db/schema.rb
/doc/api
/doc/plugins
/doc/app
/config/database.yml
/coverage
/public/stylesheets/site.css
TEXT

touch_gitignore
git :init
git :add => "."
git :commit => "-a -m 'Created empty Rails app'"

rake("rails:freeze:gems")
git :add => "vendor/rails"
git :commit => "-a -m 'Froze Rails gems'"


# Remove default routes

gsub_file 'config/routes.rb', /^  map\.connect/ do |match|
  '  # map.connect'
end
git :add => "."
git :commit => "-a -m 'Comment out default routes so that we have to explicitly define any routes that don''t map to a resource.'"


# Return 404 for routing errors

gsub_file 'app/controllers/application_controller.rb', /^end$/ do |match|
  <<-CODE

  unless RAILS_ENV == 'development'
    rescue_from ActiveRecord::RecordNotFound, :with => :render_404
    rescue_from ActionController::UnknownController, :with => :render_404
    rescue_from ActionController::UnknownAction, :with => :render_404
    rescue_from ActionController::RoutingError, :with => :render_404
  end

  def render_403
    respond_to do |type|
      type.html { render :file => "\#{RAILS_ROOT}/public/403.html", :status => 403 }
      type.xml  { render :xml => '<not_found></not_found>', :status => 403 }
      type.all  { render :nothing => true, :status => 403 }
    end
  end

  def render_404
    respond_to do |type|
      type.html { render :file => "\#{RAILS_ROOT}/public/404.html", :status => 404 }
      type.xml  { render :xml => '<not_found></not_found>', :status => 404 }
      type.all  { render :nothing => true, :status => 404 }
    end
  end
end
  CODE
end
git :add => "."
git :commit => "-a -m 'Render 404 page when there are routing errors in production'"


# Enable asset timestamp cache

initializer 'asset_tags.rb', <<-CODE
# With the asset tag timestamps cache enabled, the asset tag helper 
# methods will make fewer expense file system calls. However this 
# prevents you from modifying any asset files while the server is running.
ActionView::Helpers::AssetTagHelper.cache_asset_timestamps = true
CODE
git :add => "."
git :commit => "-a -m 'Enabled asset timestamp cache.'"


# Setup shoulda / factory girl testing framework

plugin 'shoulda', :git => 'git://github.com/thoughtbot/shoulda.git'
git :add => "vendor/plugins"
git :commit => "-a -m 'Installed shoulda plugin'"
file 'test/shoulda_macros/macros.rb', <<-CODE
class Test::Unit::TestCase
  # Shoulda macro that ensures output is well-formed HTML.
  def self.should_be_well_formed
    should 'be well formed' do
      assert_select 'html', true
    end
  end
end
CODE
git :add => "test/shoulda_macros/macros.rb"
git :commit => "-a -m 'Added should_be_well_formed shoulda macro'"

gem "thoughtbot-factory_girl", :lib => "factory_girl", :source => "http://gems.github.com"
run "#{SUDO_CMD} gem install thoughtbot-factory_girl --source http://gems.github.com"
rake "gems:unpack GEM='thoughtbot-factory_girl'"
git :add => "vendor/gems"
git :commit => "-a -m 'Installed Factory Girl gem'"

run "#{SUDO_CMD} gem install rcov"
plugin 'rcov_plugin', :git => 'git://github.com/commondream/rcov_plugin.git'
git :add => "vendor/plugins"
git :commit => "-a -m 'Installed rcov plugin'"


# Setup HAML/SASS templates

gem "haml"
run "#{SUDO_CMD} gem install haml"
rake "gems:unpack GEM='haml'"
run 'haml --rails .'
initializer 'sass.rb', <<-CODE
# Format CSS in standard, human-readable style.
Sass::Plugin.options[:style] = :expanded

# Override default template location of public/stylesheets/sass to something outside of
# public so the raw templates won't be served up by the web server
Sass::Plugin.options[:template_location] = RAILS_ROOT + "/app/views/stylesheets"
CODE
git :add => "."
git :commit => "-a -m 'Installed HAML gem and plugin'"

file 'app/views/layouts/application.html.haml', <<-HAML
!!! Strict
%html{ "xml:lang" => "en", :lang => "en-us", :xmlns => "http://www.w3.org/1999/xhtml" }
  %head
    %meta{ :content => "text/html; charset=utf-8", "http-equiv" => "content-type" }
    %title My Application
    %link{ :href => "/stylesheets/site.css", :rel => "stylesheet", :media => "all", :type => "text/css" }
  %body
    = yield
HAML
file 'app/views/stylesheets/site.sass', <<-SASS
// Sitewide Stylesheet
SASS
git :add => "."
git :commit => "-a -m 'Added basic layout and stylesheet.'"


# Create DB schemas

if yes?("Create DB schemas? (yes/no)")
  rake "db:create"
  rake "db:create", :env => 'test'
  rake "db:migrate"
end