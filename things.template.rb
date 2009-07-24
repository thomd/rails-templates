#
# rails template for things application
#
# usage:
#    rails things -m "things.template.rm"
#

run "rm public/index.html"


# create things controller
file "app/controllers/things_controller.rb", <<-HTML
class ThingsController < ApplicationController
  # call-seq:
  #   GET http://domain.tld/things
  # 
  def index
    @things = Thing.all
  end
  
  # call-seq:
  #   GET http://domain.tld/things/:id
  # 
  def show
    @thing = Thing.find(params[:id])
  end
  
  # call-seq:
  #   GET http://domain.tld/things/new
  # 
  def new
    @thing = Thing.new
  end
  
  # call-seq:
  #   POST http://domain.tld/things
  # 
  def create
    @thing = Thing.new(params[:thing])
    @thing.save!
    self.redirect_to(things_url)
  rescue ActiveRecord::RecordInvalid
    self.render('new')
  end
  
  # call-seq:
  #   GET http://domain.tld/things/:id/edit
  # 
  def edit
    @thing = Thing.find(params[:id])
  end
  
  # call-seq:
  #   PUT http://domain.tld/things/:id
  # 
  def update
    @thing = Thing.find(params[:id])
    @thing.update_attributes!(params[:thing])
    self.redirect_to(thing_url(@thing))
  rescue ActiveRecord::RecordInvalid
    self.render('edit')
  end
  
  # call-seq:
  #   DELETE http://domain.tld/things/:id
  # 
  def destroy
    Thing.delete(params[:id])
    self.redirect_to("/things")
  end
end
HTML


# generate thing model and migrate
generate(:model, "Thing", "name:string", "size:integer", "description:text")

file "app/models/thing.rb", <<-HTML
class Thing < ActiveRecord::Base
  self.validates_presence_of(:name, :size, :description)
  self.validates_uniqueness_of(:name)
  self.validates_numericality_of(:size)
end
HTML

rake "db:migrate"


# create layout view
file "app/views/layouts/things.haml", <<-HTML
!!! Strict
%html
  %head
  %body
    = yield
HTML


# create delete-partial
file "app/views/things/_delete.haml", <<-HTML
%form{:action => thing_url(@thing), :method => 'post'}
  %input{:type => 'hidden', :name => '_method', :value => 'delete'}
  %input{:type => 'hidden', :name => 'authenticity_token', :value => form_authenticity_token}
  %input{:type => 'submit', :value => 'Delete'}
HTML


# create form fields partial
file "app/views/things/_form_fields.haml", <<-HTML
%input{:type => 'hidden', :name => 'authenticity_token', :value => form_authenticity_token}
%label= "Name:"
%input{:name => 'thing[name]', :value => @thing.name}
%label= "Size:"
%input{:name => 'thing[size]', :value => @thing.size}
%label= "Description:"
%textarea{:name => 'thing[description]'}= @thing.description
%input{:type => 'submit', :value => 'Save'}
- if @thing.errors.any?
  %ul
    - @thing.errors.each_full do |msg|
      %li= msg
HTML


# create edit view
file "app/views/things/edit.haml", <<-HTML
%h1= "Editing %s" % @thing.name
%form{:action => thing_url(@thing), :method => 'post'}
  %input{:type => 'hidden', :name => '_method', :value => 'put'}
  = self.render('form_fields')
HTML


# generate index view
file "app/views/things/index.haml", <<-HTML
%h1= "All things"
%ul
  - @things.each do |thing|
    %li
      %a{:href => thing_url(thing)}= thing.name
%a{:href => new_thing_url}= "Make a new thing"
HTML


# generate new view
file "app/views/things/new.haml", <<-HTML
%h1= "Making a new thing"
%form{:action => things_url, :method => 'post'}
  = self.render('form_fields')
HTML


# generate show view
file "app/views/things/show.haml", <<-HTML
%h1= @thing.name
%div
  %a{:href => edit_thing_url(@thing)}= "edit"
  = self.render('delete')
%a{:href => things_url}= "Go back"
HTML


# generate routing
file "config/routes.rb", <<-HTML
ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'things'
  map.things(    '/things',          { :controller => 'things', :action => 'index',   :conditions => { :method => :get    } })
  map.things(    '/things',          { :controller => 'things', :action => 'create',  :conditions => { :method => :post   } })
  map.new_thing( '/things/new',      { :controller => 'things', :action => 'new',     :conditions => { :method => :get    } })
  map.edit_thing('/things/:id/edit', { :controller => 'things', :action => 'edit',    :conditions => { :method => :get    } })
  map.thing(     '/things/:id',      { :controller => 'things', :action => 'show',    :conditions => { :method => :get    } })
  map.thing(     '/things/:id',      { :controller => 'things', :action => 'update',  :conditions => { :method => :put    } })
  map.thing(     '/things/:id',      { :controller => 'things', :action => 'destroy', :conditions => { :method => :delete } })
end
HTML


# install haml plugin
gem 'haml'
rake "gems:install", :sudo => true
run "haml --rails ."

