!########################################################################
!PROGRAM  : COMVARS
!PURPOSE  : Declare all the common variables usually in use within codes
!########################################################################
module COMMON_VARS
  USE SCIFOR_VERSION
  implicit none
  private

  !include "scifor_version.inc"

  !PARAMETERS
  !===============================================================
  complex(8),parameter,public :: zero=(0.d0,0.d0)
  complex(8),parameter,public :: xi=(0.d0,1.d0)
  complex(8),parameter,public :: one=(1.d0,0.d0)
  real(8),parameter,public    :: sqrt2 = 1.41421356237309504880169d0
  real(8),parameter,public    :: sqrt3 = 1.73205080756887729352745d0
  real(8),parameter,public    :: sqrt6 = 2.44948974278317809819728d0
  real(8),parameter,public    :: pi    = 3.14159265358979323846264338327950288419716939937510d0
  real(8),parameter,public    :: pi2   = 6.28318530717959d0
  real(8),parameter,public    :: gamma_euler = 0.57721566490153286060d0  !euler s constant
  real(8),parameter,public    :: euler= 2.7182818284590452353602874713526624977572470936999595749669676277240766303535d0
  integer,parameter,public    :: max_int  = huge(1) 
  real(8),parameter,public    :: max_real = huge(1.d0)
  real(8),parameter,public    :: epsilonr=epsilon(1.d0),epsilonq=1.d-30
  integer,parameter,public    :: dbl=8,dp=8        ! "double" precision
  integer,parameter,public    :: ddp=16            ! "quad"   precision
  integer,parameter,public    :: sp = kind(1.0)    ! "single" precision


  !mpi vars:
  !=========================================================
  integer,public          :: MPIERR,MPISIZE=1,MPIID=0
  CHARACTER(LEN=3),public :: MPICHAR


  !OMP VARS:
  !=========================================================
  integer,public :: omp_num_threads,omp_id,omp_size

  !Date variables:
  integer(4) :: year
  integer(4) :: mese
  integer(4) :: day
  integer(4) :: h
  integer(4) :: m
  integer(4) :: s
  integer(4) :: ms
  character(len=9),parameter,dimension(12) :: month = (/ &
       'January  ', 'February ', 'March    ', 'April    ', &
       'May      ', 'June     ', 'July     ', 'August   ', &
       'September', 'October  ', 'November ', 'December ' /)


  interface txtfy
     module procedure i_to_ch,r_to_ch,c_to_ch
  end interface txtfy

  !===============================================

  public :: timestamp
  public :: error,warning
  public :: msg
  public :: txtfy
  public :: bold
  public :: underline
  public :: highlight
  public :: erased
  public :: red,green,yellow,blue,purple,cyan
  public :: bold_red,bold_green,bold_yellow,bold_blue,bold_purple,bold_cyan
  public :: bg_red,bg_green,bg_yellow,bg_blue,bg_purple,bg_cyan


