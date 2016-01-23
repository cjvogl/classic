subroutine setaux(mbc,mx,xlower,dx,maux,aux)

    ! Called at start of computation before calling qinit, and
    ! when AMR is used, also called every time a new grid patch is created.
    ! Use to set auxiliary arrays aux(1:maux, 1-mbc:mx+mbc, 1-mbc:my+mbc).
    ! Note that ghost cell values may need to be set if the aux arrays
    ! are used by the Riemann solver(s).
    !
    ! This default version does nothing.

    implicit none
    integer, intent(in) :: mbc,mx,maux
    real(kind=8), intent(in) :: xlower,dx
    real(kind=8), intent(out) ::  aux(maux,1-mbc:mx+mbc)
    real(kind=8) :: rho1, bulk1, rho2, bulk2, rho3, bulk3
    common /cparam/ rho1, bulk1, rho2, bulk2, rho3, bulk3
    integer :: i

    do i=1-mbc,mx+mbc
      if (xlower + (i-0.5d0)*dx < 0.1866d0) then
        aux(1,i) = rho1*dsqrt(bulk1/rho1)
        aux(2,i) = dsqrt(bulk1/rho1)
      elseif (xlower + (i-0.5d0)*dx < 0.2032d0) then
        aux(1,i) = rho2*dsqrt(bulk2/rho2)
        aux(2,i) = dsqrt(bulk2/rho2)
      else
        aux(1,i) = rho3*dsqrt(bulk3/rho3)
        aux(2,i) = dsqrt(bulk3/rho3)
      endif
    enddo

end subroutine setaux
