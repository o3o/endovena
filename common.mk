###############
# Common part
###############
DEFAULT: all
BIN = bin
DC = dmd
NAME_TEST = test-runner
NAME_DEBUG = $(NAME)d
NAME_REL = $(NAME)

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
	$(DC) $^ $(DCFLAGS) $(DCFLAGS_IMPORT) $(DCFLAGS_LINK) $(VERSION_FLAG) -of$@

$(BIN)/$(NAME_REL): $(SRC) $(LIB)| builddir
	$(DC) $^ $(DCFLAGS_REL) $(DCFLAGS_IMPORT) $(DCFLAGS_LINK) $(VERSION_FLAG) -of$@
	$(UPX) $@

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
	tar -jcf pkg/$(NAME)-$(VERSION).tar.bz2 $^
	zip pkg/$(NAME)-$(VERSION).zip $^

pkgsrc: $(PKG_SRC) | pkgdir
	tar -jcf pkg/$(NAME)-$(VERSION)-src.tar.bz2 $^

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
	@echo $(VERSION)

var:
	@echo
	@echo NAME:       $(NAME)
	@echo NAME_TEST:  $(NAME_TEST)
	@echo NAME_DEBUG: $(NAME_REL)
	@echo NAME_REL:   $(NAME_REL)
	@echo
	@echo D_DIR:$(D_DIR)
	@echo SRC:$(SRC)
	@echo DCFLAGS_IMPORT: $(DCFLAGS_IMPORT)
	@echo LIB: $(LIB)
	@echo
	@echo DCFLAGS: $(DCFLAGS)
	@echo DCFLAGS_LINK: $(DCFLAGS_LINK)
	@echo VERSION: $(VERSION_FLAG)
	@echo
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
