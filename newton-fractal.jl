using Printf
using Plots


"""Równanie prostej z dwóch liczb urojonych."""
function line_eq(A::Complex, B::Complex)
    x1, y1 = real(A), imag(A)
    x2, y2 = real(B), imag(B)
    return x -> (y2 - y1) / (x2 - x1) * (x - x1) + y1
end


"""Utworzenie ładnej sekwencji x-ów."""
function scaled_xs(A::Complex, B::Complex)
    x1, x2 = real(A), real(B)
    return x -> (sin((x - 0.5)pi) + 1) * (x2 - x1) / 2 + x1
end


"""Pochodna numeryczna pierwszego rzędu."""
function diff(func::Function, x::Any; h::Float64=1e-4, args...)
    return (func(x + h; args...) - func(x - h; args...)) / (2h)
end


"""Pochodna numeryczna drugiego rzędu."""
function diff2(func::Function, x::Any; h::Float64=1e-4, args...)
    return (func(x + h; args...) - 2func(x; args...) + func(x - h; args...)) / (h^2)
end


"""Równanie stycznej do funkcji w punkcie x"""
function tangent(func::Function, x0::Any; diff_func::Union{Function,Nothing}=nothing, args...)
    if isnothing(diff_func)
        return x -> diff(func, x0; args...) * (x - x0) + func(x0)
    else
        return x -> diff_func(x0) * (x - x0) + func(x0)
    end
end


"""Oblicza najkrótsze odległości z listy `points` do listy `centers` 
i zwraca indeksy najbliższych środków do każdego punktu."""
function points_to_centers(points::AbstractVector, centers::AbstractVector)
    closest_centers = Array{Int64,1}(undef, length(points))
    for (index, point) in enumerate(points)
        distances = abs.(centers .- point)
        closest_centers[index] = indexin(min(distances...), distances)[1]
    end
    return closest_centers
end


"""Zwraca nową wartość dla x po jednym kroku algorytmu Newtona.
Possible args: h::Float64
"""
function newton_step(func::Function, x::Any; diff_func::Union{Function,Nothing}=nothing, args...)
    if isnothing(diff_func)
        return x - func(x) / diff(func, x; args...)
    else
        return x - func(x) / diff_func(x)
    end
end


"""Zwraca punkt x, w którym funkcja jest równa 0. Opiera się na algorytmie Newtona.
Possible args: h::Float64
"""
function newton_find_root(func::Function, x::Any; tol::Float64=1e-3, verbose::Bool=false, max_steps::Number=1e3, args...)
    newx = undef
    iteration = 0
    if verbose & isa(x, Complex)
        @printf("[Iteracja = %3d] [x = %10.5f + i(%10.5f)] [newx =  undefined]\n", iteration, real(x), imag(x))
    elseif verbose
        @printf("[Iteracja = %3d] [x = %10.5f] [newx =  undefined]\n", iteration, x)
    end
    while true
        newx = newton_step(func, x; args...)
        iteration += 1
        if verbose & isa(x, Complex)
            @printf("[Iteracja = %3d] [x = %10.5f + i(%10.5f)] [newx = %10.5f + i(%10.5f)]\n", iteration, real(x), imag(x), real(newx), imag(newx))
        elseif verbose
            @printf("[Iteracja = %3d] [x = %10.5f] [newx =  %10.5f]\n", iteration, x, newx)
        end
        if abs(newx - x) < tol
            break
        end
        if iteration > max_steps
            @printf("Osiągnięto maksymalną ilość iteracji: %s. Przerwanie pętli.\n", max_steps)
            break
        end
        x = newx
    end
    return newx
end


