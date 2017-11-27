       function tenstore_2s(T,w)
        implicit none
        
        integer, intent(in) :: w
        type(Tensor2s), intent(in) :: T
        type(Tensor2) :: tenstore_2s
        integer :: i
        
        tenstore_2s%ab = 0.d0
        do i=1,3
         tenstore_2s%ab(i,i) = T%a6(i)
        enddo
        tenstore_2s%ab(1,2) = T%a6(4)/dble(w)
        tenstore_2s%ab(2,3) = T%a6(5)/dble(w)
        tenstore_2s%ab(3,1) = T%a6(6)/dble(w)
        tenstore_2s%ab(2,1) = tenstore_2s%ab(1,2)
        tenstore_2s%ab(3,2) = tenstore_2s%ab(2,3)
        tenstore_2s%ab(1,3) = tenstore_2s%ab(3,1)

       end function tenstore_2s
       
       function tenstore_2(T,w)
        implicit none
        
        integer, intent(in) :: w
        type(Tensor2), intent(in) :: T
        type(Tensor2) :: tenstore_2
        
        tenstore_2%ab = T%ab

       end function tenstore_2
       
       function tenstore_4(T,w)
        implicit none
        
        integer, intent(in), optional :: w
        type(Tensor4), intent(in) :: T
        type(Tensor4) :: tenstore_4
        
        tenstore_4%abcd = T%abcd

       end function tenstore_4
       
       function tenstore_4s(T,w)
        implicit none
        
        integer, intent(in), optional :: w
        type(Tensor4s), intent(in) :: T
        type(Tensor4) :: tenstore_4s
        integer :: i,j,k,l
        integer, dimension(3,3) :: i6j6
        
        i6j6 = reshape( (/1,4,6, 4,2,5, 6,5,3/), (/3, 3/) )
        
        forall (i=1:3,j=1:3,k=1:3,l=1:3) tenstore_4s%abcd(i,j,k,l)
     *             = T%a6b6(i6j6(i,j),i6j6(k,l))

       end function tenstore_4s