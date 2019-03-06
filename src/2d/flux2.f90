


!     =====================================================
    subroutine flux2(ixy,maxm,num_eqn,num_waves,num_aux,num_ghost,mx, &
    q1d,dtdx1d,aux1,aux2,aux3,method,mthlim, &
    qadd,fadd,gadd,cfl1d,wave,s, &
    amdq,apdq,cqxx,bmasdq,bpasdq,rpn2,rpt2,use_fwave, &
    abl_center,abl_edge1,abl_edge2,abl_edge3,i_abl_lower,i_abl_upper)
!     =====================================================

!     # Compute the modification to fluxes f and g that are generated by
!     # all interfaces along a 1D slice of the 2D patch.
!     #    ixy = 1  if it is a slice in x
!     #          2  if it is a slice in y
!     # This value is passed into the Riemann solvers. The flux modifications
!     # go into the arrays fadd and gadd.  The notation is written assuming
!     # we are solving along a 1D slice in the x-direction.

!     # fadd(:,i) modifies F to the left of cell i
!     # gadd(:,i,1) modifies G below cell i
!     # gadd(:,i,2) modifies G above cell i

!     # The method used is specified by method(2:3):

!         method(2) = 1 if only first order increment waves are to be used.
!                   = 2 if second order correction terms are to be added, with
!                       a flux limiter as specified by mthlim.

!         method(3) = 0 if no transverse propagation is to be applied.
!                       Increment and perhaps correction waves are propagated
!                       normal to the interface.
!                   = 1 if transverse propagation of increment waves
!                       (but not correction waves, if any) is to be applied.
!                   = 2 if transverse propagation of correction waves is also
!                       to be included.

!     Note that if method(6)=1 then the capa array comes into the second
!     order correction terms, and is already included in dtdx1d:
!     If ixy = 1 then
!        dtdx1d(i) = dt/dx                 if method(6) = 0
!                  = dt/(dx*capa(i,jcom))  if method(6) = 1
!     If ixy = 2 then
!        dtdx1d(j) = dt/dy                 if method(6) = 0
!                  = dt/(dy*capa(icom,j))  if method(6) = 1

!     Notation:
!        The jump in q (q1d(:,i)-q1d(:,i-1))  is split by rpn2 into
!            amdq =  the left-going flux difference  A^- Delta q
!            apdq = the right-going flux difference  A^+ Delta q
!        Each of these is split by rpt2 into
!            bmasdq = the down-going transverse flux difference B^- A^* Delta q
!            bpasdq =   the up-going transverse flux difference B^+ A^* Delta q
!        where A^* represents either A^- or A^+.


!cf2py intent(in) num_aux
!f2py external rpn2, rpt2
!f2py intent(callback) rpn2,rpt2

    use abl_module, only: abl_type, scale_for_abl

    implicit double precision (a-h,o-z)
    integer num_aux
    external rpn2,rpt2
    dimension    q1d(num_eqn, 1-num_ghost:maxm+num_ghost)
    dimension   amdq(num_eqn, 1-num_ghost:maxm+num_ghost)
    dimension   apdq(num_eqn, 1-num_ghost:maxm+num_ghost)
    dimension bmasdq(num_eqn, 1-num_ghost:maxm+num_ghost)
    dimension bpasdq(num_eqn, 1-num_ghost:maxm+num_ghost)
    dimension   cqxx(num_eqn, 1-num_ghost:maxm+num_ghost)
    dimension   qadd(num_eqn, 1-num_ghost:maxm+num_ghost)
    dimension   fadd(num_eqn, 1-num_ghost:maxm+num_ghost)
    dimension   gadd(num_eqn, 2, 1-num_ghost:maxm+num_ghost)

    dimension dtdx1d(1-num_ghost:maxm+num_ghost)
    dimension dtdx1d_abl(1-num_ghost:maxm+num_ghost)
    dimension dtdxave_abl(1-num_ghost:maxm+num_ghost)
    dimension aux1(num_aux,1-num_ghost:maxm+num_ghost)
    dimension aux2(num_aux,1-num_ghost:maxm+num_ghost)
    dimension aux3(num_aux,1-num_ghost:maxm+num_ghost)

    dimension     s(num_waves,1-num_ghost:maxm+num_ghost)
    dimension  wave(num_eqn, num_waves, 1-num_ghost:maxm+num_ghost)

    dimension abl_center(1-num_ghost:maxm+num_ghost)
    dimension abl_edge1(1-num_ghost:maxm+num_ghost)
    dimension abl_edge2(1-num_ghost:maxm+num_ghost)
    dimension abl_edge3(1-num_ghost:maxm+num_ghost)

    dimension method(7),mthlim(num_waves)
    logical :: limit, use_fwave
    common /comxyt/ dtcom,dxcom,dycom,tcom,icom,jcom

    limit = .false.
    do mw=1,num_waves
        if (mthlim(mw) > 0) limit = .TRUE.
    end do

