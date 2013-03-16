Name: boss
Version: 0.9.0
Release: 1
Summary: MeeGo Build Orchestration Server System
Group: Productivity/Networking/Web/Utilities
License: GPL2
URL: http://wiki.meego.com/BOSS
Source0: boss-%{version}.tar.bz2

BuildRequires: -post-build-checks -rpmlint-Factory
Requires: rabbitmq-server >= 1.7.2, python-boss-skynet > 0.6.0, boss-bundle
%description
The BOSS package configures the servers used to connect BOSS participants.

%prep
%setup -q -n src/

%build
true

%install
make DESTDIR=%{buildroot} install-to-bundler

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
#7. tell supervisor to pickup config and code changes
skynet apply || true
skynet reload boss || true


%pre
/usr/sbin/groupadd -r boss 2> /dev/null || :
/usr/sbin/useradd -r -o -s /bin/false -c "User for BOSS" -d /var/spool/boss -g boss boss 2> /dev/null || :
SERVICE_DIR=/etc/service
SERVER_HOME=/var/lib/boss
SNAME=boss
[ -f /etc/sysconfig/boss ] && . /etc/sysconfig/boss

if [ -e ${SERVICE_DIR}/${SNAME} ]; then
    rm ${SERVICE_DIR}/${SNAME}
fi
if /usr/bin/svok $SERVER_HOME; then
  # Upgrade from daemontools based version
    echo "stopping daemontools controlled boss-viewer ..."
    # Shut down the supervise and log too
    svc -dx ${SERVER_HOME}
    sleep 1
    svc -dx ${SERVER_HOME}/log
fi

%postun
#don't do anything in case of upgrade
if [ ! $1 -eq 1 ] ; then
    if [ -e /usr/sbin/rabbitmqctl ]; then
      echo "Removing boss exchange/user from RabbitMQ"
      rabbitmqctl delete_vhost boss
      rabbitmqctl delete_user boss
    fi
fi

%insserv_cleanup

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%doc INSTALL README
%config(noreplace) /etc/skynet/boss.conf
%config(noreplace) /etc/supervisor/conf.d/boss.conf
/usr/bin/boss_check_pdef
/usr/bin/boss_clean_processes
/usr/bin/boss
/usr/lib/boss-bundle/boss_check_pdef
/usr/lib/boss-bundle/boss_clean_processes
/usr/lib/boss-bundle/boss
/usr/lib/boss-bundle/wrapper

%package -n boss-viewer
Summary: Wrapper around ruote-kit
Group: Productivity/Networking/Web/Utilities
Requires: boss

%description -n boss-viewer
A web based viewer to provide an overview of BOSS processes

%pre -n boss-viewer

SERVICE_DIR=/etc/service
VIEWER_HOME=/var/lib/boss-viewer
VIEWER_DAEMON_DIR=/var/lib/boss-viewer/boss-viewer
SNAME=boss-viewer
[ -f /etc/sysconfig/boss-viewer ] && . /etc/sysconfig/boss-viewer

if [ -e ${SERVICE_DIR}/${SNAME} ]; then
    rm ${SERVICE_DIR}/${SNAME}
fi
if /usr/bin/svok $VIEWER_DAEMON_DIR; then
  # Upgrade from daemontools based version
    echo "stopping daemontools controlled boss-viewer ..."

    # Shut down the supervise and log too
    svc -dx ${VIEWER_DAEMON_DIR}
    sleep 1
    svc -dx ${VIEWER_DAEMON_DIR}/log
fi

%files -n boss-viewer
%defattr(-,root,root,-)
/usr/bin/boss-viewer
/usr/lib/boss-bundle/boss-viewer
%config(noreplace) /etc/supervisor/conf.d/boss-viewer.conf

%post -n boss-viewer
#7. tell supervisor to pickup config and code changes
skynet apply || true
skynet reload boss || true

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

