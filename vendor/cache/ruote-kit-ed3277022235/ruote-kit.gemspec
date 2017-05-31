# -*- encoding: utf-8 -*-
# stub: ruote-kit 2.3.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "ruote-kit"
  s.version = "2.3.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Kenneth Kalmer", "Torsten Schoenebaum", "John Mettraux"]
  s.date = "2017-04-10"
  s.description = "\nruote workflow engine, wrapped in a loving rack embrace\n  "
  s.email = ["kenneth.kalmer@gmail.com"]
  s.files = ["CHANGELOG.txt", "CREDITS.txt", "LICENSE.txt", "Rakefile", "TODO.txt", "lib/ruote-kit.rb", "lib/ruote-kit/application.rb", "lib/ruote-kit/core_ext.rb", "lib/ruote-kit/helpers/json_helpers.rb", "lib/ruote-kit/helpers/link_helpers.rb", "lib/ruote-kit/helpers/misc_helpers.rb", "lib/ruote-kit/helpers/pagination_helpers.rb", "lib/ruote-kit/helpers/render_helpers.rb", "lib/ruote-kit/public/_ruote", "lib/ruote-kit/public/_ruote/images", "lib/ruote-kit/public/_ruote/images/favicon.png", "lib/ruote-kit/public/_ruote/images/ruote-buttons.png", "lib/ruote-kit/public/_ruote/images/ruote.png", "lib/ruote-kit/public/_ruote/javascripts", "lib/ruote-kit/public/_ruote/javascripts/foolbox-all.min.js", "lib/ruote-kit/public/_ruote/javascripts/jquery-1.9.1.min.js", "lib/ruote-kit/public/_ruote/javascripts/rk.js", "lib/ruote-kit/public/_ruote/javascripts/ruote-fluo-all.min.js", "lib/ruote-kit/public/_ruote/stylesheets", "lib/ruote-kit/public/_ruote/stylesheets/reset.css", "lib/ruote-kit/public/_ruote/stylesheets/rk.css", "lib/ruote-kit/public/_ruote/stylesheets/ruote-buttons.png", "lib/ruote-kit/public/_ruote/stylesheets/ruote-fluo-editor.css", "lib/ruote-kit/public/_ruote/stylesheets/ruote-fluo.css", "lib/ruote-kit/resources/errors.rb", "lib/ruote-kit/resources/expressions.rb", "lib/ruote-kit/resources/participants.rb", "lib/ruote-kit/resources/processes.rb", "lib/ruote-kit/resources/schedules.rb", "lib/ruote-kit/resources/workitems.rb", "lib/ruote-kit/version.rb", "lib/ruote-kit/views/_pagination.html.haml", "lib/ruote-kit/views/_tree_editor.html.haml", "lib/ruote-kit/views/error.html.haml", "lib/ruote-kit/views/errors.html.haml", "lib/ruote-kit/views/expression.html.haml", "lib/ruote-kit/views/expressions.html.haml", "lib/ruote-kit/views/http_error.html.haml", "lib/ruote-kit/views/index.html.haml", "lib/ruote-kit/views/layout.html.haml", "lib/ruote-kit/views/participants.html.haml", "lib/ruote-kit/views/process.html.haml", "lib/ruote-kit/views/process_launched.html.haml", "lib/ruote-kit/views/processes.html.haml", "lib/ruote-kit/views/processes_new.html.haml", "lib/ruote-kit/views/schedules.html.haml", "lib/ruote-kit/views/workitem.html.haml", "lib/ruote-kit/views/workitems.html.haml", "ruote-kit.gemspec", "spec/cases/orphan_workitem_spec.rb", "spec/core_ext_spec.rb", "spec/resources/errors_spec.rb", "spec/resources/expressions_spec.rb", "spec/resources/index_spec.rb", "spec/resources/participants_spec.rb", "spec/resources/processes_spec.rb", "spec/resources/schedules_spec.rb", "spec/resources/workitems_spec.rb", "spec/ruote-kit_configure_spec.rb", "spec/spec_helper.rb", "spec/support/engine_helper.rb", "spec/support/link_helper.rb", "spec/support/rack_helper.rb", "spec/support/render_helper.rb", "spec/webapp_helpers_spec.rb"]
  s.homepage = "http://github.com/kennethkalmer/ruote-kit"
  s.licenses = ["MIT"]
  s.rubyforge_project = "ruote"
  s.rubygems_version = "2.2.2"
  s.summary = "ruote workflow engine, wrapped in a loving rack embrace"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sinatra>, [">= 1.2.0"])
      s.add_runtime_dependency(%q<sinatra-respond_to>, [">= 0.8.0"])
      s.add_runtime_dependency(%q<haml>, [">= 3.1.4"])
      s.add_runtime_dependency(%q<rufus-json>, [">= 0.2.5"])
      s.add_development_dependency(%q<rspec>, [">= 2.5.0"])
      s.add_development_dependency(%q<rack-test>, ["= 0.5.7"])
      s.add_development_dependency(%q<webrat>, ["= 0.7.3"])
    else
      s.add_dependency(%q<sinatra>, [">= 1.2.0"])
      s.add_dependency(%q<sinatra-respond_to>, [">= 0.8.0"])
      s.add_dependency(%q<haml>, [">= 3.1.4"])
      s.add_dependency(%q<rufus-json>, [">= 0.2.5"])
      s.add_dependency(%q<rspec>, [">= 2.5.0"])
      s.add_dependency(%q<rack-test>, ["= 0.5.7"])
      s.add_dependency(%q<webrat>, ["= 0.7.3"])
    end
  else
    s.add_dependency(%q<sinatra>, [">= 1.2.0"])
    s.add_dependency(%q<sinatra-respond_to>, [">= 0.8.0"])
    s.add_dependency(%q<haml>, [">= 3.1.4"])
    s.add_dependency(%q<rufus-json>, [">= 0.2.5"])
    s.add_dependency(%q<rspec>, [">= 2.5.0"])
    s.add_dependency(%q<rack-test>, ["= 0.5.7"])
    s.add_dependency(%q<webrat>, ["= 0.7.3"])
  end
end
