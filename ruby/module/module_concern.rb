module M1
end
module M2
  extend ActiveSupport::Concern
end

dm = M2.methods - M1.methods
puts "added methods: #{dm}"