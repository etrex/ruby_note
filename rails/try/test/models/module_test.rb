require 'test_helper'

class ModuleConcernTest < ActiveSupport::TestCase
  test "extend concern" do
    module M1
    end
    module M2
      extend ActiveSupport::Concern
    end

    print_methods(M2, M1)
  end

  test "extend concern2" do
module M
  extend ActiveSupport::Concern
  included do
    puts self.new.b
    def a
      "a"
    end
  end
  def b
    "b"
  end
end

class C
  include M
end

    print_methods(C)
  end
end
