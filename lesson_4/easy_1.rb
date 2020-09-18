# Q1
# They are all objects.  You can find their class by calling the #class method.

# Q2
# Mix in modules via #include followed by the module name.

# Q3
# The string representing the class is able to be called on via the self.class
# method call within the string interpolation of # go_fast.  #self returns the
# calling object of the method that it's called in and #class returns the class
# name of its caller (self, which was the calling object)

# Q4
# AngryCat.new

# Q5
# Pizza has an instance variable @name.  Instance variables are denoted by the @
# preceding the rest of the name.  You can check for instance variables via
# checking the class definition or asking the object with #instance_variables

# Q6
# We could add a getter method, either via defining it manually or using the
# method attr_reader.  We can also access the instance variable directly
# via calling method #instance_variable_get on the object and passing
# the instance variable name as a argument.

# Q7
# If it is a custom class, go to the class definition to check to see if there is
# a custom #to_s defined.  If not, go to Object.  It will by default return a string
# representation of the object (its id, class)

# Q8
# self refers to the calling object when the method #make_one_year_older is called.

# Q9
# self refers to the class.  This denotes a class method.

# Q10
# Bag.new('red', 'canvas'); You need to call #new on the class and pass in two
# arguments.
