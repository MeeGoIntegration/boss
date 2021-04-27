target ?= ./boss-bundle
bundle_dir = $(DESTDIR)$(target)

vendor/build:
	mkdir -p vendor/build/gems
	gem build boss.gemspec
	mv boss-*.gem vendor/build/gems/
	cd ruote; gem build ruote.gemspec
	mv ruote/ruote-*.gem vendor/build/gems/
	cd ruote-kit; gem build ruote-kit.gemspec
	mv ruote-kit/ruote-kit-*.gem vendor/build/gems/

install: vendor/build
	cp vendor/build/gems/*.gem vendor/cache/
	bundle install --local --standalone \
		--path $(bundle_dir) \
		--binstubs $(bundle_dir)/bin

clean:
	rm -rf vendor/build .bundle Gemfile.lock

update_gems: vendor/build
	cd vendor/build; gem generate_index
	UPDATE_GEMS=1 bundle package --no-install --path $(bundle_dir)



.PHONY: clean
