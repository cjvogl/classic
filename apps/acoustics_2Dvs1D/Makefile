#
# This a modified version of Makefile.common for the clawpack code
#
# See the end of this file for a summary, or type "make help".


# General makefile settings
SHELL = /bin/sh
INSTALL_PROGRAM ?= $(INSTALL)
INSTALL_DATA ?= $(INSTALL) -m 644

# Fortran compiler:  FC may be set as an environment variable or in make
# file that 'includes' this one.  Otherwise assume gfortran.
FC ?= gfortran
ifeq ($(FC),f77)
	# make sometimes sets FC=f77 if it is not set as environment variable
	# reset to gfortran since f77 will not work.
	FC = gfortran
endif

CLAW_FC ?= $(FC)
LINK ?= $(CLAW_FC)

# Path to version of python to use:  May need to use something other than
# the system default in order for plotting to work.  Can set CLAW_PYTHON as
# environment variable or in make file that 'includes' this one.
PYTHON ?= python
CLAW_PYTHON ?= $(PYTHON)

# Variables below should be set in Makefile that "includes" this one.
# Default values if not set:
EXE = xclaw
EXE1D = xclaw1d
CLAW_PKG = classic
OUTDIR = _output
PLOTDIR = _plots
LIB_PATHS ?= $(CURDIR)/
OVERWRITE ?= True
RESTART ?= False
GIT_STATUS ?= False
SETRUN_FILE = setrun.py
SETRUN_FILE1D = setrun1d.py
SETRUN_FILE2D = setrun2d.py
SETPLOT_FILE = setplot.py
NOHUP ?= False
NICE ?= None

OUTDIR1D = $(OUTDIR)1d
#----------------------------------------------------------------------------
# Lists of source, modules, and objects
LIB:=$(CLAW)/classic/src/2d
COMMON_SOURCES = \
  $(LIB)/setaux.f90 \
  $(LIB)/driver.f90 \
  $(LIB)/claw2ez.f \
  $(LIB)/claw2.f \
  $(LIB)/bc2.f \
  $(LIB)/b4step2.f90 \
  $(LIB)/step2.f90 \
  $(LIB)/step2ds.f90 \
  $(LIB)/dimsp2.f \
  $(LIB)/flux2.f90 \
  $(LIB)/copyq2.f \
  $(LIB)/inlinelimiter.f90 \
  $(LIB)/src2.f90 \
  $(LIB)/out2.f \
  $(LIB)/restart2.f \
  $(LIB)/opendatafile.f

COMMON_MODULES ?=
SOURCES = \
  ic.f \
  qinit.f \
	setprob.f \
	$(CLAW)/riemann/src/rpn2_acoustics.f90 \
	$(CLAW)/riemann/src/rpt2_acoustics.f90
MODULES ?=
EXCLUDE_SOURCES ?=
EXCLUDE_MODULES ?=

LIB1D:=$(CLAW)/classic/src/1d
COMMON_SOURCES1D = \
  $(LIB1D)/setaux.f90 \
  $(LIB1D)/bc1.f \
  $(LIB1D)/b4step1.f90 \
  $(LIB1D)/driver.f90 \
  $(LIB1D)/claw1ez.f \
  $(LIB1D)/claw1.f \
  $(LIB1D)/copyq1.f \
  $(LIB1D)/inlinelimiter.f90 \
  $(LIB1D)/opendatafile.f \
  $(LIB1D)/out1.f \
  $(LIB1D)/step1.f90

COMMON_MODULES1D ?=
SOURCES1D = \
  ic.f \
  qinit1d.f \
	src1d.f \
	setprob1d.f \
	$(CLAW)/riemann/src/rp1_acoustics.f90
MODULES1D ?=
EXCLUDE_SOURCES1D ?=
EXCLUDE_MODULES1D ?=

#consolidate custom and common sources into a single list for compilations
SOURCES := $(shell python $(CLAW)/clawutil/src/checkSources.py \
		$(COMMON_SOURCES) ";" $(EXCLUDE_SOURCES) ";" $(SOURCES))
MODULES := $(shell python $(CLAW)/clawutil/src/checkSources.py \
		$(COMMON_MODULES) ";" $(EXCLUDE_MODULES) ";" $(MODULES))

