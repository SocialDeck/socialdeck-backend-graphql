module Types
  class CardType < Types::BaseObject
    field :id, ID, null: false
    field :user, Types::UserType, null: true
    field :author, Types::UserType, null: false
    field :card_name, String, null: false
    field :display_name, String, null: false
    field :name, String, null: false
    field :business_name, String, null: true
    field :address, Types::AddressType, null: true
    field :number, String, null: true
    field :email, String, null: true
    field :birth_date, Types::DateTimeType, null: true
    field :twitter, String, null: true
    field :linked_in, String, null: true
    field :facebook, String, null: true
    field :instagram, String, null: true
    field :verified, Boolean, null: false
    field :mobile, Boolean, null: false
    field :card_token, String, null: false do
      argument :token, String, required: true
    end

    def verified
      !!object.user_id
    end

    def card_token(token:)
      current_user = AuthorizeUserRequest.call(token).result
      AuthenticateCard.call(current_user.id, object.id).result
    end    

    def mobile
      TelephoneNumber.parse(object.number, :us).valid_types.include?(:mobile)
    end
  end
end