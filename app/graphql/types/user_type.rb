module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :username, String, null: false
    field :name, String, null: false do
      argument :token, String, required: true
    end


    def name(token:)
      current_user = AuthorizeUserRequest.call(token).result
      return object.name if current_user.id == object.id

      connections = Connection.where(contact_id: object.id, user_id: current_user.id)
      name_field = ''
      connections.each do |connection|
        name_field = connection.card.name ? connection.card.name : name_field
      end
      name_field ? name_field : object.name
    end 


  end
end