SOURCES1D := $(shell python $(CLAW)/clawutil/src/checkSources.py \
		$(COMMON_SOURCES1D) ";" $(EXCLUDE_SOURCES1D) ";" $(SOURCES1D))
MODULES1D := $(shell python $(CLAW)/clawutil/src/checkSources.py \
		$(COMMON_MODULES1D) ";" $(EXCLUDE_MODULES1D) ";" $(MODULES1D))


# Make list of .o files required from the sources above:
OBJECTS = $(subst .F,.o, $(subst .F90,.o, $(subst .f,.o, $(subst .f90,.o, $(SOURCES)))))
MODULE_FILES = $(subst .F,.mod, $(subst .F90,.mod, $(subst .f,.mod, $(subst .f90,.mod, $(MODULES)))))
# FYI: Sort weeds out duplicate paths
MODULE_PATHS = $(sort $(dir $(MODULE_FILES)))
MODULE_OBJECTS = $(subst .F,.o, $(subst .F90,.o, $(subst .f,.o, $(subst .f90,.o, $(MODULES)))))

OBJECTS1D = $(subst .F,.o, $(subst .F90,.o, $(subst .f,.o, $(subst .f90,.o, $(SOURCES1D)))))
MODULE_FILES1D = $(subst .F,.mod, $(subst .F90,.mod, $(subst .f,.mod, $(subst .f90,.mod, $(MODULES1D)))))
# FYI: Sort weeds out duplicate paths
MODULE_PATHS1D = $(sort $(dir $(MODULE_FILES1D)))
MODULE_OBJECTS1D = $(subst .F,.o, $(subst .F90,.o, $(subst .f,.o, $(subst .f90,.o, $(MODULES1D)))))


#----------------------------------------------------------------------------
# Compiling, linking, and include flags
# User set flags, empty if not set
INCLUDE ?=
FFLAGS ?=
LFLAGS ?= $(FFLAGS)
PPFLAGS ?=

INCLUDE1D ?=

# These will be included in all actual compilation and linking, one could
# actually overwrite these before hand but that is not the intent of these
# variables
ALL_INCLUDE ?=
ALL_FFLAGS ?=
ALL_LFLAGS ?=

ALL_INCLUDE1D ?=

# Add includes, the module search paths and library search paths are appended
# at the end of the ALL_INCLUDE variable so that INCLUDE can override any of
# the default settings
ALL_INCLUDE += $(addprefix -I,$(INCLUDE))
ALL_INCLUDE += $(addprefix -I,$(MODULE_PATHS)) $(addprefix -L,$(LIB_PATHS))

ALL_INCLUDE1D += $(addprefix -I,$(INCLUDE1D))
ALL_INCLUDE1D += $(addprefix -I,$(MODULE_PATHS1D)) $(addprefix -L,$(LIB_PATHS))

# ALL_FFLAGS and ALL_LFLAGS currently only includes the user defined flags
ALL_FFLAGS += $(FFLAGS) $(PPFLAGS)
ALL_LFLAGS += $(LFLAGS)

# Module flag setting, please add other compilers here as necessary
ifeq ($(findstring gfortran,$(CLAW_FC)),gfortran)
	# There should be no space between this flag and the argument
	MODULE_FLAG = -J
	OMP_FLAG = -fopenmp
else ifeq ($(CLAW_FC),ifort)
	# Note that there shoud be a space after this flag
	MODULE_FLAG = -module
	OMP_FLAG = -openmp
else
	# Assume gcc like flagging, probably should raise an error here
	MODULE_FLAG = -J
	OMP_FLAG = -fopenmp
endif

# We may want to set MAKELEVEL here as it is not always set but we know we are
# not the first level (the original calling Makefile should be MAKELEVEL = 0)
# MAKELEVEL ?= 0

#----------------------------------------------------------------------------
# Targets that do not correspond to file names:
.PHONY: .objs .exe clean clobber new all output plots;

# Reset suffixes that we understand
.SUFFIXES:
.SUFFIXES: .f90 .f .mod .o

# Default Rules, the module rule should be executed first in most instances,
# this way the .mod file ends up always in the correct spot
%.mod : %.f90 ; touch $@; $(CLAW_FC) -c -cpp $< $(MODULE_FLAG)$(@D) $(ALL_INCLUDE) $(ALL_FFLAGS) -o $*.o
%.mod : %.f   ; touch $@; $(CLAW_FC) -c -cpp $< $(MODULE_FLAG)$(@D) $(ALL_INCLUDE) $(ALL_FFLAGS) -o $*.o

