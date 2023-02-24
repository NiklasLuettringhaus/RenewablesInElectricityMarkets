#************************************************************************
# Incredible Chairs, Simple LP
using JuMP
using Gurobi
using Plots
#************************************************************************

#************************************************************************
#PARAMETERS
include("data_Step_3.jl")

#************************************************************************



#************************************************************************
# Model
FN = Model(Gurobi.Optimizer)

@variable(FN,p_d[d=1:D]>=0) #load of demand
@variable(FN,p_w[w=1:W]>=0) #wind farm production
@variable(FN,p_g[g=1:G]>=0) #power scheduled of generetor g
@variable(FN,theta[n=1:N]) #voltage angle at each bus


@objective(FN, Max, sum(U_d[d]*p_d[d] for d=1:D)  #Revenue from demand
            - sum(C_g[g]*p_g[g] for g=1:G) # Production cost + start-up cost conventional generator
            - sum(0*p_w[w] for w=1:W)) #Maximize the social whalefare, /# Production cost Wind farm


@constraint(FN,[d=1:D], p_d[d] <= Cap_d[d]) #Demand limits constraint
@constraint(FN,[g=1:G], p_g[g] <= Cap_g[g]) #Generation limits constraint
@constraint(FN,[w=1:W], p_w[w] <= WF_prod[w]) #Weather-based limits constraint WF

@constraint(FN, Balance[n=1:N], sum(p_d[d] for d=1:D if psi_d[d,n]==1) 
                                + sum(B[n,m]*(theta[n]-theta[m]) for m=1:N if F[n,m]>0) 
                                - sum(p_w[w] for w=1:W if psi_w[w,n]==1) 
                                - sum(p_g[g] for g=1:G if psi_g[g,n]==1)
                                ==0) #Power balance constraint
@constraint(FN,[n=1:N,m=1:N],B[n,m]*(theta[n]-theta[m])<=F[n,m]) # Max Capacity of line connecting bus n to m
@constraint(FN,[n=1:N,m=1:N],B[n,m]*(theta[n]-theta[m])>=-F[n,m]) # Min Capacity of line connecting bus n to m
@constraint(FN,theta[1]==0) # Voltage angle at the reference bus

#print(FN) #print model to screen (only usable for small models)

#************************************************************************
