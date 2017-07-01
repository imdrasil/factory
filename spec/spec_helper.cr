require "minitest/autorun"
require "../src/factory"

class Test
  @@static = 1
  @@dynamic = 1
  property f1 : String, f2 : Int32, f3 : Float64,
    f4 : String?, f5 : Int32?, f6 : Array(Int32)?

  def initialize(hash : Hash(String, String | Int32 | Float64 | Array(Int32)))
    @f1 = hash["f1"].as(String)
    @f2 = hash["f2"].as(Int32)
    @f3 = hash["f3"].as(Float64)
    @f6 = hash["f6"].as(Array(Int32)) if hash.has_key?("f6")
  end

  def f4!
    @f4.not_nil!
  end

  def f4!=(v)
    @f4 = v
  end

  def self.static
    @@static += 1
  end

  def self.dynamic
    @@dynamic += 1
  end
end

class Human
  property f1 : String, f2 : Int32?

  def initialize(hash)
    @f1 = hash["f1"]
  end
end

class Pet
  property f1 : String, f2 : Int32

  def initialize
    @f1 = "cat"
    @f2 = 23
  end
end

class PetFactory < Factory::Base
  assign :f1, "dog"
  assign :f2, 32
end

class HumanFactory < Factory::Base
  attr :f1, "Stive"
  assign :f2, rand(1..4), Int32
end

class TestFactory < Factory::Base
  argument_type String | Int32 | Float64 | Array(Int32)
  sequence(:f1) { |i| "some#{i}" }
  attr :f2, ->{ Test.static }
  attr :f3, rand, Float64
  assign :f4, "assign"
  assign :f5, ->{ Test.dynamic }

  def self.after_initialize(t)
    t.f4! += "2"
  end

  trait :addon do
    attr :f1, "addon1"
  end
end

class SecondTestFactory < TestFactory
  attr :f2, -1
  assign :f3, 0.64

  trait :nested do
    attr :f1, "nested"
    assign :f2, -2
    assign :f4, "nestedaddon"
  end
end

class ThirdTestFactory < SecondTestFactory
  attr :f1, "third"

  def self.after_initialize(t)
    super
    t.f1 += "a"
  end
end
