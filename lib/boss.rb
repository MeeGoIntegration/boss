require 'boss/participant'
require 'boss/receiver'
require 'boss/registrar'
require 'boss/store'
require 'boss/viewer'
require 'boss/worker'

module Boss
  class << self
    attr_accessor :connection  # provide class methods for reading/writing
  end
end
