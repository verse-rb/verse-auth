# frozen_string_literal: true

require "verse/core"
require_relative "login/version"

module Verse
  module Login
  end
end

require_relative "login/error"

require_relative "login/service/login_strategy/saml"
require_relative "login/service/login_strategy/simple"