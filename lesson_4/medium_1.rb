# Q1
# Ben is right.  @balance has a getter method created by attr_reader.  This
# creates a method named balance that returns the object pointing to @balance.

# Q2
# This problem has two parts, based on the syntax shown:
# 1. quantity on line 11 needs to have an @ in front of it to denote that it is
# reassigning the value for the instance variable @quantity.  Without it, Ruby
# thinks a new local variable is being initialized.
# 2. If Alan is trying to use the setter method for quantity, a setter method
# for quantity needs to be defined (either via custom definition or
# attr_writer) and quantity = needs to change to self.quantity = (otherwise
# Ruby will think a new local variable is being initialized)

# Q3
# It is generally poor practice to not create setter or getter methods if you
# don't need them.  Changing attr_reader to attr_accessor will create setter
# methods for both quantity and product_name; the latter of which does not need
# a setter method.
# Also, since the public methods of the class is being changed, it will allow
# clients of the class to change quantity directly via the setter method instead
# of using the #update_quantity method.  Any protections built into the
# #update_quantity method can be circumvented and could potentially pose probems.

# Q4
class Greeting
  def greet(string)
    puts string
  end
end

class Hello < Greeting
  def hi
    greet("Hello")
  end
end

class Goodbye < Greeting
  def bye
    greet("Goodbye")
  end
end

# Q5
class KrispyKreme
  def initialize(filling_type, glazing)
    @filling_type = filling_type
    @glazing = glazing
  end

  def to_s
    filling = @filling_type.nil? ? 'Plain' : @filling_type

    if @glazing.nil?
      filling
    else
      "#{filling} with #{@glazing}"
    end
  end

end

# Q6
# The first one directly references the instance variable @template to set the
# variable in #create_template; the second uses the setter method created via
# attr_accessor.
# Both versions use the getter method created via attr_accessor to return
# the object @template is pointing to, but the 2nd uses the unncessary reference
# to self.

# Q7
# Change light_status to status.
