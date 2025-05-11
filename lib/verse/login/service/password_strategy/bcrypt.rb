# frozen_string_literal: true

module Verse
  module Login
    module PasswordStrategy
      class BCrypt
        class << self
          attr_accessor :initialized
        end

        def check?(password, encrypted_password)
          return false unless encrypted_password

          unless self.class.initialized
            begin
              require "bcrypt"
              self.class.initialized = true
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
