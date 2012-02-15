!###############################################################
!     PROGRAM  : IOTOOLS
!     TYPE     : Module
!     PURPOSE  : SIMPLE PLOTTING/READING LIBRARY FOR FORTRAN 90/95
!     AUTHORS  : Adriano Amaricci (SISSA)
!###############################################################
module IOFILE
  USE COMMON_VARS
  implicit none
  private

  !file size to be stored automagically (in Kb)
  integer,public :: store_size=2048

  public :: file_size
  public :: file_length
  public :: file_info
  public :: data_open
  public :: data_store
  public :: reg_filename
  public :: create_data_dir
  public :: close_file

contains

  subroutine close_file(pname)
    character(len=*) :: pname
    open(10,file=trim(adjustl(trim(pname))),access="append")
    write(10,*)""
    close(10)
  end subroutine close_file


  !+-----------------------------------------------------------------+
  !PURPOSE  : 
  !+-----------------------------------------------------------------+
  function file_size(file,printf) result(size)
    integer               :: size,status
    character(len=*)      :: file
    integer,dimension(13) :: buff
    logical,optional      :: printf
    logical               :: control
    inquire(file=trim(adjustl(trim(file))),exist=control)
    if(.not.control)then
       call msg('Cannot read '//trim(adjustl(trim(file)))//'. Skip file_size')
       return
    endif
    open(10,file=trim(adjustl(trim(file))))
    call fstat(10,buff,status)
    size=nint(buff(8)/dble(1024))
    if(present(printf).AND.printf==.true.)&
         write(*,"(A,A,A,f9.6,A)")"file: **",trim(adjustl(trim(file))),"** is ",size," Kb"
  end function file_size



  !******************************************************************
  !******************************************************************
  !******************************************************************



  !+-----------------------------------------------------------------+
  !PURPOSE  : 
  !+-----------------------------------------------------------------+
  function file_info(file)
    integer               :: file_info
    character(len=*)      :: file
    integer,dimension(13) :: buff
    integer               :: status,ifile,ierr
    logical               :: IOfile
    inquire(file=trim(adjustl(trim(file))),exist=IOfile)
    if(.not.IOfile)then
       print*,'Cannot read ',trim(adjustl(trim(file))),': skip file_size'
       file_info=0
       return
    endif
    open(10,file=trim(adjustl(trim(file))))
    call fstat(10,buff,status)
    if(status == 0)then
       WRITE (*, FMT="('Device ID:',               T30, I19)") buff(1)
       WRITE (*, FMT="('Inode number:',            T30, I19)") buff(2)
       WRITE (*, FMT="('File mode (octal):',       T30, O19)") buff(3)
       WRITE (*, FMT="('Number of links:',         T30, I19)") buff(4)
       WRITE (*, FMT="('Owner''s uid:',            T30, I19)") buff(5)
       WRITE (*, FMT="('Owner''s gid:',            T30, I19)") buff(6)
       WRITE (*, FMT="('Device where located:',    T30, I19)") buff(7)
       WRITE (*, FMT="('File size:',               T30, I19)") buff(8)
       WRITE (*, FMT="('Last access time:',        T30, A19)") buff(9)
       WRITE (*, FMT="('Last modification time',   T30, A19)") buff(10)
       WRITE (*, FMT="('Last status change time:', T30, A19)") buff(11)
       WRITE (*, FMT="('Preferred block size:',    T30, I19)") buff(12)
       WRITE (*, FMT="('No. of blocks allocated:', T30, I19)") buff(13)
    endif
    close(10)
  end function file_info



  !******************************************************************
  !******************************************************************
  !******************************************************************



  !+-----------------------------------------------------------------+
  !PURPOSE  : 
  !+-----------------------------------------------------------------+
  function file_length(file) result(length)
    integer          :: length
    character(len=*) :: file
    integer :: ifile,ierr
    logical :: IOfile
    inquire(file=trim(adjustl(trim(file))),exist=IOfile)
    if(.not.IOfile)then
       call msg('Cannot read +'//trim(adjustl(trim(file)))//'. Skip file_size')
       length=0
       return
    endif
    open(99,file=trim(adjustl(trim(file))))
    ifile=0;ierr=0
    do while(ierr==0)
       read(99,*,iostat=ierr)
       ifile=ifile+1
    enddo
    length=ifile-1
    write(*,'(A,I9,A)') 'there are', length,' lines in +'//trim(adjustl(trim(file)))
    rewind(99)
    close(99)
  end function file_length



  !******************************************************************
  !******************************************************************
  !******************************************************************



  !+-----------------------------------------------------------------+
  !PURPOSE  : 
  !+-----------------------------------------------------------------+
  function reg_filename(file) result(reg)
    character(len=*)                                   :: file    
    character(len=len_trim(trim(adjustl(trim(file))))) :: reg
    reg=trim(adjustl(trim(file)))
  end function reg_filename


  !******************************************************************
  !******************************************************************
  !******************************************************************




  !+-----------------------------------------------------------------+
  !PURPOSE  : 
  !+-----------------------------------------------------------------+
  subroutine data_store(file,size)
    character(len=*)  :: file
    integer,optional  :: size
    logical           :: control
    character(len=9)  :: csize 
    integer           :: cstatus,fsize
    call msg("store: "//file)
    !Check file exists:
    inquire(file=reg_filename(file),exist=control)
    if(control)then
       !Check if store_size is environment variable:
       call get_environment_variable("STORE_SIZE",csize,STATUS=cstatus)
       if(cstatus/=1)read(csize,"(I9)")store_size
       fsize=store_size;if(present(size))fsize=size
       if(file_size(reg_filename(file))>fsize)&
            call system("gzip -fv "//trim(adjustl(trim(file))))
    endif
  end subroutine data_store


  !******************************************************************
  !******************************************************************
  !******************************************************************



  !+-----------------------------------------------------------------+
  !PURPOSE  : 
  !+-----------------------------------------------------------------+
  subroutine data_open(filename,tar)
    integer                        :: i
    character(len=*)               :: filename
    character(len=10)              :: type
    logical                        :: compressed,control
    logical,optional,intent(out)   :: tar
    type=".gz"
    inquire(file=reg_filename(filename),exist=control)
    if(control)then             !If exist return (no untar)
       if(present(tar))tar  = .false.
       return
    else                        !else search the correct compress format
       inquire(file=reg_filename(filename)//reg_filename(type),exist=compressed)
       if(present(tar))tar =compressed
       if(.not.compressed)return
    endif

    call msg("deflate: "//reg_filename(filename)//reg_filename(type))
    call system("gunzip "//reg_filename(filename)//reg_filename(type))
    return
  end subroutine data_open


  !******************************************************************
  !******************************************************************
  !******************************************************************




  !+-----------------------------------------------------------------+
  !PURPOSE  : 
  !+-----------------------------------------------------------------+
  subroutine create_data_dir(dir_name)
    character(len=*),optional :: dir_name
    character(len=256)        :: name
    logical                   :: logical,control
    name="DATAsrc";if(present(dir_name))name=dir_name
    control = check_data_dir(name)
    if(control)then
       call abort("Can not create dir +"//trim(adjustl(trim(name)))//": ATTENTION",stop=.false.)
       return
    else
       call system("mkdir -v "//trim(adjustl(trim(name))))
    endif
  end subroutine create_data_dir


  !******************************************************************
  !******************************************************************
  !******************************************************************



  !+-----------------------------------------------------------------+
  !PURPOSE  : 
  !+-----------------------------------------------------------------+
  function check_data_dir(dir_name) result(logic)
    character(len=*),optional :: dir_name
    logical                   :: logic
    call system("if [ -d "//trim(adjustl(trim(dir_name)))//" ]; then echo > dir_exist; fi")
    inquire(file="dir_exist",EXIST=logic)
    call system("rm -f dir_exist")
  end function check_data_dir



  !******************************************************************
  !******************************************************************
  !******************************************************************


end module IOFILE




