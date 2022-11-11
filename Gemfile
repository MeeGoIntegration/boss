if ENV['UPDATE_GEMS']
  source "https://rubygems.org"
end

source "file:///#{File.expand_path('.')}/vendor/build" do
  gem "ruote"
  gem "ruote-kit"
  gem "boss"
  gem "pg"
end

# This is needed but not pulled in as dependency
gem "tzinfo-data"
