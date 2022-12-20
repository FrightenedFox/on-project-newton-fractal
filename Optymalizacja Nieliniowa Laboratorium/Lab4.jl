using Plots

function phi(i)
    if i <= 1
        return i
    else
        return phi(i-1) + phi(i-2)
    end
end

function fib_k(lower, upper, tol)
    i = 1
    len = upper - lower
    while phi(i) < len / tol 
        i += 1
    end 
    return i 
end

function fibonacci(f, lower, upper, tol; minimize=true)
    k = fib_k(lower, upper, tol)
    c = upper - phi(k - 1) / phi(k) * (upper - lower)
    d = lower + upper - c 
    i = 0
    print("Iteracja: $i \t a=$lower \t b=$upper \t β=$(phi(k-1)/phi(k))\n")
    while i <= k - 4
        if ~((f(c) < f(d)) ⊻ minimize)
            upper = d
            i += 1
        else
            lower = c
            i += 1
        end
        c = upper - phi(k - i - 1) / phi(k - i) * (upper - lower)
        d = lower + upper - c
        print("Iteracja: $i \t a=$lower \t b=$upper \t β=$(phi(k-1)/phi(k))\n")
    end
    return (lower + upper) / 2
end

function plot_func(func::Function, start=-10, stop=10, step=0.1;
    ylims=nothing, aspect_ratio=:auto)
    xs = start:step:stop
    plot_var = plot(xs, func.(xs), aspect_ratio=aspect_ratio)
    if ~isnothing(ylims)
        plot!(plot_var, ylims=ylims)
    end
    return plot_var
end
    
ϵ = 1e-5

func1(x) = 5 / x^2 - 3 * x
func2(x) = exp(x) * cos(x)
func3a(x) = (x^2 - 3) * exp(x)
func3b(x) = (x^3) / (x^2 - x -2)


plot_func(func1, -20, 20)
fibonacci(func1, -5, 0, ϵ)

plot_func(func2, -2, 2, ylims=(-2, 2))
fibonacci(x -> -func2(x), 0, 2, ϵ)
fibonacci(func2, 0, 2, ϵ, minimize=false) + 2*pi

plot_func(func2, 6, 8)
fibonacci(func2, 6, 8, ϵ, minimize=false)

plot_func(func3a, -5, 0)
# fibonacci(func2, 6, 8, ϵ, minimize=false)