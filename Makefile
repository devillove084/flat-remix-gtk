# GNU make is required to run this file. To install on *BSD, run:
#   gmake PREFIX=/usr/local install

PREFIX ?= /usr
IGNORE ?= $(patsubst %/index.theme,%,$(wildcard ./Flat-Remix-GTK-Yellow*/index.theme))
THEMES ?= $(patsubst %/index.theme,%,$(wildcard ./*/index.theme))

# excludes IGNORE from THEMES list
THEMES := $(filter-out $(IGNORE), $(THEMES))

all:

install:
	mkdir -p $(DESTDIR)$(PREFIX)/share/themes
	cp -a $(THEMES) $(DESTDIR)$(PREFIX)/share/themes

uninstall:
	-rm -rf $(foreach theme,$(THEMES),$(DESTDIR)$(PREFIX)/share/themes/$(theme))

_get_version:
	$(eval VERSION := $(shell git show -s --format=%cd --date=format:%Y%m%d HEAD))
	@echo $(VERSION)

dist: _get_version
	git archive --format=tar.gz -o $(notdir $(CURDIR))-$(VERSION).tar.gz master -- $(THEMES)

aur_release: _get_version
	cd aur; \
	sed "s/pkgver=.*/pkgver=$(VERSION)/" -i PKGBUILD; \
	makepkg --printsrcinfo > .SRCINFO; \
	git commit -a -m "$(VERSION)"; \
	git push origin

copr_release: _get_version
	sed "s/Version:.*/Version: $(VERSION)/" -i flat-remix-gtk.spec
	git add flat-remix-gtk.spec
	git commit -m "Update flat-remix-gtk.spec version $(VERSION)"
	git push origin

release: _get_version
	$(MAKE) copr_release
	git tag -f $(VERSION)
	git push origin --tags
	$(MAKE) aur_release

undo_release: _get_version
	-git tag -d $(VERSION)
	-git push --delete origin $(VERSION)


.PHONY: $(THEMES) all install uninstall _get_version dist release undo_release

# .BEGIN is ignored by GNU make so we can use it as a guard
.BEGIN:
	@head -3 Makefile
	@false
