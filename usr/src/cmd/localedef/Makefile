#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source.  A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#

#
# Copyright 2011 Nexenta Systems, Inc.  All rights reserved.
# Copyright 2011 EveryCity Ltd. All rights reserved.
# Copyright 2013 DEY Storage Systems, Inc.
# Copyright 2015 Joyent, Inc.
#

PROG=localedef

NDIR=native
NPROG=$(NDIR)/localedef

include ../Makefile.cmd

OBJS = 	charmap.o collate.o ctype.o messages.o monetary.o numeric.o time.o \
	scanner.o localedef.o wide.o parser.tab.o
NOBJS = $(OBJS:%.o=native/%.o) native/avl.o native/mkdirp.o

HDRS	= localedef.h

SRCS   = $(OBJS:%.o=%.c)

CPPFLAGS	+= -I $(SRC)/lib/libc/port/locale
NATIVE_CPPFLAGS	+= -I $(SRC)/lib/libc/port/locale
CERRWARN	+= -_gcc=-Wno-char-subscripts
CERRWARN	+= -_gcc=-Wno-uninitialized
CERRWARN	+= -_gcc=-Wno-unused-label
LDLIBS		+= -lgen
LDLIBS 		+= -lavl

NATIVELDLIBS=

YFLAGS		= -d -b parser

CLEANFILES	= $(NOBJS) $(OBJS) parser.tab.c parser.tab.h
CLOBBERFILES	= $(PROG) $(NPROG) $(POFILE)

PIFILES		= $(OBJS:%.o=%.i)
POFILE		= localedef_cmd.po

LOCNAMES:sh	= cat locales.txt
LOCNAMES	+= zz_AA.UTF-8
ALIASES:sh	= cut -d' ' -f2 aliases.txt

LOCDIRS		= $(LOCNAMES:%=locale/%)

CATDIRS		= \
		$(LOCDIRS:%=%/LC_COLLATE) \
		$(LOCDIRS:%=%/LC_CTYPE) \
		$(LOCDIRS:%=%/LC_MESSAGES) \
		$(LOCDIRS:%=%/LC_MONETARY) \
		$(LOCDIRS:%=%/LC_NUMERIC) \
		$(LOCDIRS:%=%/LC_TIME)

DATA		= $(CATDIRS:%=%/LCL_DATA)

DCOLL		= LC_COLLATE/LCL_DATA
DCTYPE		= LC_CTYPE/LCL_DATA
DMSGS		= LC_MESSAGES/LCL_DATA
DMON		= LC_MONETARY/LCL_DATA
DNUM		= LC_NUMERIC/LCL_DATA
DTIME		= LC_TIME/LCL_DATA

ROOTLOCDIRS	= $(LOCDIRS:%=$(ROOTLIB)/%)
ROOTCATDIRS	= $(CATDIRS:%=$(ROOTLIB)/%)
ROOTDATA	= $(DATA:%=$(ROOTLIB)/%)
ROOTALIASLINKS  = $(ALIASES:%=$(ROOTLIB)/locale/%)

#
# This is a list of locales that happen to have translations for them
# present in the gate.
#
TRANSDIR	= translations
TRANSLOCS	= \
		zz_AA.UTF-8
TRANSMOS	= $(TRANSLOCS:%=$(TRANSDIR)/%.mo)

OSTMOFILE	= LC_MESSAGES/SUNW_OST_OSLIB.mo

PRIVTRANSLOCS	= \
		zz_AA.UTF-8
PRIVFILE	= LC_MESSAGES/priv_names
		

ROOTTRANSLATIONS = $(TRANSLOCS:%=$(ROOTLIB)/locale/%/$(OSTMOFILE))
ROOTPRIVTRANS = $(PRIVTRANSLOCS:%=$(ROOTLIB)/locale/%/$(PRIVFILE))

$(ROOTDATA)	:= FILEMODE=0444

