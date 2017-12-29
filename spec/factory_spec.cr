require "./spec_helper"

describe Factory do
  describe "factory_builders" do
    describe "without arguments" do
      @subject : Test?
      let(:subject) { Factory.build_second_test }

      it "calls after initialize callbacks" do
        expect(subject.f4.ends_with?("2")).must_equal true
      end
    end

    describe "**attrs" do
      it "adds attributes" do
        subject = Factory.build_second_test(f1: "specified name")
        expect(subject.f1).must_equal("specified name")
      end

      it "defined assigns overrides attributes and calls after initialize callbacks" do
        expect(Factory.build_second_test(f4: "some text").f4).must_equal("assign2")
      end
    end

    describe "traits, **attrs" do
      it "adds attributes" do
        expect(Factory.build_second_test(["addon"], f1: "specified name").f1).must_equal("specified name")
      end

      it "defined assigns overrides attributes and calls after initialize callbacks" do
        expect(Factory.build_second_test(["addon"], f4: "some text").f4).must_equal("assign2")
      end
    end

    describe "attrs" do
      it "adds attributes" do
        subject = Factory.build_second_test({"f1" => "specified name"})
        expect(subject.f1).must_equal("specified name")
      end

      it "accepts hash with symbol args" do
        hash = {:f1 => "specified name"}
        expect(Factory.build_second_test(hash).f1).must_equal("specified name")
      end

      it "defined assigns overrides attributes and calls after initialize callbacks" do
        expect(Factory.build_second_test({"f4" => "some text"}).f4).must_equal("assign2")
      end
    end

    describe "traits, attrs" do
      it "adds attributes" do
        expect(Factory.build_second_test(["addon"], {:f1 => "specified name"}).f1).must_equal("specified name")
      end

      it "defined assigns overrides attributes and calls after initialize callbacks" do
        expect(Factory.build_second_test(["addon"], {:f4 => "some text"}).f4).must_equal("assign2")
      end
    end
  end

  describe "attr" do
    it "execute static expression only once" do
      old = Factory.build_test.f3
      expect(Factory.build_test.f3).must_equal(old)
    end

    it "executes procs each time" do
      old = Factory.build_test.f2
      expect(Factory.build_test.f2).must_equal(old + 1)
    end
  end

  describe "assign" do
    it "execute static expression only once" do
      old = Factory.build_human.f2
      expect(Factory.build_human.f2).must_equal(old)
    end

    it "executes procs each time" do
      old = Factory.build_test.f5.not_nil!
      expect(Factory.build_test.f5.not_nil!).must_equal(old + 1)
    end
  end

  describe "trait" do
    it "defined assigns overrides everything" do
      expect(Factory.build_second_test(["assign"]).f4).must_equal("nestedassign2")
    end
  end

  describe "sequence" do
    it "defines sequence class" do
      TestFactory::F1Sequence
    end

    it "inrements value" do
      old = TestFactory::F1Sequence.current
      Factory.build_test
      expect(TestFactory::F1Sequence.current).must_equal(1 + old)
    end
  end
end
