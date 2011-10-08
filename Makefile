default:
	touch default

install:
	install -D -m 755 boss-daemon.rb $(DESTDIR)/usr/lib/boss/boss-daemon.rb
	install -D -m 644 notify_boss.pm $(DESTDIR)/usr/lib/obs/server/plugins/notify_boss.pm
	install -D -m 755 boss-log.run $(DESTDIR)/var/lib/boss/log/run
	install -D -m 755 boss.run $(DESTDIR)/var/lib/boss/run
	install -D -m 755 boss_clean_processes $(DESTDIR)/usr/bin/boss_clean_processes
	install -D -m 755 boss_check_pdef $(DESTDIR)/usr/bin/boss_check_pdef



