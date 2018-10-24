class A
  class << self
    # correct
    def public_foo
      private_foo
    end

    # private method `private_foo' called for A:Class (NoMethodError)
    def public_foo2
      A.private_foo
    end

    private

    # this is a private class method
    def private_foo
      'foo'
    end
  end
end

puts A.public_foo