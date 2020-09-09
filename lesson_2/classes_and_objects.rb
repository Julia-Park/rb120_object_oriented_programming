=begin
1. Given the below usage of the Person class, code the class definition.
2. Modify the class definition from above to facilitate the following methods.
   Note that there is no name= setter method now.
2. Now create a smart name= method that can take just a first name or a full name,
   and knows how to set the first_name and last_name appropriately.
=end

class Person
  attr_accessor :first_name, :last_name
  attr_reader :name
  
  def initialize(name)
    self.name = name
  end

  def name=(new_name)
    names = new_name.split(' ')
    self.first_name = names.first
    self.last_name = ( names.size > 1 ? names.last : '' )
    @name = (self.first_name + ' ' + self.last_name).strip
  end

  def to_s
    self.name
  end
end

# Test Exercise 1
# bob = Person.new('bob')
# p bob.name                  # => 'bob'
# bob.name = 'Robert'
# p bob.name                  # => 'Robert'

# Test Exercise 2
bob = Person.new('Robert')
# p bob.name                  # => 'Robert'
# p bob.first_name            # => 'Robert'
# p bob.last_name             # => ''
# bob.last_name = 'Smith'
# p bob.name                  # => 'Robert Smith'

# Test Exercise 3
bob.name = "John Adams"
# p bob.first_name            # => 'John'
# p bob.last_name             # => 'Adams'
# p bob.name

# Test Exercise 4
# bob = Person.new('Robert Smith')
# rob = Person.new('Robert Smith')
# p bob.name == rob.name

# # Test Exercise 5
# bob = Person.new("Robert Smith")
# puts "The person's name is: #{bob}" 
  # => Going to print string rep of object gibberish without a custom #to_s
