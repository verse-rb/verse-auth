# frozen_string_literal: true
#
module Verse
  module Login
    module Config
      extend self

      def config(symbol, default_value)
        attr_accessor symbol

        instance_variable_set("@#{symbol}", default_value)
      end

      # Role definition for the custom role backend
      config :role_definition_path, "./config/roles/base"
      config :role_definition_template_path, "./config/roles/templates"

      # Can the user have multiple roles or is it a single role?
      # Set it to :multiple if your roles are stored in a separate table
      config :role_type, :single

      # The column name in the database for the role
      config :role_column, :role # The column name in the user table
      # The repository to use for the role. By default,
      # it will use the User::Repository
      config :role_repository, "User::Repository"

      # The key used to find the user for the given role.
      # Used for the multiple role backend or if the role
      # column is not stored in the user table.
      # If you use a multi-role per user, you might want to change it
      # to user_id, and change the role_repository to e.g. User::Role::Repository
      config :role_user_foreign_key, :id

      # Where we store the user / account record
      config :user_repository, "User::Repository"
      # The username column name. Could be email, username, etc.
      # Used to find the user when logging in
      config :user_column_username, :username

      # The encrypted password column name. Could be password, hashed_password, etc.
      # Used by simple and 2fa login strategies, to find the user
      # when logging in.
      config :user_column_encrypted_password, :encrypted_password
      # The role column name. Could be role, roles, etc.
      config :user_column_role, :role
      config :user_primary_key, :id

      # The algorithm used to check the password hash.
      config :password_strategy, Verse::Login::PasswordStrategy::BCrypt

      # The time to wait when the user is not found.
      # This is to prevent inferring the existence of a user
      # based on the time it takes to check the password.
      config :wait_when_user_not_found, 0.2

      # Turn on if you want to use and emit refresh token
      # Refresh token must be stored in the database
      config :refresh_token, true
      # Define the repository where to store the refresh token.
      # A user can have multiple refresh tokens.
      config :refresh_token_repository, "User::LoginState::Repository"
      # Where to store the random generated nonce (a 63bits positive integer)
      config :refresh_token_nonce, :nonce

      # Is the user verifiable? E.g., do we need to send an email to verify the user?
      config :verifiable, false

      # Which column in the [user] table we are using to check for verification.
      config :verifiable_column, :verified_at

      # Whether the login check that the user is active
      # or not.
      config :lockable, false

      # Whether the login check that the user is active
      # or not.
      config :lockable_column, :locked_at

      # SAML configuration

      # An array of SAML providers
      # verse-login will use ruby-saml backend
      # for SAML authentication, hence the settings
      # are based on the ruby-saml settings.
      # Array of OneLogin::RubySaml::Settings
      config :saml_providers, {}

      # Allow to call an initialization endpoint
      # with a custom redirect URL.
      # Useful for example if the user was on a page
      # and need to login again.
      config :saml_allow_custom_redirect, true

      # The default redirect URL after a successful login.
      # This is the URL where the user will be redirected
      # after a successful login.
      config :saml_default_redirect, "/"

      # This feature allow to store a custom redirect URL
      # in a cookie. This is useful if the user was on a page
      # and need to login again.
      config :saml_custom_redirect_cookie, "redirect"

      # Security to prevent redirection to external sites.
      # This configuration value is requiring a proc
      # that will check the host of the redirect URL.
      config :saml_custom_redirect_host_check, proc{ |host|
        # local redirect only.
        host.start_with?("/")
     }

      # Options to pass to the SAML response
      # @see OneLogin::RubySaml::Response
      config :saml_response_options, {}
    end
  end
end
