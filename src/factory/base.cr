module Factory
  class Base
    def self.build
    end

    def self.after_initialize(obj)
    end

    def self.after_create(obj)
    end

    def self.before_create(obj)
    end

    def self.attributes
      {} of String => String
    end

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

    macro hash_type(type)
      {% HASH_TYPE.push(type.stringify) %}
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
      class {{(name.id.stringify.camelcase + "Sequence").id}}
        @@start = {{init}}

        def self.next
          @@start += 1
          @@start - 1
        end
      end

      {% SEQUENCES[name.id.stringify] = "->(#{block.args[0]} : Int32) { #{block.body.id} }" %}
    end

    macro avoid_sequence(name)
      {% STOP_SEQUENCE.push(name.id.stringify) %}
    end

    macro inherited
      STOP_SEQUENCE = [] of String
      SEQUENCES = {} of String => String
      CLASS_NAME = [] of String
      HASH_TYPE = [] of String
      ATTRIBUTES = {} of String => String
      ASSIGNS = {} of String => String
      \{% if @type.superclass != Factory::Base %}
        \{% for k, v in @type.superclass.constant("ASSIGNS") %}
          \{% ASSIGNS[k] = v %}
        \{% end %}

        \{% for k, v in @type.superclass.constant("ATTRIBUTES") %}
          \{% ATTRIBUTES[k] = v %}
        \{% end %}

        \{% for k, v in @type.superclass.constant("SEQUENCES") %}
          \{% SEQUENCES[k] = v %}
        \{% end %}
      \{% end %}

      macro finished
        \{% if CLASS_NAME.empty? %}
           \{% CLASS_NAME.push(@type.stringify.gsub(/Factory$/, "").id) %}
        \{% end %}
        module ::Factory
          def self.build_\{{@type.stringify.gsub(/Factory$/, "").underscore.id}}(**args)
            \{{@type}}.build(**args)
          end

          def self.build_\{{@type.stringify.gsub(/Factory$/, "").underscore.id}}(opts)
            \{{@type}}.build(opts)
          end

          def self.build_\{{@type.stringify.gsub(/Factory$/, "").underscore.id}}(count : Int32, **args)
            arr = [] of \{{CLASS_NAME.last.id}}
            count.times { arr << \{{@type}}.build(**args) }
            arr
          end

          def self.build_\{{@type.stringify.gsub(/Factory$/, "").underscore.id}}(count : Int32, opts)
            arr = [] of \{{CLASS_NAME.last.id}}
            count.times { arr << \{{@type}}.build(opts) }
            arr
          end
        end

        \{% Factory::FACTORIES[@type.stringify.gsub(/Factory$/, "").underscore] = @type.stringify %}

        def self.build(opts)
          attrs = attributes
          opts.each do |k, v|
            attrs[k.to_s] = v
          end
          obj = \{{CLASS_NAME.last.id}}.new(attrs)
          \{% for k, v in ASSIGNS %}
          obj.\{{k.id}} = \{% if v =~ /->/ %} \{{v.id}}.call \{% else %} @@assign_\{{k.id}} \{% end %}
          \{% end %}
          after_initialize(obj)
          obj
        end

        def self.build(**opts)
          attrs = attributes
          opts.each do |k, v|
            attrs[k.to_s] = v
          end
          obj = \{{CLASS_NAME.last.id}}.new(attrs)
          \{% for k, v in ASSIGNS %}
          obj.\{{k.id}} = \{% if v =~ /->/ %} \{{v.id}}.call \{% else %} @@assign_\{{k.id}} \{% end %}
          \{% end %}
          after_initialize(obj)
          obj
        end

        def self.attributes
          \{% if HASH_TYPE.empty? %}
          {
            \{% for k, v in ATTRIBUTES %}
              \{{k.id.stringify}} => \{% if v =~ /->/ %} \{{v.id}}.call \{% else %} @@\{{k.id}} \{% end %},
            \{% end %}
            \{% for k, v in SEQUENCES %}
              \{{k.id.stringify}} => (\{{v.id}}.call(\{{(k.camelcase + "Sequence").id}}.next))
            \{% end %}
          }
          \{% else %}
            hash = {} of String => \{{HASH_TYPE.last.id}}
            \{% for k, v in ATTRIBUTES %}
              hash[\{{k.id.stringify}}] = \{% if v =~ /->/ %} \{{v.id}}.call \{% else %} @@\{{k.id}} \{% end %}
            \{% end %}
            \{% for k, v in SEQUENCES %}
              hash[\{{k.id.stringify}}] = (\{{v.id}}.call(\{{(k.camelcase + "Sequence").id}}.next))
            \{% end %}
            hash
          \{% end %}
        end
      end
    end
  end
end
