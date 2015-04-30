NAME = libendovena.a
VERSION = 0.1.0

ROOT_SOURCE_DIR = src
SRC = $(getSources) 
SRC_TEST = $(filter-out $(ROOT_SOURCE_DIR)/app.d, $(SRC)) 
SRC_TEST += $(wildcard tests/*.d)

# Compiler flag
# -----------
DCFLAGS += -lib
DCFLAGS += -debug #compile in debug code
#DCFLAGS += -g # add symbolic debug info
#DCFLAGS += -w # warnings as errors (compilation will halt)
DCFLAGS += -wi # warnings as messages (compilation will continue)

# release flags
DCFLAGS_REL = -O -wi -release -inline -boundscheck=off

DCFLAGS_TEST += -unittest
# Linker flag
# -----------
# DCFLAGS_LINK += 
# DCFLAGS_LINK += -L-L/usr/lib/

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

include common.mk
