Name: boss
Version: 0.9.2
Release: 1
Summary: Build Orchestration Server System
Group: Productivity/Networking/Web/Utilities
License: GPL2
Source0: boss-%{version}.tar.gz
Requires: rabbitmq-server >= 1.7.2, python-boss-skynet > 0.6.0
Obsoletes: boss-bundle
BuildRequires:  rubygems ruby-devel
%rubygems_requires
BuildRequires:  rubygem(bundler) git gcc-c++ openssl-devel pkg-config

%description
The BOSS package configures the servers used to connect BOSS participants.
The web based viewer to provide an overview of BOSS processes is now
integrated directly into BOSS.

%prep
%setup

%build
gem build boss.gemspec
mv boss-*.gem vendor/cache/

%install
# http://bundler.io/v1.3/man/bundle-install.1.html#DEPLOYMENT-MODE
# --deployment means "Gems are installed to vendor/bundle"
bundle install --local --standalone --deployment --binstubs=%{buildroot}/usr/bin/ --no-cache --shebang=/usr/bin/ruby
mkdir -p %{buildroot}/usr/lib/boss-bundle/

sed -i -e's#^BUNDLE_PATH:.*$#BUNDLE_PATH: /usr/lib/boss-bundle/vendor/bundle#' .bundle/config  
sed -i -e's#^BUNDLE_BIN:.*$#BUNDLE_BIN: /usr/bin#' .bundle/config

cp -al vendor %{buildroot}/usr/lib/boss-bundle/
cp -al .bundle/ %{buildroot}/usr/lib/boss-bundle/
cp -al Gemfile Gemfile.lock %{buildroot}/usr/lib/boss-bundle/

#Install the config files and boss-install
make DESTDIR=%{buildroot} install-rest

# Change #!/usr/local/bin/ruby to #!/usr/bin/ruby
sed -i -e 's_#!/usr/local/bin/ruby_#!/usr/bin/ruby_' $(grep -rl "usr/local/bin/ruby" %{buildroot})

%post
echo "Please run boss-install as root to setup rabbitmq, users and skynet"

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
%dir /etc/skynet
%dir /etc/supervisor
%dir /etc/supervisor/conf.d
%config(noreplace) /etc/skynet/boss.conf
%config(noreplace) /etc/supervisor/conf.d/boss.conf
/usr/bin/*
/usr/lib/boss-bundle

%package -n boss-obs-plugin
Summary: MeeGo Build Orchestration Server System
Group: Productivity/Networking/Web/Utilities
Requires: obs-server perl-Net-RabbitMQ perl-JSON-XS perl-common-sense

%description -n boss-obs-plugin
This BOSS package configures the OBS servers to connect to the BOSS engine.

%files -n boss-obs-plugin
%defattr(-,root,root,-)
/usr/lib/obs/server/plugins/notify_boss.pm
%dir /usr/lib/obs
%dir /usr/lib/obs/server
%dir /usr/lib/obs/server/plugins
