#-------------------------------------------------------------------------------
#
# Copyright (c) 2006 Cadence Design Systems, Inc.
#
#-------------------------------------------------------------------------------
#
# FILE : Makefile
#
# Top-Level Makefile for URM kit
#
#-------------------------------------------------------------------------------

LOCALMAKE = gmake

CC_lnx86 = gcc
CC_sol86 = cc
CC_sun4v = cc
CC_ibmrs = xlc
CXX_lnx86 = g++
CXX_sol86 = CC
CXX_sun4v = CC
CXX_ibmrs = xlC
CC = $(CC_$(ARCH))
CXX = $(CXX_$(ARCH))
LD = $(CXX)

MAKEOVERRIDES=

ACTIVITY = optimize

#-------------------------------------------------------------------------------
# Kit info
#

PKDDIR     = ../../../packdef
CNFFILE    = $(PKDDIR)/uvm.cnf
PKDFILE    = $(PKDDIR)/$(KITNAME).pkd

#-------------------------------------------------------------------------------
# Version info #

URM_VERSION = `dvversion $(CNFFILE) | sed -e 's/\.\([a-z]\)/-\1/' | sed -e 's/ //'`


#-------------------------------------------------------------------------------
# directory/compiler info
#

BITS = 32

UVM_ROOTDIR        = $(DV_VOBROOT)/uvm
UVM_LIBDIR         = $(UVM_ROOTDIR)/src/$(KITNAME)/lib
UVM_DPIDIR         = ../src/dpi

INSTALL_MARK_ALL   = $(UVM_LIBDIR)/$(SRC_MARKER) 
INSTALL_MARK_32    = $(INSTALL_MARK_ALL)
INSTALL_MARK_64    = $(INSTALL_MARK_ALL)
INSTALL_MARKERS    = ${INSTALL_MARK_${BITS}}

include $(DV_VOBROOT)/dvproject/Rules.src

SRC_PATH = ${UVM_LIBDIR}

C_SUFFIX = c
CC_SUFFIX = cc
OBJ_SUFFIX = o

X_EXT_32 =
X_EXT_64 = 64.
X_EXT    = ${X_EXT_${BITS}}

X_OBJ_SUFFIX = $(X_EXT)$(OBJ_SUFFIX)

# C_OPT_FLAGS = 
C_OUT_FLAGS = -c -o

BITS_FLAG   = -m${BITS}

UVMLIBNAME = libuvmpli
UVMDPINAME = libuvmdpi

NCROOT = `ncroot`

C_IFLAGS = -I${NCROOT}/tools/inca/include -I. -I${UVM_DPIDIR}

CFLAGS_lnx86_32 = -m32 -shared -fpic -Wall
CFLAGS_lnx86_64 = -m64 -shared -fpic -Wall
CFLAGS_sol86_32 = -DOSCHIP_REV=s10_x86_x86 -xarch=sse2 -D_FILE_OFFSET_BITS=64 -xbuiltin -KPIC
CFLAGS_sol86_64 = -DOSCHIP_REV=s10_x86_x86 -xarch=sse2 -m64 -DSOL86_64 -DLP64BUILD -D_FILE_OFFSET_BITS=64 -xbuiltin -KPIC
CFLAGS_sun4v_32 = -Kpic
CFLAGS_sun4v_64 = -m64 -Kpic 
CFLAGS_ibmrs_32 = -DOSCHIP_REV=aix5_3_0_rs6000 -q32 
CFLAGS_ibmrs_64 = -DOSCHIP_REV=aix5_3_0_rs6000 -q64 

CFLAGS =  ${C_IFLAGS} ${C_OPT_FLAGS} $(CFLAGS_$(ARCH)_$(BITS))

UVM_LDFLAGS_lnx86_32 = -m32 -Wl,-G -shared 
UVM_LDFLAGS_lnx86_64 = -m64 -Wl,-G -shared 
UVM_LDFLAGS_sol86_32 = -dy -G
UVM_LDFLAGS_sol86_64 = -dy -G -m64
UVM_LDFLAGS_sun4v_32 = -dy -G 
UVM_LDFLAGS_sun4v_64 = -m64 -dy -G 
UVM_LDFLAGS_ibmrs_32 = -bexpfull -brtl -bhalt:5 -bmaxdata:0xD0000000/dsa -bnoentry -G \
                   -bI:uvm_import_file -q32 
UVM_LDFLAGS_ibmrs_64 = -bexpfull -brtl -bhalt:5 -bnoentry -G \
                   -bI:uvm_import_file -q64 

UVM_LDFLAGS = $(UVM_LDFLAGS_$(ARCH)_$(BITS))

SHARED_LIB_DIRS =
SHARED_LIBS =

UVM_SOURCES = uvm_registration.c uvm_rbtree.c uvm_user.c uvm_extras.c
UVM_DPI_CCSOURCES = uvm_dpi.cc
UVM_DPI_CSOURCES = 

UVM_COBJECTS = $(UVM_SOURCES:.c=.$(X_OBJ_SUFFIX))
UVM_DPI_COBJECTS = $(UVM_DPI_CSOURCES:.c=.$(X_OBJ_SUFFIX))
UVM_DPI_CCOBJECTS = $(UVM_DPI_CCSOURCES:.cc=.$(X_OBJ_SUFFIX))
UVM_OBJECTS = $(UVM_COBJECTS)

