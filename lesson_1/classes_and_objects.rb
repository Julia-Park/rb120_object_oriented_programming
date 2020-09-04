require 'pry'

class GoodDog
  attr_accessor :name, :height, :weight

  def initialize(n, h, w)
    self.name = n
    self.height = h
    self.weight = w
  end

  def speak
    "#{name} says arf!"
  end

  def change_info(n, h, w)
    self.name = n
    self.height = h
    self.weight = w
  end

  def info
    "#{name} weighs #{weight} and is #{height} tall."
  end
end

sparky = GoodDog.new("Sparky", "10 inches", "10 lbs")

=begin
1. Create a class called MyCar. When you initialize a new instance or object of the
class, allow the user to define some instance variables that tell us the year, color,
and model of the car. Create an instance variable that is set to 0 during
instantiation of the object to track the current speed of the car as well.
Create instance methods that allow the car to speed up, brake, and shut the car off.


=end

class MyCar
  attr_accessor :year, :color, :model, :speed

  def initialize(year, color, model)
    self.year = year
    self.color = color
    self.model = model
    self.speed = 0
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
end

jetta = MyCar.new(2018, 'Grey', 'VW Jetta')

puts jetta.info
jetta.current_speed
jetta.speed_up(20)
jetta.brake(10)
jetta.speed_up(20)
jetta.shut_off
jetta.spray_paint