!     # initialize flux increments:
!     -----------------------------

    ! Initializing qadd here is probably the least confusing approach,
    ! given the nature of the donor-cell upwind loop below.
    do i = 1-num_ghost, mx+num_ghost
        do m = 1, num_eqn
            qadd(m,i) = 0.d0
        end do
    end do

    ! Unnecessary to init fadd to zero here because it only gets
    ! modified by the second-order corrections

    ! Unnecessary to init gadd to zero here -- can init first time
    ! it's set instead

!     # solve Riemann problem at each interface and compute Godunov updates
!     ---------------------------------------------------------------------

    call rpn2(ixy,maxm,num_eqn,num_waves,num_aux,num_ghost,mx,q1d,q1d, &
    aux2,aux2,wave,s,amdq,apdq)

!   adjust dtdx1d for abl if needed
    do i = 0, mx+1
        dtdx1d_abl(i) = dtdx1d(i)
    end do
    if (abl_type /= 0) then
        call scale_for_abl(abl_center,num_ghost,maxm,mx,i_abl_lower,i_abl_upper, &
                           dtdx1d_abl,0)
    end if


!     # Set qadd for the donor-cell upwind method (Godunov)
    do i = 1, mx+1
        do m = 1, num_eqn    ! qadd(:,i-1) is still in cache from last cycle of outer loop
            qadd(m,i-1) = qadd(m,i-1) - dtdx1d_abl(i-1)*amdq(m,i)
        end do
        do m = 1, num_eqn
            qadd(m,i) = qadd(m,i) - dtdx1d_abl(i)*apdq(m,i)
        end do
    end do

!     # compute maximum wave speed for checking Courant number:
    cfl1d = 0.d0
    do i=1,mx+1
        do mw=1,num_waves
        !          # if s>0 use dtdx1d(i) to compute CFL,
        !          # if s<0 use dtdx1d(i-1) to compute CFL:
            cfl1d = dmax1(cfl1d, dtdx1d(i)*s(mw,i), &
                -dtdx1d(i-1)*s(mw,i))
        end do
    end do

    if (method(2) == 1) go to 130

!     # modify F fluxes for second order q_{xx} correction terms:
!     -----------------------------------------------------------

!     # apply limiter to waves:
    if (limit) call limiter(maxm,num_eqn,num_waves,num_ghost,mx, &
    wave,s,mthlim)

!     # For correction terms below, need average of dtdx in cell
!     # i-1 and i.  We compute these and overwrite dtdx1d.

