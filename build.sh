#!/bin/bash

#
#  NAME
#    build.sh
#
#  DESCRIPTION
#    Build the json-fortran library and unit tests.
#
#  USAGE
#    build.sh         : build using gfortran
#    build.sh -ifort  : build using ifort
#
#  REQUIRES
#    FoBiS.py : https://github.com/szaghi/FoBiS      [version 1.2.5 or later required]
#    RoboDoc  : http://rfsber.home.xs4all.nl/Robo/   [version 4.99.38 is the one tested]
#
#  AUTHOR
#    Jacob Williams : 12/27/2014
#

set -e

PROJECTNAME='jsonfortran'       # project name for robodoc (example: jsonfortran_2.0.0)
DOCDIR='./documentation/'       # build directory for documentation
SRCDIR='./src/'                 # library source directory
TESTDIR='./src/tests/'          # unit test source directory
BINDIR='./bin/'                 # build directory for unit tests
LIBDIR='./lib/'                 # build directory for library
MODCODE='json_module.f90'       # json module file name
LIBOUT='libjsonfortran.a'       # name of json library


# The following warning might be triggered by ifort unless explicitly silenced:
# warning #7601: F2008 standard does not allow an internal procedure to be an actual argument procedure name. (R1214.4).
# In the context of F2008 this is an erroneous warning.
# See https://prd1idz.cps.intel.com/en-us/forums/topic/486629
INTELCOMPILERFLAGS='-c -O2 -warn -stand f08 -diag-disable 7601 -traceback'
#INTELCOMPILERFLAGS='-c -O2 -warn -traceback -stand f08 -assume protect_parens -assume buffered_io -check all'

GNUCOMPILERFLAGS='-c -O2 -fbacktrace -Wall -Wextra -Wno-maybe-uninitialized -pedantic -std=f2008'

FCOMPILER='gnu' #Set default compiler to gfortran


# command line argument parsing
# N.B.: Arguments appearing later in the list take precidence over those appearing earlier.
#       e.g., "./build.sh --compiler intel --coverage no --compiler gnu --coverage" will
#       perform the build with the GFORTRAN compiler, and coverage analysis

script_name="$(basename $0)"

# usage message
print_usage () {
    echo -e "\n\nUsage:\n"
    echo -e "${script_name} [--compiler {intel|gnu|<other>}] [--cflags '<custom compiler flags here>']\n\
         [--coverage [{yes|no}]] [--profile [{yes|no}]] [--skip-tests [{yes|no}]]\n\
         [--skip-documentation [{yes|no}]] [--help]"
    echo ""
    echo -e "Any flags that take an optional yes or no argument will default to 'yes' when no\n\
argument is passed. Additionally, A custom compiler may be passed to the 'compiler'\n\
flag, but appropriate 'cflags' should also be passed to the script.\n\n"
}


while [ "$#" -ge "1" ]; do # Get command line arguments while there are more left to process

    key="$1" # Command line args are key-value pairs or value-less keys

    case $key in #find known keys
	--compiler) #pick the compiler. Defaults to gfortran, but intel or custom compilers can be used
	    case "$2" in
		intel|Intel|INTEL|ifort)
		    FCOMPILER='Intel'
		    FCOMPILERFLAGS="$INTELCOMPILERFLAGS"
		    shift
		    ;;
		gnu|Gnu|GNU|gfortran|Gfortran|GFortran|GFORTRAN)
		    FCOMPILER='gnu'
		    FCOMPILERFLAGS="$GNUCOMPILERFLAGS"
		    shift
		    ;;
		*)
		    FCOMPILER="custom"
		    echo "Warning: Trying to build with unsupported compiler, $2." 1>&2
		    echo "Please ensure you set appropriate --cflags and (single) quote them" 1>&2
		    FC="$2"
		    shift
		    ;;
	    esac
	    ;;
	--cflags)
	    FCOMPILERFLAGS="$2"
	    # no good way to check that the user didn't do something questionable
	    shift
	    ;;
	--coverage) # enable coverage
	    case $2 in
		yes|Yes|YES)
		    CODE_COVERAGE="yes"
		    shift
		    ;;
		no|No|NO)
		    CODE_COVERAGE="no"
		    shift
		    ;;
		*)
		    CODE_COVERAGE="yes"
		    # don't shift because $2 is some other flag
		    ;;
	    esac
	    ;;
	--profile) #nable profiling
	    case $2 in
		yes|Yes|YES)
		    CODE_PROFILE="yes"
		    shift
		    ;;
		no|No|NO)
		    CODE_PROFILE="no"
		    shift
		    ;;
		*)
		    CODE_PROFILE="yes"
		    # don't shift because $2 is some other flag
		    ;;
		esac
	    ;;
	--skip-tests) # skip tests
	    case $2 in
		yes|Yes|YES)
		    JF_SKIP_TESTS="yes"
		    shift
		    ;;
		no|No|NO)
		    JF_SKIP_TESTS="no"
		    shift
		    ;;
		*)
		    JF_SKIP_TESTS="yes"
		    ;;
	    esac
	    ;;
	--skip-documentation)
	    case $2 in
		yes|Yes|YES)
		    JF_SKIP_DOCS="yes"
		    shift
		    ;;
		no|No|NO)
		    JF_SKIP_DOCSS="no"
		    shift
		    ;;
		*)
		    JF_SKIP_DOCS="yes"
		    ;;
	    esac
	    ;;
	--help)
	    print_usage
	    exit 0
	    ;;
	*)
	    echo "Unknown flag, \"$1\", passed to ${script_name}!" 2>&1
	    print_usage
	    exit 1
	    ;;
    esac
    shift # look at next argument
