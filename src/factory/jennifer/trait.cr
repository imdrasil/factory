require "./association"

module Factory
  class Trait(T)
    include Jennifer::AssociationDefinition

    macro inherited
      {% verbatim do %}
      ASSOCIATIONS = [] of String

      def self.associations
        ASSOCIATIONS
      end

      def self.process_association(obj, assoc : String)
        {% for assoc in ASSOCIATIONS %}
          __process_association_{{assoc.id}}(obj) if assoc == {{assoc}}
        {% end %}
      end
      {% end %}
    end
  end
end
