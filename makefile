# makefile release 0.6.0
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


#############
# Funcs     #
#############
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
## Per impostare modalita release
## make rel=y
BUILD = $(if $(or $(rel), $(rl) ), -brelease)

# per compilare con ldc
## make ldc=y
COMPILER = $(if $(or $(ldc), $(rl)), --compiler=ldc)
# make run s=timer:countdown
SUB += $(if $(s), $(NAME):$(s))
DUBFLAGS = -q $(CONFIG) $(BUILD) $(COMPILER) $(SUB)

# si usa cosi:
# make test W=tests.common.testRunOnce
# oppure con piu' parametri
# make test W='tests.common.testRunOnce -d'
WHERE += $(if $(W), $(W))
SEP = $(if $(WHERE), -- )

.PHONY: build force run test testd testc testl btest upx pkgall pkg pkgtar pkgsrc up tags style syn loc clean clobber pb pc pp changelog ver var help

DEFAULT: build

build:
	$(DUB) build $(DUBFLAGS)

force:
	$(DUB) build --force --combined $(DUBFLAGS)

run: build
	$(DUB) run $(DUBFLAGS)

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

upx: build
	$(UPX) $(BIN)/$(NAME)

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

changelog: CHANGELOG.txt
CHANGELOG.txt: CHANGELOG.md
	pandoc -f markdown_github -t plain $^ > $@
ver:
	@echo $(PROJECT_VERSION)

var:
	@echo "General"
	@echo "--------------------"
	@echo "NAME     :" $(NAME)
	@echo "BIN_NAME :" $(BIN_NAME)
	@echo "PRJ_VER  :" $(PROJECT_VERSION)
	@echo "DUBFLAGS :" $(DUBFLAGS)
	@echo
	@echo "Directory"
	@echo "--------------------"
	@echo "D_DIR           :" $(D_DIR)
	@echo "BIN             :" $(BIN)
	@echo "ROOT_SOURCE_DIR :" $(ROOT_SOURCE_DIR)
varsrc:
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
	@echo "   build   : Compiles in debug mode"
	@echo "   force   : Forces a recompilation"
	@echo "   run     : Builds and runs"
	@echo "   test    : Builds and executes the tests"
	@echo "   testd   : Enable debug output"
	@echo "   testc   : Print execution time per test"
	@echo "   testl   : Lists tests"
	@echo "   btest   : Builds tests"
	@echo "   upx     : Makes compressed exe"
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
	@echo "   make rel=y  : Uses 'release' build"
	@echo "   make ldc=y  : Uses 'ldc' compiler"
	@echo "   make rl=y   : Uses 'ldc' compiler and 'release' build"
	@echo "   make s=x    : Uses 's' subpakages"
