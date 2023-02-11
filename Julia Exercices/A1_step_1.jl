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
