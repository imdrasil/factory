module Factory
  abstract class Trait(T)
    include BaseDSL

    def self.add_attributes(hash) : Void
    end

    def self.make_assigns(obj : T) : Void
    end

    def self.process_association(obj, assoc)
    end

    def self.associations
      [] of String
    end

    macro inherited
      CLASS_NAME = [] of String
      HASH_TYPE = [] of String

      macro finished
        {% verbatim do %}
          def self.add_attributes(hash) : Void
            {% if !ATTRIBUTES.empty? %}
              {
                {% for k, v in ATTRIBUTES %}
                  {{k.id.stringify}} => {% if v =~ /->/ %} {{v.id}}.call {% else %} @@{{k.id}} {% end %},
                {% end %}
              }.each do |k, v|
                hash[k] = v
              end
            {% end %}
          end

          def self.make_assigns(obj : T) : Void
            {% for k, v in ASSIGNS %}
            obj.{{k.id}} = {% if v =~ /->/ %} {{v.id}}.call {% else %} @@assign_{{k.id}} {% end %}
            {% end %}
          end
        {% end %}
      end
    end
  end
end
