#************************************************************************
# Incredible Chairs, Simple LP
using JuMP
using Gurobi
using DataFrames
using LinearAlgebra
import XLSX

#import Pkg; Pkg.add("XLSX")
#import Pkg; Pkg.add("DataFrames")

#************************************************************************

#************************************************************************
#PARAMETERS
include("data_Step_5_Reserve_Market.jl")

#************************************************************************

#************************************************************************
# Model
FN = Model(Gurobi.Optimizer)

@variable(FN,up_g[t=1:T,g=1:G]>=0) #up reserve generators
@variable(FN,down_g[t=1:T,g=1:G]>=0) #down reserve generators
@variable(FN,up_e[t=1:T,w=1:2]>=0) #up reserve electrolyser
@variable(FN,down_e[t=1:T,w=1:2]>=0) #down reserve electrolyser


@objective(FN, Min, sum(up_g[t,g] * c_res_g[g] for t=1:T, g=1:G)
                    + sum(down_g[t,g] * c_res_g[g] for t=1:T, g=1:G)
                    + sum(up_e[t,w] * c_res_e[w] for t=1:T, w=1:2)
                    + sum(down_e[t,w] * c_res_e[w] for t=1:T, w=1:2)
)

#Capacity Limits
@constraint(FN,[t=1:T, d=1:D], sum(up_g[t,g] + down_e[t,w] for g=1:G, w=1:2) == sum(Cap_d[t,d] for d=1:D)*0.2)      #up reserve requirements     
@constraint(FN,[t=1:T, d=1:D], sum(down_g[t,g] + up_e[t,w] for g=1:G, w=1:2) == sum(Cap_d[t,d] for d=1:D)*0.15) #up reserve  limits constraint

@constraint(FN,[t=1:T,g=1:G], up_g[t,g] <= Cap_g[g])        #Generation limits constraint
@constraint(FN,[t=1:T,g=1:G], down_g[t,g] <= Cap_g[g])      #Generation limits constraint
@constraint(FN,[t=1:T,w=1:2], up_e[t,w] <= WF_cap[w]/2)   #capacity-based limits constraint WF
@constraint(FN,[t=1:T,w=1:2], down_e[t,w] <= WF_cap[w]/2) #capacity-based limits constraint WF

#=
#Ramping up and down constraints
@constraint(FN,[t=1:T,g=1:G], abs(up_g[t,g])-abs((t-1<1 ? Cap_g_init[g] : up_g[t-1,g]))<=Ramp_g_d[g])
@constraint(FN,[t=1:T,g=1:G], p_g[t,g] >= (t-1<1 ? Cap_g_init[g] : p_g[t-1,g]) - Ramp_g_d[g]) #ramp down constraint
=#


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
    #DA_price = -dual.(Balance) #Equilibrium price

    #println("Cost of hydrogen production: ", round(value(sum(DA_price[t]*p_w_H2_DA[t,w] for t=1:T, w=1:2)), digits = 2))
    #println("Cost of up balancing: ", round(value(sum(up_bal_w_H2[t,w]*0.85*DA_price[t] for t=1:T, w=1:2)), digits = 2))
    #println("Cost of down balancing: ", round(value(sum(down_bal_w_H2[t,w]*1.1*DA_price[t] for t=1:T, w=1:2)), digits = 2))
    #Market clearing price
    #=println("Market clearing price:")
    for t=1:T
        println("Hour $t: ", value(DA_price[t])) #Print equilibrium price
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

    println("Daily demand:")
    for d=1:D
        println("D$d: ", round(Int,value(sum(p_d[t,d] for t=1:T))))
    end
    println("\n")

    println("Daily profit of windfarms:")
    for w=1:W
        println("WF $w: ", round(Int,value(sum(p_w_grid_DA[t,w]*DA_price[t] for t=1:T))))
    end
    println("\n")

    println("Daily production of windfarms:")
    for w=1:W
        println("Grid WF $w: ", round(Int,value(sum(p_w_grid_DA[t,w] for t=1:T))))
        println("H2 WF $w: ", round(Int,value(sum(p_w_H2_DA[t,w] for t=1:T))))
    end
    println("\n")

    println("Daily production of hydrogen:")
    for w=1:2
        println("WF $w: ", round(Int,value(sum(p_w_H2_DA[t,w]*H2_prod for t=1:T))))
    end
    println("\n")

    println("Fulfilled demand:")
    for t=1:T
            println("Hour $t: ", round(value((sum(p_d[t,d] for d=1:D)/sum(Cap_d[d] for d=1:D))*100),digits=2), "%")
    end
    
    =#
    println("\n")
    Up_Gen=DataFrame(value.(up_g),Up_Gen)
    Down_Gen=DataFrame(value.(down_g),Down_Gen)
    Up_El=DataFrame(value.(up_g),Up_El)
    Down_El=DataFrame(value.(down_g),Down_El)

else
    println("No optimal solution available")
end

#************************************************************************

#**************************

if(isfile("results_step5_reserve.xlsx"))
    rm("results_step5_reserve.xlsx")
end

XLSX.writetable("results_step5_reserve.xlsx",
    Up_Gen = (collect(eachcol(Up_Gen)), names(Up_Gen)),
    Down_Gen = (collect(eachcol(Down_Gen)), names(Down_Gen)),
    Up_El = (collect(eachcol(Up_El)), names(Up_El)),
    Down_El = (collect(eachcol(Down_El)), names(Down_El)),
    )
#*****************************************************