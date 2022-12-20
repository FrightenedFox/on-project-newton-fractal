using Pkg
Pkg.add("Plots")

using Plots

function plot_func(func::Function, start=-10, stop=10, step=0.1;
    ylims=nothing, aspect_ratio=:auto)
    xs = start:step:stop
    plot_var = plot(xs, func.(xs), aspect_ratio=aspect_ratio)
    if ~isnothing(ylims)
        plot!(plot_var, ylims=ylims)
    end
    return plot_var
end


function lagrange(f::Function, lower, upper, tol, tol_d)
    d = lower
    old_d = upper
    c = (lower + upper) / 2
    f_c = f(c) 
    d = 0.5 * (f(lower) * (c^2 - upper^2) + f_c * (upper^2 - lower^2) + 
        f(upper) * (lower^2 - c^2)) / (f(lower) * (c - upper) + 
        f_c * (upper - lower) + f(upper) * (lower - c))
    f_d = f(d)
    i = 1
    print("Iteracja: $i \t a=$lower \t c=$c \t d=$d \t b=$upper \n")
    while (abs(upper - lower) > tol) & (abs(old_d - d) > tol_d)
        if (lower < d) & (d < c)
            if f_d < f_c 
                upper, c, f_c = c, d, f_d
            else
                lower = d
            end
        elseif (c < d) & (d < upper)
            if f_d < f_c 
                lower, c, f_c = c, d, f_d
            else
                upper = d
            end
        else
            print("Algorytm nie jest zbieżny")
            return 
        end
        old_d = d 
        d = 0.5 * (f(lower) * (c^2 - upper^2) + f_c * (upper^2 - lower^2) + 
            f(upper) * (lower^2 - c^2)) / (f(lower) * (c - upper) + 
            f_c * (upper - lower) + f(upper) * (lower - c))
        f_d = f(d)

        i += 1
        print("Iteracja: $i \t a=$lower \t c=$c \t d=$d \t b=$upper \n")
    end
    return d
end

function my_range(a, b)
    return min(a, b), max(a, b)
end

function expansionBDS(f::Function, x0, delta)
    f_x0 = f(x0)
    f_pd = f(x0 + delta)
    f_md = f(x0 - delta)
    if any(isinf.([f_x0, f_pd, f_md]))
        print("Wartości funkcji nie są skończone\n")
        return NaN
    end 
    if f_x0 < min(f_pd, f_md)
        return my_range(x0 - delta, x0 + delta)
    elseif f_x0 > max(f_pd, f_md)
        print("Funkcja nie jest unimodalna w minimum\n")
        return NaN
    elseif f_pd > f_md 
        step = -delta 
        f_x2 = f_pd 
    end
    x1 = x0 
    x2 = x0 + step
    i = 0
    while true
        x3 = x0 + 2 * step 
        i += 1
        print("Iteracja: $i \t x1=$x1 \t x2=$x2 \t x3=$x3 \t step=$step \n")

        if isinf(x3)
            print("Nie udało się ustaić przedziału\n")
            return NaN
        end
        f_x3 = f(x3)
        if isinf(f_x3)
            print("Wartość funkcji nie jest skończona\n")
            return NaN
        end 
        if f_x3 > f_x2
            return my_range(x1, x3)
        end 
        step *= 2 
        x1, x2, f_x2 = x2, x3, f_x3
    end
end


ϵ = 1e-2
ϵ_d = ϵ * 1e-2

func1(x) = 5 / x^2 - 3 * x
func2(x) = exp(x) * cos(x)
func3a(x) = (x^2 - 3) * exp(x)
func3b(x) = (x^3) / (x^2 - x -2)

plot_func(func3b, -25, 30, 0.1; aspect_ratio=:equal)
plot_func(func3b, -4, -1, 0.1; aspect_ratio=:auto)
lagrange(func3b, 2.5, 10, ϵ, ϵ_d)
lagrange(func3b, -2, -1.1, ϵ, ϵ_d)

expansionBDS(func3b, 8, 1e-5)
