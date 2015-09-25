NAME = endovena
PROJECT_VERSION = 0.3.0

ROOT_SOURCE_DIR = src
BIN=bin
SRC = $(getSources)
TARGET = lib
SRC_TEST = $(filter-out $(ROOT_SOURCE_DIR)/app.d, $(SRC))
SRC_TEST += $(wildcard tests/*.d)

# Compiler flag
# -----------
ifeq ($(TARGET),lib)
	DCFLAGS += -lib
	DCFLAGS_REL += -lib
endif

DCFLAGS += $(DBG_CODE) #compile in debug code
DCFLAGS += $(OPTIMIZE) #optimize
#DCFLAGS += -g # add symbolic debug info
DCFLAGS += $(WARN_AS_ERR) # warnings as errors (compilation will halt)
#DCFLAGS += $(WARN_AS_MSG) # warnings as messages (compilation will continue)

# release flags
DCFLAGS_REL += -O -wi -release -inline -boundscheck=off

DCFLAGS_TEST += -unittest
# Linker flag
# -----------
# DCFLAGS_LINK +=
# DCFLAGS_LINK += $(LINKERFLAG)-L/usr/lib/

# Version flag
# -----------
#VERSION_FLAG += -version=StdLoggerDisableLogging
#VERSION_FLAG += -version=use_gtk

# Packages
# -----------
PKG = $(wildcard $(BIN)/$(NAME))
PKG_SRC = $(PKG) $(SRC) makefile

# -----------
# Libraries
# -----------


# -----------
# Test  library
# -----------

# unit-threaded
# -----------
LIB_TEST += $(D_DIR)/unit-threaded/libunit-threaded.a
DCFLAGS_IMPORT_TEST += -I$(D_DIR)/unit-threaded/source

# dunit
# -----------
#LIB += $(D_DIR)/dunit/libdunit.a
#DCFLAGS_IMPORT += -I$(D_DIR)/dunit/source

# dmocks-revived
# -----------
#LIB_TEST += $(D_DIR)/DMocks-revived/libdmocks-revived.a
#DCFLAGS_IMPORT_TEST += -I$(D_DIR)/DMocks-revived

LIB_TEST += $(LIB)
DCFLAGS_IMPORT_TEST += $(DCFLAGS_IMPORT)

###############
# Common part
###############
DEFAULT: all

DC = dmd
STATIC_LIB_EXT = .a
STATIC_LIB_PRE = lib
ifeq ($(TARGET),lib)
	NAME_DEBUG = $(STATIC_LIB_PRE)$(STATIC_LIBNAME)d$(STATIC_LIB_EXT)
	NAME_REL = $(STATIC_LIB_PRE)$(STATIC_LIBNAME)$(STATIC_LIB_EXT)
else
	NAME_DEBUG = $(NAME)d
	NAME_REL = $(NAME)
endif

ifeq ($(DC),gdc)
	COMPILER=gdc
	STATIC_LIBNAME=$(NAME)-$(COMPILER)
	WARN_AS_ERR=-Werror
	WARN_AS_MSG=-w
	DBG_CODE=-fdebug
	OUTPUT=-o
	OPTIMIZE=-O2
	LINKERFLAG=-Xlinker
else
	COMPILER=dmd
	STATIC_LIBNAME=$(NAME)
	WARN_AS_MSG=-wi
	WARN_AS_ERR=-w
	#compile in debug code
	DBG_CODE=-debug
	OUTPUT=-of
	OPTIMIZE=-O
	LINKERFLAG=-L
endif

NAME_TEST = test-runner

DSCAN = $(D_DIR)/Dscanner/bin/dscanner
MKDIR = mkdir -p
RM = -rm -f
UPX = upx --no-progress

BITS ?= $(shell getconf LONG_BIT)
DCFLAGS += -m$(BITS)

getSources = $(shell find $(ROOT_SOURCE_DIR) -name "*.d")

# Version flag
# use: make VERS=x
# -----------
VERSION_FLAG += $(if $(VERS), -version=$(VERS), )

.PHONY: all clean clobber test testv run pkg pkgsrc tags syn style loc var ver help release

all: builddir $(BIN)/$(NAME_DEBUG)
release: builddir $(BIN)/$(NAME_REL)

builddir:
	@$(MKDIR) $(BIN)

$(BIN)/$(NAME_DEBUG): $(SRC) $(LIB)| builddir
	$(DC) $^ $(DCFLAGS) $(DCFLAGS_IMPORT) $(DCFLAGS_LINK) $(VERSION_FLAG) $(OUTPUT)$@

$(BIN)/$(NAME_REL): $(SRC) $(LIB)| builddir
	$(DC) $^ $(DCFLAGS_REL) $(DCFLAGS_IMPORT) $(DCFLAGS_LINK) $(VERSION_FLAG) -of$@
ifneq ($(TARGET),lib)
	$(UPX) $@
endif

run: all
	$(BIN)/$(NAME_DEBUG)

## with unit_threaded:
## make test T=test_name
test: build_test
	@$(BIN)/$(NAME_TEST) $(T)

testv: build_test
	@$(BIN)/$(NAME_TEST) -d $(T)

build_test: $(BIN)/$(NAME_TEST)

$(BIN)/$(NAME_TEST): $(SRC_TEST) $(LIB_TEST)| builddir
	$(DC) $^ $(DCFLAGS_TEST) $(DCFLAGS_IMPORT_TEST) $(DCFLAGS_LINK) $(VERSION_FLAG) -of$@

pkgdir:
	$(MKDIR) pkg

pkg: $(PKG) | pkgdir
	tar -jcf pkg/$(NAME)-$(PROJECT_VERSION).tar.bz2 $^
	zip pkg/$(NAME)-$(PROJECT_VERSION).zip $^

pkgsrc: $(PKG_SRC) | pkgdir
	tar -jcf pkg/$(NAME)-$(PROJECT_VERSION)-src.tar.bz2 $^

tags: $(SRC)
	$(DSCAN) --ctags $^ > tags

style: $(SRC)
	$(DSCAN) --styleCheck $^

syn: $(SRC)
	$(DSCAN) --syntaxCheck $^

loc: $(SRC)
	$(DSCAN) --sloc $^

clean:
	$(RM) $(BIN)/*.o
	$(RM) $(BIN)/*.log
	$(RM) $(BIN)/__*
	$(RM) $(BIN)/$(NAME_TEST)

clobber: clean
	$(RM) $(BIN)/$(NAME_REL)
	$(RM) $(BIN)/$(NAME_DEBUG)

ver:
	@echo $(PROJECT_VERSION)

var:
	@echo
	@echo NAME:       $(NAME)
	@echo NAME_DEBUG: $(NAME_DEBUG)
	@echo NAME_REL:   $(NAME_REL)
	@echo TARGET:     $(TARGET)
	@echo PRJ_VER:    $(PROJECT_VERSION)
	@echo
	@echo D_DIR: $(D_DIR)
	@echo BIN:   $(BIN)
	@echo SRC:   $(SRC)
	@echo LIB:   $(LIB)
	@echo
	@echo DC:      $(DC)
	@echo DCFLAGS: $(DCFLAGS)
	@echo DCFLAGS_LINK: $(DCFLAGS_LINK)
	@echo DCFLAGS_IMPORT: $(DCFLAGS_IMPORT)
	@echo VERSION: $(VERSION_FLAG)
	@echo
	@echo ==== test ===
	@echo NAME_TEST: $(NAME_TEST)
	@echo SRC_TEST: $(SRC_TEST)
	@echo DCFLAGS_IMPORT_TEST: $(DCFLAGS_IMPORT_TEST)
	@echo LIB_TEST: $(LIB_TEST)
	@echo
	@echo T: $(T)

# Help Target
help:
	@echo "The following are some of the valid targets for this Makefile:"
	@echo "... all (the default if no target is provided)"
	@echo "... test"
	@echo "... testv Runs unitt_threded test in verbose (-debug) mode"
	@echo "... run"
	@echo "... clean"
	@echo "... clobber"
	@echo "... pkg Generates a binary package"
	@echo "... pkgsrc Generates a source package"
	@echo "... tags Generates tag file"
	@echo "... style Checks programming style"
	@echo "... syn"
	@echo "... upx Compress using upx"
	@echo "... loc Counts lines of code"
	@echo "... var Lists all variables"
