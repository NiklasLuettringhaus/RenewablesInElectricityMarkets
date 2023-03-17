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
include("data_Step_5.jl")

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
@constraint(FN,[t=1:T, d=1:D], sum(up_g[t,g] + up_e[t,w] for g=1:G, w=1:2) == Cap_d[t,d]*0.2)      #up reserve requirements     
@constraint(FN,[t=1:T, d=1:D], sum(down_g[t,g] + down_e[t,w] for g=1:G, w=1:2) == Cap_d[t,d]*0.15) #up reserve  limits constraint

@constraint(FN,[t=1:T,g=1:G], up_g[t,g] <= Cap_g[g])        #Generation limits constraint
@constraint(FN,[t=1:T,g=1:G], down_g[t,g] <= Cap_g[g])      #Generation limits constraint
@constraint(FN,[t=1:T,w=1:2], up_e[t,w] <= WF_cap[w]/2)   #capacity-based limits constraint WF
@constraint(FN,[t=1:T,w=1:2], down_e[t,w] <= WF_cap[w]/2) #capacity-based limits constraint WF

#=
#Ramping up and down constraints
@constraint(FN,[t=1:T,g=1:G], abs(up_g[t,g])-abs((t-1<1 ? Cap_g_init[g] : up_g[t-1,g]))<=Ramp_g_d[g])
@constraint(FN,[t=1:T,g=1:G], p_g[t,g] >= (t-1<1 ? Cap_g_init[g] : p_g[t-1,g]) - Ramp_g_d[g]) #ramp down constraint
=#

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

    println("Cost of hydrogen production: ", round(value(sum(DA_price[t]*p_w_H2_DA[t,w] for t=1:T, w=1:2)), digits = 2))
    println("Cost of up balancing: ", round(value(sum(up_bal_w_H2[t,w]*0.85*DA_price[t] for t=1:T, w=1:2)), digits = 2))
    println("Cost of down balancing: ", round(value(sum(down_bal_w_H2[t,w]*1.1*DA_price[t] for t=1:T, w=1:2)), digits = 2))
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
    DA_price_df=DataFrame(DA_price,areas)
    Flows_df=DataFrame(value.(f[1, :, :]),areas)
    PG_df=DataFrame(value.(p_g[:, :]),:auto)
    PD_df=DataFrame(value.(p_d[:, :]),:auto)
    PW_Grid_df=DataFrame(value.(p_w_grid_DA[:, :]),:auto)
    PG_zonal_df=DataFrame(value.(p_g[:, :])*psi_g*psi_n,areas)
    PD_zonal_df=DataFrame(value.(p_d[:, :])*psi_d*psi_n,areas)
    PW_Grid_zonal_df=DataFrame(value.(p_w_grid_DA[:, :])*psi_w*psi_n,areas)

    Hydrogen_Prodcution_Day_ahead_df=DataFrame(value.(p_w_H2_DA[: , :]), Wind_turbines)
    Down_Blancing_H2_df=DataFrame(value.(down_bal_w_H2[:, :]),Wind_turbines )
    Up_Blancing_H2_df=DataFrame(value.(up_bal_w_H2[:, :]), Wind_turbines)
    Load_Curtailment_df=DataFrame(value.(load_cur[:, :]), vec(Loads))
    Lindt_Curtailment_df=DataFrame(value.(wind_cur[:, :]), Wind_turbines)                   #Rittersport is better anyway


else
    println("No optimal solution available")
end

println(Load_Curtailment_df)
#************************************************************************

#**************************
if(isfile("results_step4_zonal.xlsx"))
    rm("results_step4_zonal.xlsx")
end

XLSX.writetable("results_step4_H2_zonal.xlsx",
    DA_Prices = (collect(eachcol(DA_price_df)), names(DA_price_df)),
    Flows = (collect(eachcol(Flows_df)), names(Flows_df)),
    Generation = (collect(eachcol(PG_df)), names(PG_df)),
    Demand=(collect(eachcol(PD_df)), names(PD_df)),
    Wind_to_Grid=(collect(eachcol(PW_Grid_df)), names(PW_Grid_df)),
    Zonal_Generation=(collect(eachcol(PG_zonal_df)), names(PG_zonal_df)),
    Zonal_Demand=(collect(eachcol(PD_zonal_df)), names(PD_zonal_df)),
    Zonal_Wind=(collect(eachcol(PW_Grid_zonal_df)), names(PW_Grid_zonal_df)),

    Hydrogen_Prodcution_Day_ahead=(collect(eachcol(Hydrogen_Prodcution_Day_ahead_df)), names(Hydrogen_Prodcution_Day_ahead_df)),
    Down_Blancing_H2=(collect(eachcol(Down_Blancing_H2_df)), names(Down_Blancing_H2_df)),
    Up_Blancing_H2=(collect(eachcol(Up_Blancing_H2_df)), names(Up_Blancing_H2_df)),
    Lindt_Curtailment=(collect(eachcol(Lindt_Curtailment_df)), names(Lindt_Curtailment_df)), #no chocolate for you
    Load_Curtailment=(collect(eachcol(Load_Curtailment_df)), names(Load_Curtailment_df)),

    )

#*****************************************************