using Plots
using Printf

ϵ = 1e-3

function golden_improved(func, lower, upper, eps; minimize=true)
    ratio = 2 / (3 + sqrt(5))
    x1 = (1 - ratio) * lower + ratio * upper
    func_x1 = func(x1)
    while abs(upper - lower) > 2 * eps
        x2 = (1 - ratio) * x1 + ratio * upper
        func_x2 = func(x2)
        if ~((func_x1 < func_x2) ⊻ minimize)
            upper = lower
            lower = x2
        else
            lower = x1
            x1 = x2
            func_x1 = func_x2
        end 
    end
    return (upper + lower) / 2
end

func_b(x) = -(1 + log(x)) / x 
xs = 0:0.001:10
func_b_plot = plot(xs, func_b.(xs), ylims=(-5, 10))
golden_improved(func_b, 0, 2.5, ϵ)

func_e(x) = exp(-x) / (x ^ 2 - 1)
xs = -3:0.001:3
func_c_plot = plot(xs, func_e.(xs), ylims=(-10, 10))
golden_improved(func_e, -0.5 , 0.99, ϵ, minimize=true) 
golden_improved(func_e, -0.5 , 0.99, ϵ, minimize=false)