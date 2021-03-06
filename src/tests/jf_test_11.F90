!*******************************************************************************************************
!****u* JSON/jf_test_11
!
!  NAME
!    jf_test_11
!
!  DESCRIPTION
!    11th unit test to test unicode support if enabled
!
!  USES
!    json_module
!    iso_fortran_env (intrinsic)
!
!  HISTORY
!    Izaak Beekman : created : 3/13/2015
!
!  LICENSE
!
!    JSON-FORTRAN: A Fortran 2008 JSON API
!
!    https://github.com/jacobwilliams/json-fortran
!
!    Copyright (c) 2014, Jacob Williams
!
!    All rights reserved.
!
!    Redistribution and use in source and binary forms, with or without modification,
!    are permitted provided that the following conditions are met:
!    * Redistributions of source code must retain the above copyright notice, this
!      list of conditions and the following disclaimer.
!    * Redistributions in binary form must reproduce the above copyright notice, this
!      list of conditions and the following disclaimer in the documentation and/or
!      other materials provided with the distribution.
!    * The names of its contributors may not be used to endorse or promote products
!      derived from this software without specific prior written permission.
!    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
!    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
!    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
!    DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
!    ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
!    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
!    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
!    ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
!    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
!    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
!
!  SOURCE

module jf_test_11_mod

    use json_module
    use, intrinsic :: iso_fortran_env , only: error_unit, output_unit, wp => real64

    implicit none

    character(len=*),parameter :: dir = '../files/inputs/'               !working directory
# ifdef USE_UCS4
    character(len=*),parameter :: unicode_file = 'hello-world-ucs4.json'
#endif
    character(len=*),parameter :: ascii_equivalent = 'hello-world-ascii.json'

contains

    subroutine test_11(error_cnt)

!   Read the file generated in jf_test_2, and extract some data from it.

    implicit none

    integer,intent(out) :: error_cnt
    character(kind=CK,len=:),allocatable :: cval
    type(json_file) :: json    !the JSON structure read from the file:
    type(json_file) :: clone

    error_cnt = 0
    call json_initialize()
    if (json_failed()) then
        call json_print_error_message(error_unit)
        error_cnt = error_cnt + 1
    end if

    write(error_unit,'(A)') ''
    write(error_unit,'(A)') '================================='
    write(error_unit,'(A)') '   EXAMPLE 11'
    write(error_unit,'(A)') '================================='
    write(error_unit,'(A)') ''

