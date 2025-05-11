# frozen_string_literal: true

require_relative "./helper/simple_login"

module Verse
  module Login
    module Helper
      extend self

      include SimpleLoginHelper
    end
  end
end
