module Factory
  class Trait
    Factory.default_methods

    def self.add_attributes(hash)
      hash
    end

    def self.make_assignes(obj)
      obj
    end

    macro inherited
      SEQUENCES = {} of String => String
      CLASS_NAME = [] of String
      HASH_TYPE = [] of String
      ATTRIBUTES = {} of String => String
      ASSIGNS = {} of String => String

      macro finished
        def self.add_attributes(hash)
          {
            \{% for k, v in ATTRIBUTES %}
              \{{k.id.stringify}} => \{% if v =~ /->/ %} \{{v.id}}.call \{% else %} @@\{{k.id}} \{% end %},
            \{% end %}
          }.each do |k, v|
          	hash[k] = v
          end
        end

        def self.make_assignes(obj)
        	\{% for k, v in ASSIGNS %}
          obj.\{{k.id}} = \{% if v =~ /->/ %} \{{v.id}}.call \{% else %} @@assign_\{{k.id}} \{% end %}
          \{% end %}
        end
      end
    end
  end
end
