#************************************************************************
# Incredible Chairs, Simple LP
using JuMP
using Gurobi


include("data_Step_2.jl")

#************************************************************************
# Model
FN = Model(Gurobi.Optimizer)

@variable(FN,p_d[t=1:T,d=1:D]>=0) #load of demand
@variable(FN,p_w_grid[t=1:T,w=1:W]>=0) #wind farm production to grid
@variable(FN,p_w_H2[t=1:T,w=1:W]>=0) #wind farm production to electrolyzer
@variable(FN,p_g[t=1:T,g=1:G]>=0) #power scheduled of generetor g


@objective(FN, Max, sum(U_d[t,d]*p_d[t,d] for t=1:T,d=1:D)  #Revenue from demand
            - sum(C_g[g]*p_g[t,g] for t=1:T,g=1:G) # Production cost conventional generator
            + sum(H2_price*p_w_H2[t,w]*H2_prod for t=1:T, w=1:2)) #Maximize the social whalefare, /# Production cost Wind farm


#Capacity limits
@constraint(FN,[t=1:T,d=1:D], p_d[t,d] <= Cap_d[t,d]) #Demand limits constraint
@constraint(FN,[t=1:T,g=1:G], p_g[t,g] <= Cap_g[g]) #Generation limits constraint
@constraint(FN,[t=1:T,w=1:W], p_w_grid[t,w] + p_w_H2[t,w] <= WF_prod[t,w]) #Weather-based limits constraint WF

#Power Balance
@constraint(FN, Balance[t=1:T], sum(p_d[t,d] for d=1:D) - sum(p_w_grid[t,w] for w=1:W) - sum(p_g[t,g] for g=1:G)==0) #Power balance constraint

#Ramping up and down constraints
@constraint(FN,[t=1:T,g=1:G], p_g[t,g] <= (t-1<1 ? Cap_g_init[g] : p_g[t-1,g]) + Ramp_g_u[g]) #ramp up constraint
@constraint(FN,[t=1:T,g=1:G], p_g[t,g] >= (t-1<1 ? Cap_g_init[g] : p_g[t-1,g]) - Ramp_g_d[g]) #ramp down constraint

#Electrolyzer constraints
@constraint(FN,[t=1:T, w=1:2], 0.01*(WF_cap[w]/2) <= p_w_H2[t,w] <= WF_cap[w]/2)
@constraint(FN,[t=1:T, w=1:2], sum(p_w_H2[t,w]*H2_prod for t=1:T) >= H2_cap)

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

    #Equilibrium price
    DA_price = -dual.(Balance[:])
    println("\n")
    println("Cost of hydrogen production: ", value(sum(DA_price[t]*p_w_H2[t,w] for t=1:T, w=1:2)))
    
    #Market clearing price
    println("\n")  
    println("Average market clearing price: ", value(sum(DA_price[t] for t=1:T)/T)) #Print average market clearing price
    println("\n")
    println("Market clearing price:")
    for t=1:T
        println("Hour $t: ", value(DA_price[t]))    #Print equilibrium price
    end   

    println("\n")
    println("Daily profit of each generator:")
    for g=1:G
        println("G$g: ", round(Int,value(sum(p_g[t,g]*(DA_price[t] - C_g[g]) for t=1:T))))
    end
    println("\n")

    println("Daily production of each generator:")
    for g=1:G
        println("G$g: ", round(Int,value(sum(p_g[t,g] for t=1:T))))
    end
    println("\n")

    println("Daily profit of windfarms:")
    for w=1:W
        println("WF $w: ", round(Int,value(sum(p_w_grid[t,w]*DA_price[t] for t=1:T) + sum(H2_price*p_w_H2[t,w]*H2_prod for t=1:T))))
    end
    println("\n")

    println("Daily production of hydrogen:")
    for w=1:2
        println("WF $w: ", round(Int,value(sum(p_w_H2[t,w]*H2_prod for t=1:T))))
    end
    println("\n")

    #println("Utility of each demand:")
    #for d=1:D
    #    println("D$d: ", round(Int, value(sum(p_d[t,d]*(U_d[d] - DA_price[t]) for t=1:T))))
    #end

else
    println("No optimal solution available")
end
#************************************************************************