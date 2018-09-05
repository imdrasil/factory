require "../spec_helper"

describe Factory::Base do
  let(:described_class) { Factory::Base }

  describe "#build" do
    describe "without defined attributes" do
      it "calls constructor without hash and assigns" do
        expect(PetFactory.build.f1).must_equal("dog")
      end
    end

    describe "without arguments" do
      @subject : Test?
      let(:subject) { SecondTestFactory.build }

      it "calls after initialize callbacks" do
        expect(subject.f4.ends_with?("2")).must_equal(true)
      end
    end

    describe "**attrs" do
      it "adds attributes" do
        subject = SecondTestFactory.build(f1: "specified name")
        expect(subject.f1).must_equal("specified name")
      end

      it "defined assigns overrides attributes and calls after initialize callbacks" do
        expect(SecondTestFactory.build(f4: "some text").f4).must_equal("assign2")
      end
    end

    describe "traits, **attrs" do
      it "adds attributes" do
        expect(SecondTestFactory.build(["addon"], f1: "specified name").f1).must_equal("specified name")
      end

      it "defined assigns overrides attributes and calls after initialize callbacks" do
        expect(SecondTestFactory.build(["addon"], f4: "some text").f4).must_equal("assign2")
      end
    end

    describe "attrs" do
      it "adds attributes" do
        subject = SecondTestFactory.build({"f1" => "specified name"})
        expect(subject.f1).must_equal("specified name")
      end

      it "accepts hash with symbol args" do
        hash = {:f1 => "specified name"}
        expect(SecondTestFactory.build(hash).f1).must_equal("specified name")
      end

      it "defined assigns overrides attributes and calls after initialize callbacks" do
        expect(SecondTestFactory.build({"f4" => "some text"}).f4).must_equal("assign2")
      end
    end

    describe "traits, attrs" do
      it "adds attributes" do
        expect(SecondTestFactory.build(["addon"], {:f1 => "specified name"}).f1).must_equal("specified name")
      end

      it "defined assigns overrides attributes and calls after initialize callbacks" do
        expect(SecondTestFactory.build(["addon"], {:f4 => "some text"}).f4).must_equal("assign2")
      end
    end
  end

  describe "finished" do
    it "generates factory method" do
      # TODO: rewrite via assertion
      Factory.build_test
    end
  end

  describe ".attributes" do
    it "returns hash with element of attributes type" do
      expect(TestFactory.attributes).must_be_instance_of(Hash(String, String | Int32 | Float64 | Array(Int32)))
    end

    it "returns hash with automatically generated type" do
      expect(HumanFactory.attributes).must_be_instance_of(Hash(String, String))
    end

    it "includes only attrs" do
      expect(TestFactory.attributes.keys).must_equal %w(f1 f2 f3)
    end
  end

  describe ".get_trait" do
    it "returns trait class if it is defined" do
      expect(TestFactory.get_trait("addon")).must_equal(TestFactory::AddonTrait)
      expect(SecondTestFactory.get_trait("addon")).must_equal(TestFactory::AddonTrait)
      expect(SecondTestFactory.get_trait("nested")).must_equal(SecondTestFactory::NestedTrait)
    end

    it "returns nil if it isn't defined" do
      expect(TestFactory.get_trait("nested")).must_equal(nil)
    end
  end

  describe ".initialize_with" do
    it "creates object with given hash attributes and assignes" do
      obj = SecondTestFactory._initialize_with(SecondTestFactory.attributes, [] of String)
      expect(obj.class).must_equal(Test)
      expect(obj.f2).must_equal(-1)
      expect(obj.f4).must_equal("assign")
    end
  end

  describe ".build_attributes" do
    it { expect(SecondTestFactory.build_attributes({"f1" => "f1"})["v1"]).must_equal("v1") }
    it { expect(SecondTestFactory.build_attributes({:f1 => "v1"})["f1"]).must_equal("v1") }
    it { expect(SecondTestFactory.build_attributes({f1: "v1"})["f1"]).must_equal("v1") }

    it "adds trait's attributes" do
      hash = SecondTestFactory.build_attributes({} of String => String, ["nested"])
      expect(hash["f4"]).must_equal("nestedaddon")
    end

    it "given params ovveride traits" do
      hash = SecondTestFactory.build_attributes({"f1" => "f1"}, ["nested"])
      expect(hash["f1"]).must_equal("f1")
    end
  end

  describe ".make_assigns" do
    @object : Test?

    let(:object) { Factory.build_test }

    it "assigns to given object" do
      SecondTestFactory.make_assigns(object, [] of String)
      expect(object.f3).must_equal(0.64)
    end

    it "assigns traits to given object" do
      SecondTestFactory.make_assigns(object, ["nested"])
      expect(object.f2).must_equal(-2)
    end
  end

  describe "_after_initialize" do
    it "calls parent callback as well" do
      subject = Factory.build_third_test
      expect(subject.f4).must_equal("assign2")
      expect(subject.f1.ends_with?("a")).must_equal(true)
    end
  end

  describe "%describe_class" do
    describe "child factory describes fully different class" do
      it "creates instance of child factory described class" do
        subject = Factory.build_human_pet
        expect(subject.is_a?(Human)).must_equal(true)
        expect(subject.f1).must_equal("centaur")
        expect(subject.f2).must_equal(32)
      end
    end
  end

  describe "%skip_empty_constructor" do
    it "doesn't render constructor without parameters and prevent some compile time issues" do
      Factory.build_human_pet
    end
  end
end
