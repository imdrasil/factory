require "./trait"

module Factory
  class Base
    def self.build
    end

    def self.get_trait(name)
    end

    def self.after_initialize(obj)
    end

    def self.after_create(obj)
      raise "Not Implemented yet"
    end

    def self.before_create(obj)
      raise "Not Implemented yet"
    end

    def self.attributes
      {} of String => String
    end

    Factory.default_methods
    Factory.render_build_methods

    macro after_initialize(&block)
      def self.after_initialize({{block.args[0].id}})
        super
        {{block.body}}
      end
    end

    macro before_create(&block)
      def self.before_create({{block.args[0].id}})
        super
        {{block.body}}
      end
    end

    macro after_create(&block)
      def self.after_create({{block.args[0].id}})
        super
        {{block.body}}
      end
    end

    macro describe_class(klass)
      {% CLASS_NAME.push(klass.stringify) %}
    end

    macro argument_type(type)
      {% ARGUMENT_TYPE.push(type.stringify) %}
    end

    macro trait(name)
      {% trait_name = (name.id.stringify.camelcase + "Trait") %}
      {% TRAITS[name.id.stringify] = trait_name %}
      class {{trait_name.id}} < ::Factory::Trait
        {{yield}}
      end
    end

    macro initialize_with(&block)
      def self.initialize_with({{block.args[0].id}}, {{block.args[1].id}})
        {{block.body}}
      end
    end

    macro inherited
      TRAITS = {} of String => String
      SEQUENCES = {} of String => String
      CLASS_NAME = [] of String
      ARGUMENT_TYPE = [] of String
      ATTRIBUTES = {} of String => String
      ASSIGNS = {} of String => String
      \{% if @type.superclass != Factory::Base %}
        \{% for k, v in @type.superclass.constant("ASSIGNS") %}
          \{% ASSIGNS[k] = v %}
        \{% end %}

        \{% for k, v in @type.superclass.constant("ATTRIBUTES") %}
          \{% ATTRIBUTES[k] = v %}
        \{% end %}
      \{% end %}

      macro finished
        def self.get_trait(name : String)
          t = super
          return t if t
          \{% for k, v in TRAITS %}
            return \{{v.id}} if \{{k}} == name
          \{% end %}
        end

        \{% if ARGUMENT_TYPE.size == 0 && @type.superclass != Factory::Base %}
          \{% ARGUMENT_TYPE.push(@type.superclass.constant("ARGUMENT_TYPE").last) %}
        \{% end %}
        \{% if CLASS_NAME.empty? %}
          \{% if @type.superclass != Factory::Base %}
            \{% CLASS_NAME.push(@type.superclass.constant("CLASS_NAME").last) %}
          \{% else %}
            \{% CLASS_NAME.push(@type.stringify.gsub(/Factory$/, "").id) %}
          \{% end %}
        \{% end %}

        \{% factory_name = @type.stringify.gsub(/Factory$/, "").underscore %}
        factory_builders(\{{factory_name.id}})


        \{% Factory::FACTORIES[factory_name] = @type.stringify %}

        \{% if ATTRIBUTES.empty? %}
          def self.initialize_with(hash, traits)
            obj = \{{CLASS_NAME.last.id}}.new
            make_assigns(obj, traits)
            obj
          end
        \{% else %}
          def self.initialize_with(hash, traits)
            obj = \{{CLASS_NAME.last.id}}.new(hash)
            make_assigns(obj, traits)
            obj
          end
        \{% end %}

        def self.build(traits = [] of String | Symbol, **attrs)
          obj = initialize_with(build_attributes(attrs, traits), traits)
          after_initialize(obj)
          obj
        end

        def self.build(attrs : Hash)
          obj = initialize_with(build_attributes(attrs), [] of String)
          after_initialize(obj)
          obj
        end

        def self.build(traits : Array, attrs : Hash)
          obj = initialize_with(build_attributes(attrs, traits), traits)
          after_initialize(obj)
          obj
        end

        def self.attributes
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
        end

        def self.build_attributes(opts, traits = [] of String | Symbol)
          attrs = attributes
          traits.each do |name|
            trait = get_trait(name.to_s)
            raise "Unknown trait" if trait.nil?
            trait.not_nil!.add_attributes(attrs)
          end
          opts.each do |k, v|
            attrs[k.to_s] = v
          end
          attrs
        end

        def self.make_assigns(obj, traits)
          \{% for k, v in ASSIGNS %}
          obj.\{{k.id}} = \{% if v =~ /->/ %} \{{v.id}}.call \{% else %} @@assign_\{{k.id}} \{% end %}
          \{% end %}
          traits.each do |name|
            trait = get_trait(name.to_s)
            raise "Unknown trait" if trait.nil?
            trait.not_nil!.make_assignes(obj)
          end
        end
      end
    end
  end
end
