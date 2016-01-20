subroutine src2(meqn,mbc,mx,my,xlower,ylower,dx,dy,q,maux,aux,t,dt)

    ! Called to update q by solving source term equation
    ! $q_t = \psi(q)$ over time dt starting at time t.
    !
    ! This default version does nothing.

    implicit none
    integer, intent(in) :: mbc,mx,my,meqn,maux
    real(kind=8), intent(in) :: xlower,ylower,dx,dy,t,dt
    real(kind=8), intent(in) ::  aux(maux,1-mbc:mx+mbc,1-mbc:my+mbc)
    real(kind=8), intent(inout) ::  q(meqn,1-mbc:mx+mbc,1-mbc:my+mbc)
    real(kind=8) :: delta
    real(kind=8) :: spatial, signal, eps, force, xc, yc
    real(kind=8) :: rho, bulk, cc, zz
    common /cparam/ rho,bulk,cc,zz
    integer :: i,j,k


    eps = 2.5d0*dx

    do j=1,my+mbc
      yc = ylower + (j-0.5d0)*dy
      do i=1,mx+mbc
        xc = xlower + (i-0.5d0)*dx

        spatial = dexp(-(yc/0.0125d0)**8)
        signal = 1.0d-5*dexp(-((t-0.9d0)/0.3d0)**2)

        force = 0.d0
        do k=1,4
          force = force + 1.d0/4.d0*delta(xc,eps)
        enddo

        q(2,i,j) = q(2,i,j) + dt*spatial*signal*force/rho
      enddo
    enddo

end subroutine src2

function delta(z,eps)

  real(kind=8) :: delta
  real(kind=8) :: z, pi, eps
  pi = 4.d0*datan(1.d0)

  if (z .lt. -eps) then
      delta = 0.d0
  else if (z .gt. eps) then
      delta = 0.d0
  else
      delta = (1.d0 + dcos(pi*z/eps))/(2.d0*eps)
  end if

  return
end function delta