# ifdef USE_UCS4
    ! parse the json file:
    write(error_unit,'(A)') ''
    write(error_unit,'(A)') 'parsing file: '//dir//unicode_file

    call json%load_file(filename = dir//unicode_file)

    if (json_failed()) then    !if there was an error reading the file

        call json_print_error_message(error_unit)
        error_cnt = error_cnt + 1

    else

        write(error_unit,'(A)') ''
        write(error_unit,'(A)') 'reading data from file...'

        write(error_unit,'(A)') ''
        call json%get('UCS4 support?', cval)
        if (json_failed()) then
            call json_print_error_message(error_unit)
            error_cnt = error_cnt + 1
        else
            write(error_unit,'(A)') 'UCS4 support? '//cval
        end if

        write(error_unit,'(A)') ''
        call json%get('hello world.Amharic', cval)
        if (json_failed()) then
            call json_print_error_message(error_unit)
            error_cnt = error_cnt + 1
        else
            write(error_unit,'(A)') 'hello world.Amharic : '//cval
        end if

        write(error_unit,'(A)') ''
        call json%get('hello world.Portuguese', cval)
        if (json_failed()) then
            call json_print_error_message(error_unit)
            error_cnt = error_cnt + 1
        else
            write(error_unit,'(A)') 'hello world.Portuguese : '//cval
        end if

        write(error_unit,'(A)') ''
        call json%get('hello world.Russian', cval)
        if (json_failed()) then
            call json_print_error_message(error_unit)
            error_cnt = error_cnt + 1
        else
            write(error_unit,'(A)') 'hello world.Russian : '//cval
        end if

        write(error_unit,'(A)') ''
        call json%get('hello world.Hebrew', cval)
        if (json_failed()) then
            call json_print_error_message(error_unit)
            error_cnt = error_cnt + 1
        else
            write(error_unit,'(A)') 'hello world.Hebrew : '//cval
        end if

        write(error_unit,'(A)') ''
        call json%get('hello world.Urdu', cval)
        if (json_failed()) then
            call json_print_error_message(error_unit)
            error_cnt = error_cnt + 1
        else
            write(error_unit,'(A)') 'hello world.Urdu : '//cval
        end if

        write(error_unit,'(A)') ''
        call json%print_to_string(cval)
        if (json_failed()) then
           call json_print_error_message(error_unit)
           error_cnt = error_cnt + 1
        else
           write(error_unit,'(A)') 'The contents of the file were:'
           write(error_unit,'(A)') cval
        end if

        write(error_unit,'(A)') ''
        call clone%load_from_string(cval)
        if ( json_failed()) then
           call json_print_error_message(error_unit)
           error_cnt = error_cnt + 1
        end if

        write(error_unit,'(A)') ''
        write(error_unit,'(A)') 'Printing same file, but now to stdout:'
        call clone%print_file(output_unit)
        if (json_failed()) then
           call json_print_error_message(error_unit)
           error_cnt = error_cnt + 1
        end if

        write(error_unit,'(A)') ''
        write(error_unit,'(A)') 'Writing json file object to "../files/'//unicode_file//'"'
        call clone%print_file('../files/'//unicode_file)
        if ( json_failed() ) then
           call json_print_error_message(error_unit)
           error_cnt = error_cnt + 1
        end if

    end if

    ! clean up
    write(error_unit,'(A)') ''
    write(error_unit,'(A)') 'destroy...'
    call json%destroy()
    if (json_failed()) then
        call json_print_error_message(error_unit)
        error_cnt = error_cnt + 1
    end if
    call clone%destroy()
    if (json_failed()) then
        call json_print_error_message(error_unit)
        error_cnt = error_cnt + 1
    end if

# endif
    ! parse the json file:
    write(error_unit,'(A)') ''
    write(error_unit,'(A)') 'parsing file: '//dir//ascii_equivalent
    write(error_unit,'(A)') 'This is the ascii equivalent of "../files/inputs/hello-world-ucs4.json"'

    call json%load_file(filename = dir//ascii_equivalent)

    if (json_failed()) then    !if there was an error reading the file

        call json_print_error_message(error_unit)
        error_cnt = error_cnt + 1

    else

        write(error_unit,'(A)') ''
        write(error_unit,'(A)') 'reading data from file...'

        write(error_unit,'(A)') ''
        call json%get('UCS4 support?', cval)
        if (json_failed()) then
            call json_print_error_message(error_unit)
            error_cnt = error_cnt + 1
        else
            write(error_unit,'(A)') 'UCS4 support? '//cval
        end if

        write(error_unit,'(A)') ''
        call json%get('hello world.Amharic', cval)
        if (json_failed()) then
            call json_print_error_message(error_unit)
            error_cnt = error_cnt + 1
        else
            write(error_unit,'(A)') 'hello world.Amharic : '//cval
        end if

        write(error_unit,'(A)') ''
        call json%get('hello world.Portuguese', cval)
        if (json_failed()) then
            call json_print_error_message(error_unit)
            error_cnt = error_cnt + 1
        else
            write(error_unit,'(A)') 'hello world.Portuguese : '//cval
        end if

        write(error_unit,'(A)') ''
        call json%get('hello world.Russian', cval)
        if (json_failed()) then
            call json_print_error_message(error_unit)
            error_cnt = error_cnt + 1
        else
            write(error_unit,'(A)') 'hello world.Russian : '//cval
        end if

        write(error_unit,'(A)') ''
        call json%get('hello world.Hebrew', cval)
        if (json_failed()) then
            call json_print_error_message(error_unit)
            error_cnt = error_cnt + 1
        else
            write(error_unit,'(A)') 'hello world.Hebrew : '//cval
        end if

        write(error_unit,'(A)') ''
        call json%get('hello world.Urdu', cval)
        if (json_failed()) then
            call json_print_error_message(error_unit)
            error_cnt = error_cnt + 1
        else
            write(error_unit,'(A)') 'hello world.Urdu : '//cval
        end if

        write(error_unit,'(A)') ''
        call json%print_to_string(cval)
        if (json_failed()) then
           call json_print_error_message(error_unit)
           error_cnt = error_cnt + 1
        else
           write(error_unit,'(A)') 'The contents of the file were:'
           write(error_unit,'(A)') cval
        end if

        write(error_unit,'(A)') ''
        write(error_unit,'(A)') 'Printing same file, but now to stdout:'
        call json%print_file(output_unit)
        if (json_failed()) then
           call json_print_error_message(error_unit)
           error_cnt = error_cnt + 1
        end if

        write(error_unit,'(A)') ''
        write(error_unit,'(A)') 'Writing json file object to "../files/'//ascii_equivalent//'"'
        call json%print_file('../files/'//ascii_equivalent)
        if ( json_failed() ) then
           call json_print_error_message(error_unit)
           error_cnt = error_cnt + 1
        end if

    end if

    ! clean up
    write(error_unit,'(A)') ''
    write(error_unit,'(A)') 'destroy...'
    call json%destroy()
    if (json_failed()) then
        call json_print_error_message(error_unit)
        error_cnt = error_cnt + 1
    end if

    end subroutine test_11

end module jf_test_11_mod

program jf_test_11
    use jf_test_11_mod , only: test_11
    implicit none
    integer :: n_errors
    n_errors = 0
    call test_11(n_errors)
    if (n_errors /= 0) stop 1
end program jf_test_11

!*******************************************************************************************************
