module Factory
  FACTORIES = {} of String => String

  macro default_methods
    macro attr(name, value, klass = nil)
      \{% if !value.is_a?(ProcLiteral) %}
        \{% if klass != nil %}
          @@\{{name.id}} : \{{klass}} = \{{value}}
        \{% else %}
          @@\{{name.id}} = \{{value}}
        \{% end %}
        \{% ATTRIBUTES[name.id.stringify] = "plain" %}
      \{% else %}
        \{% ATTRIBUTES[name.id.stringify] = value.id.stringify %}
      \{% end %}
    end

    macro assign(name, value, klass = nil)
      \{% if !value.is_a?(ProcLiteral) %}
        \{% if klass != nil %}
          @@assign_\{{name.id}} : \{{klass}} = \{{value}}
        \{% else %}
          @@assign_\{{name.id}} = \{{value}}
        \{% end %}
        \{% ASSIGNS[name.id.stringify] = "plain" %}
      \{% else %}
        \{% ASSIGNS[name.id.stringify] = value.id.stringify %}
      \{% end %}
    end

    macro sequence(name, init = 0, &block)
      \{% sclass = (name.id.stringify.camelcase + "Sequence").id %}
      \{% ATTRIBUTES[name.id.stringify] = "-> { ->(#{block.args[0]} : Int32) { #{block.body.id} }.call(#{sclass.id}.next) }" %}
      class \{{sclass}} < Factory::Sequence
        @@start = \{{init}}
      end
    end
  end

  macro render_build_methods
    macro factory_builders(factory_name)
      module ::Factory
        def self.build_\{{factory_name}}
          \{{@type}}.build
        end

        def self.build_\{{factory_name}}(**attrs)
          \{{@type}}.build(**attrs)
        end

        def self.build_\{{factory_name}}(attrs : Hash)
          \{{@type}}.build(attrs)
        end

        def self.build_\{{factory_name}}(traits : Array)
          \{{@type}}.build(traits)
        end

        def self.build_\{{factory_name}}(traits : Array, **attrs)
          \{{@type}}.build(traits, **attrs)
        end

        def self.build_\{{factory_name}}(traits : Array, attrs : Hash)
          \{{@type}}.build(traits, attrs)
        end

        def self.build_\{{factory_name}}(count : Int32)
          arr = [] of \{{CLASS_NAME.last.id}}
          count.times { arr << \{{@type}}.build }
          arr
        end

        def self.build_\{{factory_name}}(count : Int32, **attrs)
          arr = [] of \{{CLASS_NAME.last.id}}
          count.times { arr << \{{@type}}.build(**attrs) }
          arr
        end

        def self.build_\{{factory_name}}(count : Int32, attrs : Hash)
          arr = [] of \{{CLASS_NAME.last.id}}
          count.times { arr << \{{@type}}.build(attrs) }
          arr
        end

        def self.build_\{{factory_name}}(count : Int32, traits : Array)
          arr = [] of \{{CLASS_NAME.last.id}}
          count.times { arr << \{{@type}}.build(traits) }
          arr
        end

        def self.build_\{{factory_name}}(count : Int32, traits : Array, **attrs)
          arr = [] of \{{CLASS_NAME.last.id}}
          count.times { arr << \{{@type}}.build(traits, **attrs) }
          arr
        end

        def self.build_\{{factory_name}}(count : Int32, traits : Array, attrs : Hash)
          arr = [] of \{{CLASS_NAME.last.id}}
          count.times { arr << \{{@type}}.build(traits, attrs) }
          arr
        end
      end
    end
  end
end

require "./factory/*"
