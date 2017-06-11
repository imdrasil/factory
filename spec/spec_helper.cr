require "spec"
require "../src/factory"

class Test
  property f1 : String, f2 : Int32, f3 : Float64,
    f4 : String?, f5 : Int32?, f6 : Array(Int32)?

  def initialize(hash : Hash(String, String | Int32 | Float64 | Array(Int32)))
    @f1 = hash["f1"].as(String)
    @f2 = hash["f2"].as(Int32)
    @f3 = hash["f3"].as(Float64)
    @f6 = hash["f6"].as(Array(Int32)) if hash.has_key?("f6")
  end

  def self.tratata
    rand(1..20)
  end

  def save
  end
end

class TestFactory < Factory::Base
  hash_type String | Int32 | Float64 | Array(Int32)
  sequence(:f1) { |i| "some#{i}" }
  attr :f2, ->{ Test.tratata }
  attr :f3, rand, Float64
  assign :f4, "assign"
  assign :f5, ->{ rand(1..3) }

  after_initialize do |t|
    puts t.f1
    puts "asd"
  end
end

class SuperTestFactory < TestFactory
  hash_type String | Int32 | Float64 | Array(Int32)
  describe_class Test
  attr :f1, "tome"
end
