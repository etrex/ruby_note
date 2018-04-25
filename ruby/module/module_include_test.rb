module M
  def self.included(klass)
    puts "self.included executed: #{klass}"
    klass.class_eval do
      puts self
    end
  end
  def self.a_self_method
    puts "self.a_self_method executed"
  end
  def a_instance_method
    puts "a_instance_method executed"
  end
end

class C1
end

class C2
  include M
end

dm = C2.methods - C1.methods
di = C2.instance_methods - C1.instance_methods

puts "added class methods: #{dm}"
puts "added instance methods: #{di}"

# result:

# self.included executed: C2
# added class methods: []
# added instance methods: [:a_instance_method]