#############################################################################
# File		: Makefile
# Package	: rpmlint
# Author	: Frederic Lepied
# Created on	: Mon Sep 30 13:20:18 1999
# Version	: $Id$
# Purpose	: rules to manage the files.
#############################################################################

BINDIR=/usr/bin
LIBDIR=/usr/share/rpmlint
ETCDIR=/etc/rpmlint

FILES= rpmlint *.py AUTHORS INSTALL README README.CVS COPYING ChangeLog Makefile \
       config rpmlint.spec rpmdiff

PACKAGE=rpmlint
VERSION:=$(shell rpm -q --qf %{VERSION} --specfile $(PACKAGE).spec)
RELEASE:=$(shell rpm -q --qf %{RELEASE} --specfile $(PACKAGE).spec)
TAG := $(shell echo "V$(VERSION)_$(RELEASE)" | tr -- '-.' '__')

all:
	./compile.py "$(LIBDIR)/" [A-Z]*.py

clean:
	rm -f *~ *.pyc *.pyo

install:
	-mkdir -p $(DESTDIR)$(LIBDIR) $(DESTDIR)$(BINDIR) $(DESTDIR)$(ETCDIR)
	cp -p rpmdiff *.py *.pyo $(DESTDIR)$(LIBDIR)
	if [ -z "$(POLICY)" ]; then \
	  sed -e 's/@VERSION@/$(VERSION)/' < rpmlint.py > $(DESTDIR)$(LIBDIR)/rpmlint.py ; \
	else \
	  sed -e 's/@VERSION@/$(VERSION)/' -e 's/policy=None/policy="$(POLICY)"/' < rpmlint.py > $(DESTDIR)$(LIBDIR)/rpmlint.py; \
	fi
	cp -p rpmlint $(DESTDIR)$(BINDIR)
	cp -p config  $(DESTDIR)$(ETCDIR)

verify:
	pychecker *.py

version:
	@echo "$(VERSION)-$(RELEASE)"

# rules to build a test rpm

localrpm: localdist buildrpm

localdist: cleandist dir localcopy tar

cleandist:
	rm -rf $(PACKAGE)-$(VERSION) $(PACKAGE)-$(VERSION).tar.bz2

dir:
	mkdir $(PACKAGE)-$(VERSION)

localcopy:
	tar c $(FILES) | tar x -C $(PACKAGE)-$(VERSION)

tar:
	tar cvf $(PACKAGE)-$(VERSION).tar $(PACKAGE)-$(VERSION)
	bzip2 -9vf $(PACKAGE)-$(VERSION).tar
	rm -rf $(PACKAGE)-$(VERSION)

buildrpm:
	rpm -ta $(PACKAGE)-$(VERSION).tar.bz2

# rules to build a distributable rpm

rpm: changelog cvstag dist buildrpm

dist: cleandist dir export tar

export:
	cvs export -d $(PACKAGE)-$(VERSION) -r $(TAG) $(PACKAGE)

cvstag:
	cvs tag $(CVSTAGOPT) $(TAG)

changelog: ../common/username
	cvs2cl -U ../common/username -I ChangeLog 
	rm -f ChangeLog.bak
	cvs commit -m "Generated by cvs2cl the `date '+%d_%b'`" ChangeLog

# Makefile ends here
