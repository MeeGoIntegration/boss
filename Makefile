BUNDLEDIR=/usr/lib/boss-bundle
default:
	touch default

install:
	install -D -m 755 boss $(DESTDIR)/usr/bin/boss
	install -D -m 755 boss_clean_processes $(DESTDIR)/usr/bin/boss_clean_processes
	install -D -m 755 boss_check_pdef $(DESTDIR)/usr/bin/boss_check_pdef
	install -D -m 644 notify_boss.pm $(DESTDIR)/usr/lib/obs/server/plugins/notify_boss.pm
	install -D -m 644 boss.conf $(DESTDIR)/etc/skynet/boss.conf
	install -D -m 644 supervisor_boss.conf $(DESTDIR)/etc/supervisor/conf.d/boss.conf

install-to-bundler: $(DESTDIR)$(BUNDLEDIR)/wrapper
	# In the bundler approach, the binaries need to live in the boss-bundle directory
	install -D -m 755 boss $(DESTDIR)$(BUNDLEDIR)/boss
	install -D -m 755 boss_clean_processes $(DESTDIR)$(BUNDLEDIR)/boss_clean_processes
	install -D -m 755 boss_check_pdef $(DESTDIR)$(BUNDLEDIR)/boss_check_pdef
	mkdir -p $(DESTDIR)/usr/bin
	ln -s $(BUNDLEDIR)/wrapper $(DESTDIR)/usr/bin/boss
	ln -s $(BUNDLEDIR)/wrapper $(DESTDIR)/usr/bin/boss_clean_processes
	ln -s $(BUNDLEDIR)/wrapper $(DESTDIR)/usr/bin/boss_check_pdef

	install -D -m 644 notify_boss.pm $(DESTDIR)/usr/lib/obs/server/plugins/notify_boss.pm
	install -D -m 644 boss.conf $(DESTDIR)/etc/skynet/boss.conf
	install -D -m 644 supervisor_boss.conf $(DESTDIR)/etc/supervisor/conf.d/boss.conf

$(DESTDIR)$(BUNDLEDIR)/wrapper:	
	mkdir -p $(DESTDIR)$(BUNDLEDIR)
	echo -e '#!/bin/bash\ncd $(BUNDLEDIR)\nme=$$(basename $$0)\nexec bundle exec ./$$me "$$@"' > $(DESTDIR)$(BUNDLEDIR)/wrapper
	chmod 755 $(DESTDIR)$(BUNDLEDIR)/wrapper
