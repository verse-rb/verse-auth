module Verse
  module Login
    module Config
      extend self

      @role_definition_path = "./config/roles/base"
      @role_definition_template_path = "./config/roles/templates"

      # Role definition for the custom role backend
      attr_accessor :role_definition_path
      attr_accessor :role_definition_template_path

      @role_type = :single # :single or :multiple
      @role_column = :role # The column name in the user table
      @role_repository = "User::Repository"
      @role_user_primary_key = :id

      # Can the user have multiple roles or is it a single role?
      attr_accessor :role_type
      # The column name in the database for the role
      attr_accessor :role_column
      # The repository to use for the role. By default,
      # it will use the User::Repository
      attr_accessor :role_repository
      # The key used to find the user for the given role.
      # Used for the multiple role backend or if the role
      # column is not stored in the user table.
      attr_accessor :role_user_primary_key

      @user_primary_key = :id
      @user_column_username = :username
      @user_column_encrypted_password = :encrypted_password
      @user_column_role = :role
      @user_repository = "User::Repository"

      # Strategy used for login
      attr_accessor :user_repository
      attr_accessor :user_column_username
      attr_accessor :user_column_encrypted_password
      attr_accessor :user_column_role
      attr_accessor :user_primary_key


      # The algorithm used to check the password hash
      attr_accessor :password_strategy
      # The time to wait when the user is not found.
      # This is to prevent inferring the existence of a user
      # based on the time it takes to check the password.
      attr_accessor :wait_when_user_not_found
      @password_strategy = Verse::Login::PasswordStrategy::BCrypt.new
      @wait_when_user_not_found = 0.2

      # Where to store the nonce of the refresh token.
      @refresh_token = true
      @refresh_token_repository = "User::LoginState::Repository"
      @refresh_token_nonce = :nonce

      attr_accessor :refresh_token
      attr_accessor :refresh_token_repository
      attr_accessor :refresh_token_nonce

      # Whether the login check for registration
      # before login.
      @verifiable = false
      @verifiable_column = :verified_at

      attr_accessor :verifiable
      attr_accessor :verifiable_column

      # Whether the login check that the user is active
      # or not.
      @lockable = false
      @lockable_column = :locked_at

      # Whether the login check that the user is active
      # or not.
      attr_accessor :lockable
      attr_accessor :lockable_column

      # SAML configuration

      # An array of SAML providers
      # verse-login will use ruby-saml backend
      # for SAML authentication, hence the settings
      # are based on the ruby-saml settings.
      # Array of OneLogin::RubySaml::Settings
      attr_accessor :saml_providers

      # Allow to call an initialization endpoint
      # with a custom redirect URL.
      # Useful for example if the user was on a page
      # and need to login again.
      attr_accessor :saml_allow_custom_redirect
      attr_accessor :saml_default_redirect

      attr_accessor :saml_custom_redirect_cookie
      # Security to prevent redirection to external sites.
      # This configuration value is requiring a proc
      # that will check the host of the redirect URL.
      attr_accessor :saml_custom_redirect_host_check

      # Options to pass to the SAML response
      # @see OneLogin::RubySaml::Response
      attr_accessor :saml_response_options

      @saml_providers = {}
      @saml_custom_allow_redirect = true
      @saml_custom_redirect_cookie = "redirect"
      @saml_default_redirect = "/"
      @saml_response_options = {}
      @saml_custom_redirect_host_check = proc do |host|
        # local redirect only.
        host.start_with?("/")
      end
    end
  end
end
