  !if(isnan(err))call abort("check_convergence: error is NaN. EXIT...")
  open(10,file="error.err",position="append")
  write(10,*)check,err
  close(10)
