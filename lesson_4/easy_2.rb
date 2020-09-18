# Q1
# It will return a string comprised of "You will " and the return value of #choices.
# #choices will return a random sample of one of the elements in the array on line 7.

# Q2
# It will return a string comprised of "You will " and the return value of #choices.
# Since # predict_the_future is called on a RoadTrip object, it will use the
# the #choices definition within the RoadTrip class, which returns a random sample
# of one of the elements on line 13.

# Q3
# Call #ancestors on the class to find the method look up chain.
# Call #superclass on the class to find its direct superclass
# Orange > Taste > Object > Kernel > BasicObject
# Hotsauce > Taste > Object > Kernel > BasicObject

# Q4
# attr_accessor :type

# Q5
excited_dog = "excited dog"   # => local variable
@excited_dog = "excited dog"  # => instance variable denoted by @
@@excited_dog = "excited dog" # => class variable denoted by @@

# Q6
# #manufacturer is a class method.  You know because the method name is preceded
# by self.
# Call a class method by using the class itself as the caller (not the object)

# Q7
# @@cats_count tracks the number of Cat objects which have been instantiated.  This
# is done by incrementing @@cats_count by 1 every time a new object is instantiated
# via the #initialize method.  We can instantiate multiple Cat objects and verify
# the count increasing after each one by calling the Cat#cats_count method.

# Q8
# add < Game on line one next to class Bingo

# Q9
# when #play is called on a Bingo object, it will use Bingo#play instead of Game#play
# This happens because of the way Ruby uses the method lookup path when invoking
# a method.  This is an example of polymorphism in Ruby. 

# Q9
# Benefits of OOP in Ruby:
# - Group/section blocks of code which serve a similar purpose, increasing readibility
# - Allow for definition of set parameters on how objects can be interacted with
# - Allow for reproducibility of above interactions with several different objects
# - Allow for keeping to DRY principles through inheritance
# - Polymorphism, Inheritance, Encapsulation
# - Allow programmers to think more abstractly about the code they are writing
# - Objects are represented by nouns - easier to conceptualize
# - Expose funtionality to parts of code that need it; less namespace issues
# - Easily give functionality to different parts of an application without duplication
# - Build software faster using pre-written code
# - Easier to manage complexity