class PlantumlWriter
  attr_accessor :types, file

  def initialize(file_name)
    @file = File.open(file_name, 'w')
    @associations = ""
    @instances_file = File.open(file_name.to_s.gsub(/\.use\/?$/, '_instances.puml'), 'w')
    @types = {
        'integer' => 'Integer',
        'double' => 'Real',
        'float' => 'Real',
        'boolean' => 'Boolean',
        'string' => 'String'
    }
  end

  def write_head
    @file.write "@startuml\n\n" #write head
  end

  def write_abstract_class(class_name)
    @file.write "abstract class #{class_name}\n\nend\n\n"
  end

  def write_class(class_name, super_classes="", attributes="", associations={})
    @file.write "class #{class_name}#{super_classes}\n{\n#{attributes}\n}\n\n"

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

  def write_instance(instance_name, class_name, attributes=[], associations={})
    @instances_file.write "!create #{instance_name}:#{class_name}\n"
    attributes.each do |attribute, value|
      if value.is_a?(Numeric) || value.is_a?(TrueClass) || value.is_a?(FalseClass)
        @instances_file.write "!set #{instance_name}.#{attribute} := #{instance.send(attribute)}\n"
      else
        @instances_file.write "!set #{instance_name}.#{attribute} := '#{instance.send(attribute).to_s}'\n"
      end
    end
    associations.each do |x|

    end
  end

  def write_association(association_name, instance_name, foreign_instance_name)
    @instances_file.write "!insert (#{instance_name}, #{foreign_instance_name}) into #{association_name}\n"
  end

end