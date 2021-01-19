Gem::Specification.new do |s|
  s.name        = "boss"
  s.version     = "0.10.0"
  s.date        = "2021-01-19"
  s.summary     = "BOSS"
  s.description = "BOSS packaging gem"
  s.authors     = ["David Greaves and other Jolla sailors"]
  s.email       = "david.greaves@jolla.com"
  s.homepage    = "http://wiki.merproject.org/"
  s.license     = "GPLv2"
  s.executables = [
      "boss",
      "boss_clean_processes",
      "boss_check_pdef",
  ]
  s.files       = [
      "lib/boss/boss_receiver.rb",
      "lib/boss/boss_registrar.rb",
      "lib/boss/boss_store.rb",
      "lib/boss/boss_viewer.rb",
  ]
  s.add_runtime_dependency 'amqp'
  s.add_runtime_dependency 'yajl-ruby'
  s.add_runtime_dependency 'inifile'
  s.add_runtime_dependency 'ruote'
  s.add_runtime_dependency 'ruote-amqp'
  s.add_runtime_dependency 'ruote-kit'
end
