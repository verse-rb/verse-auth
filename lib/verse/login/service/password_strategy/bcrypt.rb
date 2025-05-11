module Verse
  module Login
    module PasswordStrategy
      class BCrypt
        def check(password, encrypted_password)
          return false unless password_digest

          require 'bcrypt' unless @@init
          @@init = true

          BCrypt::Password.new(password_digest) == password
        end
      end
    end
  end
end