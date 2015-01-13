# writer for use http://sourceforge.net/projects/useocl/
class UseWriter
  attr_accessor :types, :file

  def self.suffix
    'use'
  end

  def initialize(file_name)
    @filename = file_name
    @associations = ''
    @object_filename = file_name.to_s.gsub(/\..*\/?$/, '_instances.use_cmd')
    @types = {
        'integer' => 'Integer',
        'double' => 'Real',
        'float' => 'Real',
        'boolean' => 'Boolean',
        'string' => 'String'
    }
  end

  def close
    @file.try :close
    @instances_file.try :close
  end

  def write_head(type = :class)
    case type
    when :object then
      @instances_file = File.open(@object_filename, 'w')
    else
      @file = File.open(@filename, 'w')
      # write head
      @file.write "model #{Rails.application.class.parent_name}\n\n-- classes\n\n"
    end
  end

  def write_foot(type = :class)
  end

  def write_abstract_class(class_name)
    @file.write "abstract class #{class_name}\n\nend\n\n"
  end

  def write_class(class_name, super_classes = '', attributes = '', associations = {})
    super_classes = " < #{super_classes}" unless super_classes.blank?
    @file.write "class #{class_name}#{super_classes}\nattributes\n#{attributes}\nend\n\n"

    associations[:has_many].each do |name, values|
      @associations << "association #{name} between\n"
      @associations << "\t#{values[:class_name]}[1] role #{values[:role_name]}\n"
      @associations << "\t#{values[:foreign_class_name]}[*] role #{values[:foreign_role_name]}\nend\n\n"
    end

    associations[:has_one].each do |name, values|
      @associations << "association #{name} between\n"
      @associations << "\t#{values[:class_name]}[1] role #{values[:role_name]}\n"
      @associations << "\t#{values[:foreign_class_name]}[1] role #{values[:foreign_role_name]}\nend\n\n"
    end
  end

  def write_class_end
    @file.write @associations
  end

  def write_instance(instance_name, class_name, attributes = [], associations = {})
    @instances_file.write "!create #{instance_name}:#{class_name}\n"
    attributes.each do |attribute, value|
      if value.is_a?(Numeric) || value.is_a?(TrueClass) || value.is_a?(FalseClass)
        @instances_file.write "!set #{instance_name}.#{attribute} := #{value}\n"
      else
        @instances_file.write "!set #{instance_name}.#{attribute} := '#{value}'\n"
      end
    end
    # associations.each do |x|
    #
    # end
  end

  def write_association(association_name, instance_name, foreign_instance_name)
    @instances_file.write "!insert (#{instance_name}, #{foreign_instance_name}) into #{association_name}\n"
  end
end
