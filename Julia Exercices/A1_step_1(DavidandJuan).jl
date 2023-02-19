#************************************************************************
# Incredible Chairs, Simple LP
using JuMP
using Gurobi
#************************************************************************

#************************************************************************
#PARAMETERS
#Bid price of demand d
U_d = [17.93875424, 24.42616924, 4.749346522, 21.18061301, 2.951325259, 11.02942244, 13.33877397, 12.30192194, 16.97765831, 22.95542703, 2.598026883, 16.71032337, 11.91189354, 16.98398964, 12.96682873, 11.388699587, 18.51956607]

#Offer price of generator g
C_g = [13.32, 13.32, 20.7, 20.93, 26.11, 10.52, 10.52, 6.02, 5.47, 0, 10.52, 10.89]

#Startup Cost of generator 
C_st = [1430.4, 1430.4, 1725, 3056.7, 437, 312, 312, 0, 0, 0, 624, 2298]

#Capacity of generator g
Cap_g = [152, 152, 350, 591, 60, 155, 155, 400, 400, 300, 310, 350] 

#Wind farm production for each time step(hour) t and wind farm w
WF_prod = [7.7, 15.2, 4.6, 47.7, 24, 14.2]  

#maximum load of demand 
    Cap_d = [67.48173, 60.37839, 111.877605, 46.17171, 44.395875, 85.24008, 78.13674, 106.5501, 108.325935, 120.75678, 165.152655, 120.75678, 197.117685, 62.154225, 207.772695, 113.65344, 79.912575]

# Sets
D = length(U_d)
G = length(C_g)
#Number of WF
W = 6
#************************************************************************


#************************************************************************
# Model
FN = Model(Gurobi.Optimizer)

@variable(FN,p_d[d=1:D]>=0) #load of demand
@variable(FN,p_w[w=1:W]>=0) #wind farm production
@variable(FN,p_g[g=1:G]>=0) #power scheduled of generetor g
@variable(FN,act_g[g=1:G],Bin) #Binary variable: 1 if generator is active, 0 otherwise

@objective(FN, Max, sum(U_d[d]*p_d[d] for d=1:D)  #Revenue from demand
            - sum(C_g[g]*p_g[g] + C_st[g] for g=1:G) # Production cost + start-up cost conventional generator
            - sum(0*p_w[w] for w=1:W)) #Maximize the social whalefare, /# Production cost Wind farm


@constraint(FN,[d=1:D], p_d[d] <= Cap_d[d]) #Demand limits constraint
@constraint(FN,[g=1:G], p_g[g] <= Cap_g[g]*act_g[g]) #Generation limits constraint
@constraint(FN,[w=1:W], p_w[w] <= WF_prod[w]) #Weather-based limits constraint WF
@constraint(FN, Balance, sum(p_d[d] for d=1:D) - sum(p_w[w] for w=1:W) - sum(p_g[g] for g=1:G)==0) #Power balance constraint

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
    DA_price = -dual.(Balance) #Equilibrium price
    println("Market clearing price:")
    println(DA_price)  #Print equilibrium price
    println("\n")
    println("Profit of each generator:")
    for g=1:G
        println("G$g:", round(Int,value(p_g[g])*(DA_price - C_g[g])))
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
