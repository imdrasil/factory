module Factory
  module Jennifer
    class Base < ::Factory::Base
      not_a_factory

      def self.after_create(obj)
      end

      def self.before_create(obj)
      end

      macro before_create(&block)
        def self.before_create({{block.args[0].id}})
          super
          {{yield}}
        end
      end

      macro after_create(&block)
        def self.after_create({{block.args[0].id}})
          super
          {{block.body}}
        end
      end

      macro after_finished_hook
        {% if IS_FACTORY[-1] == "true" %}
          {% factory_name = @type.stringify.gsub(/Factory$/, "").underscore %}
          factory_creators({{factory_name.id}})

          \{% if ATTRIBUTES.empty? %}
            \{% if !IGNORED_METHODS.includes?("empty_constructor") %}
              def self.initialize_with(hash, traits)
                obj = described_class.build
                make_assigns(obj, traits)
                obj
              end
            \{% end %}
          \{% else %}
            \{% if !IGNORED_METHODS.includes?("hash_constructor") %}
              def self.initialize_with(hash, traits)
                obj = described_class.build(hash)
                make_assigns(obj, traits)
                obj
              end
            \{% end %}
          \{% end %}

          def self.create(traits = [] of String | Symbol, **attrs)
            obj = initialize_with(build_attributes(attrs, traits), traits)
            after_initialize(obj)
            before_create(obj)
            obj.save
            after_create(obj)
            obj
          end

          def self.create(attrs : Hash)
            obj = initialize_with(build_attributes(attrs), [] of String)
            after_initialize(obj)
            before_create(obj)
            obj.save
            after_create(obj)
            obj
          end

          def self.create(traits : Array, attrs : Hash)
            obj = initialize_with(build_attributes(attrs, traits), traits)
            after_initialize(obj)
            before_create(obj)
            obj.save
            after_create(obj)
            obj
          end
        {% end %}
      end

      macro factory_creators(factory_name)
        module ::Factory
          def self.create_{{factory_name}}
            obj = {{@type}}.create
            obj
          end

          def self.create_{{factory_name}}(**attrs)
            obj = {{@type}}.build(**attrs)
            obj
          end

          def self.create_{{factory_name}}(attrs : Hash)
            obj = {{@type}}.build(attrs)
            obj
          end

          def self.create_{{factory_name}}(traits : Array)
            obj = {{@type}}.build(traits)
            obj
          end

          def self.create_{{factory_name}}(traits : Array, **attrs)
            obj = {{@type}}.build(traits, **attrs)
            obj
          end

          def self.create_{{factory_name}}(traits : Array, attrs : Hash)
            obj = {{@type}}.build(traits, attrs)
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
