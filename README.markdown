# rails templates

Collection of templates for my rails needs.

Make sure you have Rails 2.3 or greater installed.

## Usage

    rails project_name -m simple.template.rb
or

    railst project_name simple

For this put the following function (based on [Ryan Bates][1]) into your bashrc:

    function railst {
      template=$1
      appname=$2
      shift 2
      rails $appname -m http://github.com/thomd/rails-templates/raw/master/$template.template.rb $@
    }

## Templates

### plugin.loading-notice

This is a simple prove of concept application for the [loading_notice][2] rails-plugin.

### simple

This is a simple start-to-experiment rails application. It uses Ryan Bates [nifty-generators][3] and inits git.

### things

Rails template for a things application. Not finished yet ...

### rspec

A simple rails application for experimenting with [rspec][4]. 

[1]: http://github.com/ryanb/rails-templates/tree/master
[2]: http://github.com/thomd/loading_notice
[3]: http://github.com/ryanb/nifty-generators
[4]: http://rspec.info/
