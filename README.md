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

Just do:

    require 'Rails2use'

    Rails2use.extract! # default will extract the use file to rails_project/doc/gen/uml/output.use

    Rails2use.extract! file: Rails.root.join('doc', 'gen', 'api', 'uml', 'apiv2.use') # the folder structure will be automtically generated

## Contributing

1. Fork it ( https://github.com/[my-github-username]/rails2use/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
