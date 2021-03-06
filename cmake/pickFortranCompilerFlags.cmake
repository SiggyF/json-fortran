if ( NOT Fortran_FLAGS_INIT )
  set ( Fortran_FLAGS_INIT TRUE )
  set ( ENABLE_BACK_TRACE TRUE CACHE BOOL
    "Enable backtraces on unexpected runtime errors? (Recommended)" )
  set ( ENABLE_COMPILE_TIME_WARNINGS TRUE CACHE BOOL
    "Enable diagnostic warnings at compile time? (Recommended)" )
  set ( ENABLE_RUNTIME_CHECKS FALSE CACHE BOOL
    "Enable compiler run-time checks? (Enabling this will turn off most compiler optimizations.)" )
  mark_as_advanced ( ENABLE_RUNTIME_CHECKS )

  if ( "${CMAKE_Fortran_COMPILER_ID}" MATCHES "Intel" )
    if ( ENABLE_BACK_TRACE )
      set ( CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -traceback")
    endif ()
    if ( ENABLE_COMPILE_TIME_WARNINGS )
      # The following warning might be triggered by ifort unless explicitly silenced:
      # warning #7601: F2008 standard does not allow an internal procedure to be an actual argument procedure
      # name. (R1214.4). In the context of F2008 this is an erroneous warning.
      # See https://prd1idz.cps.intel.com/en-us/forums/topic/486629
      set ( CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -warn -stand f08 -diag-disable 7601" )
    endif ()
    if ( ENABLE_RUNTIME_CHECKS )
      set ( CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -check all" )
    endif ()
  elseif ( "${CMAKE_Fortran_COMPILER_ID}" MATCHES "GNU" )
    set ( ENABLE_CODE_COVERAGE FALSE CACHE BOOL
      "Compile with code coverage output enabled using gcov. May not work on Mac.")
    if ( ENABLE_CODE_COVERAGE )
      set ( CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fprofile-arcs -ftest-coverage" )
    endif ()
    if ( ENABLE_BACK_TRACE )
      set ( CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fbacktrace" )
    endif ()
    if ( ENABLE_COMPILETIME_CHECKS )
      set ( CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -Wall -Wextra -Wno-maybe-uninitialized -pedantic -std=f2008" )
    endif ()
    if ( ENABLE_RUNTIME_CHECKS )
      set ( CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fcheck=all" )
    endif ()
  endif ()
endif ()
