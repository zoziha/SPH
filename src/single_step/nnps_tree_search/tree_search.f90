module tree_search_m

    use sph_kinds, only: rk
    use quad_types, only: rectangle_t, circle_t, point_t
    use quad, only: quad_tree_t
    use parameter
    use output_m, only: set_statistics_print
    use utils, only: get_distance
    implicit none
    private

    public :: tree_search

contains

    !> 树型搜索法，适用于变光滑长度
    subroutine tree_search(itimestep, ntotal, hsml, x, niac, pair_i, &
                           pair_j, w, dwdx, countiac)
        integer, intent(in) :: itimestep, ntotal
        real(rk), intent(in) :: hsml(maxn)
        real(rk), intent(in) :: x(dim, maxn)
        integer, intent(out) :: niac
        integer, intent(out) :: pair_i(max_interaction)
        integer, intent(out) :: pair_j(max_interaction)
        real(rk), intent(out) :: w(max_interaction)
        real(rk), intent(out) :: dwdx(dim, max_interaction)
        integer, intent(out) :: countiac(maxn)

        type(quad_tree_t) qt    !! 四叉树
        logical bool            !! @todo: 删除
        type(circle_t) range    !! 查找域
        type(point_t), allocatable :: found(:)  !! 查找所得粒子
        real(rk), save :: range_width = 0       !! 查找域宽度
        type(rectangle_t), save :: boundary     !! 树型求解域
        integer scale_k, i, j, k
        real(rk) dx(dim), r !! 粒子间距

        select case (skf)
        case (1)
            scale_k = 2
        case (2, 3)
            scale_k = 3
        end select

        countiac(1:ntotal) = 0
        niac = 0

        ! 根据各维度最大值、最小值，计算比求解域更大的四(八)叉树边界
        if (range_width == 0) &
            call set_target_boundary(minval(x(:, 1:ntotal), dim=2), &
                                     maxval(x(:, 1:ntotal), dim=2), &
                                     range_width, boundary)

        call qt%constructor(boundary, 1)
        do i = 1, ntotal
            bool = qt%insert(point_t(x(1, i), x(2, i), index=i))
        end do

        do i = 1, ntotal - 1
            range = circle_t(x(1, i), x(2, i), scale_k*hsml(i))

            !@todo: 找不到足够的交互粒子
            call qt%query(range, found)

            do k = 1, size(found)
                j = found(k)%index
                if (j <= i) cycle  ! 如果域内粒子序号小于等于当前粒子序号，说明已经计录过了，则跳过

                niac = niac + 1
                pair_i(niac) = i
                pair_j(niac) = j
                countiac(i) = countiac(i) + 1
                countiac(j) = countiac(j) + 1

                call get_distance(x(1:dim, i), x(1:dim, j), dx, r)
                !> 计算核函数值和导数备用
                call kernel(r, dx, hsml(i), w(niac), dwdx(1:dim, niac))

            end do
            deallocate (found)

        end do

        !     statistics for the interaction
        call set_statistics_print(itimestep, ntotal, niac, countiac)

    end subroutine tree_search

    !> 根据比例因子，计算求解域
    subroutine set_target_boundary(min, max, width, boundary)
        real(rk), intent(in) :: min(dim), max(dim)
        real(rk), intent(out) :: width
        type(rectangle_t), intent(out) :: boundary

        real(rk), dimension(dim) :: center

        width = maxval(max - min)*tree_scale_ratio
        center = 0.5*(min + max)
        boundary = rectangle_t(center(1), center(2), width, width)

    end subroutine set_target_boundary

end module tree_search_m
