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
include("data_Step_4.jl")

#************************************************************************

#************************************************************************
# Model
FN = Model(Gurobi.Optimizer)

@variable(FN,p_d[t=1:T,d=1:D]>=0) #load of demand

@variable(FN,up_bal_w_H2[t=1:T,w=1:W]>=0) # up balancing action of electrolyzers
@variable(FN,down_bal_w_H2[t=1:T,w=1:W]>=0) # down balancing action of electrolyzers
@variable(FN, wind_cur[t=1:T, w=1:W]>=0) #wind farm curtailment if electrolyzer
@variable(FN, load_cur[t=1:T, d=1:D]>=0) #load curtailment

@variable(FN,p_w_grid_DA[t=1:T,w=1:W]>=0) #wind farm production to grid from DA
@variable(FN,p_w_H2_DA[t=1:T,w=1:W]>=0) #wind farm production to electrolyzer from DA

@variable(FN,p_g[t=1:T,g=1:G]>=0) #power scheduled of generetor g
@variable(FN,f[t=1:T,a=1:A,b=1:A]) #DC flows between nodes n to m



@objective(FN, Max, sum(U_d[t,d]*p_d[t,d] for t=1:T,d=1:D)              #Revenue from demand
            - sum(cost_load_cur*load_cur[t,d] for t=1:T, d=1:D)         #curtailment cost load
            - sum(C_g[g]*p_g[t,g] for t=1:T,g=1:G)                      #Production cost + start-up cost conventional generator
            - sum(up_bal_w_H2[t,w]*0.85*DA_price[t] for t=1:T, w=1:2)   #cost for upbalancing > lowering consumption
            - sum(down_bal_w_H2[t,w]*1.1*DA_price[t] for t=1:T, w=1:2)) #cost for downbalancing > increasing consumption

#Capacity Limits
@constraint(FN,[t=1:T,d=1:D], p_d[t,d] <= Cap_d[t,d]) #Demand limits constraint
@constraint(FN,[t=1:T,g=1:G], p_g[t,g] <= Cap_g[g]) #Generation limits constraint
@constraint(FN,[t=1:T,w=1:W], p_w_grid_DA[t,w] + p_w_H2_DA[t,w] <= WF_prod[t,w]) #Weather-based limits constraint WF from DA market

#Power Balance
@constraint(FN, Balance[t=1:T,a=1:A], sum(p_d[t,d]*psi_d[d,n] for d=1:D, n=1:N if psi_n[n,a]==1) 
                                + sum(f[t,a,b] for b=1:A if ATC[a,b]>0) 
                                - sum(p_w_grid_DA[t,w]*psi_w[w,n] for w=1:W, n=1:N if psi_n[n,a]==1) 
                                - sum(p_g[t,g]*psi_g[g,n] for g=1:G, n=1:N if psi_n[n,a]==1)
                                ==0)

#Ramping up and down constraints
@constraint(FN,[t=1:T,g=1:G], p_g[t,g] <= (t-1<1 ? Cap_g_init[g] : p_g[t-1,g]) + Ramp_g_u[g]) #ramp up constraint
@constraint(FN,[t=1:T,g=1:G], p_g[t,g] >= (t-1<1 ? Cap_g_init[g] : p_g[t-1,g]) - Ramp_g_d[g]) #ramp down constraint

#Power Flow constraints
@constraint(FN,[t=1:T,a=1:A,b=1:A],f[t,a,b]<=ATC[a,b]) # Max ATC connecting zones a to b
@constraint(FN,[t=1:T,a=1:A,b=1:A],f[t,a,b]>=-ATC[b,a]) # Min ATC connecting zones a to b
@constraint(FN,[t=1:T,a=1:A,b=1:A],f[t,a,b]==-f[t,b,a]) #Symmetrical flow

#Electrolyzer constraints
@constraint(FN,[t=1:T, w=1:2], 0.01*(WF_cap[w]/2) <= p_w_H2_DA[t,w] <= WF_cap[w]/2)
@constraint(FN,[t=1:T, w=1:2], sum(p_w_H2_DA[t,w]*H2_prod for t=1:T) >= H2_cap)

#Balancing action
@constraint(FN,[t=1:T; sum(WF_error[t,w] for w=1:W) >= 0], sum(WF_error[t,w] for w=1:W) == sum(wind_cur[t,w] for w=1:W) + sum(down_bal_w_H2[t,w] for w=1:2))    #down balancing action of electrolyzer needs to match WF error
@constraint(FN,[t=1:T; sum(WF_error[t,w] for w=1:W) < 0], abs(sum(WF_error[t,w] for w=1:W)) == sum(load_cur[t,d] for d=1:D) + sum(up_bal_w_H2[t,w] for w=1:2))  #up balancing action of electrolyzer needs to match WF error
@constraint(FN,[t=1:T, w=1:2], -up_bal_w_H2[t,w] <= p_w_H2_DA[t,w] - 0.01*(WF_cap[w]/2))                    #maximum up balancing
@constraint(FN,[t=1:T, w=1:2], down_bal_w_H2[t,w] <= WF_cap[w]/2 - p_w_H2_DA[t,w])                          #maximum down balancing

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
            println("Hour $t: ", round(value((sum(p_d[t,d] for d=1:D)/sum(Cap_d[t,d] for d=1:D))*100),digits=2), "%")
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