contains



  !+-------------------------------------------------------------------+
  !PURPOSE  : prints the current YMDHMS date as a time stamp.
  ! Example: 31 May 2001   9:45:54.872 AM
  !+-------------------------------------------------------------------+
  subroutine timestamp(unit)
    integer,optional        :: unit
    integer                 :: unit_
    integer(4),dimension(8) :: data
    unit_=6;if(present(unit))unit_=unit
    if(mpiID==0)then
       call date_and_time(values=data)
       call print_date(data,unit_)
    endif
  end subroutine timestamp

  !******************************************************************
  !******************************************************************
  !******************************************************************


  !+-------------------------------------------------------------------+
  !PURPOSE  : print actual date
  !+-------------------------------------------------------------------+
  subroutine print_date(dummy,unit)
    integer(4),dimension(8) :: dummy
    integer                 :: unit
    integer(4)                          :: year
    integer(4)                          :: mese
    integer(4)                          :: day
    integer(4)                          :: h
    integer(4)                          :: m
    integer(4)                          :: s
    integer(4)                          :: ms
    character(len=9),parameter,dimension(12) :: month = (/ &
         'January  ', 'February ', 'March    ', 'April    ', &
         'May      ', 'June     ', 'July     ', 'August   ', &
         'September', 'October  ', 'November ', 'December ' /)
    year = dummy(1)
    mese = dummy(2)
    day  = dummy(3)
    h    = dummy(5)
    m    = dummy(6)
    s    = dummy(7)
    ms   = dummy(8)
    write(unit,"(A,i2,1x,a,1x,i4,2x,i2,a1,i2.2,a1,i2.2,a1,i3.3)")&
         "Timestamp: +",day,trim(month(mese)),year, h,':',m,':',s,'.',ms
    write(unit,*)""
  end subroutine print_date



  !******************************************************************
  !******************************************************************
  !******************************************************************



  !+-------------------------------------------------------------------+
  !PURPOSE  : send error message to std.out and exit 
  !+-------------------------------------------------------------------+
  subroutine error(text,id)
    character(len=*) :: text
    character(len=4) :: char_id
    integer,optional :: id
    integer          :: id_
    id_=0;if(present(id))id_=id
    if(id_ > mpiSIZE)id_=0
    if(mpiID==id_)then
       if(mpiID==0)then
          write(*,'(A)',advance="no")bold_red("error:")
       else
          write(char_id,"(I4)")id_
          write(*,'(A)',advance="no")bold_red("error from cpu"//char_id//":")
       endif
       write(*,'(A)')bg_red(text)
    endif
    stop
  end subroutine error

  subroutine warning(text,unit,id)
    character(len=*) :: text
    character(len=4) :: char_id
    integer,optional :: id,unit
    integer          :: id_,unit_
    id_=0;if(present(id))id_=id;if(id_ > mpiSIZE)id_=0
    unit_=6;if(present(unit))unit_=unit
    if(mpiID==id_)then
       if(mpiID==0)then
          write(unit_,'(A)',advance="no")bold_yellow("warning:")
       else
          write(char_id,"(I4)")id_
          write(unit_,'(A)',advance="no")bold_yellow("warning from cpu"//char_id//":")
       endif
       write(unit_,'(A)')bg_yellow(text)
    endif
  end subroutine warning


  !******************************************************************
  !******************************************************************
  !******************************************************************


  subroutine msg(message,unit,id)
    character(len=*) :: message
    integer,optional :: unit,id
    integer          :: unit_,i,id_
    id_=0;if(present(id))id_=id;if(id_ > mpiSIZE)id_=0
    unit_=6;if(present(unit))unit_=unit
    if(mpiID==id_)then
       if(mpiID==0)then
          write(unit_,'(A)',advance="no")"msg:"
       else
          write(unit_,'(A,I3,A)',advance="no")"msg from cpu",id_,": "
       endif
       write(*,'(A)') message
    endif
  end subroutine msg


  !******************************************************************
  !******************************************************************
  !******************************************************************

  function i_to_ch(i4) result(string)
    character(len=32) :: string
    integer           :: i4
    call i4_to_s_left(i4,string)
  end function i_to_ch

  function r_to_ch(r8) result(string)
    character(len=32) :: string
    character(len=16) :: string_
    real(8)           :: r8
    call r8_to_s_left(r8,string_)
    string=adjustl(string_)
  end function r_to_ch

  function c_to_ch(c) result(string)
    character(len=32+3) :: string
    character(len=16) :: sre,sim
    complex(8)        :: c
    real(8)           :: re,im
    re=real(c,8);im=aimag(c)
    call r8_to_s_left(re,sre)
    call r8_to_s_left(im,sim)
    string="("//trim(sre)//","//trim(sim)//")"
  end function c_to_ch

  !******************************************************************
  !******************************************************************
  !******************************************************************

  function bold(text) result(textout)
    character(len=*) :: text
    character(len=8+len(text)) :: textout
    textout=achar(27)//"[1m"//text//achar(27)//"[0m"
  end function bold

  function underline(text) result(textout)
    character(len=*) :: text
    character(len=8+len(text)) :: textout
    textout=achar(27)//"[4m"//text//achar(27)//"[0m"
  end function underline

  function highlight(text) result(textout)
    character(len=*) :: text
    character(len=8+len(text)) :: textout
    textout=achar(27)//"[7m"//text//achar(27)//"[0m"
  end function highlight

  function erased(text) result(textout)
    character(len=*) :: text
    character(len=8+len(text)) :: textout
    textout=achar(27)//"[9m"//text//achar(27)//"[0m"
  end function erased

  function red(text) result(textout)
    character(len=*) :: text
    character(len=9+len(text)) :: textout
    textout=achar(27)//"[91m"//text//achar(27)//"[0m"
  end function red

  function green(text) result(textout)
    character(len=*) :: text
    character(len=9+len(text)) :: textout
    textout=achar(27)//"[92m"//text//achar(27)//"[0m"
  end function green

  function yellow(text) result(textout)
    character(len=*) :: text
    character(len=9+len(text)) :: textout
    textout=achar(27)//"[93m"//text//achar(27)//"[0m"
  end function yellow

  function blue(text) result(textout)
    character(len=*) :: text
    character(len=9+len(text)) :: textout
    textout=achar(27)//"[94m"//text//achar(27)//"[0m"
  end function blue

  function purple(text) result(textout)
    character(len=*) :: text
    character(len=9+len(text)) :: textout
    textout=achar(27)//"[95m"//text//achar(27)//"[0m"
  end function purple

  function cyan(text) result(textout)
    character(len=*) :: text
    character(len=9+len(text)) :: textout
    textout=achar(27)//"[96m"//text//achar(27)//"[0m"
  end function cyan

  function bold_red(text) result(textout)
    character(len=*) :: text
    character(len=11+len(text)) :: textout
    textout=achar(27)//"[1;91m"//text//achar(27)//"[0m"
  end function bold_red

  function bold_green(text) result(textout)
    character(len=*) :: text
    character(len=11+len(text)) :: textout
    textout=achar(27)//"[1;92m"//text//achar(27)//"[0m"
  end function bold_green

  function bold_yellow(text) result(textout)
    character(len=*) :: text
    character(len=11+len(text)) :: textout
    textout=achar(27)//"[1;93m"//text//achar(27)//"[0m"
  end function bold_yellow

  function bold_blue(text) result(textout)
    character(len=*) :: text
    character(len=11+len(text)) :: textout
    textout=achar(27)//"[1;94m"//text//achar(27)//"[0m"
  end function bold_blue

  function bold_purple(text) result(textout)
    character(len=*) :: text
    character(len=11+len(text)) :: textout
    textout=achar(27)//"[1;95m"//text//achar(27)//"[0m"
  end function bold_purple

  function bold_cyan(text) result(textout)
    character(len=*) :: text
    character(len=11+len(text)) :: textout
    textout=achar(27)//"[1;96m"//text//achar(27)//"[0m"
  end function bold_cyan

  function bg_red(text) result(textout)
    character(len=*) :: text
    character(len=9+len(text)) :: textout
    textout=achar(27)//"[41m"//text//achar(27)//"[0m"
  end function bg_red

  function bg_green(text) result(textout)
    character(len=*) :: text
    character(len=9+len(text)) :: textout
    textout=achar(27)//"[42m"//text//achar(27)//"[0m"
  end function bg_green

  function bg_yellow(text) result(textout)
    character(len=*) :: text
    character(len=9+len(text)) :: textout
    textout=achar(27)//"[43m"//text//achar(27)//"[0m"
  end function bg_yellow

  function bg_blue(text) result(textout)
    character(len=*) :: text
    character(len=9+len(text)) :: textout
    textout=achar(27)//"[44m"//text//achar(27)//"[0m"
  end function bg_blue

  function bg_purple(text) result(textout)
    character(len=*) :: text
    character(len=9+len(text)) :: textout
    textout=achar(27)//"[45m"//text//achar(27)//"[0m"
  end function bg_purple

  function bg_cyan(text) result(textout)
    character(len=*) :: text
    character(len=9+len(text)) :: textout
    textout=achar(27)//"[46m"//text//achar(27)//"[0m"
  end function bg_cyan



  !******************************************************************
  !******************************************************************
  !******************************************************************

  subroutine i4_to_s_left ( i4, s )
    !! I4_TO_S_LEFT converts an I4 to a left-justified string.
    !  Example:
    !    Assume that S is 6 characters long:
    !        I4  S
    !         1  1
    !        -1  -1
    !         0  0
    !      1952  1952
    !    123456  123456
    !   1234567  ******  <-- Not enough room!
    !  Parameters:
    !    Input, integer ( kind = 4 ) I4, an integer to be converted.
    !    Output, character ( len = * ) S, the representation of the integer.
    !    The integer will be left-justified.  If there is not enough space,
    !    the string will be filled with stars.
    character :: c
    integer   :: i
    integer   :: i4
    integer   :: idig
    integer   :: ihi
    integer   :: ilo
    integer   :: ipos
    integer   :: ival
    character(len=*) ::  s
    s = ' '
    ilo = 1
    ihi = len ( s )
    if ( ihi <= 0 ) then
       return
    end if
    !  Make a copy of the integer.
    ival = i4
    !  Handle the negative sign.
    if ( ival < 0 ) then
       if ( ihi <= 1 ) then
          s(1:1) = '*'
          return
       end if
       ival = -ival
       s(1:1) = '-'
       ilo = 2
    end if
    !  The absolute value of the integer goes into S(ILO:IHI).
    ipos = ihi
    !  Find the last digit of IVAL, strip it off, and stick it into the string.
    do
       idig = mod ( ival, 10 )
       ival = ival / 10
       if ( ipos < ilo ) then
          do i = 1, ihi
             s(i:i) = '*'
          end do
          return
       end if
       call digit_to_ch ( idig, c )
       s(ipos:ipos) = c
       ipos = ipos - 1
       if ( ival == 0 ) then
          exit
       end if
    end do
    !  Shift the string to the left.
    s(ilo:ilo+ihi-ipos-1) = s(ipos+1:ihi)
    s(ilo+ihi-ipos:ihi) = ' '
  end subroutine i4_to_s_left

  subroutine r8_to_s_left ( r8, s )
    !! R8_TO_S_LEFT writes an R8 into a left justified string.
    !    An R8 is a real ( kind = 8 ) value.
    !    A 'G14.6' format is used with a WRITE statement.
    !  Parameters:
    !    Input, real ( kind = 8 ) R8, the number to be written into the string.
    !    Output, character ( len = * ) S, the string into which
    !    the real number is to be written.  If the string is less than 14
    !    characters long, it will will be returned as a series of asterisks.
    integer :: i
    real(8) :: r8
    integer :: s_length
    character(len=*) ::  s
    character(len=16) :: s2
    s_length = len ( s )
    if ( s_length < 16 ) then
       do i = 1, s_length
          s(i:i) = '*'
       end do
    else if ( r8 == 0.0D+00 ) then
       s(1:16) = '     0.0      '
    else
       write ( s2, '(g16.9)' ) r8
       s(1:16) = s2
    end if
    !  Shift the string left.
    s = adjustl ( s )
  end subroutine r8_to_s_left

  subroutine digit_to_ch(digit,ch)
    !! DIGIT_TO_CH returns the character representation of a decimal digit.
    !    Instead of CHAR, we now use the ACHAR function, which
    !    guarantees the ASCII collating sequence.
    !  Example:
    !    DIGIT   CH
    !    -----  ---
    !      0    '0'
    !      1    '1'
    !    ...    ...
    !      9    '9'
    !     17    '*'
    !  Parameters:
    !    Input, integer ( kind = 4 ) DIGIT, the digit value between 0 and 9.
    !    Output, character CH, the corresponding character.
    character :: ch
    integer   :: digit
    if ( 0 <= digit .and. digit <= 9 ) then
       ch = achar ( digit + 48 )
    else
       ch = '*'
    end if
  end subroutine digit_to_ch


END MODULE COMMON_VARS
