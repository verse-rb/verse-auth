require_relative "./simple_login_input"

module Verse
  module Login
    module Helper
      module SimpleLoginHelper

        DESCRIPTION = <<-MD
          This endpoint is used to authenticate a user with a username and password.
          It returns tokens for authentication and refresh, and rights mapping
          for the given role.
        MD

        # Generate action for simple login
        # You can use around to add custom logic:
        #
        # ```
        # simple_login
        #
        # around :simple_login do
        #   if server.env["REMOTE_ADDR"] != "1.2.3.4"
        #     raise Verse::Error::Unauthorized, "Not allowed"
        #   end
        #   yield
        # end
        # ```
        #
        # @param method [Symbol] HTTP method (default: :post)
        # @param path [String] Path for the endpoint (default: "login")
        #
        # @param input [Class] Input class (default: SimpleLoginInput).
        #   This module should implement Schema const and the `process_params` method.
        #
        # @see SimpleLoginInput
        # @param description [String] Description for the endpoint (default: DESCRIPTION)
        # @param method_name [Symbol] Method name for the action (default: :simple_login)
        # @param opts [Hash] Additional options for the action.
        # Those options, such as `renderer:`, will be passed to the `on_http` hook.
        def simple_login(
          method: :post,
          path: "login",
          input: SimpleLoginInput,
          description: DESCRIPTION,
          method_name: :simple_login,
          **opts
        )
          input_arg = input

          { auth: nil }.merge(opts).tap do |options|
            hook = on_http(method, path, **options)
            expose hook do
              desc description

              input input_arg.schema
            end
            define_method(method_name) do
              Service::SimpleLogin.new(auth_context).(
                **input_arg.process_params(params),
                env: params.env,
              )
            end
          end
        end
      end
    end
  end
end
