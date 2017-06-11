require "./spec_helper"

describe Factory do
  describe "#build" do
    # puts Factory.build(:super_test).inspect
    hash = {"f6" => [1], "f1" => "try"}
    puts Factory.build_super_test.inspect
    puts Factory.build_super_test.inspect
    puts Factory.build_test.inspect
    puts Factory.build_test(3, hash)
  end
end
