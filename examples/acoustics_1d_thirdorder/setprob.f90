subroutine setprob

    implicit none
    character*25 :: fname
    integer :: iunit
    real(kind=8) :: rho1, bulk1, rho2, bulk2, rho3, bulk3
    common /cparam/ rho1, bulk1, rho2, bulk2, rho3, bulk3

    ! Set the material parameters for the acoustic equations
    ! Passed to the Riemann solver rp1.f in a common block

    iunit = 7
    fname = 'setprob.data'
    ! open the unit with new routine from Clawpack 4.4 to skip over
    ! comment lines starting with #:
    call opendatafile(iunit, fname)


    read(7,*) rho1
    read(7,*) bulk1
    read(7,*) rho2
    read(7,*) bulk2
    read(7,*) rho3
    read(7,*) bulk3

end subroutine setprob