%.o : %.f90 ;             $(CLAW_FC) -c -cpp $< 					$(ALL_INCLUDE) $(ALL_FFLAGS) -o $@
%.o : %.f ;               $(CLAW_FC) -c -cpp $< 					$(ALL_INCLUDE) $(ALL_FFLAGS) -o $@

#----------------------------------------------------------------------------
# Executable:

.objs:  $(MODULE_FILES) $(OBJECTS);

# The order here is to again build the module files correctly
$(EXE): $(MODULE_FILES) $(MODULE_OBJECTS) $(OBJECTS) $(MAKEFILE_LIST) ;
	$(LINK) $(MODULE_OBJECTS) $(OBJECTS) $(ALL_INCLUDE) $(ALL_LFLAGS) -o $(EXE)
$(EXE1D): $(MODULE_FILES1D) $(MODULE_OBJECTS1D) $(OBJECTS1D) $(MAKEFILE_LIST) ;
		$(LINK) $(MODULE_OBJECTS1D) $(OBJECTS1D) $(ALL_INCLUDE1D) $(ALL_LFLAGS) -o $(EXE1D)

.exe: $(EXE);
		$(MAKE) exe1d

exe1d: $(EXE1D);

exe2d: $(EXE);

debug:
	@echo 'debugging -- MODULES:'
	@echo $(MODULES)
	@echo 'debugging -- MODULE_FILES:'
	@echo $(MODULE_FILES)
	@echo 'debugging -- MODULE_PATHS:'
	@echo $(MODULE_PATHS)

#----------------------------------------------------------------------------

# Command to create *.html files from *.f etc:
CC2HTML = $(CLAW_PYTHON) $(CLAW)/clawutil/src/python/clawutil/clawcode2html.py --force

# make list of html files to be created by 'make .htmls':
HTML = \
  $(subst .f,.f.html,$(wildcard *.f)) \
  $(subst .f95,.f95.html,$(wildcard *.f95)) \
  $(subst .f90,.f90.html,$(wildcard *.f90)) \
  $(subst .m,.m.html,$(wildcard *.m)) \
  $(subst .py,.py.html,$(wildcard *.py)) \
  $(subst .data,.data.html,$(wildcard *.data)) \
  $(subst .txt,.html,$(wildcard *.txt)) \
  $(subst .sh,.sh.html,$(wildcard *.sh)) \
  Makefile.html

# Rules to make html files:
# e.g. qinit.f --> qinit.f.html
%.f.html : %.f ; $(CC2HTML) $<
%.f95.html : %.f95 ; $(CC2HTML) $<
%.f90.html : %.f90 ; $(CC2HTML) $<
%.m.html : %.m ; $(CC2HTML) $<
%.py.html : %.py ; $(CC2HTML) $<
%.data.html : %.data ; $(CC2HTML) $<
%.sh.html : %.sh ; $(CC2HTML) $<
Makefile.html : Makefile ; $(CC2HTML) $<
# drop .txt extension, e.g. README.txt --> README.html
%.html : %.txt ; $(CC2HTML) --dropext $<

.htmls: $(HTML) ;
	$(CLAW_PYTHON) $(CLAW)/clawutil/src/python/clawutil/convert_readme.py

#----------------------------------------------------------------------------
# Run the code and put fort.* files into subdirectory named output:
# runclaw will execute setrun.py to create data files and determine
# what executable to run, e.g. xclaw or xamr.
.output: .output1d; $(MAKE) .output2d;

.output1d: $(EXE1D) $(SETRUN_FILE) $(SETRUN_FILE1D)
	$(MAKE) output1d;

.output2d: $(EXE) $(SETRUN_FILE) $(SETRUN_FILE2D);
	$(MAKE) output2d;

#----------------------------------------------------------------------------
# Run the code without checking dependencies:
output1d: $(MAKEFILE_LIST);
	-rm -f .output1d
	$(CLAW_PYTHON) $(SETRUN_FILE1D) $(CLAW_PKG)
	$(CLAW_PYTHON) $(CLAW)/clawutil/src/python/clawutil/runclaw.py $(EXE1D) $(OUTDIR1D) \
	$(OVERWRITE) $(RESTART) . $(GIT_STATUS) $(NOHUP) $(NICE)
	@echo $(OUTDIR1D) > .output1d

