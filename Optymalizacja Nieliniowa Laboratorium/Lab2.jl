using Plots
using Printf

ϵ = 1e-3

function ternary(func, lower, upper, eps; max_iters=nothing, minimize=true)
    func_lower = func(lower)
    func_upper = func(upper)
    counter = 0
    @printf("Interacja: %s\ta=%.4f\tb=%.4f;\n", counter, lower, upper)
    while abs(upper - lower) > 2 * eps
        if ~isnothing(max_iters) && counter >= max_iters
            break
        end
        x₁ = (2 * lower + upper) / 3
        func_x₁ = func(x₁)
        x₂ = (lower + 2 * upper) / 3
        func_x₂ = func(x₂)
        if func_x₁ == func_x₂ 
            lower = x₁
            func_lower = func_x₁
            upper = x₂
            func_upper = func_x₂
        elseif ~((func_x₁ < func_x₂) ⊻ minimize)
            upper = x₂
            func_upper = func_x₂
        elseif ~((func_x₁ > func_x₂) ⊻ minimize)
            lower = x₁
            func_lower = func_x₁
        end
        counter += 1
        @printf("Interacja: %s\ta=%.4f\tb=%.4f;\n", counter, lower, upper)
    end
    return (upper + lower) / 2
end

### Zadanie 1
func_a(x) = x^2 * exp(1 / x)
xs = 0:0.001:1
func_a_plot = plot(xs, func_a.(xs), ylims=(0, 10))
ternary(func_a, 0, 1, ϵ)

func_b(x) = -(1 + log(x)) / x 
xs = 0:0.001:10
func_b_plot = plot(xs, func_b.(xs), ylims=(-5, 10))
ternary(func_b, 0, 2.5, ϵ)

func_c(x) = log(x^2 - 1) + (1 / (x^2 - 1))
xs = vcat(collect(-4:0.001:-1), collect(1:0.001:4))
func_c_plot = plot(xs, func_c.(xs), ylims=(-5, 10))
ternary(func_c, -2, -1, ϵ)
ternary(func_c, 1, 2, ϵ)

iters_a = ceil(log(0.002/(1-0.01)) / log(2/3))
iters_b = ceil(log(0.002/(2.5-0.01)) / log(2/3))
iters_c = ceil(log(0.002/(1-0.01)) / log(2/3))


# Zadanie 4: 
# Wyznaczyc maksima funkcji:
# a) y = log(x)/sqrt(x)
# b) y = exp(-x) / (x^2 - 1)

# Zadanie 6:
# Wprowadzic ograniczenie liczby iteracji nmax

func_d(x) = -log(x) / sqrt(x)
xs = 0:0.1:15
func_c_plot = plot(xs, func_d.(xs), ylims=(-1, 2))
ternary(func_d, 0, 10, ϵ)

func_e(x) = exp(-x) / (x ^ 2 - 1)
xs = -3:0.001:3
func_c_plot = plot(xs, func_e.(xs), ylims=(-10, 10))
ternary(func_e, -3 , -1.1, ϵ, minimize=false) 
ternary(func_e, -0.5 , 0.99, ϵ, minimize=false)
