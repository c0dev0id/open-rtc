#
# Open-RTC.
# Copyright (C) 2013-2014 struktur AG
# Copyright 2019 - deroad
#
# This file is part of Open-RTC.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

AUTOMAKE_OPTIONS = -Wno-portability
ACLOCAL_AMFLAGS = -I m4

unexport GOBIN

EXENAME := open-rtc-server
GOPKG := github.com/wargio/open-rtc
GOPATH := "$(CURDIR)/vendor:$(CURDIR)"

CONFIG_FILE ?= open-rtc-server.conf
CONFIG_PATH ?= /etc
GOBUILDFLAGS ?=
GOTESTFLAGS ?=
SYSTEM_GOPATH = /usr/share/gocode/src/

OUTPUT := $(CURDIR)/bin
OUTPUT_JS := $(CURDIR)/build/out

BUILD_ARCH := $(shell $(GO) env GOARCH)
BUILD_OS := $(shell $(GO) env GOOS)
DIST := $(CURDIR)/dist_$(BUILD_ARCH)
DIST_SRC := $(DIST)/src
DIST_BIN := $(DIST)/bin

all: build

build: 
	$(MAKE) get
	$(MAKE) binary
	$(MAKE) assets

gopath:
	@echo GOPATH=$(GOPATH)

goget:
	if [ -z "$(DEB_BUILDING)" ]; then GOPATH=$(GOPATH) $(GO) get github.com/rogpeppe/godeps; fi
	if [ -z "$(DEB_BUILDING)" ]; then GOPATH=$(GOPATH) $(CURDIR)/vendor/bin/godeps -u dependencies.tsv; fi
	$(MKDIR_P) $(shell dirname "$(CURDIR)/vendor/src/$(GOPKG)")
	rm -f $(CURDIR)/vendor/src/$(GOPKG)
	ln -sfn $(PWD) $(CURDIR)/vendor/src/$(GOPKG)

get: goget

gogetupdate: govendorclean goget

dependencies.tsv:
	set -e ;\
	TMP=$$(mktemp -d) ;\
	cp -r $(CURDIR)/vendor $$TMP ;\
	GOPATH=$$TMP/vendor:$(CURDIR) $(CURDIR)/vendor/bin/godeps $(GOPKG)/src/app/open-rtc-server ./go/... > $(CURDIR)/dependencies.tsv ;\
	rm -rf $$TMP

binary:
	GOPATH=$(GOPATH) $(GO) build $(GOBUILDFLAGS) -o bin/$(EXENAME) -ldflags '$(INTERNALLDFLAGS)' app/$(EXENAME)

binaryrace: GOBUILDFLAGS := $(GOBUILDFLAGS) -race
binaryrace: binary

binaryall: GOBUILDFLAGS := $(GOBUILDFLAGS) -a
binaryall: binary

gofmt:
	GOPATH=$(GOPATH) $(GO) fmt app/... ./go/...

fmt: gofmt

test:
	GOPATH=$(GOPATH) $(GO) test -v $(GOTESTFLAGS) app/... ./go/...

dist_gopath: $(DIST_SRC)
	[ -d $(SYSTEM_GOPATH) ] && \
		find $(SYSTEM_GOPATH) -mindepth 1 -maxdepth 1 -type d \
			-exec ln -sf {} $(DIST_SRC) \; || true

assets: javascript fonts

release-assets: RJSFLAGS = generateSourceMaps=false preserveLicenseComments=true
release-assets: assets

fonts:
	$(MKDIR_P) $(CURDIR)/static/fonts
	cp -r $(CURDIR)/src/styles/libs/font-awesome/fonts/font* $(CURDIR)/static/fonts

javascript:
	$(MKDIR_P) $(OUTPUT_JS)
	$(NODEJS) $(CURDIR)/build/r.js \
		-o $(CURDIR)/build/build.js \
		dir=$(OUTPUT_JS) $(RJSFLAGS)

