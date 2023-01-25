import numpy as np
from autograd import grad
from scipy.optimize import line_search

NORM = np.linalg.norm

def func(x): # Objective function
    return x[0]**4 - 2*x[0]**2*x[1] + x[0]**2 + x[1]**2 - 2*x[0] + 1

Df = grad(func) # Gradient of the objective function

def Polak_Ribiere(Xj, tol, alpha_1, alpha_2):
    x1 = [Xj[0]]
    x2 = [Xj[1]]
    D = Df(Xj)
    delta = -D # Initialize the descent direction
    
    while True:
        start_point = Xj # Start point for step length selection 
        beta = line_search(f=func, myfprime=Df, xk=start_point, pk=delta, c1=alpha_1, c2=alpha_2)[0] # Selecting the step length
        if beta!=None:
            X = Xj+ beta*delta # Newly updated experimental point 
        
        if NORM(Df(X)) < tol:
            x1 += [X[0], ]
            x2 += [X[1], ]
            return X, func(X) # Return the results
        else:
            Xj = X
            d = D # Gradient of the preceding experimental point
            D = Df(Xj) # Gradient of the current experimental point
            chi = (D-d).dot(D)/NORM(d)**2 
            chi = max(0, chi) # Line (16) of the Polak-Ribiere Algorithm
            delta = -D + chi*delta # Newly updated direction
            x1 += [Xj[0], ]
            x2 += [Xj[1], ]

print(Polak_Ribiere(np.array([-1.7, -3.2]), 10**-6, 10**-4, 0.2))
