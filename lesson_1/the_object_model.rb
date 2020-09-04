=begin
Q: How do we create an object in Ruby? Give an example of the creation of an object.
A: An object is created by using class..end.  Class names are captialized, CamelCase
We define a class and instantiate an object within that class using the #.new method
=end

class Beverage
  # Content here
end

=begin
Q: What is a module? What is its purpose? How do we use them with our classes?
   Create a module for the class you created in exercise 1 and include it properly.
A: A module is a collection of behaviours; a group of reusable code. 
It allows for methods to be used across multiple classes.  
We use them with our classes via mixins.  Define the module first
via module..end and then use the include method invocation (Module#include)
within a class definition, passing the module name as an argument.
Modules are also used as a namespace.
=end

module Study
end

class MyClass
  include Study
end

my_obj = MyClass.new
