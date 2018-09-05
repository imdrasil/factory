require "./association"

module Factory
  module Jennifer
    class Base < ::Factory::Base
      include AssociationDefinition

      not_a_factory

      def self._after_create(obj)
      end

      def self._before_create(obj)
      end

      def self.process_association(obj, klasses, assoc)
      end

      macro before_create(&block)
        def self._before_create({{block.args[0].id}})
          super
          {{yield}}
        end
      end

      macro after_create(&block)
        def self._after_create({{block.args[0].id}})
          super
          {{block.body}}
        end
      end

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

      macro inherited
        ASSOCIATIONS = [] of String
      end

      macro after_finished_hook
        {% if @type.superclass != ::Factory::Jennifer::Base && @type != ::Factory::Jennifer::Base %}
          {% for assoc in @type.superclass.constant("ASSOCIATIONS") %} {% ASSOCIATIONS << assoc %} {% end %}
        {% end %}

        {% if IS_FACTORY[-1] == "true" %}
          {% factory_name = @type.stringify.gsub(/Factory$/, "").underscore %}
          factory_creators({{factory_name.id}})

          {% verbatim do %}
            {% if ATTRIBUTES.empty? %}
              {% if !IGNORED_METHODS.includes?("empty_constructor") %}
                def self._initialize_with(hash, traits)
                  obj = described_class.build
                  make_assigns(obj, traits)
                  obj
                end
              {% end %}
            {% else %}
              {% if !IGNORED_METHODS.includes?("hash_constructor") %}
                def self._initialize_with(hash, traits)
                  obj = described_class.build(hash)
                  make_assigns(obj, traits)
                  obj
                end
              {% end %}
            {% end %}

            def self.create(traits = [] of String | Symbol, **attrs)
              obj = _initialize_with(build_attributes(attrs, traits), traits)
              _after_initialize(obj)
              _before_create(obj)
              obj.save
              _after_create(obj)
              obj
            end

            def self.create(attrs : Hash)
              obj = _initialize_with(build_attributes(attrs), [] of String)
              _after_initialize(obj)
              _before_create(obj)
              obj.save
              _after_create(obj)
              obj
            end

            def self.create(traits : Array, attrs : Hash)
              obj = _initialize_with(build_attributes(attrs, traits), traits)
              _after_initialize(obj)
              _before_create(obj)
              obj.save
              _after_create(obj)
              obj
            end

            def self.make_assigns(obj, traits : Array)
              {% for k, v in ASSIGNS %}
                obj.{{k.id}} = {% if v =~ /->/ %} {{v.id}}.call {% else %} @@assign_{{k.id}} {% end %}
              {% end %}
              traits.each do |name|
                trait = get_trait(name.to_s)
                raise "Unknown trait" if trait.nil?
                trait.not_nil!.make_assigns(obj)
              end
              add_associations(obj, traits)
            end

            def self.add_associations(obj, traits : Array)
              {% if !ASSOCIATIONS.empty? %}
                trait_classes = traits.map { |e| get_trait(e) }.compact
                {% for assoc in ASSOCIATIONS %}
                  process_association(obj, trait_classes, {{assoc}})
                {% end %}
              {% end %}
            end

            def self.process_association(obj, trait_classes : Array, assoc)
              trait_classes.each do |t|
                if t.associations.includes?(assoc)
                  t.process_association(obj, assoc)
                  return
                end
              end
              {% for assoc in ASSOCIATIONS %}
                __process_association_{{assoc.id}}(obj) if {{assoc}} == assoc
              {% end %}
              super(obj, trait_classes[0...1], assoc)
            end
          {% end %}
        {% end %}
      end

      macro factory_creators(factory_name)
        module ::Factory
          def self.create_{{factory_name}}
            obj = {{@type}}.create
            obj
          end

          def self.create_{{factory_name}}(**attrs)
            obj = {{@type}}.create(**attrs)
            obj
          end

          def self.create_{{factory_name}}(attrs : Hash)
            obj = {{@type}}.create(attrs)
            obj
          end

          def self.create_{{factory_name}}(traits : Array)
            obj = {{@type}}.create(traits)
            obj
          end

          def self.create_{{factory_name}}(traits : Array, **attrs)
            obj = {{@type}}.create(traits, **attrs)
            obj
          end

          def self.create_{{factory_name}}(traits : Array, attrs : Hash)
            obj = {{@type}}.create(traits, attrs)
            obj
          end

          def self.create_{{factory_name}}(count : Int32)
            arr = [] of {{CLASS_NAME.last.id}}
            count.times { arr << create_{{factory_name}} }
            arr
          end

          def self.create_{{factory_name}}(count : Int32, **attrs)
            arr = [] of {{CLASS_NAME.last.id}}
            count.times { arr << create_{{factory_name}}(**attrs) }
            arr
          end

          def self.create_{{factory_name}}(count : Int32, attrs : Hash)
            arr = [] of {{CLASS_NAME.last.id}}
            count.times { arr << create_{{factory_name}}(attrs) }
            arr
          end

          def self.create_{{factory_name}}(count : Int32, traits : Array)
            arr = [] of {{CLASS_NAME.last.id}}
            count.times { arr << create_{{factory_name}}(traits) }
            arr
          end

          def self.create_{{factory_name}}(count : Int32, traits : Array, **attrs)
            arr = [] of {{CLASS_NAME.last.id}}
            count.times { arr << create_{{factory_name}}(traits, **attrs) }
            arr
          end

          def self.create_{{factory_name}}(count : Int32, traits : Array, attrs : Hash)
            arr = [] of {{CLASS_NAME.last.id}}
            count.times { arr << create_{{factory_name}}(traits, attrs) }
            arr
          end
        end
      end
    end
  end
end
