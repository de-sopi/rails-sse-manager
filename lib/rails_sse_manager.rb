# frozen_string_literal: true

require 'require_all'
require_all 'lib'

module RailsSseManager
  class RailsSseManagerError < StandardError; end

  def config
    @config ||= Config.new
  end

  def configure
    yield config
  end
end
