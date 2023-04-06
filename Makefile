# Makefile to compile samall projects in fortran/C/C++
#
# Sources. See:
#
# http://make.mad-scientist.net/papers/advanced-auto-dependency-generation/ (see references therein)
# https://www.gnu.org/software/make/manual/html_node/Automatic-Prerequisites.html (see references therein)
# http://nuclear.mutantstargoat.com/articles/make/ by John Tsiombikas nuclear@member.fsf.org
#
# So all the credits go to these guys!!!
#
# Use:
# 
# Create a folder to hold your project, for example
# 		~$ mkdir my_project
# and copy this makefile there
#			~$ cp Makefile ~/my_project/
# In addition, create two subfolders, include 
#		 	~$ mkdir ~/my_project/include
# to place your include (.h, .hh) files, and a folder src
# 		~$ mkdir ~/my_project/src
# to place your source (.c, .cc, .cpp) files.
#
# Then, to build you project just cd to the project folder, i.e.,
# 	~$ cd ~/my_project
# and run make
# 	~/my_project~$ make 
# then a new folder (bin) is created with the executable file 
# (my_project) inside. To run the executable my_project form the 
# project folder just do
# 	~/my_project~$ ./bin/my_project
#
# Other actions:
#
# To delete the .o (object) and .d (dependence) files
# 	~/my_project~$ make clean
# To remove .o .d and the directory bin witht the executable file
#	~/my_project~$ make mrproper
#	To see all the line parameters we can pass to the command make,
#	call
#		~/my_project~$ make help

PROG=$(notdir $(CURDIR))#name of the project
EXEDIR=       bin
SRCDIR=       src
HDIR =        include
OBJDIR=       .o
DEPDIR=       .d

CC= gcc
CXX= g++

CCFLAGS= -g -O0 -W -fPIC 
CCLIBS=	#-lm -lgmp -lmpfr 

CXXFLAGS= -g -O0 -W -fPIC
CXXLIBS= #-lm -lgmp -lmpfr

FC= gfortran
FFLAGS= -g -O3 -std=legacy -Wall -Wextra -Wconversion
FFLIBS=

CPPFLAGS+= -cpp -MMD -MP -MF $(DEPDIR)/$*.Td 
LDFLAGS+=      

ifdef OS
    $(shell mkdir $(OBJDIR) 2>NUL:)
    $(shell mkdir $(DEPDIR) 2>NUL:)
		$(shell mkdir $(EXEDIR) 2>NUL:)
    PROG:=$(PROG).exe
    MV = move
    POSTCOMPILE = $(MV) $(DEPDIR)\$*.Td $(DEPDIR)\$*.d 2>NUL
    RMFILES = del /Q /F $(OBJDIR)\*.o $(DEPDIR)\*.d 2>NUL
    RMDIR = rd $(OBJDIR) $(DEPDIR) 2>NUL
    RUN=$(EXEDIR)\$(PROG)
    RMEXE= del /Q /F $(EXEDIR) 2>NUL
    USE=Use:
    USE.HELP='make help', to see other options.
    USE.BUILD='make', to build the executable, $(EXEDIR)\$(PROG).
    USE.CLEAN='make clean', to delete the object and dep files.
    USE.MRPROPER='make mrproper', to delete the directory with the executable as well.
    ECHO=@echo.
else 
    ifeq ($(filter $(shell uname), "Linux" "Darwin"),)
        $(shell mkdir -p $(OBJDIR) >/dev/null)
        $(shell mkdir -p $(DEPDIR) >/dev/null)
        $(shell mkdir -p $(EXEDIR) >/dev/null)
        MV = mv -f
        POSTCOMPILE = $(MV) $(DEPDIR)/$*.Td $(DEPDIR)/$*.d
        RMFILES = $(RM) $(OBJDIR)/*.o $(DEPDIR)/*.d
        RMDIR = rmdir $(OBJDIR) $(DEPDIR)
        RUN= ./$(EXEDIR)/$(PROG)
        RMEXE = rm -rf $(EXEDIR)
        USE="Use:"
        USE.HELP="      'make help', to see other options."
        USE.BUILD="     'make', to build the executable, $(EXEDIR)/$(PROG)."
        USE.CLEAN="     'make clean', to delete the object and dep files."
        USE.MRPROPER="     'make mrproper', to delete the executable as well."
        ECHO=@echo
				ifeq ($(shell uname), Darwin)
					CC= gcc-12
					CXX= g++-12
				  CCFLAGS+= -I/opt/homebrew/include
				  CCLIBS+= -L/opt/homebrew/lib #-lm -lgmp -lmpfr
					CXXFLAGS+= -I/opt/homebrew/include
					CXXLIBS+= -L/opt/homebrew/lib #-lm -lgmp -lmpfr
		  	endif
    endif
endif

SRCS_ALL=$(wildcard $(SRCDIR)/*.c)
SRCS_ALL+=$(wildcard $(SRCDIR)/*.cc)
SRCS_ALL+=$(wildcard $(SRCDIR)/*.f)

SRCS=$(filter-out %_flymake.c, $(notdir $(basename $(SRCS_ALL))))
SRCS+=$(filter-out %_flymake.cc, $(notdir $(basename $(SRCS_ALL))))
SRCS+=$(filter-out %_flymake.f, $(notdir $(basename $(SRCS_ALL))))

OBJS=$(patsubst %,$(OBJDIR)/%.o,$(SRCS))
DEPS=$(patsubst %,$(DEPDIR)/%.d,$(SRCS))

# Note: -std=legacy.  We use std=legacy to compile fortran 77
#
all: $(EXEDIR)/$(PROG)

$(EXEDIR)/$(PROG): $(OBJS)
	$(CXX) -o $@ $^ $(LDFLAGS) $(CXXLIBS) $(CCLIBS) $(FFLIBS)
	$(ECHO)
	$(ECHO) $(PROG) built in directory $(EXEDIR)
	$(ECHO)
#	$(ECHO) $(USE)
#	$(ECHO)      $(USE.HELP)
#	$(ECHO)

run: $(EXEDIR)/$(PROG)
	$(RUN)

help:
	$(ECHO)
	$(ECHO) $(USE)
	$(ECHO)      $(USE.BUILD)
	$(ECHO)      $(USE.CLEAN)
	$(ECHO)      $(USE.MRPROPER)
	$(ECHO)

filter:
	$(ECHO) $(SRCS_ALL)
	$(ECHO) "== filter example =="
	$(ECHO) "filter: " $(filter %_flymake.cc, $(SRCS_ALL))
	$(ECHO) "filter-out: $(filter-out %_flymake.c, $(SRCS_ALL))"
	$(ECHO)

clean:
	$(RMFILES)
	$(RMDIR)

mrproper: clean
	$(RMEXE)

$(OBJDIR)/%.o: $(SRCDIR)/%.c $(DEPDIR)/%.d
	$(CC) $(CCFLAGS) $(CPPFLAGS) -I$(HDIR) -c $< -o$@
	$(POSTCOMPILE)

$(OBJDIR)/%.o: $(SRCDIR)/%.cc $(DEPDIR)/%.d
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -I$(HDIR) -c $< -o$@
	$(POSTCOMPILE)

$(OBJDIR)/%.o: $(SRCDIR)/%.f $(DEPDIR)/%.d
	$(FC) $(FFLAGS) $(CPPFLAGS) -I$(HDIR) -c $< -o$@
	$(POSTCOMPILE)

$(DEPDIR)/%.d:;
.PRECIOUS: $(DEPDIR)

-include $(DEPS)

.PHONY: clean mrproper all run
