Gem::Specification.new do |s|
  s.name        = "boss"
  s.version     = "0.12.0"
  s.date        = "2022-12-14"
  s.summary     = "BOSS"
  s.description = "BOSS packaging gem"
  s.authors     = ["David Greaves and other Jolla sailors"]
  s.email       = "david.greaves@jolla.com"
  s.homepage    = "http://wiki.merproject.org/"
  s.license     = "GPLv2"
  s.executables = [
      "boss",
      "boss_clean_processes",
      "boss_clean_errors",
      "boss_check_pdef",
  ]
  s.files       = [
                   "lib/boss/store.rb",
                   "lib/boss/viewer.rb",
                   "lib/boss/participant.rb",
                   "lib/boss/config.rb",
                   "lib/boss/worker.rb",
                   "lib/boss/registrar.rb",
                   "lib/boss/receiver.rb",
                   "lib/boss.rb",
  ]
  s.add_runtime_dependency 'bunny'
  s.add_runtime_dependency 'yajl-ruby'
  s.add_runtime_dependency 'inifile'
  s.add_runtime_dependency 'ruote'
  s.add_runtime_dependency 'ruote-kit'
  s.add_runtime_dependency 'ruote-sequel'
  s.add_runtime_dependency 'pg'
end