styles: fonts
	cd $(CURDIR)/src/styles && $(MAKE) styles

styleshint:
	cd $(CURDIR)/src/styles && $(MAKE) styleshint

styleslint:
	cd $(CURDIR)/src/styles && $(MAKE) styleslint

jshint:
	@if [ "$(JSHINT)" = "" ]; then echo "Command 'jshint' not found"; exit 1; fi
	$(FIND) static/ -wholename static/js/libs -prune -o -name "*.js" -print0 | xargs -0 -n1 $(JSHINT) --config .jshint

jsbeautify:
	@if [ "$(JS_BEAUTIFY)" = "" ]; then echo "Command 'js-beautify' not found"; exit 1; fi
	$(FIND) static/ \( -path static/js/libs -o -path static/translation \) -prune -o -name "*.js" -exec $(JS_BEAUTIFY) -t -o {}.new {} \; -exec mv -f {}.new {} \;

build-i18n:
	cd $(CURDIR)/src/i18n && $(MAKE) build

extract-i18n:
	cd $(CURDIR)/src/i18n && $(MAKE) extract

update-i18n:
	cd $(CURDIR)/src/i18n && $(MAKE) update

release-binary: GOPATH = "$(DIST):$(CURDIR)/vendor:$(CURDIR)"
if GO_14
release-binary: INTERNALLDFLAGS = -X main.version $(PACKAGE_VERSION) -X main.defaultConfig $(CONFIG_PATH)/$(CONFIG_FILE)
else
release-binary: INTERNALLDFLAGS = -X main.version=$(PACKAGE_VERSION) -X main.defaultConfig=$(CONFIG_PATH)/$(CONFIG_FILE)
endif
release-binary: OUTPUT = $(DIST_BIN)
release-binary: dist_gopath $(DIST_BIN) binary

release: release-binary release-assets

clean:
	$(GO) clean -i -r app/... 2>/dev/null || true
	rm -rf $(CURDIR)/static/fonts
	rm -rf $(CURDIR)/build/out
	rm -f $(CURDIR)/bin/$(EXENAME)

distclean: clean
	rm -rf $(DIST)

govendorclean:
	rm -rf vendor/*

pristine: distclean govendorclean
	rm -f server.conf

$(DIST_SRC):
	$(MKDIR_P) $@

$(DIST_BIN):
	$(MKDIR_P) $@

tarball: TARPATH = $(DIST)/$(PACKAGE_NAME)-$(PACKAGE_VERSION)
tarball: distclean release install
	mkdir -pv $(TARPATH)/www/static/js/libs/pdf
	mkdir -pv $(TARPATH)/www/static/js/sandboxes
	mkdir -pv $(TARPATH)/bin
	cp bin/$(EXENAME) $(TARPATH)/bin
	cp -R doc/ $(TARPATH)/
	cp -R html/ $(TARPATH)/www/
	cp -R static/ $(TARPATH)/www/
	cp $(OUTPUT_JS)/*.js $(TARPATH)/www/static/js
	cp $(OUTPUT_JS)/libs/pdf/*.js $(TARPATH)/www/static/js/libs/pdf
	cp $(OUTPUT_JS)/sandboxes/*.js $(TARPATH)/www/static/js/sandboxes
	echo -n $(PACKAGE_VERSION) > $(TARPATH)/version.txt
	cp server.conf.in $(TARPATH)/server.conf
	tar czf $(DIST)/$(PACKAGE_NAME)-$(PACKAGE_VERSION)_$(BUILD_OS)_$(BUILD_ARCH).tar.gz -C $(DIST) $(PACKAGE_NAME)-$(PACKAGE_VERSION)

.PHONY: clean distclean govendorclean pristine goget gogetupdate build javascript fonts styles release release-binary dist_gopath gopath binary binaryrace binaryall tarball assets dependencies.tsv
