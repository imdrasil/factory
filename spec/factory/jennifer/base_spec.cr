require "../../spec_helper"

describe Factory::Jennifer::Base do
  let(:described_class) { Factory::Jennifer::Base }

  before do
    ::Jennifer::Adapter.adapter.begin_transaction
  end

  after do
    ::Jennifer::Adapter.adapter.rollback_transaction
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
