class PlantumlWriter
  def self.suffix
    'puml'
  end

  attr_accessor :types, :file

  def initialize(file_name)
    @filename = file_name
    @object_filename = file_name.to_s.gsub(/\..*\/?$/, '_instances.puml')
    @associations = ""
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

  def write_head(type=:class)
    file = case type
             when :object then
               @instances_file = File.open(@object_filename, 'w')
               @instances_file
             else
               @file = File.open(@filename, 'w')
               @file
           end
    file.write "@startuml\n\n" #write head
  end

  def write_foot(type=:class)
    file = case type
             when :object then
               @instances_file
             else
               @file
           end
    file.write "\n@enduml"
  end

  def write_abstract_class(class_name)
    @file.write "abstract class #{class_name}\n\nend\n\n"
  end

  def write_class(class_name, super_classes="", attributes="", associations={})
    @file.write "class #{class_name}#{super_classes} {\n#{attributes}\n}\n\n"

    associations[:has_many].each do |name, values|
      @associations << values[:class_name]+ ' "1" o-- "*" '+ values[:foreign_class_name] + "\n"

      #@associations << "association #{name} between\n"
      #@associations << "\t#{values[:class_name]}[1] role #{values[:role_name]}\n"
      #@associations << "\t#{values[:foreign_class_name]}[*] role #{values[:foreign_role_name]}\nend\n\n"
    end


    associations[:has_one].each do |name, values|
      @associations << values[:class_name]+ ' "1" o-- "1" '+ values[:foreign_class_name] + "\n"
    end
  end

  def write_class_end
    @file.write @associations
  end

  def write_instance(instance_name, class_name, attributes=[], associations={})
    @instances_file.write "object #{instance_name}{\n"
    attributes.each do |attribute, value|
      if value.is_a?(Numeric) || value.is_a?(TrueClass) || value.is_a?(FalseClass)
        @instances_file.write "#{attribute} = #{value}\n"
      else
        @instances_file.write "#{attribute} = '#{value}'\n"
      end
    end
    @instances_file.write "}\n\n"
    associations.each do |x|

    end

  end

  def write_association(association_name, instance_name, foreign_instance_name)
    @instances_file.write "#{instance_name} o-- #{foreign_instance_name}\n"
  end

end