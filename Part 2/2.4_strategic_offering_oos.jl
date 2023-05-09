#************************************************************************
# Initialization
using JuMP
using Gurobi
using DataFrames
import XLSX
using DataFrames
using XLSX

#************************************************************************

#************************************************************************
#PARAMETERS
include("A2_data_step_2.4_oos.jl")


#************************************************************************

#************************************************************************
# Model
FN = Model(Gurobi.Optimizer)

@variable(FN,p_d[d=1:D]>=0) #load of demand
@variable(FN,p_o[g=1:G]>=0) #power scheduled of generetor g
@variable(FN,p_s[s=1:S]>=0) #power scheduled of strategic generetor g

@variable(FN,theta[n=1:N]) #voltage angle at each bus
@variable(FN,f[n=1:N,m=1:N]) #DC flows between nodes n to m


@objective(FN, Max, sum(alpha_bid[sc,k]*alpha_bid_fix[k]*p_d[d] for d=1:D)  #Revenue from demand
            - sum(cg[g]*p_o[g] for g=1:G)  
            - sum(alpha_offer_s[s]*p_s[s] for g=1:S))

#Capacity Limits
@constraint(FN,[k=1:K, sc=1:SC], d[k] <= D_max_k[k]*demand[sc,k])   #Demand limits constraint
@constraint(FN,[o=2:O, sc=1:SC], p_o[o,sc] <= P_max_o[o])           #Generation limits constraint
@constraint(FN,[o=1, sc=1:SC], p_o[o,sc] <= P_max_o[o]*wind_prod[sc,1]) #Wind farm production constraint

#Power Balance
@constraint(FN, Balance[n=1:N], sum(p_d[d] for d=1:D if psi_D[d,n]==1) 
                                + sum(f[n,m] for m=1:N if F[n,m]>0) 
                                - sum(p_o[o,] for g=1:G if psi_O[g,n]==1)
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


    #cg[g]*p_g[g]
    SW= sum(U_d[d]*value.(p_d[d]) for d=1:D) 
        - sum(cg[g]*value.(p_g[g]) for g=1:G)

    profit=value.(p_g).*(value.(psi_O)*value.(DA_price)-cg)

    DA_price_df=DataFrame(transpose(DA_price), nodes)
    DC_flow_df=DataFrame(value.(transpose(f[:, :])),nodes)
    Pg_nodal_df=DataFrame(value.(p_g[:]')*psi_O,nodes)
    Pd_nodal_df=DataFrame(value.(p_d[:]')*psi_D,nodes)
    Price_g_df= DataFrame(Alpha_offer_o=psi_O*value.(DA_price), P_g=value.(p_g))
    Bid_d_df= DataFrame(Alpha_bid=value.(U_d[:]), D=value.(p_d[:]))
    SW_vs_Prof_df=DataFrame(Social_welfare=SW, Profit_max= sum(profit))
    Profit_df= DataFrame([value.(profit[:])],:auto)
else
    println("No optimal solution available")
end

println(DC_flow_df)
println("Powergenerated by each generator: ", value.(p_g))
#println(PG_df)

#************************************************************************

#**************************
if(isfile("A2_results_step2.1.xlsx"))
    rm("A2_results_step2.1.xlsx")
end

XLSX.writetable("A2_results_step2.1.xlsx",
    DC_flow= (collect(eachcol(DC_flow_df)), names(DC_flow_df)),
    Pg_nodal = (collect(eachcol(Pg_nodal_df)), names(Pg_nodal_df)),
    Pd_nodal=(collect(eachcol(Pd_nodal_df)), names(Pd_nodal_df)),
    Clearing = (collect(eachcol(DA_price_df)), names(DA_price_df)),
    Price_g = (collect(eachcol(Price_g_df)), names(Price_g_df)),
    Bid_d= (collect(eachcol(Bid_d_df)), names(Bid_d_df)),
    Profit= (collect(eachcol(Profit_df)), names(Profit_df)),
    SW_vs_Prof= (collect(eachcol(SW_vs_Prof_df)), names(SW_vs_Prof_df))
    )

#*****************************************************