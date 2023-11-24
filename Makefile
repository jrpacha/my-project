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
# Create a gtihub project using this template. We shall assume that the
# project is saved with he name "my-project"
# 
# Clone the repository in a folder of your local machine,
#   ~$ cd Desktop
#   ~ Desktop/my-project$ git clone git@github.com:jrpacha/my-project.git
#   ~ Desktop/my-project$ cd my-project
#
# Place your source files in the directory src. For example
#		~ Desktop/my-project$ ls src
# 	 main.cc    message.cc
#
# Place your header files in the directory include. For example,
#   ~ Desktop/my-project$ ls include
#   message.hh
#     
# Use make to build the program in the directory bin
#   ~ Desktop/my-project$ make
#
# You can run the program either with ./bin/my-project or with make run:
#   ~ Desktop/my-project$ ./bin/my-program
# or,
#   ~ Desktop/my-project$ make run
#
# Moreover,
#   ~ Desktop/my-project$ make clean    # delete obj and dep files
#   ~ Desktop/my-project$ make mrproper # also removes directory bin
#   ~ make help                         # shows Makefile's flags

PROG=$(notdir $(CURDIR))#name of the project
EXEDIR=       bin
SRCDIR=       src
HDIR =        include
OBJDIR=       .o
DEPDIR=       .d

CC= gcc
CXX= g++

CCFLAGS+= -g -O0 -W -fPIC 
CCLIBS+= #-lm -lgmp -lmpfr 

CXXFLAGS+= -g -O0 -W -fPIC
CXXLIBS+= #-lm -lgmp -lmpfr

FC= gfortran
FFLAGS= -g -O3 -std=legacy -Wall -Wextra -Wconversion
FFLIBS=
LDFLAGS+=      

ifdef OS
    $(shell mkdir $(OBJDIR) 2>NUL:)
    $(shell mkdir $(DEPDIR) 2>NUL:)
		$(shell mkdir $(EXEDIR) 2>NUL:)
    PROG:=$(PROG).exe
		CPPFLAGS+= -cpp -MMD -MP -MF $(DEPDIR)/$*.Td 
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
				CPPFLAGS+= -cpp -MMD -MP -MF $(DEPDIR)/$*.Td
        USE="Use:"
        USE.HELP="      'make help', to see other options."
        USE.BUILD="     'make', to build the executable, $(EXEDIR)/$(PROG)."
        USE.CLEAN="     'make clean', to delete the object and dep files."
        USE.MRPROPER="     'make mrproper', to delete the executable as well."
        ECHO=@echo
				ifeq ($(shell uname), Darwin)
					CC= gcc-13
					CXX= g++-13
					CCFLAGS+= -I/opt/homebrew/include
					CCLIBS+= -L/opt/homebrew/lib #-lm -lgmp -lmpfr 
					CXXFLAGS+= -I/opt/homebrew/include
					#CXXLIBS+= -L/opt/homebrew/lib #-lm -lgmp -lmpfr
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
