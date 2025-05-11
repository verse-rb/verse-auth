# frozen_string_literal: true

module Verse
  module Login
    module Helper
      module SimpleLoginInput
        Schema = Verse::Schema.define do
          field   :username, String
          field   :password, String
          field?  :role, String
        end

        def schema = Schema

        # How to pass the inputs to the service.
        def process_params(params)
          {
            username: params.username,
            password: params.password,
            role: params.role,
          }
        end
      end
    end
  end
end
