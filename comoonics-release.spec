#
# Copyright (c) 2001 ATIX GmbH, 2007 ATIX AG.
# Einsteinstrasse 10, 85716 Unterschleissheim, Germany
# All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
%{!?RELEASE: %global RELEASE 0}

%define _user root
%define _sysconfdir /etc

%define RELEASENAME Gumpn
%if %{RELEASE} > 0
%define PRODUCTNAME OpenSharedRoot
%else
%define PRODUCTNAME Com.oonis
%endif
%define PRODUCTVERSION 5.0 pre
%define DISTRIBUTIONNAME %{PRODUCTNAME} %{PRODUCTVERSION} (%{RELEASENAME})
%define DISTRIBUTIONBASE %{DISTRIBUTIONNAME} Base
%define DISTRIBUTIONEXTRAS %{DISTRIBUTIONNAME} Extras

%define GROUPPARENT System Environment
%define GROUPCHILDEXTRAS Extras
%define GROUPCHILDBASE Base
%define GROUPCHILDSLES SLES
%define GROUPCHILDSLES10 SLES10
%define GROUPCHILDSLES11 SLES11
%define GROUPCHILDRHEL RHEL
%define GROUPCHILDRHEL4 RHEL4
%define GROUPCHILDRHEL5 RHEL5
%define GROUPCHILDRHEL6 RHEL6
%define GROUPCHILDFEDORA Fedora

Group:          %{GROUPPARENT}/%{GROUPCHILDBASE}
Distribution:   %{DISTRIBUTIONBASE}
Name:           comoonics-release
Version:        5.0
Release:        1.pre
Summary:        com.oonics release package
License:        GPLv2+
Vendor:         ATIX AG
Packager:       ATIX AG <http://bugzilla.atix.de>
ExclusiveArch:  noarch
URL:            http://www.atix.de/comoonics/
Source0:        comoonics-release-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-buildroot

%description
Adds the release files for com.oonics enterprise IT Platform.

%prep
%setup -q

%build

%install
rm -rf $RPM_BUILD_ROOT

# common
#install -Dpm 644 comoonics-RPM-GPG.key $DOCDIR/comoonics-RPM-GPG.key
%if %{RELEASE} > 0
install -m 644 comoonics-release-$(echo %{?_dist} | tr [A-Z] [a-z]) $RPM_BUILD_ROOT/%{_sysconfdir}/comoonics-release
%else
install -Dm 644 comoonics-release $RPM_BUILD_ROOT/%{_sysconfdir}/comoonics-release
%endif

%post
#rpm --import 

%clean
rm -rf $RPM_BUILD_ROOT

%files
%doc comoonics-RPM-GPG.key
%attr(0644, root, root) %{_sysconfdir}/comoonics-release

%changelog
* Tue Aug 09 2011 Marc Grimme <grimme[AT]atix.de> - 0-1
- initial release
