# frozen_string_literal: true

module Verse
  module Login
    module LoginStrategy
      class Base < Verse::Service::Base
        protected

        def user_repository
          return @user_repository if @user_repository

          repository = Verse::Login::Config.user_repository

          repository_class = \
            if repository.is_a?(String)
              Verse::Util::Reflection.constantize(repository)
            else
              repository
            end

          @user_repository = repository_class.new(auth_context)
        end

        def auth_failed!
          raise Verse::Error::AuthenticationFailed, "Invalid credentials"
        end

        # Generate the tokens for the pair user/role
        def login(user, role, env:)
          assert_is_verified!(user) if Verse::Login::Config.registerable
          assert_is_not_locked!(user) if Verse::Login::Config.lockable

          SecureRandom.random_number(2**63)

          Verse::Login::TokenBuilder.new(auth_context).build(
            user,
            role,
            env:,
            nonce: SecureRandom.random_number(2**63),
          )
        end

        def assert_is_verified!(user)
          verified = user.send(
            Verse::Login::Config.verifiable_column
          )

          return if verified

          raise Verse::Login::Error::AccountNotVerified, "Account is not verified"
        end

        def assert_is_not_locked!(user)
          locked = user.send(
            Verse::Login::Config.lockable_column
          )

          return if !locked

          raise Verse::Login::Error::AccountLocked, "Account is locked"
        end
      end
    end
  end
end