done # with argument parsing loop

# if no compiler selected, then we're defaulting to gnu, and need to check that the cflags are set
if [ "$FCOMPILER" = 'gnu' ] && [ -z "$FCOMPILERFLAGS" ]; then
    FCOMPILERFLAGS="$GNUCOMPILERFLAGS"
fi

if [[ $CODE_COVERAGE == [yY]* ]]; then
    echo "Trying to compile with code coverage instrumentation."
    COVERAGE="-coverage"
fi

if [[ $CODE_PROFILE == [yY]* ]]; then
    echo "Trying to compile with code profiling instrumentation."
    PROFILING="-profile"
fi

if [[ $FCOMPILER == custom ]]; then
    CUSTOM="-fc $FC"
fi

#build the stand-alone library:
echo ""
echo "Building library..."

# work around for FoBiS.py PR #45
[ -d "$LIBDIR" ] || mkdir "$LIBDIR"

FoBiS.py build -ch -compiler ${FCOMPILER} ${CUSTOM} -cflags "${FCOMPILERFLAGS}" ${COVERAGE} ${PROFILING} -dbld ${LIBDIR} -s ${SRCDIR} -dmod ./ -dobj ./ -t ${MODCODE} -o ${LIBOUT} -mklib static -colors

#build the unit tests (uses the above library):
if [[ $JF_SKIP_TESTS != [yY]* ]]; then
    echo ""
    echo "Building unit tests..."

    # FoBiS.py PR #45 work around
    [ -d "$BINDIR" ] || mkdir "$BINDIR"

    for TEST in "${TESTDIR%/}"/jf_test_*.f90; do
	THIS_TEST=${TEST##*/}
	echo "Build ${THIS_TEST%.f90}"
	FoBiS.py build -ch -compiler ${FCOMPILER} ${CUSTOM} -cflags "${FCOMPILERFLAGS}" ${COVERAGE} ${PROFILING} -dbld ${BINDIR} -s ${TESTDIR} -i ${LIBDIR} -libs ${LIBDIR}/${LIBOUT} -dmod ./ -dobj ./ -t ${THIS_TEST} -o ${THIS_TEST%.f90} -colors
    done
else
    echo "Skip building the unit tests since \$JF_SKIP_TESTS has been set to 'true'."
fi

#build the documentation with RoboDoc (if present):
echo ""
if [[ $JF_SKIP_DOCS != [yY]* ]]; then
    if hash robodoc 2>/dev/null; then
	echo "Building documentation..."
	robodoc --rc ./robodoc.rc --src ${SRCDIR} --doc ${DOCDIR} --documenttitle ${PROJECTNAME}
    else
	echo "ROBODoc not found! Cannot build documentation. ROBODoc can be installed from: http://www.xs4all.nl/~rfsber/Robo/"
    fi
else
    echo "Skip building documentation since \$JF_SKIP_DOCS has been set to ${JF_SKIP_DOCS}."
fi

# Run all the tests unless $JF_SKIP_TESTS
echo ""
if [[ $JF_SKIP_TESTS != [yY]* ]] ; then
    echo "Running tests..."
    cd "$BINDIR"
    OLD_IGNORES="$GLOBIGNORE"
    GLOBIGNORE='*.*'
    #
    for TEST in jf_test_*; do
	# It would be nice to run json output printed to stdout through jsonlint, however,
	# some tests output more than one json structure and these need to be split
	./${TEST}
    done
    GLOBIGNORE="$OLD_IGNORES"
else
    echo "Skip running the unit tests since \$JF_SKIP_TESTS has been set to ${JF_SKIP_TESTS}."
fi
