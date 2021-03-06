!> 定义流体粒子粘度的子程序
!> subroutine to define the fluid particle viscosity
subroutine viscosity(ntotal, itype, x, rho, eta)

    use sph_kind, only: rk
    use parameter
    implicit none

    !> 在模拟中所使用的粒子总数
    !> number of particles in simulation
    integer, intent(in) :: ntotal
    !> 粒子类型
    !> type of particle
    integer, intent(in) :: itype(maxn)
    !> 粒子坐标
    !> coordinates of all particles
    real(rk), intent(in) :: x(dim, maxn)
    !> 粒子密度
    !> density
    real(rk), intent(in) :: rho(maxn)
    !> 粒子动态粘性力
    !> dynamic viscosity
    real(rk), intent(out) :: eta(maxn)

    integer :: i

    do i = 1, ntotal

        if (abs(itype(i)) == 1) then
            eta(i) = 0._rk
        else if (abs(itype(i)) == 2) then
            eta(i) = 1.0e-3_rk
        end if

    end do

end subroutine viscosity
