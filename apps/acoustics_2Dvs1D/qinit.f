
c
c
c
c     =====================================================
       subroutine qinit(meqn,mbc,mx,my,xlower,ylower,
     &                   dx,dy,q,maux,aux)
c     =====================================================
c
c     # Set initial conditions for q.
c     # Acoustics with smooth radially symmetric profile to test accuracy
c
       implicit double precision (a-h,o-z)
       dimension q(meqn, 1-mbc:mx+mbc, 1-mbc:my+mbc)
       real(kind=8) :: ic

       external ic
c
       pi = 4.d0*datan(1.d0)
       width = 0.2d0

       do 20 i=1,mx
          xcell = xlower + (i-0.5d0)*dx
          do 20 j=1,my
             ycell = ylower + (j-0.5d0)*dy
             r = dsqrt(xcell**2 + ycell**2)

             q(1,i,j) = ic(r)
             q(2,i,j) = 0.d0
             q(3,i,j) = 0.d0
  20         continue
       return
       end
