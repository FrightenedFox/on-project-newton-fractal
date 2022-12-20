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
    plot!(plot_var, fmt = :png)
    savefig("plot.png") 
    return plot_var
end

function random_uniform(start, stop)
    return start + rand() * (stop - start)
end

function bisection(df, lower, upper, tol; minimize=false)
    iteracja = 0
    while (upper - lower > 2 * tol)
        m = (lower + upper) / 2
        df_m = df(m)
        print("Iteracja: $iteracja \t a=$lower \t b=$upper \t m=$m \t df.m=$df_m \n")
        while df_m == 0
            m = (lower + upper) / 2 + random_uniform(-tol, tol)
            df_m = df(m)
        end 
        if (df_m < 0)  ⊻ minimize
            lower = m
        else
            upper = m 
        end
        iteracja += 1
    end
    print("Iteracja: $iteracja \t a=$lower \t b=$upper \n")
    return (upper + lower) / 2
end

function newton(df, d2f, x, tol)
    iteracja = 0
    while true
        iteracja += 1
        newx = x - df(x) / d2f(x)
        print("Iteracja: $iteracja \t old x=$x \t new x=$newx \t d=$(- df(x) / d2f(x)) \n")
        if abs(newx - x) < tol
            return newx
        end
        x = newx
        if iteracja > 1000
            break
        end
    end
end

function secant(df, x1, x2, tol)
    iteracja = 0
    df_x2 = df(x2)
    while true
        iteracja += 1
        df_x1 = df(x1)
        new_x = x1 - df_x1 * (x1 - x2) / (df_x1 - df_x2)
        print("Iteracja: $iteracja \t old x=$x1 \t new x=$new_x \t d=$(- df_x1 * (x1 - x2) / (df_x1 - df_x2)) \n")
        if abs(new_x - x1) < tol
            return new_x
        end
        x2 = x1
        df_x2 = df_x1
        x1 = new_x
        if iteracja > 1000
            break 
        end
    end
end


function armijo_rule(f, df, x, alpha, rho, d)
    d = -sign(df(x)) * abs(d)
    while f(x + d) > f(x) + alpha * d * df(x)
        d *= rho
    end
    return x + d
end

function newton_armijo(f, df, d2f, x, alpha, rho, tol)
    iteracja = 0
    f_x = f(x)
    while true
        df_x = df(x)
        d2f_x = d2f(x)
        d = -sign(df_x)
        if d2f_x > 0
            d = - df_x / d2f_x
        end
        print("Iteracja: $iteracja \t old x=$x \t new x=$(x + d) \t d=$d \n")
        iteracja_wewnetrzna = 0
        while true
            global newx, f_newx
            newx = x + d
            f_newx = f(newx)
            iteracja_wewnetrzna += 1
            print("\tNormalizacja armijo: $iteracja_wewnetrzna \t new x=$(x + d) \t d=$d \n")
            if f_newx <= f(x) + alpha * d * df_x
                break 
            end
            d *= rho
        end 
        print("\tPo normalizacji armijo: new x=$(x + d) \t d=$d \n")
        if abs(newx - x) < tol 
            return newx
        end
        if iteracja > 1000
            break 
        end
        x = newx
        f_x = f_newx
        iteracja += 1
    end
end


ϵ = 1e-3
func3a(x) = (x^2 - 3) * exp(x)
dfunc3a(x) = 2 * x * exp(x) + (x^2 - 3) * exp(x)

dfunc3a_min(x) = -(2 * x * exp(x) + (x^2 - 3) * exp(x))

d2func3a(x) = 2 * exp(x) + 4 * x * exp(x) + (x^2 - 3) * exp(x)
plot_func(func3a, -1, 1.7, 0.1; aspect_ratio=:equal)
bisection(dfunc3a, -2, 2.1, ϵ)


plot_func(func3a, -4, -2, 0.1; aspect_ratio=:equal)
bisection(dfunc3a, -4, -2.1, ϵ, minimize=true)


plot_func(func3a, -4, 2, 0.1; aspect_ratio=:auto)
newton(dfunc3a, d2func3a, 600, ϵ)

func3b(x) = (x^3) / (x^2 - x -2)
dfunc3b(x) = (x^4 - 2x^3 - 6x^2) / (x^2 - x -2)^2
d2func3b(x) = ((4x^3 - 6x^2 - 12x)*(x^2 - x -2)^2 - (2x - 1)*(x^4 - 2x^3 - 6x^2)) / (x^2 - x -2)^4


dfunc3b(x) = (x^4-2*x^3-6*x^2)/(x^4-2*x^3-3*x^2+4*x+4)
d2func3b(x) = (6*x^3+12*x^2+24*x)/(x^6-3*x^5-3*x^4+11*x^3+6*x^2-12*x-8)

plot_func(func3b, -5, 5, 0.01; aspect_ratio=:equal, ylims=(-5, 10))
newton(dfunc3b, d2func3b, 5.6, ϵ)

secant(dfunc3b, 2.5, 2.500000001, ϵ)
newton(dfunc3b, d2func3b, 2.5, ϵ)


func4(x) = -1 * exp(-x^2)
dfunc4(x) = 2 * x * exp(-x^2)
d2func4(x) = (2 - 4 * x^2) * exp(-x^2)

plot_func(func4, -100, -50, 0.01; aspect_ratio=:auto)
newton(dfunc4, d2func4, 0.6, ϵ)
newton_armijo(func4, dfunc4, d2func4, -202, 0.5, 0.2, ϵ)
