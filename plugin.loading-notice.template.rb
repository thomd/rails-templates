#
# prove of concept application for loading_notice rails-plugin
#
# http://github.com/thomd/loading_notice
#


# loading_notice plugin
plugin 'loading_notice', :git => 'http://github.com/thomd/loading_notice.git/'
rake "loading_notice:install"


# generators
run "rm public/index.html"
generate :controller, 'time'
route "map.root :controller => 'time'"


# generate time controller
file "app/controllers/time_controller.rb", <<-HTML
class TimeController < ApplicationController

  def index
  end

  def now
    render :text  => current_time
  end

  def now_delayed
    sleep 3
    render :text  => current_time
  end

  private

  def current_time
    "<p>Time is <em>#{DateTime.now.to_s}</em> now.</p>"
  end
end
HTML


# generate layout template
file "app/views/layouts/time.html.erb", <<-HTML
<!DOCTYPE html>
<html>
<head>
  <title>Proof of Concept 'loading_notice'</title>
  <%= javascript_include_tag :defaults, 'loading_notice' %>
  <%= stylesheet_link_tag 'loading_notice' %>
  <script type="text/javascript">
    window.onload = function(){
      window.loading_notice = new LoadingNotice("loading");
    }
  </script>

</head>
<body>
  <div id="loading" style="display: none">Loading...</div>
  <%= yield %>
</body>
</html>
HTML


# generate index view
file "app/views/time/index.html.erb", <<-HTML
<%= link_to_remote "get time", :update => "times", :url => {:controller => "time", :action => "now"}, :position => "after" %> | 
<%= link_to_remote "get time 3 seconds delayed", :update => "times", :url => {:controller => "time", :action => "now_delayed"}, :position => "after" %>
<div id="times"></div>
HTML
