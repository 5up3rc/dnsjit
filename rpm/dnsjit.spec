Name:           dnsjit
Version:        0.9.1
Release:        1%{?dist}
Summary:        Engine for capturing, parsing and replaying DNS
Group:          Productivity/Networking/DNS/Utilities

License:        GPLv3
URL:            https://github.com/DNS-OARC/dnsjit
Source0:        %{name}_%{version}.orig.tar.gz

BuildRequires:  libpcap-devel libev-devel luajit-devel
BuildRequires:  autoconf
BuildRequires:  automake
BuildRequires:  libtool

%description
dnsjit is a combination of parts taken from dsc, dnscap, drool,
and put together around Lua to create a script-based engine for easy
capturing, parsing and statistics gathering of DNS message while also
providing facilities for replaying DNS traffic.


%prep
%setup -q -n %{name}_%{version}


%build
sh autogen.sh
%configure
make %{?_smp_mflags}


%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT


%check
make test


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root)
%{_bindir}/*
%{_datadir}/doc/*
%{_mandir}/man1/*
%{_mandir}/man3/*


%changelog
* Wed Feb 14 2018 Jerry Lundström <lundstrom.jerry@gmail.com> 0.9.0-1
- Initial SPEC file
