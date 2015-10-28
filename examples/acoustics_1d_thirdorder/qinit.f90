subroutine qinit(meqn,mbc,mx,xlower,dx,q,maux,aux)

    ! Set initial conditions for the q array.
    ! This default version prints an error message since it should
    ! not be used directly.  Copy this to an application directory and
    ! loop over all grid cells to set values of q(1:meqn, 1:mx).

    implicit none

    integer, intent(in) :: meqn,mbc,mx,maux
    real(kind=8), intent(in) :: xlower,dx
    real(kind=8), intent(in) :: aux(maux,1-mbc:mx+mbc)
    real(kind=8), intent(inout) :: q(meqn,1-mbc:mx+mbc)

    integer :: i
    real(kind=8) :: xcell

      do i=1,mx
         xcell = xlower + (i-0.5d0)*dx
         q(1,i) = 1.d-5*dexp(-((xcell-0.1162d0)/4.5d-4)**2)
         q(2,i) = 0.d0
      enddo

end subroutine qinit
