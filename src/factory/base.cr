require "./trait"

module Factory
  class Base
    IS_FACTORY = ["false"]

    macro after_finished_hook
    end

    def self.build
    end

    def self.get_trait(name : String, go_deep)
    end

    def self.get_trait(name : Symbol)
      get_trait(name.to_s)
    end

    def self._after_initialize(obj)
    end

    def self.assign_attr(obj, name, value)
      raise "Attribute #{name} can't be found."
    end

    def self.attributes
      {} of String => String
    end

    Factory.default_methods
    Factory.build_methods

    macro not_a_factory
      {% IS_FACTORY << "false" %}
    end

    macro after_initialize(&block)
      def self._after_initialize({{block.args[0].id}})
        super
        {{block.body}}
      end
    end

    macro initialize_with(&block)
      def self._initialize_with({{block.args[0].id}}, {{block.args[1].id}})
        {{block.body}}
      end
    end

    macro describe_class(klass)
      {% CLASS_NAME.push(klass.stringify) %}
    end

    macro argument_type(type)
      {% ARGUMENT_TYPE.push(type.stringify) %}
    end

    # traits could be defined only for some class
    macro trait(name)
      {% trait_name = "#{name.id.stringify.camelcase.id}Trait" %}
      {% TRAITS[name.id.stringify] = trait_name %}

      macro _macro_trait_{{name.id}}
        class {{trait_name.id}} < ::Factory::Trait(\{{CLASS_NAME[-1].id}})
          {{yield.stringify.id}}
        end
      end

      {% TRAIT_CLASS_DECLARATIONS << "_macro_trait_#{name.id}" %}
    end

    macro skip_all_constructors
      skip_hash_constructor
      skip_empty_constructor
    end

    macro inherited
      IS_FACTORY = ["true"]
      TRAITS = {} of String => String
      SEQUENCES = {} of String => String
      CLASS_NAME = [] of String
      ARGUMENT_TYPE = [] of String
      ATTRIBUTES = {} of String => String
      ASSIGNS = {} of String => String
      IGNORED_METHODS = [] of String
      TRAIT_CLASS_DECLARATIONS = [] of String

      \{% if @type.superclass.constant("IS_FACTORY")[-1] == "true" %}
        \{% for k, v in @type.superclass.constant("ASSIGNS") %}
          \{% ASSIGNS[k] = v %}
        \{% end %}

        \{% for k, v in @type.superclass.constant("ATTRIBUTES") %}
          \{% ATTRIBUTES[k] = v %}
        \{% end %}
      \{% end %}

      def self.described_class
        \{% begin %}
        \{{CLASS_NAME.last.id}}
        \{% end %}
      end

      macro skip_hash_constructor
        \{% IGNORED_METHODS << "hash_constructor" %}
      end

      macro skip_empty_constructor
        \{% IGNORED_METHODS << "empty_constructor" %}
      end

      macro finished
        \{% for trait in TRAIT_CLASS_DECLARATIONS %}
          \{{trait.id}}
        \{% end %}

        def self.get_trait(name : String, go_deep : Bool = true)
          \{% for k, v in TRAITS %}
            return \{{v.id}} if \{{k}} == name
          \{% end %}
          super if go_deep
        end

        \{% if ARGUMENT_TYPE.size == 0 && @type.superclass.constant("IS_FACTORY")[-1] == "true" && @type.superclass.constant("ARGUMENT_TYPE").size != 0 %}
          \{% ARGUMENT_TYPE.push(@type.superclass.constant("ARGUMENT_TYPE").last) %}
        \{% end %}
        \{% if CLASS_NAME.empty? %}
          \{% if @type.superclass.constant("IS_FACTORY")[-1] == "true" %}
            \{% CLASS_NAME.push(@type.superclass.constant("CLASS_NAME").last) %}
          \{% else %}
            \{% CLASS_NAME.push(@type.stringify.gsub(/Factory$/, "").id) %}
          \{% end %}
        \{% end %}

        \{% if IS_FACTORY[-1] == "true" %}
          \{% factory_name = @type.stringify.gsub(/Factory$/, "").underscore.gsub(/::/, "_") %}
          factory_builders(\{{factory_name.id}})

          \{% Factory::FACTORIES[factory_name] = @type.stringify %}

          \{% if ATTRIBUTES.empty? %}
            \{% if !IGNORED_METHODS.includes?("empty_constructor") %}
              def self._initialize_with(hash, traits)
                obj = described_class.new
                make_assigns(obj, traits)
                obj
              end
            \{% end %}
          \{% else %}
            \{% if !IGNORED_METHODS.includes?("hash_constructor") %}
              def self._initialize_with(hash, traits)
                obj = described_class.new(hash)
                make_assigns(obj, traits)
                obj
              end
            \{% end %}
          \{% end %}

          def self.build(traits = [] of String | Symbol, **attrs)
            obj = _initialize_with(build_attributes(attrs, traits), traits)
            _after_initialize(obj)
            obj
          end

          def self.build(attrs : Hash | NamedTuple)
            obj = _initialize_with(build_attributes(attrs), [] of String)
            _after_initialize(obj)
            obj
          end

          def self.build(traits : Array, attrs : Hash | NamedTuple)
            obj = _initialize_with(build_attributes(attrs, traits), traits)
            _after_initialize(obj)
            obj
          end

          def self.attributes
            \{% begin %}
            \{% if !ATTRIBUTES.empty? %}
              \{% if ARGUMENT_TYPE.empty? %}
              {
                \{% for k, v in ATTRIBUTES %}
                  \{{k.id.stringify}} => \{% if v =~ /->/ %} \{{v.id}}.call \{% else %} @@\{{k.id}} \{% end %},
                \{% end %}
              }
              \{% else %}
                hash = {} of String => \{{ARGUMENT_TYPE.last.id}}
                \{% for k, v in ATTRIBUTES %}
                  hash[\{{k.id.stringify}}] = \{% if v =~ /->/ %} \{{v.id}}.call \{% else %} @@\{{k.id}} \{% end %}
                \{% end %}
                hash
              \{% end %}
            \{% else %}
              {} of String => String
            \{% end %}
            \{% end %}
          end

          def self.build_attributes(opts, traits : Array = [] of String | Symbol)
            attrs = attributes
            traits.each do |name|
              trait = get_trait(name.to_s)
              raise "Unknown trait \"#{name.to_s}\"" if trait.nil?
              trait.not_nil!.add_attributes(attrs)
            end
            opts.each do |k, v|
              attrs[k.to_s] = v
            end
            attrs
          end

          def self.make_assigns(obj, traits)
            \{% begin %}
            \{% for k, v in ASSIGNS %}
              obj.\{{k.id}} = \{% if v =~ /->/ %} \{{v.id}}.call \{% else %} @@assign_\{{k.id}} \{% end %}
            \{% end %}
            traits.each do |name|
              trait = get_trait(name.to_s)
              raise "Unknown trait" if trait.nil?
              trait.not_nil!.make_assignes(obj)
            end
            \{% end %}
          end
        \{% end %}

        after_finished_hook
      end
    end
  end
end
