#************************************************************************
# Incredible Chairs, Simple LP
using JuMP
using Gurobi
#************************************************************************

#************************************************************************
# PARAMETERS

U_d=[] #Bid price of demand d

C_g=[] # offer price of generator g

Cap_g=[] #capacity of generaotr generaotr generaotr g
Cap_d=[] #maximum load of demand d
#************************************************************************


#************************************************************************
# Model
FN = Model(Gurobi.Optimizer)

@variable(FN,p_d[d=1:D]>=0) #load of demand
@variable(FN,p_g[g=1:G]>=0) #power scheduled of generetor g

@objective(FN, Max, sum( U_d[d]*p_d[d] for d=1:D)-sum( C_g[g]*p_g[g] for g=1:G)) #Maximize the social walefare

@constraint(FN,[d=1:D],p_d[d]<=Cap_d[d]) #Demand limits constraint
@constraint(FN,[g=1:G],p_g[g]<=Cap_g[g]) #Generation limits constraint
@constraint(FN,sum(p_d[d] for d=1:D)-sum(p_g[g] for g=1:G)=0) #Power balance constraint

print(FN) #print model to screen (only usable for small models)

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
    for f=1:F
        println("$(Flowers[f]) = $(value(x[f]))")
    end
else
    println("No optimal solution available")
end
#************************************************************************
