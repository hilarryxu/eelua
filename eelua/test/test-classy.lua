local Class = require'classy'
local tap = require'tap'
local ok = tap.ok

-- Class Animal
local Animal = Class.extend(Class, {
  __name__ = 'Animal',
  __init__ = function(self, name, age)
    self.name = name
    self.age = age
    self.health = 100
  end,

  die = function(self)
    self.health = 0
  end,

  eat = function(self, what)
    self.health = self.health + 5
  end
})

-- Class Tiger
local Tiger = Class.extend(Animal, {
  __name__ = 'Tiger',
  eat = function(self, animal)
    Animal.eat(self, animal)
    animal:die()
  end
})

-- Class Sheep
local Sheep = Class.extend(Animal, {
  __name__ = 'Sheep',
  __init__ = function(self, name, age)
    Animal.__init__(self, name, age)
    self.shorn = false
  end
})

local function main()
  local leo = Tiger('Leo', 3)
  ok(leo.name == 'Leo', "leo's name is Leo")
  ok(leo.age == 3, "leo's age is 3")
  ok(leo.health == 100, "leo's health is 100")
  local molli = Sheep('Molli', 1)
  ok(molli.name == 'Molli', "molli's name is Leo")
  ok(molli.age == 1, "molli's age is 3")
  ok(molli.health == 100, "molli's health is 100")
  ok(molli.shorn == false, "molli's shorn is false")
  leo:eat(molli)
  ok(leo.health == 105, "leo's health is 105")
  ok(molli.health == 0, "molli's health is 0")
end

main()

-- vim: set ts=4 sw=2 sts=2 et:

