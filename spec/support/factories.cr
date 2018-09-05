class Test
  @@static = 1
  @@dynamic = 1
  property f1 : String, f2 : Int32, f3 : Float64,
    f5 : Int32?, f6 : Array(Int32)?
  property! f4 : String?

  def initialize(hash : Hash(String, String | Int32 | Float64 | Array(Int32)))
    @f1 = hash["f1"].as(String)
    @f2 = hash["f2"].as(Int32)
    @f3 = hash["f3"].as(Float64)
    @f6 = hash["f6"].as(Array(Int32)) if hash.has_key?("f6")
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

  after_initialize do |t|
    t.f4 += "2"
  end

  trait :addon do
  end
end

class SecondTestFactory < TestFactory
  attr :f2, -1
  assign :f3, 0.64

  trait :nested do
    assign :f2, -2
    attr :f4, "nestedaddon"
  end

  trait :assign do
    assign :f4, "nestedassign"
  end
end

class ThirdTestFactory < SecondTestFactory
  attr :f1, "third"

  after_initialize do |t|
    t.f1 += "a"
  end
end

class HumanPetFactory < PetFactory
  describe_class Human
  skip_empty_constructor
  assign :f1, "centaur"

  initialize_with do |hash, traits|
    obj = described_class.new({"f1" => "some value"})
    make_assigns(obj, traits)
    obj
  end
end

class FilmFactory < Factory::Jennifer::Base
  attr :name, "Super Film"
  attr :rating, 2
  attr :budget, 12.3f32

  trait :bad do
    assign :rating, 0
  end

  trait :hit do
    assign :rating, 10
    sequence(:name) { |i| "Best Film #{i}" }
  end
end

class CustomFilmFactory < FilmFactory
  sequence(:name) { |i| "Custom Film #{i}" }

  association :author, AuthorFactory

  after_create do |obj|
    obj.name = obj.name! + "after"
  end

  before_create do |obj|
    obj.name = obj.name! + "before"
  end
end

class FictionFilmFactory < CustomFilmFactory
  trait :with_special_author do
    association :author, options: {name: "Special Author"}
  end
end

class AuthorFactory < Factory::Jennifer::Base
  sequence(:name) { |i| "Author #{i}" }
end
