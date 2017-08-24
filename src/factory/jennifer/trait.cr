module Factory
  class Trait(T)
    macro inherited
      ASSOCIATIONS = [] of String

      ::Factory::Jennifer.association_macro

      def self.associations
        ASSOCIATIONS
      end

      def self.process_association(obj, assoc : String)
        \{% for assoc in ASSOCIATIONS %}
          __process_association_\{{assoc.id}}(obj) if assoc == \{{assoc}}
        \{% end %}
      end
    end
  end
end
