#
# rails template for rspec experiments
#

plugin 'rspec', :git => "git://github.com/dchelimsky/rspec.git"
plugin 'rspec-rails', :git => "git://github.com/dchelimsky/rspec-rails.git"

generate("rspec")
generate("rspec_scaffold post title:string body:text author:integer created_at:datetime updated_at:datetime")

git :init

file ".gitignore", <<-END
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
END

run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run "cp config/database.yml config/database.example.yml"
run "rm public/index.html"
  
git :add => ".", :commit => "-m 'initial commit'"
