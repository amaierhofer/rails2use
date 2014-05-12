require "rails2use/version"

module Rails2use

  def self.extract!(options={})
    Rails2use.extract(options)
  end

  def self.extract(options={})
    options[:file] ||= Rails.root.join('doc', 'uml', 'output.use')

    path = Rails.root.join ''
    sub_paths = (options[:file].to_s+'/').gsub(path.to_s, '').split('/')

    sub_paths.each do |subdir|
      path = path.join subdir
      Dir.mkdir(path.dirname) unless Dir.exists?(path.dirname)
    end
    path

    use_types = {
        'integer' => 'Integer',
        'double' => 'Real',
        'float' => 'Real',
        'boolean' => 'Boolean',
        'string' => 'String'
    }


    abstract_classes = []
    subclasses = {}

    model_blacklist = [Doorkeeper::AccessGrant, Doorkeeper::AccessToken, Doorkeeper::Application]
    attribute_blacklist = %w(model)
    File.open(options[:file], 'w') do |f|
      f.write "model Paij\n\n-- classes\n\n" #write head

      Rails.application.eager_load! unless Rails.configuration.cache_classes
      all_models = (ActiveRecord::Base.descendants - model_blacklist)

      #abstract classes first
      all_models.each do |model|

        #belongs_to
        model.reflect_on_all_associations(:belongs_to).each do |association|
          #extract polymorphic classes and determine abstract class status
          class_name = association.name.to_s.camelcase
          if association.options.has_key?(:polymorphic) && !class_name.in?(abstract_classes)
            f.write "abstract class #{class_name}\n\nend\n\n"
            abstract_classes << class_name
            subclasses[model.name] = [class_name]
          end
        end
      end


      model_associations = "-- associations\n\n"
      all_models.each do |model|

        #def_abstract_class = abstract_classes.include?(model.name) ? 'abstract ' : ''
        def_super_classes = subclasses.has_key?(model.name) ? " < #{subclasses[model.name].join(',')}" : ''

        model_attributes = ''
        model.attribute_names.each do |attribute|
          model_attributes << " #{attribute} : #{use_types[model.columns_hash[attribute].type.to_s]}\n" if use_types.has_key?(model.columns_hash[attribute].type.to_s) && !attribute.in?(attribute_blacklist)
        end
        f.write "class #{model.name}#{def_super_classes}\nattributes\n#{model_attributes}\nend\n\n"


        #has_many
        model.reflect_on_all_associations(:has_many).each do |association|
          #extract associations, also belongs_to are covered by this feature
          model_associations << "association #{(model.name.to_s+association.name.to_s).camelcase} between\n"
          model_associations << "\t#{model.name}[1] role #{(association.name.to_s+model.name).underscore}\n"
          class_name = association.options.has_key?(:as) && association.options[:as].to_s.camelcase.in?(abstract_classes) ? association.options[:as].to_s.camelcase : association.class_name
          model_associations << "\t#{class_name}[*] role #{association.name}\nend\n\n"
        end


        #has_and_belongs_to_many

        #has_one
        model.reflect_on_all_associations(:has_one).each do |association|
          #skip thorugh-associations
          unless association.options.has_key?(:through)
            model_associations << "association #{(model.name.to_s+association.name.to_s).camelcase} between\n"
            model_associations << "\t#{model.name}[1] role #{(association.name.to_s+model.name).underscore}\n"
            model_associations << "\t#{association.class_name}[1] role #{association.name}\nend\n\n"
          end
        end
      end
      f.write model_associations

      all_models.each do |model|
        all_instances = model.unscoped.all
        all_instances.each_with_index do |instance, i|
          f.write "!create #{model.name.underscore}#{i}:#{model.name}\n"
          model.attribute_names.each do |attribute|
            value = instance.send attribute
            if value.present?
              if value.is_a?(Numeric) || value.is_a?(TrueClass) || value.is_a?(FalseClass)
                f.write "!set #{model.name.underscore}#{i}.#{attribute} := #{instance.send(attribute)}\n"
              else
                f.write "!set #{model.name.underscore}#{i}.#{attribute} := '#{instance.send(attribute).to_s}'\n"
              end
            end
          end
        end
      end
    end

  end
end
