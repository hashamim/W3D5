class AttrAccessorObject
  def self.my_attr_accessor(*names)
    # ...
    names.each do |name|
      define_method(name) do
        self.instance_variable_get("@#{name}")
      end
    end
  # ...
    names.each do |name|
      define_method("#{name}=") do |value|
        self.instance_variable_set("@#{name}", value)
      end
    end
  end
end

class Klass < AttrAccessorObject
   my_attr_accessor(:var1,:var2)  
   def initialize  
     @var1 = "var1"    
     @var2 = "var2"
   end
 end