# frozen_string_literal: true

module Verse
  module Login
    module Error
      Base = Class.new(Verse::Error::Base)

      BadCredentials = Class.new(Base)
      AccountLocked = Class.new(Base)
      AccountNotVerified = Class.new(Base)

      InvalidSamlProvider = Class.new(Base)
      InvalidSamlResponse = Class.new(Base)
    end
  end
end
