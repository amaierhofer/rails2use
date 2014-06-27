require 'rails2use'
require 'rails'
module Rails2use
  class Railtie < Rails::Railtie
    rake_tasks do
      f = File.join(File.dirname(__FILE__), '..', '..', 'tasks', 'uml.rake')
      load f
      # load 'tasks/uml.rake'
    end
  end
end
