
generate :nifty_layout
generate :nifty_scaffold, "post name:string content:text index new edit"
route "map.root :controller => 'post'"


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


rake "db:migrate"