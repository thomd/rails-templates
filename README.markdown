# rails templates

templates for my rails needs

## usage:

    rails project -m simple.template.rb
or

    railst project simple

For this put the following function (based on [Ryan Bates][1]) into your bashrc:

    function railst {
      appname=$1
      template=$2
      shift 2
      rails $appname -m http://github.com/thomd/rails-templates/raw/master/$template.template.rb $@
    }



[1]: http://github.com/ryanb/rails-templates/tree/master