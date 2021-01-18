require 'rqrcode'

module Types
  class QueryType < Types::BaseObject

    # User Endpoints

    field :users, [Types::UserType], null: true

    def users
      User.all
    end

    field :blocked_Users, [Types::UserType], null: true do
      argument :token, ID, required: true
    end

    def blocked_users(token:)
      begin
        user = AuthorizeUserRequest.call(token).result
        raise GraphQL::ExecutionError, "User does not exist" unless user
      rescue ExceptionHandler::ExpiredSignature => e
        raise GraphQL::ExecutionError, e.message
      rescue ExceptionHandler::DecodeError => e
        raise GraphQL::ExecutionError, e.message
      end

      User.where(id: Connection.where(card_id: -1, contact_id: user.id).pluck(:user_id))
    end

    # Card Queries

    field :card, Types::CardType, null: true do
      argument :card_token, ID, required: true
    end

    def card(card_token:)
      begin
        AuthorizedCardRequest.call(card_token).result
      rescue ExceptionHandler::ExpiredSignature => e
        raise GraphQL::ExecutionError, e.message
      rescue ExceptionHandler::DecodeError => e
        raise GraphQL::ExecutionError, e.message
      end
    end

    field :share_card_by_email, String, null: true do
      argument :token, ID, required: true
      argument :id, ID, required: true
      argument :email, String, required: true
    end

    def share_card_by_email(token:, id:, email:)
      begin
        user = AuthorizeUserRequest.call(token).result
        raise GraphQL::ExecutionError, "User does not exist" unless user
      rescue ExceptionHandler::ExpiredSignature => e
        raise GraphQL::ExecutionError, e.message
      rescue ExceptionHandler::DecodeError => e
        raise GraphQL::ExecutionError, e.message
      end

      card = Card.find_by(user_id: user.id, id: id)
      card_token = AuthenticateCard.call(user.id, card.id).result
      UserNotifierMailer.send_card_email(user, card, card_token, email).deliver
    end

    field :authored_cards, [Types::CardType], null: true do
      argument :token, ID, required: true
    end

    def authored_cards(token:)
      begin
        user = AuthorizeUserRequest.call(token).result
        raise GraphQL::ExecutionError, "User does not exist" unless user
      rescue ExceptionHandler::ExpiredSignature => e
        raise GraphQL::ExecutionError, e.message
      rescue ExceptionHandler::DecodeError => e
        raise GraphQL::ExecutionError, e.message
      end

      Card.where(author_id: user.id, user_id: nil)
    end

    field :owned_cards, [Types::CardType], null: true do
      argument :token, ID, required: true
    end

    def owned_cards(token:)
      begin
        user = AuthorizeUserRequest.call(token).result
        raise GraphQL::ExecutionError, "User does not exist" unless user
      rescue ExceptionHandler::ExpiredSignature => e
        raise GraphQL::ExecutionError, e.message
      rescue ExceptionHandler::DecodeError => e
        raise GraphQL::ExecutionError, e.message
      end

      Card.where(user_id: user.id)
    end

    field :contacts, [Types::CardType], null: true do
      argument :token, ID, required: true
      argument :search, String, required: false
    end

    def contacts(token:, search:nil)
      begin
        user = AuthorizeUserRequest.call(token).result
        raise GraphQL::ExecutionError, "User does not exist" unless user
      rescue ExceptionHandler::ExpiredSignature => e
        raise GraphQL::ExecutionError, e.message
      rescue ExceptionHandler::DecodeError => e
        raise GraphQL::ExecutionError, e.message
      end

      if search
        Card.where(id: Connection.where(user_id: user.id).pluck(:card_id)).where.not(id: -1).order(:name).search(search)
      else
        Card.where(id: Connection.where(user_id: user.id).pluck(:card_id)).where.not(id: -1).order(:name)
      end
    end

    field :favorites, [Types::CardType], null: true do
      argument :token, ID, required: true
    end

    def favorites(token:)
      begin
        user = AuthorizeUserRequest.call(token).result
        raise GraphQL::ExecutionError, "User does not exist" unless user
      rescue ExceptionHandler::ExpiredSignature => e
        raise GraphQL::ExecutionError, e.message
      rescue ExceptionHandler::DecodeError => e
        raise GraphQL::ExecutionError, e.message
      end

      Card.where(id: Connection.where(user: user.id, favorite:true).pluck(:card_id)).where.not(id: -1).order(:name)
    end

    # Connection Queries

    field :subscribers, [Types::LinkType], null: true do
      argument :token, ID, required: true
    end

    def subscribers(token:)
      begin
        user = AuthorizeUserRequest.call(token).result
        raise GraphQL::ExecutionError, "User does not exist" unless user
      rescue ExceptionHandler::ExpiredSignature => e
        raise GraphQL::ExecutionError, e.message
      rescue ExceptionHandler::DecodeError => e
        raise GraphQL::ExecutionError, e.message
      end

      Connection.where(contact_id: user.id).where.not(card_id: -1).left_outer_joins(:user).order('"users"."name"')
    end

    # field :logs, [Types::LogType], null: true do
    #   argument :card_id, ID, required: true
    #   argument :token, ID, required: true
    # end

    # def logs(card_id:, token:)
    #   user = AuthorizeUserRequest.call(token).result
    #   Log.where(card_id: card_id, user_id: user.id)
    # end

  end
end
