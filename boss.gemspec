Gem::Specification.new do |s|
  s.name        = 'boss'
  s.version     = '0.9.2'
  s.executables << 'boss'
  s.executables << 'boss_clean_processes'
  s.executables << 'boss_check_pdef'
  s.date        = '2017-03-21'
  s.summary     = "BOSS"
  s.description = "BOSS packaging gem"
  s.authors     = ["David Greaves and other Jolla sailors"]
  s.email       = 'david.greaves@jolla.com'
  s.files       = ["lib/boss/boss_receiver.rb",
                   "lib/boss/boss_registrar.rb",
                   "lib/boss/boss_store.rb",
                   "lib/boss/boss_viewer.rb",
                  ]
  s.homepage    =
    'http://wiki.merproject.org/'
  s.license       = 'GPLv2'
end
