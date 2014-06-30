%w(version use_writer plantuml_writer railtie).each { |f| require "rails2use/#{f}" }

module Rails2use
  attr_accessor :writer

  def self.extract!(options={})
    Rails2use.extract(options)
  end

  def self.extract(options={})
    options[:writer] ||= 'PlantumlWriter'
    const_writer = options[:writer].constantize
    suffix = const_writer.suffix
    options[:file] ||= Rails.root.join('doc', 'uml', "output.#{suffix}")

    types = if options[:type]
              options[:type].split(',').map { |t| t.strip.downcase }
            else
              'class'
            end

    path = Rails.root.join ''
    sub_paths = (options[:file].to_s+'/').gsub(path.to_s, '').split('/')

    sub_paths.each do |subdir|
      path = path.join subdir
      Dir.mkdir(path.dirname) unless Dir.exists?(path.dirname)
    end
    #path

    abstract_classes = []
    subclasses = {}

    model_blacklist = defined?(Doorkeeper) ? [Doorkeeper::AccessGrant, Doorkeeper::AccessToken, Doorkeeper::Application] : []
    Rails.application.eager_load! #unless Rails.configuration.cache_classes
    all_models = (ActiveRecord::Base.descendants - model_blacklist)

    attribute_blacklist = %w(model)

    @writer = const_writer.new options[:file]

    @writer.write_head :class if types.include?('class')
    #abstract classes first
    all_models.each do |model|

      #belongs_to
      model.reflect_on_all_associations(:belongs_to).each do |association|
        #extract polymorphic classes and determine abstract class status
        class_name = association.name.to_s.camelcase
        if association.options.has_key?(:polymorphic)
          if !abstract_classes.include?(class_name)
            @writer.write_abstract_class class_name if types.include?('class')
            abstract_classes << class_name
          end
          subclasses[model.name] = [class_name]
        end
      end
    end

    all_models.each do |model|
      model_associations = {:has_many => {}, :has_one => {}}
      #def_abstract_class = abstract_classes.include?(model.name) ? 'abstract ' : ''
      def_super_classes = subclasses.has_key?(model.name) ? subclasses[model.name].join(',') : ''

      model_attributes = ''
      attribute_names = model.try(:attribute_names) rescue model.columns.map { |c| c.name }
      attribute_names.each do |attribute|
        model_attributes << " #{attribute} : #{@writer.types[model.columns_hash[attribute].type.to_s]}\n" if @writer.types.has_key?(model.columns_hash[attribute].type.to_s) && !attribute_blacklist.include?(attribute)
      end

      #has_many
      model.reflect_on_all_associations(:has_many).each do |association|
        #extract associations, also belongs_to are covered by this feature
        class_name = association.options.has_key?(:as) && abstract_classes.include?(association.options[:as].to_s.camelcase) ? association.options[:as].to_s.camelcase : association.class_name
        model_associations[:has_many][(model.name.to_s+'_'+association.name.to_s).camelcase] = {class_name: model.name, role_name: (association.name.to_s+model.name).underscore, foreign_class_name: class_name, foreign_role_name: association.name}
      end

      #has_and_belongs_to_many

      #has_one
      model.reflect_on_all_associations(:has_one).each do |association|
        #skip thorugh-associations
        unless association.options.has_key?(:through)
          model_associations[:has_one][(model.name.to_s+'_'+association.name.to_s).camelcase] = {class_name: model.name, role_name: (association.name.to_s+model.name).underscore, foreign_class_name: association.class_name, foreign_role_name: association.name}
        end
      end
      @writer.write_class model.name, def_super_classes, model_attributes, model_associations if types.include?('class')
    end
    @writer.write_class_end if types.include?('class')

    @writer.write_foot :class if types.include?('class')
    # end class diagram

    if types.include?('object')
      @writer.write_head :object
      all_instances = []
      all_models.each do |model|
        all_instances_by_model = model.unscoped.all
        all_instances += all_instances_by_model
        all_instances_by_model.each do |instance|
          instance_name = "#{model.name.underscore}#{instance.id.to_s}"
          attributes = {}
          attribute_names = model.try(:attribute_names) rescue model.columns.map { |c| c.name }
          attribute_names.each do |attribute|
            if @writer.types.has_key?(model.columns_hash[attribute].type.to_s) && !attribute_blacklist.include?(attribute)
              value = instance.send attribute
              attributes[attribute] = value if value.present?
            end
          end
          @writer.write_instance instance_name, model.name, attributes
        end
      end
      all_instances.each do |instance|
        model = instance.class
        instance_name = "#{model.name.underscore}#{instance.id.to_s}"
        model.reflect_on_all_associations(:has_many).each do |association|
          association_name = (model.name.to_s+'_'+association.name.to_s).camelcase
          foreign_instances = instance.send association.name
          foreign_instances = [foreign_instances] unless foreign_instances.is_a?(Enumerable)
          foreign_instances.each do |foreign_instance|
            @writer.write_association association_name, instance_name, foreign_instance.class.to_s.underscore+foreign_instance.id.to_s
          end
          #class_name = association.options.has_key?(:as) && association.options[:as].to_s.camelcase.in?(abstract_classes) ? association.options[:as].to_s.camelcase : association.class_name
        end
      end
      @writer.write_foot :object
    end
    @writer.close
    options[:file]
  end
end
