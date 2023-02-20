#************************************************************************
# Incredible Chairs, Simple LP
using JuMP
using Gurobi
#************************************************************************

#************************************************************************
#PARAMETERS
include("data_Step_1.jl")

#************************************************************************



#************************************************************************
# Model
FN = Model(Gurobi.Optimizer)

@variable(FN,p_d[d=1:D]>=0) #load of demand
@variable(FN,p_w[w=1:W]>=0) #wind farm production
@variable(FN,p_g[g=1:G]>=0) #power scheduled of generetor g

@objective(FN, Max, sum(U_d[d]*p_d[d] for d=1:D)  #Revenue from demand
            - sum(C_g[g]*p_g[g] for g=1:G) # Production cost + start-up cost conventional generator
            - sum(0*p_w[w] for w=1:W)) #Maximize the social whalefare, /# Production cost Wind farm


@constraint(FN,[d=1:D], p_d[d] <= Cap_d[d]) #Demand limits constraint
@constraint(FN,[g=1:G], p_g[g] <= Cap_g[g]) #Generation limits constraint
@constraint(FN,[w=1:W], p_w[w] <= WF_prod[w]) #Weather-based limits constraint WF
@constraint(FN, Balance, sum(p_d[d] for d=1:D) - sum(p_w[w] for w=1:W) - sum(p_g[g] for g=1:G)==0) #Power balance constraint

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
    println(DA_price)  #Print equilibrium price
    println("\n")
    println("Profit of each generator:")
    for g=1:G
        println("G$g:", round(Int,value(p_g[g])*(DA_price - C_g[g])))
    end
    println("\n")
    println("Profit of each wind farm:")
    for w=1:W
        println("G$w:", round(Int,value(p_w[w])*(DA_price - 0)))
    end
    println("\n")
    println("Utility of each demand:")
    for d=1:D
        println("D$d:", round(Int, value(p_d[d])*(U_d[d] - DA_price)))
    end

else
    println("No optimal solution available")
end
#************************************************************************
