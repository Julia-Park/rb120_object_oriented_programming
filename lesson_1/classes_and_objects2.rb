# class GoodDog
#   DOG_YEARS = 7

#   attr_accessor :name, :age

#   @@number_of_dogs = 0

#   def initialize(n, a)
#     @@number_of_dogs += 1 
#     self.name = n
#     self.age = a * DOG_YEARS
#   end

#   def self.total_number_of_dogs
#     @@number_of_dogs
#   end

#   def to_s
#     "This dog's name is #{name} and it is #{age} in dog years."
#   end
# end


# puts GoodDog.total_number_of_dogs   # => 0

# dog1 = GoodDog.new("dog1", 3)
# dog2 = GoodDog.new("dog2", 6)

# puts GoodDog.total_number_of_dogs   # => 2

# sparky = GoodDog.new("Sparky", 4)
# puts sparky.age

# puts sparky

class GoodDog
  attr_accessor :name, :height, :weight

  def initialize(n, h, w)
    self.name   = n
    self.height = h
    self.weight = w
  end

  def change_info(n, h, w)
    self.name   = n
    self.height = h
    self.weight = w
  end

  def info
    "#{self.name} weighs #{self.weight} and is #{self.height} tall."
  end

  def what_is_self
    self
  end
end

sparky = GoodDog.new('Sparky', '12 inches', '10 lbs')
p sparky.what_is_self

=begin
Add a class method to your MyCar class that calculates the gas mileage of any car.
> any car means use class method
=end

class MyCar
  attr_accessor :year, :color, :model, :speed

  def initialize(year, color, model)
    self.year = year
    self.color = color
    self.model = model
    self.speed = 0
  end

  def self.mileage(gallons, miles)
    "The car's mileage is #{gallons/miles} miles per gallon of gas."
  end

  def speed_up(speed_change)
    self.speed = self.speed + speed_change
    puts current_speed
  end

  def brake(speed_change)
    self.speed = self.speed - speed_change
    puts current_speed
  end

  def shut_off
    self.speed = 0
    puts current_speed
  end

  def current_speed
    "You are now going #{speed} mph."
  end

  def info
    "You have a #{color} #{year} #{model}."
  end

  def spray_paint
    puts "What color do you want to spray paint your car?"
    self.color = gets.chomp
    puts "Great!  Your car is now #{color}."
  end

  def to_s
    "#{color} #{year} #{model}"
  end
end

=begin
3. You run into this error because the setter method has not been defined within
the class definition, nor was attr_accessor / attr_writer called within the 
class definition to create a setter method for the name attribute.  attr_reader
only creates a getter method.

You can fix it by doing one of the above.
=end