LIB_SUFFIX = so

UVMSHARED_LIB = $(UVMLIBNAME).$(X_EXT)$(LIB_SUFFIX)
UVMDPISHARED_LIB = $(UVMDPINAME).$(X_EXT)$(LIB_SUFFIX)

TARGETS = $(UVMSHARED_LIB) $(UVMDPISHARED_LIB)

all: $(ACTIVITY) $(ACTIVITY)64 package

install: build 

build: $(UVM_SOURCES) $(UVMSHARED_LIB) $(UVMDPISHARED_LIB)

uvm_registration.$(X_OBJ_SUFFIX): uvm_registration.$(C_SUFFIX) $(HEADERS)
	$(CC) $(CFLAGS) $(C_OUT_FLAGS) $@ uvm_registration.$(C_SUFFIX)

uvm_rbtree.$(X_OBJ_SUFFIX): uvm_rbtree.$(C_SUFFIX) $(HEADERS)
	$(CC) $(CFLAGS) $(C_OUT_FLAGS) $@ uvm_rbtree.$(C_SUFFIX)

uvm_user.$(X_OBJ_SUFFIX): uvm_user.$(C_SUFFIX) $(HEADERS)
	$(CC) $(CFLAGS) $(C_OUT_FLAGS) $@ uvm_user.$(C_SUFFIX)

uvm_extras.$(X_OBJ_SUFFIX): uvm_extras.$(C_SUFFIX) $(HEADERS)
	$(CC) $(CFLAGS) $(C_OUT_FLAGS) $@ uvm_extras.$(C_SUFFIX)

uvm_hdl.$(X_OBJ_SUFFIX): $(UVM_DPIDIR)/uvm_hdl.$(C_SUFFIX) $(HEADERS)
	$(CC) $(CFLAGS) $(C_OUT_FLAGS) $@ $(UVM_DPIDIR)/uvm_hdl.c

uvm_svcmd_dpi.$(X_OBJ_SUFFIX): $(UVM_DPIDIR)/uvm_svcmd_dpi.$(C_SUFFIX) $(HEADERS)
	$(CC) $(CFLAGS) $(C_OUT_FLAGS) $@ $(UVM_DPIDIR)/uvm_svcmd_dpi.c

uvm_regex.$(X_OBJ_SUFFIX): $(UVM_DPIDIR)/uvm_regex.$(CC_SUFFIX) $(HEADERS)
	$(CXX) $(CFLAGS) $(C_OUT_FLAGS) $@ $(UVM_DPIDIR)/uvm_regex.cc

uvm_dpi.$(X_OBJ_SUFFIX): $(UVM_DPIDIR)/uvm_dpi.$(CC_SUFFIX) $(HEADERS)
	$(CXX) $(CFLAGS) $(C_OUT_FLAGS) $@ $(UVM_DPIDIR)/uvm_dpi.cc

${UVMSHARED_LIB} : ${UVM_OBJECTS}
	$(CC) $(UVM_OBJECTS) -o $(UVMSHARED_LIB) $(UVM_LDFLAGS) 

${UVMDPISHARED_LIB} : ${UVM_DPI_CCOBJECTS} ${UVM_DPI_COBJECTS}
	$(CXX) ${UVM_DPI_CCOBJECTS} ${UVM_DPI_COBJECTS} -o $(UVMDPISHARED_LIB) $(UVM_LDFLAGS) 

libclean:
	rm -rf *.${OBJ_SUFFIX} *.${LIB_SUFFIX} INCA_libs *.log *.key urm_install.done

#--------------------------#
# OPTIMIZED/RELEASE builds #
#--------------------------#

optimize : 
	C_OPT_FLAGS=""; \
	export C_OPT_FLAGS; \
	$(MAKE) $(CCMAKEOPT) ACTIVITY=$@ BITS=$(BITS) $(BUILDDIRS) install_all

optimize32: optimize

optimize64: 
	C_OPT_FLAGS=""; \
	export C_OPT_FLAGS; \
	$(MAKE) $(CCMAKEOPT) ACTIVITY=optimize BITS=64 $(BUILDDIRS) install_all

#--------------#
# DEBUG builds #
#--------------#

debug : build
	C_OPT_FLAGS="-g"; \
	export C_OPT_FLAGS; \
	$(MAKE) $(CCMAKEOPT) ACTIVITY=$@ BITS=$(BITS) $(BUILDDIRS) install_all

debug32: debug

debug64: build
	C_OPT_FLAGS="-g"; \
	export C_OPT_FLAGS; \
	$(MAKE) $(CCMAKEOPT) ACTIVITY=debug BITS=64 $(BUILDDIRS) install_all

install_all: $(UVMSHARED_LIB) $(UVMDPISHARED_LIB) $(INSTALL_MARKERS) $(EXAMPLE_MARKERS)
	echo "**** install_all: $(INSTALL_MARKERS) $(EXAMPLE_MARKERS)"

clean: libclean

lint:
	@echo "Lint not supported in UVM"

