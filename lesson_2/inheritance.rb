=begin
Suppose we're building a software system for a pet hotel business,
so our classes deal with pets.

1. Create a sub-class from Dog called Bulldog overriding the swim method
   to return "can't swim!"
2. Create a new class called Cat which can do everything a dog can, except swim or
   fetch.  Assume the methods do the exact same thing (don't just copy and paste)
=end

class Pet
  def run
    'running!'
  end

  def jump
    'jumping!'
  end
end

class Cat < Pet
  def speak
    'meow!'
  end  
end

class Dog < Pet
  def speak
    'bark!'
  end

  def swim
    'swimming!'
  end

  def fetch
    'fetching!'
  end
end

class Bulldog < Dog
  def swim
    "can't swim!"
  end
end

# teddy = Dog.new
# puts teddy.speak           # => "bark!"
# puts teddy.swim            # => "swimming!"

# karl = Bulldog.new
# puts karl.speak           # => "bark!"
# puts karl.swim            # => "can't swim!"

# pete = Pet.new
# kitty = Cat.new
# dave = Dog.new
# bud = Bulldog.new

# puts pete.run                # => "running!"
# puts pete.speak              # => NoMethodError

# puts kitty.run               # => "running!"
# puts kitty.speak             # => "meow!"
# puts kitty.fetch             # => NoMethodError

# puts dave.speak              # => "bark!"

# puts bud.run                 # => "running!"
# puts bud.swim                # => "can't swim!"

=begin
Class hierarchy diagram:

          ___Pet___
          |       |
         Dog     Cat
          |
        Bulldog

The method look up path is the sequence of locations in the code where the Ruby
interpreter will access to find a method being invoked.  

The order in which Ruby will traverse the class hierarchy to look for methods to invoke.
=end