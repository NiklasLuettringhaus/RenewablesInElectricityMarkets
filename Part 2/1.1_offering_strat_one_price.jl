#************************************************************************
# Step 1.1
using JuMP
using Gurobi
using Plots
#************************************************************************

#************************************************************************
#PARAMETERS
include("A2_data_step_1.1.jl")

#************************************************************************

#************************************************************************
# Model
A2_11 = Model(Gurobi.Optimizer)

@variable(A2_11, p_DA[t=1:T]>=0)                #production sold in DA market
@variable(A2_11, delta_up[t=1:T, s in generated_values]>=0)     #up balancing sold in balancing market
@variable(A2_11, delta_down[t=1:T, s in generated_values]>=0)   #down balancing sold in balancing market
@variable(A2_11, delta[t=1:T, s in generated_values]>=0)        #total balancing in real time needed in balancing market

@objective(A2_11, Max, sum(prob[s] *    (scenarios[s][2][t] * p_DA[t] 
                                        + 0.9 * scenarios[s][2][t] * delta_up[t,s] 
                                        - 1.2 * scenarios[s][2][t] * delta_down[t,s]) for t=1:T, s in generated_values))


@constraint(A2_11,[t=1:T], 0 <= p_DA[t] <= p_nom)                                                       #capacity limit constraint for WF
@constraint(A2_11,[t=1:T, s in generated_values], delta[t,s] == scenarios[s][1][t]*p_nom - p_DA[t])     #balancing need
@constraint(A2_11,[t=1:T, s in generated_values], delta_up[t,s] - delta_down[t,s] == delta[t,s])        #composition of balancing
@constraint(A2_11,[t=1:T], 0 <= p_DA[t] <= p_nom)

#************************************************************************
# Solve
solution = optimize!(A2_11)
println("Termination status: $(termination_status(A2_11))")
#************************************************************************

#************************************************************************
# Solution
if termination_status(A2_11) == MOI.OPTIMAL
    println("Optimal objective value: $(objective_value(A2_11))")
    println("Solution: ")
    DA_price = -dual.(Balance) #Equilibrium price
    println("Market clearing price:")
    println(DA_price)  #Print equilibrium price
    println("\n")
    println("Profit of each generator:")
    for g=1:G
        println("G$g:", round(Int,value(p_g[g])*(DA_price - C_g[g])))
    end
else
    println("No optimal solution available")
end