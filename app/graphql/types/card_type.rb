# frozen_string_literal: true

module Types
  class CardType < Types::BaseObject
    field :id, ID, null: false
    field :card_token, ID, null: false do
      argument :token, ID, required: true
    end
    field :user, Types::UserType, null: true
    field :author, Types::UserType, null: false
    field :card_name, String, null: false
    field :display_name, String, null: false
    field :name, String, null: false
    field :business_name, String, null: true
    field :address, Types::AddressType, null: true
    field :number, String, null: true
    field :mobile, Boolean, null: false
    field :email, String, null: true
    field :birth_date, Types::DateTimeType, null: true
    field :twitter, String, null: true
    field :linked_in, String, null: true
    field :facebook, String, null: true
    field :instagram, String, null: true
    field :verified, Boolean, null: false
    field :favorite, Boolean, null: false do
      argument :token, ID, required: false
    end
    field :mutual, Boolean, null: false do
      argument :token, ID, required: false
    end

    def verified
      !!object.user_id
    end

    def card_token(token:)
      user = AuthorizeUserRequest.call(token).result
      AuthenticateCard.call(user.id, object.id).result
    end

    def favorite(token: nil)
      return false unless token

      user = AuthorizeUserRequest.call(token).result
      connection = Connection.find_by(user_id: user.id, card_id: object.id)
      return false unless connection

      connection.favorite || false
    end

    def mutual(token: nil)
      return true if object.user.blank?
      return true if token.blank?

      user = AuthorizeUserRequest.call(token).result
      connection = Connection.find_by(contact_id: user.id, user_id: object.user.id)

      !!connection
    end

    def mobile
      TelephoneNumber.parse(object.number, :us).valid_types.include?(:mobile)
    end
  end
end
