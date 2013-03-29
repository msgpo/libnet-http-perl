# Source from CPAN 

# Note: We compileour own package because of Debian bug  #704134
# see: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=704134

RELEASE=3.0

VERSION=6.06
PKGREL=1

PACKAGE=libnet-http-perl

DEBSRC=libnet-http-perl_6.03-2.debian.tar.gz
PKGDIR=Net-HTTP-${VERSION}
PKGSRC=${PKGDIR}.tar.gz

ARCH=all
DEB=${PACKAGE}_${VERSION}-${PKGREL}_${ARCH}.deb

all: ${DEB}

.PHONY: dinstall
dinstall: deb
	dpkg -i ${DEB}

.PHONY: deb
deb ${DEB}: 
	rm -rf ${PKGDIR}
	tar xf ${PKGSRC}
	cd ${PKGDIR}; tar xf ../${DEBSRC}
	cd ${PKGDIR}; patch -p1 <../update-changelog.patch
	cd ${PKGDIR}; dpkg-buildpackage -rfakeroot -b -us -uc
	lintian ${DEB}

.PHONY: clean
clean:
	rm -rf *~ *.deb *.changes ${PKGDIR}

.PHONY: distclean
distclean: clean

.PHONY: upload
upload: ${DEB}
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o rw 
	mkdir -p /pve/${RELEASE}/extra
	rm -f /pve/${RELEASE}/extra/${PACKAGE}_*.deb
	rm -f /pve/${RELEASE}/extra/Packages*
	cp ${DEB} /pve/${RELEASE}/extra
	cd /pve/${RELEASE}/extra; dpkg-scanpackages . /dev/null > Packages; gzip -9c Packages > Packages.gz
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o ro

