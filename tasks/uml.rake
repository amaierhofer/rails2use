namespace :doc do
  desc 'Generates UML diagrams.'
  task uml: :environment do
    puts 'Generating ...'
    options = {}
    options[:file] = ENV['OUTPUT'] if ENV['OUTPUT']
    options[:writer] = case ENV['FORMAT']
                       when /plant(_)?(uml)?/
                         'PlantumlWriter'
                       when /use(_)?(uml)?/
                         'UseWriter'
                       else
                         'PlantumlWriter'
                       end

    options[:type] = ENV['TYPE'] ? ENV['TYPE'] : 'class'

    file = Rails2use.extract! options
    puts "using #{options[:writer]}"
    puts "uml diagrams: #{options[:type]}"
    puts "output written to #{File.split(file)[0]}."
  end
end
