module Factory
  module Jennifer
    module AssociationDefinition
      macro association(name, factory = nil, strategy = :create, options = nil)
        {% ASSOCIATIONS << name.id.stringify %}

        {% if factory %}
          {% klass = factory %}
        {% else %}
          {% klass = (name.id.stringify.camelcase + "Factory" ).id %}
        {% end %}

        def self.__process_association_{{name.id}}(obj)
          association = {{klass}}.build({% if options %}{{options}} {% end %})
          {% if strategy.id.stringify == "build" %}
            obj.append_{{name.id}}(association)
          {% elsif strategy.id.stringify == "create" %}
            obj.add_{{name.id}}(association)
          {% else %}
            {% raise "Strategy #{strategy.id} of #{@type} is not valid" %}
          {% end %}
        end
      end
    end
  end
end
