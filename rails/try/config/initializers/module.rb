def print_methods(class1 = String, class2 = Class)
  dm = class1.methods - class2.methods
  di = class1.instance_methods - class2.instance_methods
  puts "Class Methods:"
  dm.each do |m|
    puts "#{m} = #{class1.method(m).source_location}"
  end
  puts "Instance Methods:"
  di.each do |m|
    puts "#{m} = #{class1.instance_method(m).source_location}"
  end
end