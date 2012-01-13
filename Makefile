default:
	touch default

install:
	install -D -m 755 boss $(DESTDIR)/usr/bin/boss
	install -D -m 755 boss-viewer $(DESTDIR)/usr/bin/boss-viewer
	install -D -m 755 boss_clean_processes $(DESTDIR)/usr/bin/boss_clean_processes
	install -D -m 755 boss_check_pdef $(DESTDIR)/usr/bin/boss_check_pdef
	install -D -m 644 notify_boss.pm $(DESTDIR)/usr/lib/obs/server/plugins/notify_boss.pm
	install -D -m 644 boss.conf $(DESTDIR)/etc/skynet/boss.conf
	install -D -m 644 supervisor_boss.conf $(DESTDIR)/etc/supervisor/conf.d/boss.conf
	install -D -m 644 supervisor_boss-viewer.conf $(DESTDIR)/etc/supervisor/conf.d/boss-viewer.conf
