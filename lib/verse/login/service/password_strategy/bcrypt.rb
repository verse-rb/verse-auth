module Verse
  module Login
    module PasswordStrategy
      class BCrypt
        @@init = false

        def check?(password, encrypted_password)
          return false unless encrypted_password

          require 'bcrypt' unless @@init
          @@init = true

          BCrypt::Password.new(encrypted_password) == password
        end
      end
    end
  end
end
