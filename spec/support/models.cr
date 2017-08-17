class Film < Jennifer::Model::Base
  mapping(
    id: {type: Int32, primary: true},
    name: String?,
    rating: Int32,
    budget: Float32?
  )
end
