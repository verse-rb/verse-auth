require_relative "./base"

module Verse
  module Login
    module LoginStrategy
      # Use SAML for authentication
      class Saml < Base

        def init(channel:, redirect:)
          assert_channel_valid!(channel)

          if redirect
            allow_redirect = Config.saml_allow_custom_redirect
            cookie = Config.saml_custom_redirect_cookie
            host_check = Config.saml_custom_redirect_host_check

            if host_check.nil? || host_check.(redirect)
              server.env["HTTP_REFERER"] = nil

              server.response.set_cookie(cookie, value: redirect)
            end
          end

          url = service.create_saml_request(channel:)

          # Proceed with the SAML request:
          server.redirect url
        end

        def callback(saml_response:, channel:)
          assert_channel_valid!(channel)

          response = OneLogin::RubySaml::Response.new(
            saml_response,
            Config.saml_providers[channel],
          )

          raise Verse::Error::BadCredentials, "Invalid credentials" unless response.is_valid?

          username = response.nameid

          account = system_accounts.find_by({ email: }, included: ["active_roles", "person", "state"])

          raise Verse::Error::Authorization, "Account not registered" unless account

          build_tokens(account, nil, ip:, nonce: SecureRandom.random_number(2 ** 63))

          default_redirect = Settings["redirect.default"]
          redirect = server.cookies["redirect"] || default_redirect

          begin
            output = service.saml_callback(params[:channel], params[:SAMLResponse], ip: server_ip)

            set_cookies(output.auth_token, output.refresh_token)

            server.response.set_cookie("redirect", value: nil, expires: Time.now - 600)

            if redirect != default_redirect
              redirect = "#{redirect}?token=#{output.auth_token}"

              service.validate_allowed_hosts(redirect)
            end
          rescue Verse::Error::Authorization => e
            error_code = e.message.downcase.gsub(" ", "_")

            raise e unless %w[invalid_credentials account_not_registered no_role_active].include?(error_code)

            redirect = "#{redirect}error?code=#{error_code}"
          end

          server.redirect redirect
        end

        private def assert_channel_valid!(channel)
          if !Config.saml_providers.key?(channel)
            raise Error::InvalidSamlProvider, "Invalid SAML provider"
          end
        end
      end
    end
  end
end
