Name: boss
Version: 0.1
Release:1%{?dist}
Summary: MeeGo Build Orchestration Server System
Group: Productivity/Networking/Web/Utilities
License: GPL2
URL: http://wiki.meego.com/BOSS
Source0: boss_0.1.orig.tar.gz
BuildRoot: %{name}-root-%(%{__id_u} -n)

#BuildRequires:
Requires: rabbitmq-server-1.7.2, rubygem-ruote, rubygem-ruote-amqp
%description
The BOSS package configures the servers used to connect BOSS participants.

%prep
%setup -q

%build
true

%install
rm -rf %{buildroot}
true

%post
#!/bin/bash
if -e /usr/sbin/rabbitmqctl; then
  rabbitmqctl add_vhost boss
  rabbitmqctl add_user boss boss
  rabbitmqctl set_permissions -p boss boss '.*' '.*' '.*'
fi

%postun
#!/bin/bash
if -e /usr/sbin/rabbitmqctl; then
  rabbitmqctl delete_vhost boss
  rabbitmqctl delete_user boss
fi
%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%doc INSTALL README

%changelog
* Thu Jul 22 2010 David Greaves <david@dgreaves.com> - 0.1
- Initial minimal BOSS package

