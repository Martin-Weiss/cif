#!/bin/bash
#suseconnect -p PackageHub/15.6/x86_64
#zypper in mkdud
#suseconnect -d -p PackageHub/15.6/x86_64
#https://github.com/openSUSE/installation-images/pull/659
#https://bugzilla.suse.com/show_bug.cgi?id=1215290
ISOMOUNTPOINT=/srv/www/htdocs/sles15sp6
mkdud -c sles15sp6-wget-dud.dud -d sles15sp6 -n sles15sp6-wget-dud --install instsys \
        $ISOMOUNTPOINT/Module-Basesystem/x86_64/wget-1.20.3-150600.17.3.x86_64.rpm \
        $ISOMOUNTPOINT/Module-Basesystem/x86_64/libpxbackend-1_0-0.5.3-150600.2.1.x86_64.rpm \
        $ISOMOUNTPOINT/Module-Basesystem/x86_64/libmetalink3-0.1.3-150000.3.2.1.x86_64.rpm \
        $ISOMOUNTPOINT/Module-Basesystem/x86_64/libcares2-1.19.1-150000.3.26.1.x86_64.rpm
