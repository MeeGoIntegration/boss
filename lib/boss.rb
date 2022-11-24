require 'boss/participant'
require 'boss/receiver'
require 'boss/registrar'
require 'boss/store'
require 'boss/viewer'
require 'boss/worker'
require 'boss/config'

module BOSS
  class << self
    attr_accessor :connection  # Allow a default Bunny::Session to be stored
    attr_accessor :channel     # The Bunny channel from connect_to_amqp
    attr_accessor :conf        # Holds the configuration
    attr_accessor :storage     # The storage instance as defined by the config
  end
end
