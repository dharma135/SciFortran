  open(10,file="max_error.err",access="append")
  open(11,file="min_error.err",access="append")
  open(12,file="error.err",access="append")
  open(13,file="error_distribution.err")
  write(10,*)check,error(1)
  write(11,*)check,error(2)
  write(12,*)check,err
  do i=1,Msize2
     write(13,*)Verror(i)
  enddo
  close(10);close(11);close(12);close(13)
