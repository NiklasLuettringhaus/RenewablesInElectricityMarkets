#************************************************************************
# Incredible Chairs, Simple LP
using JuMP
using Gurobi
using DataFrames
import XLSX

#import Pkg; Pkg.add("XLSX")
#import Pkg; Pkg.add("DataFrames")

using DataFrames
using XLSX

#************************************************************************

#************************************************************************
#PARAMETERS
include("data_Step_3.jl")

#************************************************************************



#************************************************************************
# Model
FN = Model(Gurobi.Optimizer)

@variable(FN,p_d[t=1:T,d=1:D]>=0) #load of demand
@variable(FN,p_w_grid[t=1:T,w=1:W]>=0) #wind farm production to grid
@variable(FN,p_w_H2[t=1:T,w=1:W]>=0) #wind farm production to electrolyzer
@variable(FN,p_g[t=1:T,g=1:G]>=0) #power scheduled of generetor g
@variable(FN,theta[t=1:T,n=1:N]) #voltage angle at each bus
@variable(FN,f[t=1:T,n=1:N,m=1:N]) #DC flows between nodes n to m

@objective(FN, Max, sum(U_d[t,d]*p_d[t,d] for t=1:T,d=1:D)  #Revenue from demand
            - sum(C_g[g]*p_g[t,g] for t=1:T,g=1:G)) # Production cost + start-up cost conventional generator

#Capacity Limits
@constraint(FN,[t=1:T,d=1:D], p_d[t,d] <= Cap_d[d]) #Demand limits constraint
@constraint(FN,[t=1:T,g=1:G], p_g[t,g] <= Cap_g[g]) #Generation limits constraint
@constraint(FN,[t=1:T,w=1:W], p_w_grid[t,w] + p_w_H2[t,w] <= WF_prod[t,w]) #Weather-based limits constraint WF

#Power Balance
@constraint(FN, Balance[t=1:T,n=1:N], sum(p_d[t,d] for d=1:D if psi_d[d,n]==1) 
                                + sum(f[t,n,m] for m=1:N if F[n,m]>0) 
                                - sum(p_w_grid[t,w] for w=1:W if psi_w[w,n]==1) 
                                - sum(p_g[t,g] for g=1:G if psi_g[g,n]==1)
                                ==0)

#Ramping up and down constraints
@constraint(FN,[t=1:T,g=1:G], p_g[t,g] <= (t-1<1 ? Cap_g_init[g] : p_g[t-1,g]) + Ramp_g_u[g]) #ramp up constraint
@constraint(FN,[t=1:T,g=1:G], p_g[t,g] >= (t-1<1 ? Cap_g_init[g] : p_g[t-1,g]) - Ramp_g_d[g]) #ramp down constraint

#Power Flow constraints
@constraint(FN,[t=1:T,n=1:N,m=1:N],f[t,n,m]<=F[n,m]) # Max Capacity of line connecting bus n to m
@constraint(FN,[t=1:T,n=1:N,m=1:N],f[t,n,m]>=-F[n,m]) # Min Capacity of line connecting bus n to m
@constraint(FN,[t=1:T],theta[t,1]==0) # Voltage angle at the reference bus
@constraint(FN,[t=1:T,n=1:N,m=1:N], f[t,n,m]==Sys_power_base*B[n,m]*(theta[t,n]-theta[t,m])) #Power flow constraints

#Electrolyzer constraints
@constraint(FN,[t=1:T, w=1:2], 0.01*(WF_cap[w]/2) <= p_w_H2[t,w] <= WF_cap[w]/2)
@constraint(FN,[t=1:T, w=1:2], sum(p_w_H2[t,w]*H2_prod for t=1:T) >= H2_cap)

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
    DA_price_df=DataFrame(DA_price,nodes)
    DC_flow_df=DataFrame(value.(f[1, :, :]),nodes)
    PG_df=DataFrame(value.(p_g[:, :]),:auto)
    PD_df=DataFrame(value.(p_d[:, :]),:auto)
    PW_Grid_df=DataFrame(value.(p_w_grid[:, :]),:auto)
    PG_nodal_df=DataFrame(value.(p_g[:, :])*psi_g,nodes)
    PD_nodal_df=DataFrame(value.(p_d[:, :])*psi_d,nodes)
    PW_nodal_zonal_df=DataFrame(value.(p_w_grid[:, :])*psi_w,nodes)
else
    println("No optimal solution available")
end

#************************************************************************

#**************************
if(isfile("results_step3_nodal.xlsx"))
    rm("results_step3_nodal.xlsx")
end

XLSX.writetable("results_step3_nodal.xlsx",
    DA_Prices = (collect(eachcol(DA_price_df)), names(DA_price_df)),
    Flows = (collect(eachcol(DC_flow_df)), names(DC_flow_df)),
    Generation = (collect(eachcol(PG_df)), names(PG_df)),
    Demand=(collect(eachcol(PD_df)), names(PD_df)),
    Wind=(collect(eachcol(PW_Grid_df)), names(PW_Grid_df)),
    Nodal_Generation=(collect(eachcol(PG_nodal_df)), names(PG_nodal_df)),
    Nodal_Demand=(collect(eachcol(PD_nodal_df)), names(PD_nodal_df)),
    Nodal_Wind=(collect(eachcol(PW_nodal_zonal_df)), names(PW_nodal_zonal_df)),
    )

#*****************************************************


