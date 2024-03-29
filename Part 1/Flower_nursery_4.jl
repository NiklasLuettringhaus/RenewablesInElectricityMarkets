#************************************************************************
# Incredible Chairs, Simple LP
using JuMP
using Gurobi
#************************************************************************

#************************************************************************
# PARAMETERS

Flowers=["roses","garden pinks","dahlia"]
F=length(Flowers)

Resources=["hours", "water", "fertilizer"]
R=length(Resources)

spaceCap=5000  # m^2

res=[ # resources utilized per rows f, columns r  
    2.5 90 0.3;
    5 100 0.5;
    2 120 0.2]

sellprice=[25 30 20] # selling price per flower f

resCap=[20000 700000 2500] #Capacity limit per resource

GreenHouseSpace=700

#************************************************************************


#************************************************************************
# Model
FN = Model(Gurobi.Optimizer)

@variable(FN,x[f=1:F]>=0,Int) #how much flowers to sell in m^2
@variable(FN,y,Bin) #decision to plant or not roses and build the greenhouse

@objective(FN, Max, sum( sellprice[f]*x[f] for f=1:F)-20000*y)

@constraint(FN,[r=1:R],sum(res[f,r]*x[f] for f=1:F)<=resCap[r])


@constraint(FN,sum(x[f] for f=1:F)<=spaceCap) #space capacity minus the space taken by the greenhouse if consturcted
@constraint(FN,x[1]<=GreenHouseSpace*y) #roses can only be planted in the greenhouse
@constraint(FN,x[1]>=200*y) #If the nursery builds the greenhouse, they have use it for at least 200m2 of roses.
@constraint(FN,x[3]<=spaceCap-GreenHouseSpace*y)

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
