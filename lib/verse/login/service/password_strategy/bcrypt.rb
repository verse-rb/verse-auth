module Service
  module PwdStrategy
    class Bcrypt
      def check(password, encrypted_password)
        return false unless password_digest

        require 'bcrypt' unless @@init
        @@init = true

        BCrypt::Password.new(password_digest) == password
      end
    end
  end
end