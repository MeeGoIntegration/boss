source "http://rubygems.org"
gem "boss"
gem "rspec", :require => "spec" 
gem "inifile"
# To use local checkout: bundle config local.ruote-amqp /mer/mer/devel/mer-mint/boss-bundle/ruby-ruote-amqp
gem "ruote-amqp", :git => "git://github.com/kennethkalmer/ruote-amqp.git", :branch => "master"
gem "ruote-kit", :git => "git://github.com/kennethkalmer/ruote-kit.git", :branch => "master"
gem "yajl-ruby", ">=1.3.0"
gem "amqp"

# That's it for our strict dependencies. However, we also want to
# ensure we're using specific git versions from things further down the tree.

# bundle config local.amqp /maemo/devel/BOSS/src/ruby-amqp
#gem "amqp", :git => "git://github.com/MeeGoIntegration/amqp.git", :branch => "mer-0.9.7"
# bundle config local.ruote /maemo/devel/BOSS/src/ruby-ruote
gem "ruote", :git => "git://github.com/MeeGoIntegration/ruote.git", :ref => "86fe481a5"



#bundle install --path=/srv/bossin1          
