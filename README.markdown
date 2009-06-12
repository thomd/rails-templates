# rails templates

Templates for my rails needs

Make sure you have Rails 2.3 or greater installed

## usage:

    rails project -m simple.template.rb
or

    railst project simple

For this put the following function (based on [Ryan Bates][1]) into your bashrc:

    function railst {
      template=$1
      appname=$2
      shift 2
      rails $appname -m http://github.com/thomd/rails-templates/raw/master/$template.template.rb $@
    }



[1]: http://github.com/ryanb/rails-templates/tree/master