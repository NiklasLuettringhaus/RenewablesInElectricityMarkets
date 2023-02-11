#************************************************************************
# Incredible Chairs, Simple LP
using JuMP
using Gurobi
#************************************************************************

#************************************************************************
# PARAMETERS
D=length(U_d)
G=length(C_g)

U_d=[17.93875424
24.42616924
4.749346522
21.18061301
2.951325259
11.02942244
13.33877397
12.30192194
16.97765831
22.95542703
2.598026883
16.71032337
11.91189354
16.98398964
12.96682873
10.388699587 #8.388699587
18.51956607] #Bid price of demand d

C_g=[13.32
13.32
20.7
20.93
26.11
10.52
10.52
6.02
5.47
0
10.52
10.89
0] # offer price of generator g

Cap_g=[152
152
350
591
60
155
155
400
400
300
310
350
113.427644] #capacity of generator g

Cap_d=[67.48173
60.37839
111.877605
46.17171
44.395875
85.24008
78.13674
106.5501
108.325935
120.75678
165.152655
120.75678
197.117685
62.154225
207.772695
113.65344
79.912575] #maximum load of demand d


#************************************************************************


#************************************************************************
# Model
FN = Model(Gurobi.Optimizer)

@variable(FN,p_d[d=1:D]>=0) #load of demand
@variable(FN,p_g[g=1:G]>=0) #power scheduled of generetor g

@objective(FN, Max, sum( U_d[d]*p_d[d] for d=1:D)-sum( C_g[g]*p_g[g] for g=1:G)) #Maximize the social walefare

@constraint(FN,[d=1:D],p_d[d]<=Cap_d[d]) #Demand limits constraint
@constraint(FN,[g=1:G],p_g[g]<=Cap_g[g]) #Generation limits constraint
@constraint(FN,sum(p_d[d] for d=1:D)-sum(p_g[g] for g=1:G)==0) #Power balance constraint

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
    #for f=1:F
    #    println("$(Flowers[f]) = $(value(x[f]))")
    #end
else
    println("No optimal solution available")
end
#************************************************************************
