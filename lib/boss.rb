require 'boss/participant'
require 'boss/receiver'
require 'boss/registrar'
require 'boss/store'
require 'boss/viewer'
require 'boss/worker'

module BOSS
  class << self
    attr_accessor :connection  # Allow a default Bunny::Session to be stored
  end
end
