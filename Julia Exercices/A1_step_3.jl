#************************************************************************
# Incredible Chairs, Simple LP
using JuMP
using Gurobi
#************************************************************************

#************************************************************************
#PARAMETERS
include("data_Step_3.jl")

#************************************************************************



#************************************************************************
# Model
FN = Model(Gurobi.Optimizer)

@variable(FN,p_d[t=1:T,d=1:D]>=0) #load of demand
@variable(FN,p_w[t=1:T,w=1:W]>=0) #wind farm production
@variable(FN,p_g[t=1:T,g=1:G]>=0) #power scheduled of generetor g
@variable(FN,theta[t=1:T,n=1:N]) #voltage angle at each bus


@objective(FN, Max, sum(U_d[t,d]*p_d[t,d] for t=1:T,d=1:D)  #Revenue from demand
            - sum(C_g[g]*p_g[t,g] for t=1:T,g=1:G) # Production cost + start-up cost conventional generator
            - sum(0*p_w[t,w] for t=1:T,w=1:W)) #Maximize the social whalefare, /# Production cost Wind farm


@constraint(FN,[t=1:T,d=1:D], p_d[t,d] <= Cap_d[d]) #Demand limits constraint
@constraint(FN,[t=1:T,g=1:G], p_g[t,g] <= Cap_g[g]) #Generation limits constraint
@constraint(FN,[t=1:T,w=1:W], p_w[t,w] <= WF_prod[t,w]) #Weather-based limits constraint WF

@constraint(FN, Balance[t=1:T,n=1:N], sum(p_d[t,d] for d=1:D if psi_d[d,n]==1) 
                                + sum(B[n,m]*(theta[t,n]-theta[t,m]) for m=1:N if F[n,m]>0) 
                                - sum(p_w[t,w] for w=1:W if psi_w[w,n]==1) 
                                - sum(p_g[t,g] for g=1:G if psi_g[g,n]==1)
                                ==0) #Power balance constraint

@constraint(FN,[t=1:T,n=1:N,m=1:N],B[n,m]*(theta[t,n]-theta[t,m])<=F[n,m]) # Max Capacity of line connecting bus n to m
@constraint(FN,[t=1:T,n=1:N,m=1:N],B[n,m]*(theta[t,n]-theta[t,m])>=-F[n,m]) # Min Capacity of line connecting bus n to m
@constraint(FN,[t=1:T],theta[t,1]==0) # Voltage angle at the reference bus

#print(FN) #print model to screen (only usable for small models)

#************************************************************************

#************************************************************************
# Solve
solution = optimize!(FN)
println("Termination status: $(termination_status(FN))")
#************************************************************************

#************************************************************************
# Solution
if termination_status(FN) == MOI.OPTIMAL
    println("Optimal objective value: $(objective_value(FN))")
    println("Solution: ")
    DA_price = -dual.(Balance) #Equilibrium price
    println("Market clearing price:")
    print(DA_price)  #Print equilibrium price
    println("\n")
else
    println("No optimal solution available")
end
#************************************************************************

