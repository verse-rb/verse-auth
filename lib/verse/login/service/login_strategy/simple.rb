require_relative "./base"

module Verse
  module Login
    module LoginStrategy
      # User password based authentication
      class SimpleLogin < Base

        def initialize(auth_context)
          super

          @username_column = Verse::Login::Config.user_column_username
          @encrypted_password_column = Verse::Login::Config.user_column_encrypted_password

          @password_strategy = Verse::Login::Config.password_strategy
        end

        public

        def call(username, password, role: nil, env: nil)
          user = user_repository.find_by!({
            Verse::Login::Config.user_column_username => username,
          })

          auth_failed! unless user

          encrypted_password = user.send(
            Verse::Login::Config.user_column_encrypted_password
          )

          result = @password_strategy.check?(
            password,
            encrypted_password,
          )

          auth_failed! unless result

          login(user, role, env:)
        rescue Verse::Error::RecordNotFound
          sleep Verse::Login::Config.wait_when_user_not_found
          auth_failed!
        end
      end
    end
  end
end
