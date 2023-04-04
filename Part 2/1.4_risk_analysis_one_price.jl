#************************************************************************
# Step 1.1
using JuMP
using Gurobi
using Plots
using CSV
using DataFrames
using XLSX
#************************************************************************

#************************************************************************
#PARAMETERS
include("A2_data_step_1.4.jl")

#************************************************************************

#************************************************************************
# Model
A2_11 = Model(Gurobi.Optimizer)

@variable(A2_11, p_DA[t=1:T]>=0)                                #production sold in DA market
@variable(A2_11, delta_up[t=1:T, s in generated_values]>=0)     #up balancing sold in balancing market
@variable(A2_11, delta_down[t=1:T, s in generated_values]>=0)   #down balancing sold in balancing market
@variable(A2_11, delta[t=1:T, s in generated_values]>=0)        #total balancing in real time needed in balancing market

# Variables for CVAR
@variable(A2_11, zetta[t = 1:T] >=0)
@variable(A2_11, zetta[t = 1:T] >=0)

@objective(A2_11, Max, sum(prob[s] *    (scenarios[s][2][t] * p_DA[t] 
                                        + (1-scenarios[s][3][t]) * 1.2 * scenarios[s][2][t] * (delta_up[t,s] - delta_down[t,s])
                                        + scenarios[s][3][t] * 0.9 * scenarios[s][2][t] * (delta_up[t,s] - delta_down[t,s])) for t=1:T, s in generated_values)
                                        - beta * (zeta - 1/(1-alpha) * prob[s]))
