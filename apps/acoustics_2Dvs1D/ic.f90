function ic(r)

  implicit none

  real(kind=8), intent(in) :: r
  real(kind=8) :: ic

  real(kind=8) :: pi, width

  pi = 4.d0*datan(1.d0)
  width = 0.1d0

  if (dabs(r-0.5d0) .le. width) then
    ic = 1.d0 + dcos(pi*(r - 0.5d0)/width)
  else
    ic = 0.d0
  end if

  return

end function ic