output2d: $(MAKEFILE_LIST);
	-rm -f .output2d
	$(CLAW_PYTHON) $(SETRUN_FILE2D) $(CLAW_PKG)
	$(CLAW_PYTHON) $(CLAW)/clawutil/src/python/clawutil/runclaw.py $(EXE) $(OUTDIR) \
	$(OVERWRITE) $(RESTART) . $(GIT_STATUS) $(NOHUP) $(NICE)
	@echo $(OUTDIR) > .output2d

#----------------------------------------------------------------------------
# Compute errors from _output and _output1d directories
.errors: .output1d; $(MAKE) .output2d; $(MAKE) errors;

errors: $(MAKEFILE_LIST);
	-rm -f .errors
	$(CLAW_PYTHON) ./compute_errors.py
	@echo $(OUTDIR) > .errors

#----------------------------------------------------------------------------

# Python command to create plots:

# (Removed Cygwin stuff...)
# Plotting command
PLOTCMD ?= $(CLAW_PYTHON) $(CLAW)/visclaw/src/python/visclaw/plotclaw.py

# Rule to make the plots into subdirectory specified by PLOTDIR,
# using data in subdirectory specified by OUTDIR and the plotting
# commands specified in SETPLOT_FILE.
.plots: .errors $(SETPLOT_FILE) $(MAKEFILE_LIST) ;
	$(MAKE) plots -f $(MAKEFILE_LIST)

# Make the plots without checking dependencies
# This has to use its own plot command to skip the check for .output
plots: $(SETPLOT_FILE) $(MAKEFILE_LIST);
	-rm -f .plots
	$(PLOTCMD) $(OUTDIR) $(PLOTDIR) $(SETPLOT_FILE)
	@echo $(PLOTDIR) > .plots

#----------------------------------------------------------------------------

# Rule to make full program by catenating all source files.
# Sometimes useful for debugging:
# Note that this will probably not compile due to mixed source forms

.program:  $(MODULES) $(SOURCES) $(MAKEFILE_LIST);
	cat  $(MODULES) $(SOURCES) claw_program.f90
	touch .program

#----------------------------------------------------------------------------

# Recompile everything:

# Note that we reset MAKELEVEL to 0 here so that we make sure to set the
# preprocessor flags correctly
new: $(MAKEFILE_LIST)
	-rm -f  $(OBJECTS)
	-rm -f  $(MODULE_OBJECTS)
	-rm -f  $(MODULE_FILES)
	-rm -f  $(EXE)
	$(MAKE) $(EXE) MAKELEVEL=0 -f $(MAKEFILE_LIST)


# Clean up options:
clean:
	-rm -f $(EXE) $(HTML)
	-rm -f .output1d .output2d .errors .plots .htmls

clobber:
	$(MAKE) clean -f $(MAKEFILE_LIST)
	-rm -f $(OBJECTS)
	-rm -f $(MODULE_OBJECTS)
	-rm -f $(MODULE_FILES)
	-rm -f fort.*  *.pyc pyclaw.log
	-rm -f -r $(OUTDIR) $(PLOTDIR)

#----------------------------------------------------------------------------

# Default option that may be redefined in the application Makefile:
all: $(MAKEFILE_LIST)
	$(MAKE) .plots -f $(MAKEFILE_LIST)
	$(MAKE) .htmls -f $(MAKEFILE_LIST)

#----------------------------------------------------------------------------

help:
	@echo '   "make .objs"    to compile object files'
	@echo '   "make .exe"     to create executable'
	@echo '   "make .data"    to create data files using setrun.py'
	@echo '   "make .output"  to run code'
	@echo '   "make output"   to run code with no dependency checking'
	@echo '   "make .plots"   to produce plots'
	@echo '   "make plots"    to produce plots with no dependency checking'
	@echo '   "make .htmls"   to produce html versions of files'
	@echo '   "make .program" to produce single program file'
	@echo '   "make new"      to remove all objs and then make .exe'
	@echo '   "make clean"    to clean up compilation and html files'
	@echo '   "make clobber"  to also clean up output and plot files'
	@echo '   "make help"     to print this message'

.help: help
