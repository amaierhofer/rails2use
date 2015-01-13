require 'rails2use'
require 'rails'

module Rails2use
  # extend rails with task
  class Railtie < Rails::Railtie
    rake_tasks do
      filename = File.dirname(__FILE__), '..', '..', 'tasks', 'uml.rake'
      load File.join(filename)
      # load 'tasks/uml.rake'
    end
  end
end
