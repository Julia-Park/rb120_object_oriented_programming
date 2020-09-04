class Animal
  attr_accessor :name
  @@num_animal = 0

  def initialize(name)
    self.name = name
    @@num_animal += 1
  end

  def speak
    "Hello!"
  end

  protected

  def self.how_many
    @@num_animal
  end

  def say_name
    "My name is #{name}!"
  end

end

class GoodDog < Animal
  def initialize(color)
    super
    @color = color
  end

  def speak
    super + " #{self.name} says arf!"
  end
end

class Cat < Animal
end


class BadDog < Animal
  def initialize(age, name)
    super(name)
    @age = age
  end

  def baddog_name
    say_name
  end
end

# sparky = GoodDog.new('Sparky')
# paws = Cat.new
# puts sparky.speak           # => Hello!
# puts paws.speak             # => Hello!

# bruno = GoodDog.new("brown")        # => #<GoodDog:0x007fb40b1e6718 @color="brown", @name="brown">
# p bruno


# p GoodDog.how_many
# p BadDog.how_many

# bear = BadDog.new(2, "Bear")
# p bear

# p Animal.how_many

# p bear.baddog_name
# p bear.say_name

=begin
Create a superclass called Vehicle for your MyCar class to inherit from and move the
behavior that isn't specific to the MyCar class to the superclass. Create a constant
in your MyCar class that stores information about the vehicle that makes it different
from other types of Vehicles.

Then create a new class called MyTruck that inherits from your superclass that also
has a constant defined that separates it from the MyCar class in some way.
=end
module TruckBed
  def check_bed
    "Look at all that space on that bed!"
  end
end

class Vehicle
  attr_accessor :year, :color, :model, :speed, :vehicle_type

  @@number_of_vehicles = 0

  def initialize(year, color, model, vehicle_type)
    self.year = year
    self.color = color
    self.model = model
    self.speed = 0
    self.vehicle_type = vehicle_type
    @@number_of_vehicles += 1
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

  def spray_paint(new_color)
    self.color = new_color
    puts "Great! Your vehicle is now #{color}."
  end

  def to_s
    "You have a #{vehicle_type} that is a #{color} #{year} #{model}"
  end

  def self.how_many
    @@number_of_vehicles
  end

  def self.mileage(gallons, miles)
    "The mileage is #{gallons/miles} miles per gallon of gas."
  end

  def age
    current_year - year
  end

  private

  def current_year 
    Time.now.year
  end
end

class MyCar < Vehicle
  attr_accessor :car_type

  NUMBER_OF_DOORS = 4
  
  def initialize(year, color, model, car_type)
    super(year, color, model, 'Car')
    self.car_type = car_type
  end
  
  def to_s
    super + " #{car_type}"
  end
end

class MyTruck < Vehicle
  attr_accessor :bed_size

  NUMBER_OF_DOORS = 2

  include TruckBed

  def initialize(year, color, model, bed_size)
    super(year, color, model, 'Truck')
    self.bed_size = bed_size
  end

  def to_s
    super + " with a #{bed_size} bed"
  end
end

# jetta = MyCar.new(2018, 'Grey', 'VW Jetta', 'Sedan')

# puts jetta
# p jetta
# p Vehicle.how_many

# p jetta.age

# ram = MyTruck.new(2020, 'Blue', 'Dodge Ram', 'Standard')

# puts ram
# p ram
# p Vehicle.how_many

# p ram.check_bed
# p ram.age

# method look up
# puts Vehicle.ancestors
# puts MyCar.ancestors
# puts MyTruck.ancestors

=begin
Create a class 'Student' with attributes name and grade. Do NOT make the grade
getter public, so joe.grade will raise an error. Create a better_grade_than?
method, that you can call like so...
puts "Well done!" if joe.better_grade_than?(bob)
=end

class Student
  attr_accessor :name
  attr_writer :grade

  def initialize(name, grade)
    self.name = name
    self.grade = grade
  end

  def better_grade_than?(other_student)
    self.get_grade > other_student.get_grade
  end

  protected

  def get_grade
    @grade
  end

end

joe = Student.new('Joe', 75)
bob = Student.new('Bob', 60)

puts "Well done!" if joe.better_grade_than?(bob)

p joe.get_grade 

=begin
8. The problem is that the code is trying to call Person#hi from outside of the class
definition, resulting in a NoMethodError.
This can be fixed by either:
1. Removing Person#hi from underneath the Private keyword within the class definition
2. Defining a public instance method within the Person class definition which calls
Person#hi.
=end