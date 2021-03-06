class Film < Jennifer::Model::Base
  mapping(
    id: Primary32,
    name: String?,
    rating: Int32,
    budget: Float32?,
    author_id: Int32?
  )

  belongs_to :author, klass: Author

  {% for callback in %i(before_save after_initialize before_create) %}
  	getter {{callback.id}} = false

  	def set_{{callback.id}}
  		@{{callback.id}} = true
  	end

  	{{callback.id}} :set_{{callback.id}}
  {% end %}
end

class Author < Jennifer::Model::Base
  mapping(
    id: Primary32,
    name: String?
  )
  has_many :films, Film
end
