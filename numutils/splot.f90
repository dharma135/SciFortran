!  include "list/d_unordered_list.f90"
program plot_3d
  USE D_UNORDERED_LIST
  USE COMMON_VARS
  USE SLPLOT
  USE TOOLS
  implicit none
  integer             :: i,L,ix,iy,pos1,pos2
  character(len=128)  :: file
  real(8)             :: y
  real(8),allocatable :: data(:),xgrid(:),ygrid(:),zgrid(:,:)
  real(8)             :: xmin,xmax
  real(8)             :: ymin,ymax
  integer             :: xsize,ysize
  type(d_linked_list) :: array
  logical             :: wl=.false.
  integer             :: nl
  xmin=1.d0 ; xmax=10.d0 ; xsize=10
  ymin=1.d0 ; ymax=10.d0 ; ysize=10
  allocate(help_buffer(18))
  help_buffer=([&
       'NAME',&
       '  splot',&
       '',&
       'SYNOPSIS',&
       '  splot x=min:max:sizex [y=min:max:sizey] [file=value] [nl=value]',&
       '',&
       'DESCRIPTION',&
       '  Read an array *Z(:) on stdin and return a 3D plot (intensity&surface)',&
       '  using a grid on both X and Y build out of the specified dimension.',&
       '  The plot consist of a data set, in *file, and a gnuplot script to ',&
       '  plot it, *plot_file.',&
       ' ',&
       'OPTIONS',&
       '  x=[min:max:sizex] -- dimension of the X axis of the grid. ',&
       '  y=[min:max:sizey] -- dimension of the Y axis of the grid. If not specified is equal to X',&
       '  file=[new.plot]   -- file name of the plot. gnuplot script in plot_*file',&
       '  nl=[0]            -- if /= 0 produces a plot with lines along one direction every nl lines',&
       '  '])
  call parse_cmd_help(help_buffer)
  call parse_cmd_variable(nl,"NL",default=0)
  call parse_cmd_variable(file,"FILE",default="new.plot")
  do i=1,command_argument_count()
     nml_var=get_cmd_variable(i)
     select case(nml_var%name)
     case("X")
        pos1=scan(nml_var%value,":")
        pos2=scan(nml_var%value(pos1+1:),":")
        if(nml_var%value(1:pos1-1)/="")read(nml_var%value(1:pos1-1),*)xmin
        if(nml_var%value(pos1+1:pos1+pos2-1)/="")read(nml_var%value(pos1+1:pos1+pos2-1),*)xmax
        if(nml_var%value(pos1+pos2+1:)/="")read(nml_var%value(pos1+pos2+1:),*)xsize
        ymin=xmin ; ymax=xmax ; ysize=xsize
     case("Y")
        pos1=scan(nml_var%value,":")
        pos2=scan(nml_var%value(pos1+1:),":")
        if(nml_var%value(1:pos1-1)/="")read(nml_var%value(1:pos1-1),*)ymin
        if(nml_var%value(pos1+1:pos1+pos2-1)/="")read(nml_var%value(pos1+1:pos1+pos2-1),*)ymax
        if(nml_var%value(pos1+pos2+1:)/="")read(nml_var%value(pos1+pos2+1:),*)ysize
     case default
        write(*,"(A)")"invalid option: +"//trim(nml_var%name)//"="//trim(nml_var%value)
     end select
  enddo

  allocate(xgrid(xsize),ygrid(ysize),zgrid(xsize,ysize))
  xgrid=linspace(xmin,xmax,xsize)
  ygrid=linspace(ymin,ymax,ysize)

  if(nl>0)wl=.true.

  array = init_list()
  i=0
  do 
     read(5,*,end=1) y
     call add_element(array,y)
     i=i+1
  end do
1 continue
  L=i ; if(L/=array%size)call abort("error in counting input")
  allocate(data(L)) ; call dump_list(array,data)

  if(L/=xsize*ysize)call abort("error in splot: xsize*ysize != data.size!")
  i=0
  do ix=1,xsize
     do iy=1,ysize
        i=i+1
        zgrid(ix,iy)=data(i)
     enddo
  enddo
  if(wl)then
     call splot(trim(adjustl(trim(file))),xgrid,ygrid,zgrid,.true.,nlines=nl)
  else
     call splot(trim(adjustl(trim(file))),xgrid,ygrid,zgrid)
  endif
  call msg("load gnuplot script plot_"//trim(adjustl(trim(file))))
end program plot_3d
