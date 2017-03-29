# makefile release 0.5.0
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
NAME = $(getNameSdl)
BIN_NAME = $(BIN)/lib$(NAME).a

#############
# Packages  #
#############
ZIP_BIN = $(BIN_NAME)
ZIP_SRC = $(ZIP_BIN) $(SRC) $(SDL_FILE) README.md CHANGELOG.md makefile
ZIP_SRC += tests/*.d
ZIP_PREFIX = $(NAME)-$(PROJECT_VERSION)


getSources = $(shell find $(ROOT_SOURCE_DIR) -name "*.d")

getVer = $(shell ag -o --nofilename '\d+\.\d+\.\d+(-\w+\.\d)?' $(ROOT_SOURCE_DIR)/$(NAME)/semver.d)
#http://stackoverflow.com/questions/1546711/can-grep-show-only-words-that-match-search-pattern#1546735
getNameSdl = $(shell ag -m1 --silent -o 'name\s+\"\K\w+' dub.sdl)

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
# per debug
# make b=debug
CONFIG += $(if $(c), -c$(c))
BUILD += $(if $(b), -b$(b))
# make run s=timer:countdown
SUB += $(if $(s), $(NAME):$(s))
DUBFLAGS = -q $(CONFIG) $(BUILD) $(SUB)

# si usa cosi:
# make test W=tests.common.testRunOnce
# oppure con piu' parametri
# make test W='tests.common.testRunOnce -d'
WHERE += $(if $(W), $(W))
SEP = $(if $(WHERE), -- )

.PHONY: all release force run run-rel test btest upx dx rx pkgall pkg pkgtar pkgsrc up tags style syn loc clean clobber pb pc pp ver var help

DEFAULT: all

all:
	$(DUB) build $(DUBFLAGS)

build-ldc:
	$(DUB) build $(DUBFLAGS) --compiler=ldc

release:
	$(DUB) build -brelease $(DUBFLAGS)

rel-ldc:
	$(DUB) build -brelease --compiler=ldc $(DUBFLAGS)

force:
	$(DUB) build --force --combined $(DUBFLAGS)

run:
	$(DUB) run $(DUBFLAGS)
run-rel:
	$(DUB) run -brelease $(DUBFLAGS)

test:
	$(DUB) test -q $(SEP) $(WHERE)
testd:
	$(DUB) test -q -- -d $(WHERE)
testc:
	$(DUB) test -q -- -c $(WHERE)
testl:
	$(DUB) test -q -- -l

btest:
	$(DUB) build -cunittest -q

dx: all upx
rx: release upx
upx: $(BIN)/$(NAME)
	$(UPX) $^

pkgdir:
	$(MKDIR) pkg

pkgall: pkg pkgtar pkgsrc

pkg: pkgdir | pkg/$(ZIP_PREFIX).zip

pkg/$(ZIP_PREFIX).zip: $(ZIP_BIN)
	zip $@ $(ZIP_BIN)

pkgtar: pkgdir | pkg/$(ZIP_PREFIX).tar.bz2

pkg/$(ZIP_PREFIX).tar.bz2: $(ZIP_BIN)
	tar -jcf $@ $^

pkgsrc: pkgdir | pkg/$(ZIP_PREFIX)-src.tar.bz2

pkg/$(ZIP_PREFIX)-src.tar.bz2: $(ZIP_SRC)
	tar -jcf $@ $^

up:
	$(DUB) upgrade

tags: $(SRC)
	$(DSCAN) --ctags $^ > tags

style: $(SRC)
	$(DSCAN) --styleCheck $^

syn: $(SRC)
	$(DSCAN) --syntaxCheck $^

loc: $(SRC)
	$(DSCAN) --sloc $^

imp: $(SRC)
	$(DSCAN) -i $^

clean:
	$(DUB) clean

clobber: clean
	$(RM) $(BIN_NAME)
	$(RM) $(BIN)/*.log
	$(RM) $(BIN)/test-runner

pb:
	@$(DUB) build --print-builds
pc:
	$(DUB) build --print-configs
pp:
	$(DUB) build --print-platform

changelog: CHANGELOG.txt
CHANGELOG.txt: CHANGELOG.md
	pandoc -f markdown_github -t plain $^ > $@

ver:
	@echo $(PROJECT_VERSION)

var:
	@echo
	@echo "General"
	@echo "--------------------"
	@echo "NAME     :" $(NAME)
	@echo "BIN_NAME :" $(BIN_NAME)
	@echo "PRJ_VER  :" $(PROJECT_VERSION)
	@echo "DUBFLAGS :" $(DUBFLAGS)
	@echo "DUB FILE :" $(SDL_FILE)
	@echo
	@echo "Directory"
	@echo "--------------------"
	@echo "D_DIR           :" $(D_DIR)
	@echo "BIN             :" $(BIN)
	@echo "ROOT_SOURCE_DIR :" $(ROOT_SOURCE_DIR)
	@echo "TEST_SOURCE_DIR :" $(TEST_SOURCE_DIR)
	@echo
	@echo "Zip"
	@echo "--------------------"
	@echo "ZIP_BIN    : " $(ZIP_BIN)
	@echo "ZIP_PREFIX :" $(ZIP_PREFIX)
	@echo 
	@echo "Zip source"
	@echo "--------------------"
	@echo $(ZIP_SRC)
	@echo
	@echo "Source"
	@echo "--------------------"
	@echo $(SRC)
	@echo

# Help Target
help:
	@echo "The following are some of the valid targets for this Makefile:"
	@echo "Compile"
	@echo "--------------------"
	@echo "   all     : (the default if no target is provided)"
	@echo "   release : Compiles in release mode"
	@echo "   rel-ldc : Compiles in release mode with ldc compiler"
	@echo "   force   : Forces a recompilation"
	@echo "   run     : Builds and runs"
	@echo "   test    : Build and executes the tests"
	@echo "   testd   : Build and executes the tests in debug mode"
	@echo "   testc   : Build and executes the tests with execution time"
	@echo "   btest   : Build the tests"
	@echo "   upx     : Compress using upx"
	@echo "   dx      : Make debug and compress using upx"
	@echo "   rx      : Make release and compress using upx"
	@echo ""
	@echo "Pack"
	@echo "--------------------"
	@echo "   pkgall : Executes pkg, pkgtar, pkgsrc"
	@echo "   pkg    : Zip binary"
	@echo "   pkgtar : Tar binary"
	@echo "   pkgsrc : Tar source"
	@echo ""
	@echo "Utility"
	@echo "--------------------"
	@echo "   up      : Forces an upgrade of all dub dependencies"
	@echo "   tags    : Generates tag file"
	@echo "   style   : Checks programming style"
	@echo "   syn     : Syntax check"
	@echo "   loc     : Counts lines of code"
	@echo "   clean   : Removes intermediate build files"
	@echo "   clobber : Removes all"
	@echo ""
	@echo "Print"
	@echo "--------------------"
	@echo "   pb  : Prints the list of available build types"
	@echo "   pc  : Prints the list of available configurations"
	@echo "   pp  : Prints the identifiers for the current build platform as used for the build fields"
	@echo "   ver : Prints version"
	@echo "   var : Lists all variables"
	@echo ""
	@echo "Common options"
	@echo "--------------------"
	@echo "   make c=conf  : Uses 'conf' configuration"
	@echo "   make b=debug : Uses 'debug' build"
	@echo "   make s=y     : Uses 'y' subpakages"
