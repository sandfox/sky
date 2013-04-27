################################################################################
# Variables
################################################################################

SKY_PACKAGE := github.com/skydb/sky
VERSION=0.3.0
PREFIX=/usr/local
DESTDIR=
BINDIR=${PREFIX}/bin
DATADIR=/var/lib/sky
INCLUDEDIR=${PREFIX}/include
LIBDIR=${PREFIX}/lib

BUILD_DIR := $(CURDIR)/.gopath

GOPATH ?= $(BUILD_DIR)
export GOPATH

SRC_DIR := $(GOPATH)/src

SKY_DIR := $(SRC_DIR)/$(SKY_PACKAGE)
SKY_MAIN := $(SKY_DIR)/sky

SKY_BIN_RELATIVE := bin/skyd
SKY_BIN := $(CURDIR)/$(SKY_BIN_RELATIVE)

all: $(SKY_BIN)

UNAME=$(shell uname)
ifeq ($(UNAME), Darwin)
SOSUFFIX=dylib
endif
ifeq ($(UNAME), Linux)
SOSUFFIX=so
endif

################################################################################
# Dependencies
################################################################################

leveldb:
	${MAKE} clean -C deps/leveldb-1.9.0
	${MAKE} -C deps/leveldb-1.9.0
	install -m 755 -d ${DESTDIR}${INCLUDEDIR}/leveldb
	install -m 755 deps/leveldb-1.9.0/include/leveldb/* ${DESTDIR}${INCLUDEDIR}/leveldb
	install -m 755 -d ${DESTDIR}${LIBDIR}
	install -m 755 deps/leveldb-1.9.0/libleveldb.a ${DESTDIR}${LIBDIR}
	install -m 755 deps/leveldb-1.9.0/libleveldb.${SOSUFFIX}.1.9 ${DESTDIR}${LIBDIR}
	ln -sf ${DESTDIR}${LIBDIR}/libleveldb.${SOSUFFIX}.1.9 ${DESTDIR}${LIBDIR}/libleveldb.${SOSUFFIX}.1
	ln -sf ${DESTDIR}${LIBDIR}/libleveldb.${SOSUFFIX}.1.9 ${DESTDIR}${LIBDIR}/libleveldb.${SOSUFFIX}

luajit:
	${MAKE} -C deps/LuaJIT-2.0.1 clean PREFIX=${PREFIX}
	${MAKE} -C deps/LuaJIT-2.0.1 PREFIX=${PREFIX}
	${MAKE} -C deps/LuaJIT-2.0.1 install PREFIX=${PREFIX}

csky:
	${MAKE} -C deps/csky clean install PREFIX=${PREFIX}

data:
	mkdir -p /var/lib/sky
	chmod 777 /var/lib/sky

deps: leveldb luajit csky data


################################################################################
# Tesy
################################################################################

test:
	@go test -v ./...

################################################################################
# Build
################################################################################

$(SKY_BIN): $(SKY_DIR)
	@mkdir -p  $(dir $@)
	@(cd $(SKY_MAIN); go build $(GO_OPTIONS) -o $@)
	@echo $(SKY_BIN_RELATIVE) is created.

$(SKY_DIR):
	@mkdir -p $(dir $@)
	@rm -f $@
	@ln -sf $(CURDIR)/ $@
	@(cd $(SKY_MAIN); go get $(GO_OPTIONS))


################################################################################
# Clean
################################################################################

clean:
	rm -rf build

.PHONY: install clean all csky leveldb luajit data  $(SKY_BIN) $(SKY_DIR)

install: $(SKY_BIN)
	install -m 755 -d ${DESTDIR}${BINDIR}
	install -m 755 bin/skyd ${DESTDIR}${BINDIR}/skyd
	install -m 755 -d ${DESTDIR}${DATADIR}
