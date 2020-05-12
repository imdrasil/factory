require "../../spec_helper"

describe Factory::Jennifer::Base do
  let(:described_class) { Factory::Jennifer::Base }

  before do
    ::Jennifer::Adapter.default_adapter.begin_transaction
  end

  after do
    ::Jennifer::Adapter.default_adapter.rollback_transaction
  end

  describe "%association" do
    it "uses factory's defined association" do
      film = Factory.create_custom_film([:bad, :hit])
      expect(film.author.nil?).wont_equal(true)
      expect(film.author!.name).must_match(/Author \d*$/)
    end

    it "uses trait's author if it is given" do
      film = Factory.create_fiction_film([:with_special_author])
      expect(film.author.nil?).wont_equal(true)
      expect(film.author!.name).must_equal("Special Author")
    end

    it "uses given overrides for factory" do
      film = Factory.create_fiction_film([:with_special_author])
      expect(film.author!.name).must_equal("Special Author")
    end

    it "uses parent association if current factory has no" do
      film = Factory.create_fiction_film
      expect(film.author.nil?).must_equal(false)
    end

    it "creates object without association if there is no one" do
      film = Factory.create_film
      expect(film.author.nil?).must_equal(true)
    end
  end

  describe "%factory_creators" do
    it "defines all create methods on module level" do
      expect(Factory.create_custom_film.new_record?).must_equal(false)
      expect(Factory.create_custom_film(name: "New film").new_record?).must_equal(false)
      expect(Factory.create_custom_film({:name => "New"}).new_record?).must_equal(false)
      expect(Factory.create_custom_film([:bad]).new_record?).must_equal(false)
      expect(Factory.create_custom_film([:bad], name: "new").new_record?).must_equal(false)
      expect(Factory.create_custom_film([:bad], {:name => "new"}).new_record?).must_equal(false)
      expect(Factory.create_custom_film(1)[0].new_record?).must_equal(false)
      expect(Factory.create_custom_film(1, name: "asd")[0].new_record?).must_equal(false)
      expect(Factory.create_custom_film(1, [:bad])[0].new_record?).must_equal(false)
      expect(Factory.create_custom_film(1, {:name => "asd"})[0].new_record?).must_equal(false)
      expect(Factory.create_custom_film(1, [:bad], name: "asd")[0].new_record?).must_equal(false)
      expect(Factory.create_custom_film(1, [:bad], {:name => "asd"})[0].new_record?).must_equal(false)
    end
  end

  describe "%before_create" do
    it "calls before create" do
      film = CustomFilmFactory.create
      expect(film.name).must_match(/before/)
      film.reload
      expect(film.name).must_match(/before/)
    end
  end

  describe "%after_create" do
    it "calls callback after creating" do
      film = CustomFilmFactory.create
      expect(film.name).must_match(/after$/)
      film.reload
      expect(film.name).wont_match(/after$/)
    end
  end

  describe ".create" do
    it "accepts hash attributes" do
      film = FilmFactory.create({:name => "Custom"})
      expect(film.name).must_equal("Custom")
      expect(film.new_record?).must_equal(false)
    end

    it "accepts traits" do
      film = FilmFactory.create([:hit, :bad])
      expect(film.rating).must_equal(0)
      expect(film.name).must_match(/Best Film/)
      expect(film.new_record?).must_equal(false)
    end

    it "accepts traits and attributes" do
      film = FilmFactory.create([:hit, :bad], {:budget => 10.0f32})
      expect(film.rating).must_equal(0)
      expect(film.name).must_match(/Best Film/)
      expect(film.budget).must_equal(10.0f32)
      expect(film.new_record?).must_equal(false)
    end

    it "all model callbacks during creating" do
      film = FilmFactory.create
      expect(film.before_create).must_equal(true)
      expect(film.before_save).must_equal(true)
      expect(film.after_initialize).must_equal(true)
    end

    describe "ancestor factory" do
      it "accepts no arguments" do
        film = CustomFilmFactory.create
        expect(film.name).must_match(/Custom Film \d*/)
        expect(film.new_record?).must_equal(false)
      end

      it "accepts hash attributes" do
        film = CustomFilmFactory.create({:name => "Custom"})
        expect(film.name).must_equal("Custombeforeafter")
        expect(film.new_record?).must_equal(false)
      end

      it "accepts traits" do
        film = CustomFilmFactory.create([:hit, :bad])
        expect(film.rating).must_equal(0)
        expect(film.name).must_match(/Best Film/)
        expect(film.new_record?).must_equal(false)
      end

      it "accepts traits and attributes" do
        film = CustomFilmFactory.create([:hit, :bad], {:budget => 10.0f32})
        expect(film.rating).must_equal(0)
        expect(film.name).must_match(/Best Film/)
        expect(film.budget).must_equal(10.0f32)
        expect(film.new_record?).must_equal(false)
      end
    end
  end
end
