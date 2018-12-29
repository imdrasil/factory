# Factory [![Build Status](https://travis-ci.org/imdrasil/factory.svg)](https://travis-ci.org/imdrasil/factory) [![Latest Release](https://img.shields.io/github/release/imdrasil/factory.svg)](https://github.com/imdrasil/factory/releases) [![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://imdrasil.github.io/factory/latest/)

Easy to use but flexible factory definition utility. Could be used for testing purpose and for developing as well.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  factory:
    github: imdrasil/factory
```

## Usage

```crystal
require "factory"
```

To define new factory
```crystal
class HumanFactory < Factory::Base
end
```

By convenience this factory will builds `Human` class but this behavior can be overrided using `describe_class` macro:

```crystal
class AdminFactory < Factory::Base
  describe_class User
end
```

Factory will build class passing to constructor hash with string keys, so those class should be ready for this. To define attributes for passing to constructor use `attr` macro:

```crystal
class TestFactory < Factory::Base
  attr :f1, "Ivan"
  attr :f2, rand, Float64
  attr :f3, -> { rand(1..3) }
end
```

Attributes, passed as `Proc` will be executed each time. Other ones - only once and cached. If type could be analyzed (as with calling `rand` upper), you can specify exact type passing it as third parameter.

There is also assign strategy using `assign` macro. Using it all attributes will be assigned after initializing.

```crystal
class TestFactory < Factory::Base
  assign :f1, "Ivan"
  assign :f2, rand, Float64
  assign :f3, -> { rand(1..3 }
end

# Will be do smth like
obj = Test.new
obj.f1 = TestFactory.f1 # "Ivan"
obj.f2 = TestFactory.f2 # 0.61 - just random value shared across all object
obj.f3 = -> { rand(1..3) }.call
```

If you specify no `attr` - will call construtor without any arguments and you will not be able pass anything to it.

If you need to specify exact type of given hash value use `argument_type`:

```crystal
class Test
  @@static = 1
  @@dynamic = 1
  property f1 : String, f2 : Int32, f3 : Float64,
    f4 : String?, f5 : Int32?, f6 : Array(Int32)?

  def initialize(hash)
    @f1 = hash["f1"].as(String)
    @f2 = hash["f2"].as(Int32)
    @f3 = hash["f3"].as(Float64)
    @f6 = hash["f6"].as(Array(Int32)) if hash.has_key?("f6")
  end
end

class TestFactory < Factory::Base
  argument_type String | Int32 | Float64 | Array(Int32)
  attr :f1, "some"
  attr :f2, 1
  attr :f3, rand, Float64
end
```

Also `after_initialize` callback could be specified:

```crystal
class TestFactory < Factory::Base
  after_initialize do |t|
    super # if you want parrent one to be inked as well
    t.f1.not_nil! += 1
  end
end
```

Builder method could be specified as well:

```crystal
class TestFactory < Factory::Base
  # here is default builder
  initialize_with do |hash, traits|
    obj = Test.new(hash)
    make_assigns(obj, traits) # makes all assignements (traits will be described later)
    obj
  end
end
```

To specify sequence of some attributes (only allowed as attr hook) use `sequence`:

```crystal
sequence(:f1) { |i| "user#{i}@example.com" }
```

You could inherite from existing factory and override some parameters:
```crystal
class HumanFactory < Factory::Base
  describe_class User
  attr :f1, "asd"
end

class AdminFactory < HumanFactory
  attr :f1, "admin"
  assign :f2, 1
end
```

Child factory inherits all attrs, assigns, traits, sequences, callbacks, class names, has value type.

To group several attributes or assignments use trait. 

```crystal
class HumanFactory < Factory::Base
  trait :homo do
    attr :iq, 50
  end
end
```

Traits can't specify callbacks, described type, hash value type.

To build object direct call could be used
```crystal
HumanFactory.build
HumanFactory.build(some_attr: "asd")
HumanFactory.build({"some_attr" => "asd")
HumanFactory.build(["some_trait"], some_attr: "asd")
HumanFactory.build(["some_trait"], {"some_attr" => "asd"})
```

Also helper methods are defined as well

```crystal
Factory.build_human
Factory.build_human(some_attr: "asd")
Factory.build_human({"some_attr" => "asd")
Factory.build_human(["some_trait"], some_attr: "asd")
Factory.build_human(["some_trait"], {"some_attr" => "asd"})
# also you can specify count as first parameter in any of thos methods
Factory.build_human(3, ["some_trait"], {"some_attr" => "asd"})
```

#### Jennifer Support

To create factory for (Jennifer)[https://github.com/imdrasil/jennifer.cr] model 

```crystal
# require all jennifer staff and models
require "factory"
require "factory/jennifer"

class FilmFactory < Factory::Jennifer::Base
  attr :rating, 5
  assign :name, "Test Film" 

  trait :bad do
    assign :rating, 0
  end
end
```

It provides direct creating methods same as for building:

```crystal
FilmFactory.create([:bad], {:name => "Atilla"})
```

Also any association could be described on the factory or trait level:

```crystal
class FilmFactory < Factory::Jennifer::Base
  association :author
  association :actor, UserFactory, options: {name: "Artemius Fault"}
end
```

Allowed arguments:

- `:name` - first argument - represent model association name (mandatory)
- `:factory` - represents factory class (optional); is defaulted from association name
- `:strategy` - represents creation strategy; optional; default is "create" (also "build" is allowed)
- `:options` - represents extra arguments to association factory; optional 

## Development

For development postgres is required because of testing integration with Jennifer.

Possible next tasks:

- think  about adding assigning via hash or named tuble argument;
- adding `%attr` to traits.


## Contributing

1. Fork it ( https://github.com/imdrasil/factory/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [imdrasil](https://github.com/imdrasil) Roman Kalnytskyi - creator, maintainer

