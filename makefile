# makefile release 0.3.0

PROJECT_VERSION = $(getVer)

#############
# Dirs      #
#############
ROOT_SOURCE_DIR = src
BIN = bin

#############
# Sources   #
#############
SRC = $(getSources)

#############
# Names     #
#############
SDL_FILE = dub.sdl
ifneq ("$(wildcard $(SDL_FILE))","")
NAME = $(getNameSdl)
else
NAME = $(getNameJson)
SDL_FILE = dub.json
endif

#############
# Packages  #
#############
ZIP = name
ZIP_SRC = $(ZIP) $(SRC) $(SDL_FILE) README.md CHANGELOG.md makefile $(SRC_TEST)
ZIP_PREFIX = $(NAME)-$(PROJECT_VERSION)

#############
# Test      #
#############
TEST_SOURCE_DIR = tests
SRC_TEST += $(shell find $(TEST_SOURCE_DIR) -name "*.d")

getSources = $(shell find $(ROOT_SOURCE_DIR) -name "*.d")
getVer = $(shell ag -o --nofilename '\d+\.\d+\.\d+' $(ROOT_SOURCE_DIR)/$(NAME)/semver.d)
#http://stackoverflow.com/questions/1546711/can-grep-show-only-words-that-match-search-pattern#1546735
getNameSdl = $(shell ag -o  'name\s+\"\K[[:alpha:]]+' dub.sdl)
getNameJson = $(shell ag -o -m1 '\"name\":\s+\"\K[[:alpha:]]+' dub.json)

#############
# Commands  #
#############
DUB = dub
DSCAN = $(D_DIR)/Dscanner/bin/dscanner
MKDIR = mkdir -p
RM = -rm -f
UPX = upx --no-progress

#############
# Flags     #
#############
# per impostatare la configurazione conf
# make c=conf
CONFIG += $(if $(c), -c$(c))
BUILD += $(if $(b), -b$(b))
DUBFLAGS = -q $(CONFIG) $(BUILD)

.PHONY: all release force run run-rel test btest upx pkgall pkg pkgtar pkgsrc tags style syn loc clean clobber pb pc pp ver var help

DEFAULT: all

all:
	$(DUB) build $(DUBFLAGS)

release:
	$(DUB) build -brelease $(DUBFLAGS)

force:
	$(DUB) build --force --combined $(DUBFLAGS)

run:
	$(DUB) run $(DUBFLAGS)

run-rel:
	$(DUB) run -brelease $(DUBFLAGS)

test:
	$(DUB) test

btest:
	$(DUB) build -cunittest -q

upx: $(BIN)/$(NAME)
	$(UPX) $^

pkgdir:
	$(MKDIR) pkg

pkgall: pkg pkgtar pkgsrc

pkg: pkgdir | pkg/$(ZIP_PREFIX).zip

pkg/$(ZIP_PREFIX).zip: $(ZIP)
	zip $@ $(ZIP)

pkgtar: pkgdir | pkg/$(ZIP_PREFIX).tar.bz2

pkg/$(ZIP_PREFIX).tar.bz2: $(ZIP)
	tar -jcf $@ $^

pkgsrc: pkgdir | pkg/$(ZIP_PREFIX)-src.tar.bz2

pkg/$(ZIP_PREFIX)-src.tar.bz2: $(ZIP_SRC)
	tar -jcf $@ $^

tags: $(SRC)
	$(DSCAN) --ctags $^ > tags

style: $(SRC)
	$(DSCAN) --styleCheck $^

syn: $(SRC)
	$(DSCAN) --syntaxCheck $^

loc: $(SRC)
	$(DSCAN) --sloc $^

clean:
	$(DUB) clean

clobber: clean
	$(RM) $(BIN)/$(NAME)
	$(RM) $(BIN)/*.log
	$(RM) $(BIN)/test-runner

pb:
	@$(DUB) build  --print-builds
pc:
	$(DUB) build  --print-configs
pp:
	$(DUB) build  --print-platform

ver:
	@echo $(PROJECT_VERSION)

var:
	@echo NAME:       $(NAME)
	@echo PRJ_VER:    $(PROJECT_VERSION)
	@echo DUBFLAGS:   $(DUBFLAGS)
	@echo
	@echo ==== dir ===
	@echo D_DIR: $(D_DIR)
	@echo BIN:   $(BIN)
	@echo ROOT_SOURCE_DIR: $(ROOT_SOURCE_DIR)
	@echo TEST_SOURCE_DIR: $(TEST_SOURCE_DIR)
	@echo
	@echo ==== zip ===
	@echo ZIP: $(ZIP)
	@echo ZIP_SRC: $(ZIP_SRC)
	@echo ZIP_PREFIX: $(ZIP_PREFIX)
	@echo 
	@echo ==== src ===
	@echo SRC:   $(SRC)

# Help Target
help:
	@echo "The following are some of the valid targets for this Makefile:"
	@echo "Compile"
	@echo "...................."
	@echo "... all (the default if no target is provided)"
	@echo "... release Compiles in release mode"
	@echo "... force  Forces a recompilation"
	@echo "... run Builds and runs"
	@echo "... test Build and executes the tests"
	@echo "... btest Build the tests"
	@echo "... upx Compress using upx"
	@echo ""
	@echo "Pack"
	@echo "...................."
	@echo "... pkgall Executes pkg, pkgtar, pkgsrc"
	@echo "... pkg Zip binary"
	@echo "... pkgtar Tar binary"
	@echo "... pkgsrc Tar source"
	@echo ""
	@echo "Utility"
	@echo "...................."
	@echo "... tags Generates tag file"
	@echo "... style Checks programming style"
	@echo "... syn Syntax check"
	@echo "... loc Counts lines of code"
	@echo "... clean Removes intermediate build files"
	@echo "... clobber"
	@echo ""
	@echo "Print"
	@echo "...................."
	@echo "... pb Prints the list of available build types"
	@echo "... pc Prints the list of available configurations"
	@echo "... pp Prints the identifiers for the current build platform as used for the build fields"
	@echo "... ver Prints version"
	@echo "... var Lists all variables"
