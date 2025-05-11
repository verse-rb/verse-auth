require 'bcrypt'

module Service
  module PwdStrategy
    class Bcrypt
      def check(password, encrypted_password)
        return false unless password_digest

        BCrypt::Password.new(password_digest) == password
      end
    end
  end
end