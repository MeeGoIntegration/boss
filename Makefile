install-rest:
	install -D -m 644 notify_boss.pm $(DESTDIR)/usr/lib/obs/server/plugins/notify_boss.pm
	install -D -m 644 boss.conf $(DESTDIR)/etc/skynet/boss.conf
	install -D -m 644 supervisor_boss.conf $(DESTDIR)/etc/supervisor/conf.d/boss.conf
