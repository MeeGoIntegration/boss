# -*- encoding: utf-8 -*-
# stub: ruote-amqp 2.3.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "ruote-amqp"
  s.version = "2.3.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Kenneth Kalmer", "John Mettraux"]
  s.date = "2017-04-10"
  s.description = "\nAMQP participant/receiver pair for ruote\n  "
  s.email = ["kenneth.kalmer@gmail.com", "jmettraux@gmail.com"]
  s.files = ["CHANGELOG.txt", "CREDITS.txt", "LICENSE.txt", "README.md", "Rakefile", "TODO.txt", "lib/ruote-amqp.rb", "lib/ruote/amqp.rb", "lib/ruote/amqp/alert_participant.rb", "lib/ruote/amqp/participant.rb", "lib/ruote/amqp/receiver.rb", "lib/ruote/amqp/version.rb", "ruote-amqp.gemspec", "spec/alert_participant_spec.rb", "spec/participant_spec.rb", "spec/participant_subclass_spec.rb", "spec/receiver_spec.rb", "spec/spec_helper.rb", "spec/support/ruote_amqp_helper.rb"]
  s.homepage = "http://ruote.rubyforge.org"
  s.rubyforge_project = "ruote"
  s.rubygems_version = "2.2.2"
  s.summary = "AMQP participant/receiver pair for ruote"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<eventmachine>, ["= 0.12.10"])
      s.add_runtime_dependency(%q<amqp>, ["= 0.9.7"])
      s.add_runtime_dependency(%q<ruote>, [">= 2.3.0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.8"])
    else
      s.add_dependency(%q<eventmachine>, ["= 0.12.10"])
      s.add_dependency(%q<amqp>, ["= 0.9.7"])
      s.add_dependency(%q<ruote>, [">= 2.3.0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 2.8"])
    end
  else
    s.add_dependency(%q<eventmachine>, ["= 0.12.10"])
    s.add_dependency(%q<amqp>, ["= 0.9.7"])
    s.add_dependency(%q<ruote>, [">= 2.3.0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 2.8"])
  end
end
