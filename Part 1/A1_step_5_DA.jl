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
include("data_Step_5_DA.jl")

#************************************************************************
#************************************************************************

#************************************************************************
# Model
FN = Model(Gurobi.Optimizer)

@variable(FN,p_d[t=1:T,d=1:D]>=0) #load of demand

@variable(FN,p_w_grid_DA[t=1:T,w=1:W]>=0) #wind farm production to grid from DA
@variable(FN,p_w_H2_DA[t=1:T,w=1:W]>=0) #wind farm production to electrolyzer from DA

@variable(FN,p_g[t=1:T,g=1:G]>=0) #power scheduled of generetor g

@objective(FN, Max, sum(U_d[t,d]*p_d[t,d] for t=1:T,d=1:D)              #Revenue from demand
            - sum(C_g[g]*p_g[t,g] for t=1:T,g=1:G)                      #Production cost + start-up cost conventional generator

#            - sum(up_g[t,g] * c_res_g[g] for t=1:T, g=1:G)
#            - sum(down_g[t,g] * c_res_g[g] for t=1:T, g=1:G)
#            - sum(up_e[t,w] * c_res_e[w] for t=1:T, w=1:2)
#            - sum(down_e[t,w] * c_res_e[w] for t=1:T, w=1:2)
)

#Capacity Limits
@constraint(FN,[t=1:T,d=1:D], p_d[t,d] <= Cap_d[t,d]) #Demand limits constraint

@constraint(FN,[t=1:T,g=1:G], Down_Res_Gen[t,g] <= p_g[t,g] <= Cap_g[g] - Up_Res_Gen[t,g]) #Generation limits constraint
@constraint(FN,[t=1:T,w=1:W], p_w_grid_DA[t,w] + p_w_H2_DA[t,w] <= WF_prod[t,w]) #Weather-based limits constraint WF from DA market
@constraint(FN,[t=1:T,w=1:2], Down_Res_El[t,w] <= p_w_H2_DA[t,w] <= WF_cap[w]/2 - Up_Res_El[t,w]) # Electrolyzer can maximum do max capacity - reserve and must do min reserve down

#Power Balance
@constraint(FN, Balance[t=1:T], sum(p_d[t,d] for d=1:D) - sum(p_w_grid_DA[t,w] for w=1:W) - sum(p_g[t,g] for g=1:G)==0) #Power balance constraint

#Ramping up and down constraints
@constraint(FN,[t=1:T,g=1:G], p_g[t,g] <= (t-1<1 ? Cap_g_init[g] : p_g[t-1,g]) + Ramp_g_u[g]) #ramp up constraint
@constraint(FN,[t=1:T,g=1:G], p_g[t,g] >= (t-1<1 ? Cap_g_init[g] : p_g[t-1,g]) - Ramp_g_d[g]) #ramp down constraint

#Electrolyzer constraints
@constraint(FN,[t=1:T, w=1:2], 0.01*(WF_cap[w]/2) <= p_w_H2_DA[t,w] <= WF_cap[w]/2)
@constraint(FN,[t=1:T, w=1:2], sum(p_w_H2_DA[t,w]*H2_prod for t=1:T) >= H2_cap)

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

    #println("Cost of hydrogen production: ", round(value(sum(DA_price[t]*p_w_H2_DA[t,w] for t=1:T, w=1:2)), digits = 2))
    #println("Cost of up balancing: ", round(value(sum(up_bal_w_H2[t,w]*0.85*DA_price[t] for t=1:T, w=1:2)), digits = 2))
    #println("Cost of down balancing: ", round(value(sum(down_bal_w_H2[t,w]*1.1*DA_price[t] for t=1:T, w=1:2)), digits = 2))
    #Market clearing price
    
    println("Market clearing price:")
    for t=1:T
        println("Hour $t: ", value(DA_price[t])) #Print equilibrium price
    end   

    for g= 1:G
        println(Down_Res_Gen)
        println(Up_Res_Gen)
        println(Down_Res_El)
        println(Up_Res_El)
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

    println("Hourly demand:")
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
            println("Hour $t: ", round(value((sum(p_d[t,d] for d=1:D)/sum(Cap_d[t,d] for d=1:D))*100),digits=2), "%")
    end

else
    println("No optimal solution available")
end

#=
#************************************************************************
DA_price_df=DataFrame(DA_price)
PG_df=DataFrame(value.(p_g[:]),:auto)
PD_df=DataFrame(value.(p_d[:]),:auto)

PW_Grid_df=DataFrame(value.(p_w_grid_DA[:]),:auto)
Hydrogen_Prodcution_Day_ahead_df=DataFrame(value.(p_w_H2_DA[:]), Wind_turbines)

#**************************
if(isfile("results_step4_zonal.xlsx"))
    rm("results_step4_zonal.xlsx")
end

XLSX.writetable("results_step5_Day_Ahead_Market2.xlsx",
    DA_Prices = (collect(eachcol(DA_price_df)), names(DA_price_df)),
    Generation = (collect(eachcol(PG_df)), names(PG_df)),
    Demand=(collect(eachcol(PD_df)), names(PD_df)),
    Wind_to_Grid=(collect(eachcol(PW_Grid_df)), names(PW_Grid_df)),
    Hydrogen_Prodcution_Day_ahead=(collect(eachcol(Hydrogen_Prodcution_Day_ahead_df)), names(Hydrogen_Prodcution_Day_ahead_df))
)
#*****************************************************

=#