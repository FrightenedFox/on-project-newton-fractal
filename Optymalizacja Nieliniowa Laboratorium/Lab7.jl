using Pkg
Pkg.add("Plots")
Pkg.add("LinearAlgebra")

using Plots
using LinearAlgebra
ϵ = 0.001

function trial_stage(f, x, step)
    n = length(x)
    versor = Matrix(1I, n, n)
    i = 1 
    while i <= n 
        if f((x + step * versor[i, :])...) < f(x...)
            x += step * versor[i, :]
        elseif f((x - step* versor[i, :])...) < f(x...)
            x -= step * versor[i, :]
        end
        i += 1
    end
    return x
end

function hookejeeves(f, x, step, alpha; tol=ϵ)
    xb = nothing
    iteracja = 0
    while step >= tol
        xb = x
        x = trial_stage(f, xb, step)
        iteracja += 1
        print("Etap próbny wykonuje się po raz: $iteracja \t\t x=$x \t f(x)=$(f(x...)) \n")
        if f(x...) < f(xb...)
            iteracja_2 = 0
            while f(x...) < f(xb...)
                old_xb = xb
                xb = x
                x = 2 * xb - old_xb
                x = trial_stage(f, x, step)
                iteracja_2 += 1
                print("\t Etap roboczy wykonuje się po raz: $iteracja_2 \t x=$x \t f(x)=$(f(x...)) \n")
            end
            x = xb
        else
            step = alpha * step
            print("Skrócenie kroku: $step \n")
        end
    end
    return xb
end

func1(x, y) = 2 * (x^2 - 3y)^2 + (1-x)^2
func2(x, y) = 4x*(1 + y) + y - 2 - 4x^2 - 4y^2
func2_min(x, y) = - func2(x, y)

x = -5:0.1:5
y = -10:0.1:10
xx = vcat((x' .* ones(length(y)))...)
yy = vcat((ones(length(x))' .* y)...)
plot3d(xx, yy, func1.(xx, yy))
plot3d(xx, yy, func2.(xx, yy))

hookejeeves(func1, [10, 5], 0.1, 0.5)

hookejeeves(func2_min, [-1, -1], 0.1, 0.5)

Pkg.add("RCall")
using RCall

R"
neldermead <- function(f, x0, alpha, beta, gamma, tol) {
    cat('Test \n')
    n <- length(x0)
    step <- 0.1 * max(c(abs(x0), 1))
    x <- matrix(x0, nrow = n + 1, ncol = n, byrow = T) + step * rbind(0, diag(n))
    f.x <- apply(x, 1, f)
    while(diff(range(f.x)) > tol) {
        cat('Test')

        l <- which.min(f.x)
        f.l <- min(f.x)
        h <- which.max(f.x)
        f.h <- max(f.x)
        xb <- colMeans(x[-h,,drop = F])
        xr <- (1 + alpha) * xb - alpha * x[h,]
        f.xr <- f(xr)
        if (f.xr < f.l) {
            xe <- (1 - gamma) * xb + gamma * xr
            f.xe <- f(xe)
            if (f.xe < f.xr) {
                x[h,] <- xe
                f.x[h] <- f.xe
            } else {
                x[h,] <- xr
                f.x[h] <- f.xr
                cat('Iteracja i = ', i, ' Odbicie ', ' f(x) = ', f(xr), '\\n')
            }
        } else {
            shrink <- T
            if (f.xr < f.x[h]) {
                x[h,] <- xr
                f.x[h] <- f.xr
                shrink <- F
            } else {
                xc <- beta * xb + (1 - beta) * x[h,]
                f.xc <- f(xc)
                if (f.xc < f.x[h]) {
                    x[h,] <- xc
                    f.x[h] <- f.xc
                }
                else if ((f.xr >= f.x[h]) && shrink) {
                    x <- matrix(x[l,], nrow = n + 1, ncol = n, byrow = T) +
                    beta * sweep(x, 2, x[l,])
                    f.x <- apply(x, 1, f)
                }
            }
        }
    }
    return(x[which.min(f.x),])
}
"

@rput func1

R"func1_r <- function(z) { 
    x = z[0]
    y = z[1]
    return(2 * (x^2 - 3*y)^2 + (1-x)^2)
}"
R"neldermead(func1_r, c(10, 5), 1, 0.5, 2, 0.001)"
