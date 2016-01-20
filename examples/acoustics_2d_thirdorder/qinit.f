c     =====================================================
      subroutine qinit(meqn,mbc,mx,my,xlower,ylower,
     &     dx,dy,q,maux,aux)
c     =====================================================
c
c
      implicit double precision (a-h,o-z)
      dimension q(meqn, 1-mbc:mx+mbc, 1-mbc:my+mbc)

      do i=1,mx
        do j=1,my
            q(1,i,j) = 0.d0
            q(2,i,j) = 0.d0
            q(3,i,j) = 0.d0
        enddo
      enddo

      return
      end
