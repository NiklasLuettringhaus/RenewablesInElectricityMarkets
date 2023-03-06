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

@variable(FN,p_w_grid[t=1:T,w=1:W]>=0) #wind farm production to grid
@variable(FN,up_bal_w_H2[t=1:T,w=1:W]>=0) # up balancing action of electrolyzers
@variable(FN,down_bal_w_H2[t=1:T,w=1:W]>=0) # down balancing action of electrolyzers
@variable(FN, wind_cur[t=1:T,w=1:W]>=0) #wind farm curtailment if electrolyzer
@variable(FN, load_cur[t=1:T, d=1:D]>=0) #load curtailment

@variable(FN,p_w_grid_DA[t=1:T,w=1:W]>=0) #wind farm production to grid from DA
@variable(FN,p_w_H2_DA[t=1:T,w=1:W]>=0) #wind farm production to electrolyzer from DA

@variable(FN,p_g[t=1:T,g=1:G]>=0) #power scheduled of generetor g
#@variable(FN,theta[t=1:T,n=1:N]) #voltage angle at each bus
@variable(FN,f[t=1:T,a=1:A,b=1:A]) #DC flows between nodes n to m



@objective(FN, Max, sum(U_d[t,d]*p_d[t,d] for t=1:T,d=1:D)  #Revenue from demand
            - sum(C_g[g]*p_g[t,g] for t=1:T,g=1:G)) # Production cost + start-up cost conventional generator

#Capacity Limits
@constraint(FN,[t=1:T,d=1:D], p_d[t,d] <= Cap_d[d]) #Demand limits constraint
@constraint(FN,[t=1:T,g=1:G], p_g[t,g] <= Cap_g[g]) #Generation limits constraint
@constraint(FN,[t=1:T,w=1:W], p_w_grid_DA[t,w] + p_w_H2_DA[t,w] <= WF_prod[t,w]) #Weather-based limits constraint WF from DA market

#Power Balance
@constraint(FN, Balance[t=1:T,a=1:A], sum(p_d[t,d]*psi_d[d,n] for d=1:D, n=1:N if psi_n[n,a]==1) 
                                + sum(f[t,a,b] for b=1:A if ATC[a,b]>0) 
                                - sum(p_w_grid[t,w]*psi_w[w,n] for w=1:W, n=1:N if psi_n[n,a]==1) 
                                - sum(p_g[t,g]*psi_g[g,n] for g=1:G, n=1:N if psi_n[n,a]==1)
                                ==0)

#Ramping up and down constraints
@constraint(FN,[t=1:T,g=1:G], p_g[t,g] <= (t-1<1 ? Cap_g_init[g] : p_g[t-1,g]) + Ramp_g_u[g]) #ramp up constraint
@constraint(FN,[t=1:T,g=1:G], p_g[t,g] >= (t-1<1 ? Cap_g_init[g] : p_g[t-1,g]) - Ramp_g_d[g]) #ramp down constraint

#Power Flow constraints
#@constraint(FN,[t=1:T,n=1:N,m=1:N],f[t,n,m]<=F[n,m]) # Max Capacity of line connecting bus n to m
#@constraint(FN,[t=1:T,n=1:N,m=1:N],f[t,n,m]>=-F[n,m]) # Min Capacity of line connecting bus n to m
@constraint(FN,[t=1:T,a=1:A,b=1:A],f[t,a,b]<=ATC[a,b]) # Max ATC connecting zones a to b
@constraint(FN,[t=1:T,a=1:A,b=1:A],f[t,a,b]>=-ATC[b,a]) # Min ATC connecting zones a to b
@constraint(FN,[t=1:T,a=1:A,b=1:A],f[t,a,b]==-f[t,b,a]) #Symmetrical flow

#Electrolyzer constraints
@constraint(FN,[t=1:T, w=1:2], 0.01*(WF_cap[w]/2) <= p_w_H2_DA[t,w] <= WF_cap[w]/2)
@constraint(FN,[t=1:T, w=1:2], sum(p_w_H2_DA[t,w]*H2_prod for t=1:T) >= H2_cap)

#Balancing action
@constraint(FN,[t=1:T; sum(WF_error[t,w] for w=1:W) >= 0], sum(WF_error[t,w] for w=1:W) == sum(wind_cur[t,w] for w=1:W) + sum(up_bal_w_H2[t,w] for w=1:2))    #up balancing action of electrolyzer needs to match WF error
@constraint(FN,[t=1:T; sum(WF_error[t,w] for w=1:W) < 0], abs(sum(WF_error[t,w] for w=1:W)) == sum(load_cur[t,d] for d=1:D) + sum(down_bal_w_H2[t,w] for w=1:2))  #down balancing action of electrolyzer needs to match WF error
@constraint(FN,[t=1:T, w=1:2], -down_bal_w_H2[t,w] <= p_w_H2_DA[t,w] - 0.01*(WF_cap[w]/2))              #maximum down balancing
@constraint(FN,[t=1:T, w=1:2], up_bal_w_H2[t,w] <= WF_cap[w]/2 - p_w_H2_DA[t,w])                        #maximum up balancing

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
    println("Market clearing price:")
    print(DA_price)  #Print equilibrium price
    println("\n")
    DA_price_df=DataFrame(DA_price,areas)
    Flows_df=DataFrame(value.(f[1, :, :]),areas)
    PG_df=DataFrame(value.(p_g[:, :]),:auto)
    PD_df=DataFrame(value.(p_d[:, :]),:auto)
    PW_Grid_df=DataFrame(value.(p_w_grid[:, :]),:auto)
    PG_zonal_df=DataFrame(value.(p_g[:, :])*psi_g*psi_n,areas)
    PD_zonal_df=DataFrame(value.(p_d[:, :])*psi_d*psi_n,areas)
    PW_Grid_zonal_df=DataFrame(value.(p_w_grid[:, :])*psi_w*psi_n,areas)

else
    println("No optimal solution available")
end

#************************************************************************

#**************************
if(isfile("results_step4_zonal.xlsx"))
    rm("results_step4_zonal.xlsx")
end

XLSX.writetable("results_step4_zonal.xlsx",
    DA_Prices = (collect(eachcol(DA_price_df)), names(DA_price_df)),
    Flows = (collect(eachcol(Flows_df)), names(Flows_df)),
    Generation = (collect(eachcol(PG_df)), names(PG_df)),
    Demand=(collect(eachcol(PD_df)), names(PD_df)),
    Wind=(collect(eachcol(PW_Grid_df)), names(PW_Grid_df)),
    Zonal_Generation=(collect(eachcol(PG_zonal_df)), names(PG_zonal_df)),
    Zonal_Demand=(collect(eachcol(PD_zonal_df)), names(PD_zonal_df)),
    Zonal_Wind=(collect(eachcol(PW_Grid_zonal_df)), names(PW_Grid_zonal_df)),
    )

#*****************************************************
=#