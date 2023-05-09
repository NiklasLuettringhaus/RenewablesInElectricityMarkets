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

@variable(FN,d[k=1:K, sc=1:SC]>=0) #load of demand
@variable(FN,p_o[o=1:O, sc=1:SC]>=0) #power scheduled of generetor o
@variable(FN,p_s[s=1:S,sc=1:SC]>=0) #power scheduled of strategic generetor s

@variable(FN,theta[n=1:N,sc=1:SC]) #voltage angle at each bus
@variable(FN,f[n=1:N,m=1:N,sc=1:SC]) #DC flows between nodes n to m


@objective(FN, Max, sum(prob * alpha_bid[sc,k]*alpha_bid_fix[k]*d[k,sc] for k=1:K, sc=1:SC)  #Revenue from demand
            - sum(prob * alpha_offer_o[sc,o]*alpha_offer_o_fix[o]*p_o[o,sc] for o=1:O, sc=1:SC)  
            - sum(prob * alpha_offer_s[s]*p_s[s,sc] for s=1:S, sc=1:SC))

#Capacity Limits
@constraint(FN,[k=1:K, sc=1:SC], d[k,sc] <= D_max_k[k]*demand[sc,k])   #Demand limits constraint
@constraint(FN,[o=2:O, sc=1:SC], p_o[o,sc] <= P_max_o[o])           #non-strategic Generation limits constraint
@constraint(FN,[o=1, sc=1:SC], p_o[o,sc] <= P_max_o[o]*wind_prod[sc,1]) #Wind farm production constraint
@constraint(FN,[s=1:S, sc=1:SC], p_s[s,sc] <= P_max_s[s]) #Generation limit of strategic producers  

#Power Balance
@constraint(FN, Balance[n=1:N, sc=1:SC], sum(d[k,sc] for k=1:K if psi_k[k,n]==1) 
                                + sum(f[n,m,sc] for m=1:N if F[n,m]>0) 
                                - sum(p_o[o,sc] for o=1:O if psi_o[o,n]==1)
                                - sum(p_s[s,sc] for s=1:S if psi_s[s,n]==1) 
                                ==0)

#Ramping up and down constraints

#Power Flow constraints
@constraint(FN,[n=1:N,m=1:N,sc=1:SC],f[n,m,sc]<=F[n,m]) # Max Capacity of line connecting bus n to m
@constraint(FN,[n=1:N,m=1:N,sc=1:SC],f[n,m,sc]>=-F[n,m]) # Min Capacity of line connecting bus n to m
@constraint(FN,[sc=1:SC],theta[1,sc]== 0) # Voltage angle at the reference bus
@constraint(FN,[n=1:N,m=1:N, sc=1:SC], f[n,m,sc]==Sys_power_base*B[n,m]*(theta[n,sc]-theta[m,sc])) #Power flow constraints


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
    lambda = -dual.(Balance) #Equilibrium price

    profit_s = zeros(S)
    for s= 1:S
    profit_s[s]= sum(prob * value.(p_s[s,sc])*value.(lambda[n,sc]) for n=1:N, sc=1:SC) - sum(prob * value.(p_s[s,sc])*C_s[s] for sc=1:SC)
    end
    #=
    DA_price_df=DataFrame(transpose(DA_price), nodes)
    DC_flow_df=DataFrame(value.(transpose(f[:, :])),nodes)
    Pg_nodal_df=DataFrame(value.(p_g[:]')*psi_O,nodes)
    Pd_nodal_df=DataFrame(value.(p_d[:]')*psi_D,nodes)
    Price_g_df= DataFrame(Alpha_offer_o=psi_O*value.(DA_price), P_g=value.(p_g))
    Bid_d_df= DataFrame(Alpha_bid=value.(U_d[:]), D=value.(p_d[:]))
    SW_vs_Prof_df=DataFrame(Social_welfare=SW, Profit_max= sum(profit))
    Profit_df= DataFrame([value.(profit[:])],:auto)
    =#
else
    println("No optimal solution available")
end

#println(DC_flow_df)
#println("Powergenerated by each generator: ", value.(p_g))
#println(PG_df)

#************************************************************************

#**************************
#=
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
=#
#*****************************************************