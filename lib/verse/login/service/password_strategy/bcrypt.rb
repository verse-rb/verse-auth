# frozen_string_literal: true

module Verse
  module Login
    module PasswordStrategy
      module BCrypt
        @initialized = false

        def self.check?(password, encrypted_password)
          return false unless encrypted_password

          unless @initialized
            begin
              # Because bcrypt gem is not always available,
              # we need to require it only when needed.
              require "bcrypt"
              @initialized = true
            rescue LoadError
              raise LoadError, "BCrypt library not found. Please install the bcrypt gem."
            end
          end

          BCrypt::Password.new(encrypted_password) == password
        end
      end
    end
  end
end
