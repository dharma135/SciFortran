program spline_
  USE D_UNORDERED_LIST
  USE COMMON_VARS
  USE PARSE_CMD
  USE TOOLS
  USE SPLINE
  implicit none
  !
  integer              :: i,L,Lin,Lout,order,ncol
  character(len=32)    :: method
  real(8)              :: x,y,a,b
  real(8),allocatable  :: datain(:),xin(:),dataout(:),xout(:)
  !
  type(d_linked_list)  :: arrayX,array
  !
  character(len=256),allocatable :: help_buffer(:)
  allocate(help_buffer(16))
  help_buffer=([&
       'NAME',&
       '  splint',&
       '',&
       'SYNOPSIS',&
       '  spline [L=value] ncol=value method=value [order=value]',&
       '',&
       'DESCRIPTION',&
       '  Read an array *Y(:) or *X(:),*Y(:) from stdin and return data interpolated ',&
       '  on a finer mesh.',&
       ' ',&
       'OPTIONS',&
       '  L=[1024|2*size.in]         -- dimension of the interpolating data ',&
       '  ncol=[1]                   -- number of columns in input',&
       '  method=[cubic|linear|poly] -- interpolative method',&
       '  order=[3]                  -- order of polynomial interpolation',&
       '  '])

  call parse_cmd_help(help_buffer)
  call parse_cmd_variable(L,"L",default=1024)
  call parse_cmd_variable(order,"ORDER",default=3)
  call parse_cmd_variable(method,"METHOD",default="cubic")
  call parse_cmd_variable(ncol,"NCOL",default=1)

  !
  if(ncol==1)then
     array = init_list()
     i=0
     do 
        read(5,*,end=1) y
        call add_element(array,y)
        i=i+1
     end do
1    continue
     Lin=i ; Lout=L;if(Lout < Lin)Lout=2*Lin
     !
     allocate(datain(Lin),xin(Lin))
     allocate(dataout(Lout),xout(Lout))
     call dump_list(array,datain)
     xin = linspace(0.d0,1.d0,Lin)
     xout= linspace(0.d0,1.d0,Lout)
  elseif(ncol==2)then
     array = init_list();arrayX=init_list()
     i=0
     do 
        read(5,*,end=2) x,y
        call add_element(arrayX,x)
        call add_element(array,y)
        i=i+1
     end do
2    continue
     Lin=i ; Lout=L;if(Lout < Lin)Lout=2*Lin
     !
     allocate(datain(Lin),xin(Lin))
     allocate(dataout(Lout),xout(Lout))
     call dump_list(array,datain)
     call dump_list(arrayX,xin)
     a=minval(xin);b=maxval(xin)
     xout= linspace(a,b,Lout)
  endif


  select case(method)
  case("cubic")
     call cubic_spline(datain,xin,dataout,xout)
  case("poly")
     call poly_spline(datain,xin,dataout,xout,N=order)
  case("linear")
     call linear_spline(datain,xin,dataout,xout)
  end select

  if(ncol==1)then
     do i=1,Lout
        write(*,*)dataout(i)
     enddo
  elseif(ncol==2)then
     do i=1,Lout
        write(*,*)xout(i),dataout(i)
     enddo
  endif
  !
end program spline_
