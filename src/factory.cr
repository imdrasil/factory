module Factory
  FACTORIES = {} of String => String

  module BaseDSL
    macro included
      macro inherited
        {% verbatim do %}
          SEQUENCES = {} of String => String
          ATTRIBUTES = {} of String => String
          ASSIGNS = {} of String => String
        {% end %}
      end
    end

    macro attr(name, value, klass = nil)
      {% if !value.is_a?(ProcLiteral) %}
        {% if klass != nil %}
          @@{{name.id}} : {{klass}} = {{value}}
        {% else %}
          @@{{name.id}} = {{value}}
        {% end %}
        {% ATTRIBUTES[name.id.stringify] = "plain" %}
      {% else %}
        {% ATTRIBUTES[name.id.stringify] = value.id.stringify %}
      {% end %}
    end

    macro assign(name, value, klass = nil)
      {% if !value.is_a?(ProcLiteral) %}
        {% if klass != nil %}
          @@assign_{{name.id}} : {{klass}} = {{value}}
        {% else %}
          @@assign_{{name.id}} = {{value}}
        {% end %}
        {% ASSIGNS[name.id.stringify] = "plain" %}
      {% else %}
        {% ASSIGNS[name.id.stringify] = value.id.stringify %}
      {% end %}
    end

    macro sequence(name, init = 0, &block)
      {% class_name = (name.id.stringify.camelcase + "Sequence").id %}
      {% ATTRIBUTES[name.id.stringify] = "-> { ->(#{block.args[0]} : Int32) { #{block.body.id} }.call(#{class_name.id}.next) }" %}
      class {{class_name}} < ::Factory::Sequence
        @@start = {{init}}
      end
    end
  end

  macro build_methods
    macro factory_builders(factory_name)
      {% verbatim do %}
      module ::Factory
        def self.build_{{factory_name}}
          {{@type}}.build
        end

        def self.build_{{factory_name}}(**attrs)
          {{@type}}.build(**attrs)
        end

        def self.build_{{factory_name}}(attrs : Hash | NamedTuple)
          {{@type}}.build(attrs)
        end

        def self.build_{{factory_name}}(traits : Array)
          {{@type}}.build(traits)
        end

        def self.build_{{factory_name}}(traits : Array, **attrs)
          {{@type}}.build(traits, **attrs)
        end

        def self.build_{{factory_name}}(traits : Array, attrs : Hash | NamedTuple)
          {{@type}}.build(traits, attrs)
        end

        def self.build_{{factory_name}}(count : Int32)
          arr = [] of {{CLASS_NAME.last.id}}
          count.times { arr << {{@type}}.build }
          arr
        end

        def self.build_{{factory_name}}(count : Int32, **attrs)
          arr = [] of {{CLASS_NAME.last.id}}
          count.times { arr << {{@type}}.build(**attrs) }
          arr
        end

        def self.build_{{factory_name}}(count : Int32, attrs : Hash | NamedTuple)
          arr = [] of {{CLASS_NAME.last.id}}
          count.times { arr << {{@type}}.build(attrs) }
          arr
        end

        def self.build_{{factory_name}}(count : Int32, traits : Array)
          arr = [] of {{CLASS_NAME.last.id}}
          count.times { arr << {{@type}}.build(traits) }
          arr
        end

        def self.build_{{factory_name}}(count : Int32, traits : Array, **attrs)
          arr = [] of {{CLASS_NAME.last.id}}
          count.times { arr << {{@type}}.build(traits, **attrs) }
          arr
        end

        def self.build_{{factory_name}}(count : Int32, traits : Array, attrs : Hash | NamedTuple)
          arr = [] of {{CLASS_NAME.last.id}}
          count.times { arr << {{@type}}.build(traits, attrs) }
          arr
        end
      end
      {% end %}
    end
  end
end

require "./factory/*"
