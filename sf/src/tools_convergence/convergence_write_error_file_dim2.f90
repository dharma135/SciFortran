  if(isnan(err))call abort("check_convergence: error is NaN. EXIT...")
  if(total_==1)then
     open(10,file="max_error.err",access="append")
     open(11,file="min_error.err",access="append")
     open(12,file="error.err",access="append")
     open(13,file="error_distribution.err")
  else
     write(label,"(I2)")index_
     open(10,file="max_error_"//trim(adjustl(trim(label)))//".err",access="append")
     open(11,file="min_error_"//trim(adjustl(trim(label)))//".err",access="append")
     open(12,file="error_"//trim(adjustl(trim(label)))//".err",access="append")
     open(13,file="error_distribution_"//trim(adjustl(trim(label)))//".err")
  endif
  write(10,*)check,error(1)
  write(11,*)check,error(2)
  write(12,*)check,err
  do i=1,Msize1
     do j=1,Msize2
        write(13,*)Verror(i,j)
     enddo
  enddo
  close(10);close(11);close(12);close(13)