!     # Second order corrections:
    if (use_fwave.eqv. .FALSE. ) then
      !            # modified in Version 4.3 to use average only in cqxx, not transverse
      ! adjust dtdxave for abl (if ndeed)
        do i = 2-num_ghost, mx+num_ghost
            dtdxave_abl(i) = 0.5d0 * (dtdx1d(i-1) + dtdx1d(i))
        end do
        if (abl_type /= 0) then
          call scale_for_abl(abl_edge2,num_ghost,maxm,mx,i_abl_lower, &
                             i_abl_upper,dtdxave_abl,0)
        end if
        do i = 2-num_ghost, mx+num_ghost
            do m = 1, num_eqn
                cqxx(m,i) = 0.d0
            end do
            do mw=1,num_waves    ! Traverse the wave array in memory-contiguous fashion
                do m=1,num_eqn
                    cqxx(m,i) = cqxx(m,i) + dabs(s(mw,i)) &
                    * (1.d0 - dabs(s(mw,i))*dtdxave_abl(i)) * wave(m,mw,i)
                enddo
            enddo
            do m = 1, num_eqn
                fadd(m,i) = 0.5d0 * cqxx(m,i)
            end do
        enddo
    else
        if (abl_type /= 0) then
            print *, "ABL not yet implemented for fwave splitting"
            stop
        end if
        do i = 2-num_ghost, mx+num_ghost
            dtdxave = 0.5d0 * (dtdx1d(i-1) + dtdx1d(i))
            do m = 1, num_eqn
                cqxx(m,i) = 0.d0
            end do
            do mw=1,num_waves
                do m=1,num_eqn
                !                 # second order corrections:
                    cqxx(m,i) = cqxx(m,i) + dsign(1.d0,s(mw,i)) &
                    * (1.d0 - dabs(s(mw,i))*dtdxave) * wave(m,mw,i)
                enddo
            enddo
            do m = 1, num_eqn
                fadd(m,i) = 0.5d0 * cqxx(m,i)
            end do
        enddo
    endif


    130 continue

    if (method(3) <= 0) go to 999   !# no transverse propagation

    if (method(2) > 1 .AND. method(3) == 2) then
    !        # incorporate cqxx into amdq and apdq so that it is split also.
        do i = 1, mx+1
            do m = 1, num_eqn
                amdq(m,i) = amdq(m,i) + cqxx(m,i)
                apdq(m,i) = apdq(m,i) - cqxx(m,i)
            end do
        end do
    endif


!      # modify G fluxes for transverse propagation
!      --------------------------------------------


!     # split the left-going flux difference into down-going and up-going:
    call rpt2(ixy,1,maxm,num_eqn,num_waves,num_aux,num_ghost,mx,q1d,q1d, &
    aux1,aux2,aux3,amdq,bmasdq,bpasdq)

!   adjust transverse fluxes for abl if needed
    if (abl_type /= 0) then
        call scale_for_abl(abl_edge1,num_ghost,maxm,mx,i_abl_lower,i_abl_upper, &
                           bmasdq,1)
        call scale_for_abl(abl_edge3,num_ghost,maxm,mx,i_abl_lower,i_abl_upper, &
                           bpasdq,1)
    end if

!     # modify flux below and above by B^- A^- Delta q and  B^+ A^- Delta q:
    do i = 1, mx+1
        ! Having two inner loops here allows traversal of gadd in memory-contiguous order
        do m = 1, num_eqn
            gadd(m,1,i-1) = -0.5d0*dtdx1d(i-1) * bmasdq(m,i)
        end do
        do m = 1, num_eqn
            gadd(m,2,i-1) = -0.5d0*dtdx1d(i-1) * bpasdq(m,i)
        end do
    end do


!     # split the right-going flux difference into down-going and up-going:
    call rpt2(ixy,2,maxm,num_eqn,num_waves,num_aux,num_ghost,mx,q1d,q1d, &
    aux1,aux2,aux3,apdq,bmasdq,bpasdq)

!   adjust transverse fluxes for abl if needed
    if (abl_type /= 0) then
        call scale_for_abl(abl_edge1,num_ghost,maxm,mx,i_abl_lower,i_abl_upper, &
                           bmasdq,0)
        call scale_for_abl(abl_edge3,num_ghost,maxm,mx,i_abl_lower,i_abl_upper, &
                           bpasdq,0)
    end if


!     # modify flux below and above by B^- A^+ Delta q and  B^+ A^+ Delta q:
    do i = 1, mx+1
        do m = 1, num_eqn
            gadd(m,1,i) = gadd(m,1,i) - 0.5d0*dtdx1d(i) * bmasdq(m,i)
        end do
        do m = 1, num_eqn
            gadd(m,2,i) = gadd(m,2,i) - 0.5d0*dtdx1d(i) * bpasdq(m,i)
        end do
    end do

    999 continue
    return
    end subroutine flux2
