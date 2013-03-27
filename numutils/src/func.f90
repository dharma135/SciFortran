program func
  USE D_UNORDERED_LIST
  USE COMMON_VARS
  USE PARSE_CMD
  implicit none
  !
  integer              :: i,L
  real(8)              :: x
  real(8),allocatable  :: xdata(:)
  type(d_linked_list)  :: array
  integer(8)                   :: evaluator_create_
  real(8)                      :: evaluator_evaluate_x_
  integer,parameter            :: buffer_size=256
  character(len = buffer_size) :: buffer
  integer(8)                   :: f
  character(len=256),allocatable :: help_buffer(:)
  buffer="x^2"
  allocate(help_buffer(15))
  help_buffer=([&
       'NAME',&
       '  func',&
       '',&
       'SYNOPSIS',&
       '  func f(x)',&
       '',&
       'DESCRIPTION',&
       '  EXPERIMENTAL ',&
       '  Read an array *x(:) from stdin and a function expression *f',&
       '  then *func return the values of the function *f(x) at *x. ',&
       ' ',&
       'OPTIONS',&
       '  f(x)[x^2] -- function form of f(x)',&
       '  almost all the implicit functions of F03 are supported',&
       '  '])
  !  
  call parse_cmd_help(help_buffer)
  if(command_argument_count()/=0)then
     do i=1,command_argument_count()
        cmd_var=get_cmd_variable(i)
        read(cmd_var%value,*)buffer
     enddo
  else
     call error("usage: cat ...|func f(x) OR func f(x) < ...")
  endif
  !
  array=init_list()
  i=0
  do 
     read(5,*,end=1)x
     call add_element(array,x)
     i=i+1
  end do
1 continue
  L=i
  !
  allocate(xdata(L))
  call dump_list(array,xdata)
  f = evaluator_create_(buffer);
  do i=1,L
     write(*,*)xdata(i),evaluator_evaluate_x_(f, xdata(i))
  enddo
  !
end program func