all: $(PROG) $(DATA)

translate: $(ROOTTRANSLATIONS) $(ROOTPRIVTRANS)

install: all $(ROOTPROG) $(ROOTDATA) $(ROOTTRANSLATIONS) $(ROOTPRIVTRANS) $(ROOTALIASLINKS)

$(NDIR):
	mkdir $@

$(NDIR)/%.o: %.c
	$(NATIVECC) $(NATIVE_CFLAGS) $(NATIVE_CPPFLAGS) -o $@ -c $<

$(NDIR)/avl.o : ../../common/avl/avl.c
	$(NATIVECC) $(NATIVE_CFLAGS) $(NATIVE_CPPFLAGS) -o $@ -c \
	  ../../common/avl/avl.c

$(NDIR)/mkdirp.o : ../../lib/libgen/common/mkdirp.c
	$(NATIVECC) $(NATIVE_CFLAGS) $(NATIVE_CPPFLAGS) -o $@ -c \
	  ../../lib/libgen/common/mkdirp.c

$(NPROG): $(NDIR) .WAIT $(NOBJS)
	$(LINK.c) $(NOBJS) -o $@ $(NATIVELDLIBS)
	$(POST_PROCESS)

$(PROG): $(OBJS)
	$(LINK.c) $(OBJS) -o $@ $(LDLIBS)
	$(POST_PROCESS)

$(OBJS) $(NOBJS):	parser.tab.h

parser.tab.c parser.tab.h: parser.y $(HDRS)
	$(YACC) $(YFLAGS) parser.y

lint:	$(SRCS)
	$(LINT.c) $(CPPFLAGS) $(SRCS)

clean:	
	$(RM) $(CLEANFILES)

clobber: clean
	$(RM) $(CLOBBERFILES)
	$(RM) -r $(LOCDIRS)
	$(RM) -r $(NDIR)
	$(RM) $(TRANSMOS)

$(POFILE):	$(PIFILES)
	$(RM) $@
	$(RM) messages.po
	$(XGETTEXT) -s $(PIFILES)
	$(SED) -e '/domain/d' messages.po > $@
	$(RM) $(PIFILES) messages.po

locale $(ROOTLOCDIRS) $(ROOTCATDIRS):
	$(INS.dir)

$(ROOTBIN)/%: $(ROOTBIN) %
	$(INS.file)

locale/%/$(DCOLL) + \
locale/%/$(DCTYPE) + \
locale/%/$(DMSGS) + \
locale/%/$(DMON) + \
locale/%/$(DNUM) + \
locale/%/$(DTIME): data/%.src $(NPROG)
	cat $< $(<:src=LC_CTYPE) $(<:src=LC_COLLATE) | ./$(NPROG) -U -w data/widths.txt -f data/$$(echo $(<F) | cut -d. -f2).cm locale/$(<F:.src=)

$(ALIASLINKS): locale
	cd locale && while read src target; do $(SYMLINK) $$src $$target; done < ../aliases.txt

$(ROOTDATA):	$(ROOTLOCDIRS) $(ROOTCATDIRS) $(DATA)
	$(RM) $@
	$(CP) $(@:$(ROOTLIB)/%=%) $@
	$(CHMOD) 0444 $@

$(ROOTALIASLINKS): $(ALIASLINKS) $(ROOTLIB)
	( cd $(ROOTLIB)/locale && while read src target; do $(RM) $$target; $(SYMLINK) $$src $$target; done ) < aliases.txt

%.mo: %.po
	$(MSGFMT) -o $@ $<

$(ROOTLIB)/locale/%/$(OSTMOFILE): $(TRANSDIR)/%.mo
	$(INS.rename)
	$(CHMOD) 0444 $@

$(ROOTLIB)/locale/%/$(PRIVFILE): $(TRANSDIR)/%.priv
	$(INS.rename)
	$(CHMOD) 0444 $@
