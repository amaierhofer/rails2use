[![Gem Version](https://badge.fury.io/rb/rails2use.svg)](http://badge.fury.io/rb/rails2use)
travis
[![Code Climate](https://codeclimate.com/github/manuel84/rails2use/badges/gpa.svg)](https://codeclimate.com/github/manuel84/rails2use)
# Rails2use

Extracts all rails model to one UML file written in USE (UML-based Specification Environment).

Currently is only ActiveRecord supported. Wrappers for Mongoid and others are planned.

## Installation

Add this line to your application's Gemfile:

    gem 'rails2use'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails2use

## Usage

Running Rake-Task:

    rake doc:uml FORMAT=use|plantuml TYPE=object,class
    
Options:

- FORMAT: use | plantuml (default = plantuml)
- TYPE: object | class (default = object,class)
- OUTPUT: *filename* (default = doc/output.puml)

You can use multiple options in a comma separated way

Using in Ruby:

    require 'rails2use'

    Rails2use.extract! # default will extract the use file to rails_project/doc/gen/uml/output.use

    Rails2use.extract! file: Rails.root.join('doc', 'gen', 'api', 'uml', 'apiv2.use') # the folder structure will be automtically generated

## Contributing

1. Fork it ( https://github.com/[my-github-username]/rails2use/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