"""Zwraca punkt x, w którym funkcja ma minimum, maksimum lub punkt przegięcia.
Possible args: verbose::Bool, tol::Float64, h::Float64, max_steps::Number
"""
function newton_optimise(x::Any;
    func::Union{Function,Nothing}=nothing,
    first_diff::Union{Function,Nothing}=nothing,
    second_diff::Union{Function,Nothing}=nothing,
    args...)
    if isnothing(first_diff) & isnothing(func)
        throw(ArgumentError("Neither `func` or `first_diff` was given. 
        At least one of them must be given."))
    elseif isnothing(first_diff)
        first_diff_num(x) = diff(func, x)
        return newton_find_root(first_diff_num, x; diff_func=second_diff, args...)
    else
        return newton_find_root(first_diff, x; diff_func=second_diff, args...)
    end
end


"""Przechowuje informacje o aktualnym położeniu wszystkich """
mutable struct PointsCloud
    points::AbstractVector
    initial_points::AbstractVector
    colors::Vector{Int64}
    steps::Int64

    function PointsCloud(points::AbstractVector)
        return new(points, points, Vector{Int64}(undef, length(points)), 0)
    end
end


"""Zrób jeden krok algorytmu Newtona dla wszystkich punktów PointsCloud.
Possible args: tol::Float64, h::Float64
"""
function step!(cloud::PointsCloud, func::Function; args...)
    cloud.points = newton_step.(func, cloud.points)
    cloud.steps += 1
end


"""Przypisz każdemu punktowi kolor najbliższego rozwiązania."""
function calc_colors!(cloud::PointsCloud, centers::AbstractVector)
    cloud.colors = points_to_centers(cloud.points, centers)
end


function root_searching_animation(
    func::Function
    ;
    x0::Union{Number, Nothing}=nothing,
    n::Int64=10,
    diff_func::Union{Function, Nothing}=nothing,
    xspan::StepRangeLen=-4:0.1:4,
    yspan::Union{StepRangeLen, Nothing}=nothing,
    filename::String="media/root_searching",
    fps::Int64=1,
    dpi::Int64=200)

    if isnothing(yspan)
        yspan = xspan
    end
    xlims = (minimum(collect(xspan)), maximum(collect(xspan)))
    ylims = (minimum(collect(yspan)), maximum(collect(yspan)))
    if isnothing(x0)
        x0 = rand(xspan)
    end
    anim = @animate for i in 1:n
        pl = plot(xlims=xlims, ylims=ylims, aspect_ratio=:equal, dpi=dpi, framestyle = :origin, legend=false)
        title!(pl, "Krok algorytmu Newtnoa nr $i")
        plot!(pl, xspan, func.(xspan))
        plot!(pl, xspan, tangent(func, x0; diff_func=diff_func).(xspan))
        next_x0 = newton_step(func, x0; diff_func=diff_func)
        scatter!(pl, [next_x0], [0], ms=4, markerstrokewidth=0.1, markerstrokealpha=1.0)
        plot!(pl, [x0, x0], [0, func(x0)], linestyle=:dash, markershape=:circle, 
        ms=4, markerstrokewidth=0.1, markerstrokealpha=1.0)
        x0 = next_x0
    end     
    gif(anim, "$filename.gif", fps=fps)   
end

"""Rysuje animację kolorowania płaszczyzny względem liczby kroków algorytmu."""
function points_fill_animation(
    func::Function,
    exact_roots::AbstractArray;
    n::Int64=20,
    span::StepRangeLen=-2:0.0085:2,
    filename::String="media/points_fill",
    fps::Int64=4,
    dpi::Int64=200,
    ms::Number=0.5,
    colors_list::Vector{String}=["red", "green", "blue", "yellow", "purple"])

    cloud = PointsCloud(vec([i + j * 1im for i in span, j in span]))
    calc_colors!(cloud, exact_roots)
    xylims = (minimum(collect(span)), maximum(collect(span)))
    anim = @animate for i in 1:n
        pl = plot(xlims=xylims, ylims=xylims, aspect_ratio=:equal, dpi=dpi)
        title!(pl, "Krok algorytmu Newtona nr $i")
        for j in unique(cloud.colors)
            scatter!(
                pl,
                real(cloud.initial_points[cloud.colors.==j]),
                imag(cloud.initial_points[cloud.colors.==j]),
                ms=ms,
                markerstrokewidth=0.0,
                markerstrokealpha=0.0,
                color=colors_list[j],
                legend=false
            )
        end
        scatter!(
            pl,
            real(exact_roots),
            imag(exact_roots),
            ms=5,
            markerstrokewidth=0.1,
            markerstrokealpha=1.0,
            legend=false
        )
        step!(cloud, func)
        calc_colors!(cloud, exact_roots)
    end
    gif(anim, "$filename.gif", fps=fps)
end


"""Rysuje animacje 'wędrowania' punktów po płaszczyźnie."""
function points_cloud_animation(
    func::Function,
    exact_roots::AbstractArray;
    n::Int64=20,
    frames_per_move::Int64=15,
    fps::Int64=30,
    span::StepRangeLen=-2:0.5:2,
    xspan::Union{StepRangeLen,Nothing}=nothing,
    yspan::Union{StepRangeLen,Nothing}=nothing,
    filename::String="media/points_cloud",
    dpi::Int64=200,
    xylims::Union{Tuple{Number,Number},Nothing}=nothing,
    ms::Number=3)

    if isnothing(xspan)
        xspan = span
    end
    if isnothing(yspan)
        yspan = span
    end
    cloud = PointsCloud(vec([i + j * 1im for i in xspan, j in yspan]))
    calc_colors!(cloud, exact_roots)
    if isnothing(xylims)
        xylims = (minimum(collect(span)), maximum(collect(span)))
    end
    uniform_x_step = 1 / (frames_per_move - 1)
    xs_vec, ys_vec = Vector{Vector{Float64}}(undef, length(cloud.points)), Vector{Vector{Float64}}(undef, length(cloud.points))
    anim = @animate for i in 1:n, j in 1:frames_per_move
        if j == 1
            old_points = cloud.points
            step!(cloud, func)
            calc_colors!(cloud, exact_roots)
            xs_vec = [func.(0:uniform_x_step:1) for func in scaled_xs.(old_points, cloud.points)]
            ys_vec = [func.(xs) for (func, xs) in zip(line_eq.(old_points, cloud.points), xs_vec)]
        end
        pl = plot(xlims=xylims, ylims=xylims, aspect_ratio=:equal, dpi=dpi)
        title!(pl, "Krok algorytmu Newtona nr $i")
        scatter!(
            pl,
            [x_vec[j] for x_vec in xs_vec],
            [y_vec[j] for y_vec in ys_vec],
            ms=ms,
            markerstrokewidth=0.0,
            markerstrokealpha=0.0,
            legend=false
        )
        scatter!(
            pl,
            real(exact_roots),
            imag(exact_roots),
            ms=5,
            markerstrokewidth=0.1,
            markerstrokealpha=1.0,
            legend=false
        )
    end
    gif(anim, "$filename.gif", fps=fps)
end


# Wprowadzenie funkcji i jej wcześniej obliczonych pierwiastków (gdy f(z) == 0)
func1(z) = z^5 + z^2 - z + 1
func1_exact_roots = [0.66236 + 0.56228im, 0.66236 - 0.56228im, 0.0 + 1.0im, 0.0 - 1.0im, -1.32472 + 0.0im]

# Poszukiwanie pierwiastka funkcji za pomocą algorytmu Newtona
newton_find_root(func1, 0.5; verbose=true)
newton_find_root(func1, 0.5+2im; verbose=true)
newton_find_root(func1, 1.3; verbose=true)

root_searching_animation(func1; x0=1.3, n=45, fps=2, dpi=250, xspan=-4:0.01:4, filename="media/hq_root_searching")

# Poszukiwanie punktów ekstremum funkcji za pomocą algorytmu Newtona.
# Innymi słowy, poszukiwanie pierwiastków funkcji f'(z) == 0.
newton_optimise(0.5; func=func1)
newton_optimise(0.5; func=func1, verbose=true)
newton_optimise(0.5; first_diff=x -> 5x^4 + 2x - 1)
newton_optimise(0.5; first_diff=x -> 5x^4 + 2x - 1, second_diff=x -> 20x^3 + 2)
newton_optimise(0.5; func=func1, tol=1e-10, h=1e-10)

# Animację kolorowania płaszczyzny względem liczby kroków algorytmu i najbliższego ostatecznego pierwiastka.
# Wykonanie zajmuje 20-100 sekund
points_fill_animation(func1, func1_exact_roots; n=15, fps=2, dpi=250, span=-2:0.001:2, ms=0.1)


# Testowanie funkcji potrzebnych dla "rozpędzania i spowalniania" punktów
xs = scaled_xs(1im, 3-1im).(0:0.05:1)
ys = line_eq(1im, 3-1im).(xs)
scatter(xs, ys, aspect_ratio=:equal)


# Animacje poszukiwania punktami swoich pierwiastków. 
# Wykonanie zajmuje 30-120 sekund
points_cloud_animation(func1, func1_exact_roots; n=25, fps=30, frames_per_move=30, dpi=250, span=-2:0.5:2, ms=3)
points_cloud_animation(func1, func1_exact_roots; n=30, fps=30, frames_per_move=30, dpi=250, ms=1.5, filename="media/points_explosion", xspan=-1.75:0.05:-1.25, yspan=0.75:0.05:1.25)
points_cloud_animation(func1, func1_exact_roots; n=10, fps=30, frames_per_move=30, dpi=250, ms=1.5, filename="media/points_no_explosion", xspan=-0.75:0.05:-0.25, yspan=1.25:0.05:1.75)
