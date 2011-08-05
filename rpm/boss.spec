Name: boss
Version: 0.6.0
Release:1%{?dist}
Summary: MeeGo Build Orchestration Server System
Group: Productivity/Networking/Web/Utilities
License: GPL2
URL: http://wiki.meego.com/BOSS
Source0: boss_%{version}.orig.tar.gz
BuildRoot: %{name}-root-%(%{__id_u} -n)

BuildRequires: -post-build-checks -rpmlint-Factory
Requires: rabbitmq-server >= 1.7.2, daemontools, rubygem-ruote > 2.1.10, rubygem-ruote-amqp, rubygem-yajl-ruby, rubygem-tzinfo
%description
The BOSS package configures the servers used to connect BOSS participants.

%prep
%setup -q

%build
true

%install
rm -rf %{buildroot}/*
cp -ra src/* %{buildroot}
install -D -m 755 rpm/boss.init %{buildroot}/etc/init.d/boss
install -d %{buildroot}/usr/sbin
ln -s -f /etc/init.d/boss %{buildroot}/usr/sbin/rcboss
install -D -m 755 rpm/boss.sysconfig %{buildroot}/etc/sysconfig/boss

%pre
/usr/sbin/groupadd -r boss 2> /dev/null || :
/usr/sbin/useradd -r -o -s /bin/false -c "User for BOSS" -d /var/spool/boss -g boss boss 2> /dev/null || :

%post
#!/bin/bash
#
#
# Sane defaults:
SERVER_HOME=/var/lib/boss
SERVER_LOGDIR=/var/log/boss
SERVER_DATABASE=/var/spool/boss
SERVER_USER=boss
SERVER_NAME="BOSS"
SERVER_GROUP=boss
SERVICE_DIR=/etc/service
# and allow local overrides
[ -f "/etc/sysconfig/boss" ] && . /etc/sysconfig/boss

# create user to avoid running server as root
# 1. create group if not existing
if ! getent group | grep -q "^$SERVER_GROUP:" ; then
    echo -n "Adding group $SERVER_GROUP.."
    groupadd --system $SERVER_GROUP 2>/dev/null ||true
    echo "..done"
fi
# 2. create dirs if not existing
test -d $SERVER_HOME || mkdir -p $SERVER_HOME
test -d $SERVER_DATABASE || mkdir -p $SERVER_DATABASE
test -d $SERVER_LOGDIR || mkdir -p $SERVER_LOGDIR

# 3. create user if not existing
if ! getent passwd | grep -q "^$SERVER_USER:"; then
    echo -n "Adding system user $SERVER_USER.."
    useradd --system -d $SERVER_HOME -g $SERVER_GROUP \
	$SERVER_USER 2>/dev/null || true
    echo "..done"
fi
# 4. adjust passwd entry
usermod -c "$SERVER_NAME" \
    -d $SERVER_HOME   \
    -g $SERVER_GROUP  \
    $SERVER_USER
# 5. adjust file and directory permissions
chown -R $SERVER_USER:$SERVER_GROUP $SERVER_HOME
chmod -R u=rwx,g=rxs,o= $SERVER_HOME

chown -R $SERVER_USER:$SERVER_GROUP $SERVER_LOGDIR
chmod -R u=rwx,g=rxs,o= $SERVER_LOGDIR

chown -R $SERVER_USER:$SERVER_GROUP $SERVER_DATABASE
chmod -R u=rwx,g=rwxs,o= $SERVER_DATABASE

# 6. create the boss user/vhost etc if we have rabbitmqctl

# This would be nice ... but Suse apparently thinks that just because
# you 'Require' a server you can't actually assume it's there...
#
# Maybe put it in a "first_run" or just provide INSTALL info to sysadmin?
# For now just force up the server - this is a virtual/convenience
# package afer all
echo "Starting RabbitMQ and configuring to auto-start"
rcrabbitmq-server start
chkconfig rabbitmq-server on
if [ -e /usr/sbin/rabbitmqctl ]; then
    echo "Adding boss exchange/user and granting access"
    rabbitmqctl add_vhost boss || true
    rabbitmqctl add_user boss boss || true
    rabbitmqctl set_permissions -p boss boss '.*' '.*' '.*' || true
fi
inittab_line="SN:2345:respawn:/usr/bin/svscan $SERVICE_DIR"

[ ! -d $SERVICE_DIR ] && mkdir -p $SERVICE_DIR

if ! grep "$inittab_line" /etc/inittab >/dev/null; then
    echo "$inittab_line" >> /etc/inittab
    init q
fi

%restart_on_update boss

%postun
#don't do anything in case of upgrade
if [ ! $1 -eq 1 ] ; then
    if [ -e /usr/sbin/rabbitmqctl ]; then
      echo "Removing boss exchange/user from RabbitMQ"
      rabbitmqctl delete_vhost boss
      rabbitmqctl delete_user boss
    fi
    # remove the svcscan from inittab
    sed -i -e '/^SN:/d' /etc/inittab
    init q
    svc -dx /etc/service/* || :
    svc -dx /etc/service/*/log || :
fi

%insserv_cleanup

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%doc INSTALL README
/usr/lib/boss/
/usr/lib/boss
/usr/lib/boss/boss-daemon.rb
/var/lib/boss/
/var/lib/boss
/var/lib/boss/run
/var/lib/boss/log
/var/lib/boss/log/run
/usr/sbin/rcboss
/etc/init.d/boss
/etc/sysconfig/boss
%config(noreplace) /etc/sysconfig/boss
%attr(755,boss,boss) /var/spool/boss/

%package -n boss-obs-plugin
Summary: MeeGo Build Orchestration Server System
Group: Productivity/Networking/Web/Utilities
Requires: obs-server perl-Net-RabbitMQ perl-JSON-XS perl-common-sense

%description -n boss-obs-plugin
This BOSS package configures the OBS servers to connect to the BOSS engine.

%files -n boss-obs-plugin
%defattr(-,root,root,-)
/usr/lib/obs/server/plugins/notify_boss.pm
%post -n boss-obs-plugin
%postun -n boss-obs-plugin

%changelog
* Fri Jul 15 2011 Ramez Hanna <rhanna@informatiq.org> - 0.6.0
- add :action => 'unregister' to boss_register participant
- New API : bump API version
* Mon Aug 30 2010 David Greaves <david@dgreaves.com> - 0.3
- Add obs-plugin
* Sun Jul 25 2010 David Greaves <david@dgreaves.com> - 0.2
- Add daemon-kit based engine
* Thu Jul 22 2010 David Greaves <david@dgreaves.com> - 0.1
- Initial minimal BOSS package

