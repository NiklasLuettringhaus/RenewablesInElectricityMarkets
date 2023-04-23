#************************************************************************
# Incredible Chairs, Simple LP
using JuMP
using Gurobi
using DataFrames
import XLSX

#import Pkg; Pkg.add("XLSX")
#import Pkg; Pkg.add("DataFrames")

#************************************************************************

#************************************************************************
#PARAMETERS
include("A2_data_step_2.1.jl")

#************************************************************************



#************************************************************************
# Model
FN = Model(Gurobi.Optimizer)

@variable(FN,p_d[d=1:D]>=0) #load of demand
@variable(FN,p_g[g=1:G]>=0) #power scheduled of generetor g

@variable(FN,theta[n=1:N]) #voltage angle at each bus
@variable(FN,f[n=1:N,m=1:N]) #DC flows between nodes n to m


@objective(FN, Max, sum(U_d[d]*p_d[d] for d=1:D)  #Revenue from demand
            - sum(cg[g]*p_g[g] for g=1:G)) # Production cost + start-up cost conventional generator

#Capacity Limits
@constraint(FN,[d=1:D], p_d[d] <= Cap_d[d]) #Demand limits constraint
@constraint(FN,[g=1:G], p_g[g] <= Cap_g[g]) #Generation limits constraint

#Power Balance
@constraint(FN, Balance[n=1:N], sum(p_d[d] for d=1:D if psi_D[d,n]==1) 
                                + sum(f[n,m] for m=1:N if F[n,m]>0) 
                                - sum(p_g[g] for g=1:G if psi_O[g,n]==1)
                                ==0)

#Ramping up and down constraints

#Power Flow constraints
@constraint(FN,[n=1:N,m=1:N],f[n,m]<=F[n,m]) # Max Capacity of line connecting bus n to m
@constraint(FN,[n=1:N,m=1:N],f[n,m]>=-F[n,m]) # Min Capacity of line connecting bus n to m
@constraint(FN,theta[1]== 0) # Voltage angle at the reference bus
@constraint(FN,[n=1:N,m=1:N], f[n,m]==Sys_power_base*B[n,m]*(theta[n]-theta[m])) #Power flow constraints


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
    #Profit_gen=sum(value.(p_g).*(DA_price*(psi_O)')-value.(p_g).*(repeat(C_g', inner=[24, 1])), dims=1)
    println("Market clearing price:")
    print(DA_price)  #Print equilibrium price
    println("\n")
    DA_price_df=DataFrame(transpose(DA_price), nodes)
    #DC_flow_df=DataFrame(value.(f[1, :, :]),nodes)
    #PG_df=DataFrame(value.(p_g[:, :]),:auto)
    #PD_df=DataFrame(value.(p_d[:, :]),:auto)
    #PW_Grid_df=DataFrame(value.(p_w_grid[:, :]),:auto)
    #PG_nodal_df=DataFrame(value.(p_g[:, :])*psi_O,nodes)
    #PD_nodal_df=DataFrame(value.(p_d[:, :])*psi_D,nodes)
    #PW_nodal_zonal_df=DataFrame(value.(p_w_grid[:, :])*psi_w,nodes)
    #Profit_gen_df=DataFrame(Profit_gen,:auto)
else
    println("No optimal solution available")
end

#************************************************************************

#**************************
if(isfile("A2_results_step2.1.xlsx"))
    rm("A2_results_step2.xlsx")
end

XLSX.writetable("A2_results_step2.xlsx",
    DA_Prices = (collect(eachcol(DA_price_df)), names(DA_price_df)),
    Flows = (collect(eachcol(DC_flow_df)), names(DC_flow_df)),
    Generation = (collect(eachcol(PG_df)), names(PG_df)),
    Demand=(collect(eachcol(PD_df)), names(PD_df)),
    Wind=(collect(eachcol(PW_Grid_df)), names(PW_Grid_df)),
    Nodal_Generation=(collect(eachcol(PG_nodal_df)), names(PG_nodal_df)),
    Nodal_Demand=(collect(eachcol(PD_nodal_df)), names(PD_nodal_df)),
    Nodal_Wind=(collect(eachcol(PW_nodal_zonal_df)), names(PW_nodal_zonal_df)),
    Profit_gen=(collect(eachcol(Profit_gen_df)), names(Profit_gen_df)),
    Profit_wind=(collect(eachcol(Profit_wind_df)), names(Profit_wind_df))
    )

#*****************************************************

