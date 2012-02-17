!+-------------------------------------------------------------------+
!PROGRAM  : 
!TYPE     : function
!PURPOSE  : 
!+-------------------------------------------------------------------+
function dv_check_convergence_local(Xnew,eps,N1,N2,id) result(convergence)
  integer,optional         :: id
  integer                  :: id_
  integer                  :: i,Msize
  logical                  :: convergence  
  integer                  :: N1,N2
  real(8)                  :: eps
  real(8)                  :: error,err
  real(8)                  :: M
  real(8)                  :: Xnew(:)
  real(8),save,allocatable :: Xold(:)
  integer,save             :: success=0,check=1
  id_=0;if(present(id))id_=id
  if(mpiID==id_)then
     Msize=size(Xnew)
     if(.not.allocated(Xold))then
        allocate(Xold(Msize))
        Xold=0.d0
     endif
     M=0.d0
     do i=1,Msize
        M=M + abs(Xnew(i)-Xold(i)/abs(Xnew(i)))
     enddo
     err= M/real(Msize,8)
     Xold=Xnew    
     include "convergence_write_error_file_V.f90"
     if(err < eps)success=success+1
     if(err > eps)success=0
     convergence=.false.
     include "convergence_check.f90"
     include "convergence_print_error_msg_V.f90"
     check=check+1
  endif
end function dv_check_convergence_local

function zv_check_convergence_local(Xnew,eps,N1,N2,id) result(convergence)
  integer,optional            :: id
  integer                     :: id_
  integer                     :: i,Msize
  logical                     :: convergence  
  integer                     :: N1,N2
  real(8)                     :: eps
  real(8)                     :: error,err
  real(8)                     :: M
  complex(8)                  :: Xnew(:)
  complex(8),save,allocatable :: Xold(:)
  integer,save                :: success=0,check=1
  id_=0;if(present(id))id_=id
  if(mpiID==id_)then
     Msize=size(Xnew)
     if(.not.allocated(Xold))then
        allocate(Xold(Msize))
        Xold=(0.d0,0.d0)
     endif
     M=0.d0
     do i=1,Msize
        M=M + abs(Xnew(i)-Xold(i)/abs(Xnew(i)))
     enddo
     err= M/real(Msize,8)
     Xold=Xnew
     include "convergence_write_error_file_V.f90"
     if(err < eps)success=success+1
     if(err > eps)success=0
     convergence=.false.
     include "convergence_check.f90"
     include "convergence_print_error_msg_V.f90"
     check=check+1
  endif
end function zv_check_convergence_local

function dm_check_convergence_local(Xnew,eps,N1,N2,id,tight) result(convergence)
  integer,optional         :: id
  integer                  :: id_
  integer                  :: i,j,Msize1,Msize2
  logical,optional         :: tight
  logical                  :: convergence,strict
  integer                  :: N1,N2
  real(8)                  :: eps
  real(8)                  :: error(2),err
  real(8),allocatable      :: M(:),Verror(:)
  real(8)                  :: Xnew(:,:)
  real(8),save,allocatable :: Xold(:,:)
  integer,save             :: success=0,check=1
  strict=.false.;if(present(tight))strict=tight
  id_=0;if(present(id))id_=id
  if(mpiID==id_)then
     Msize1=size(Xnew,1);Msize2=size(Xnew,2)
     if(.not.allocated(Xold))then
        allocate(Xold(Msize1,Msize2))
        Xold=0.d0
     endif
     if(.not.allocated(M))allocate(M(Msize1))
     if(.not.allocated(Verror))allocate(Verror(Msize1))
     M=0.d0
     do i=1,Msize2
        M=M + abs(Xnew(:,i)-Xold(:,i)/abs(Xnew(:,i)))
     enddo
     Verror= M/real(Msize2,8)
     error(1)=maxval(Verror)
     error(2)=minval(Verror)
     err=sum(Verror)/dble(size(Verror))
     Xold=Xnew
     include "convergence_write_error_file_M.f90"
     if(strict)err=error(1)
     if(err < eps)success=success+1
     if(err > eps)success=0
     convergence=.false.
     include "convergence_check.f90"
     include "convergence_print_error_msg_M.f90"
     check=check+1
  endif
end function dm_check_convergence_local

function zm_check_convergence_local(Xnew,eps,N1,N2,id,tight) result(convergence)
  integer,optional            :: id
  integer                     :: id_
  integer                     :: i,j,Msize1,Msize2
  logical,optional            :: tight
  logical                     :: convergence,strict
  integer                     :: N1,N2
  real(8)                     :: eps
  real(8)                     :: error(2),err
  real(8),allocatable         :: M(:),Verror(:)
  complex(8)                  :: Xnew(:,:)
  complex(8),save,allocatable :: Xold(:,:)
  integer,save                :: success=0,check=1
  strict=.false.;if(present(tight))strict=tight
  id_=0;if(present(id))id_=id
  if(mpiID==id_)then
     Msize1=size(Xnew,1);Msize2=size(Xnew,2)
     if(.not.allocated(Xold))then
        allocate(Xold(Msize1,Msize2))
        Xold=0.d0
     endif
     if(.not.allocated(M))allocate(M(Msize1))
     if(.not.allocated(Verror))allocate(Verror(Msize1))
     M=0.d0
     do i=1,Msize2
        M=M + abs(Xnew(:,i)-Xold(:,i)/abs(Xnew(:,i)))
     enddo
     Verror= M/real(Msize2,8)
     error(1)=maxval(Verror)
     error(2)=minval(Verror)
     err=sum(Verror)/dble(size(Verror))
     Xold=Xnew
     include "convergence_write_error_file_M.f90"
     if(strict)err=error(1)
     if(err < eps)success=success+1
     if(err > eps)success=0
     convergence=.false.
     include "convergence_check.f90"
     include "convergence_print_error_msg_M.f90"
     check=check+1
  endif
  call MPI_BCAST(convergence,1,MPI_LOGICAL,0,MPI_COMM_WORLD,mpiERR)
end function zm_check_convergence_local

!******************************************************************
!******************************************************************
!******************************************************************
