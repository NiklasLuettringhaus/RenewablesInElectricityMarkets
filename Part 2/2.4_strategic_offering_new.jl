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
include("A2_data_step_2.4.jl")


#************************************************************************

#************************************************************************
# Model
A2_22 = Model(Gurobi.Optimizer)

#Decision_variables
@variable(A2_22, alpha_offer_s[s=1:S]>=0)
@variable(A2_22, d[k=1:K,sc=1:SC]>=0)
@variable(A2_22, p_s[s=1:S,sc=1:SC]>=0)
@variable(A2_22, p_o[o=1:O,sc=1:SC]>=0)

@variable(A2_22, mu_up_k[k=1:K,sc=1:SC]>=0)
@variable(A2_22, mu_up_s[s=1:S,sc=1:SC]>=0)
@variable(A2_22, mu_up_o[o=1:O,sc=1:SC]>=0)
@variable(A2_22, mu_up_nm[sc=1:SC,n=1:N,m=1:N;Omega[n,m]==1]>=0)

@variable(A2_22, mu_down_k[k=1:K,sc=1:SC]>=0)
@variable(A2_22, mu_down_s[s=1:S,sc=1:SC]>=0)
@variable(A2_22, mu_down_o[o=1:O,sc=1:SC]>=0)
@variable(A2_22, mu_down_nm[sc=1:SC,n=1:N,m=1:N;Omega[n,m]==1]>=0)

@variable(A2_22, lambda[n=1:N,sc=1:SC])    
@variable(A2_22, gamma[n=1,sc=1:SC])     

@variable(A2_22, u_down_k[k=1:K,sc=1:SC],Bin)
@variable(A2_22, u_down_s[s=1:S,sc=1:SC],Bin)
@variable(A2_22, u_down_o[o=1:O,sc=1:SC],Bin)
@variable(A2_22, u_down_nm[sc=1:SC,n=1:N,m=1:N;Omega[n,m]==1],Bin)

@variable(A2_22, u_up_k[k=1:K,sc=1:SC],Bin)
@variable(A2_22, u_up_s[s=1:S,sc=1:SC],Bin)
@variable(A2_22, u_up_o[o=1:O,sc=1:SC],Bin)
@variable(A2_22, u_up_nm[sc=1:SC,n=1:N,m=1:N;Omega[n,m]==1],Bin)

@variable(A2_22, theta[n=1:N,sc=1:SC])

#Objective function
@objective(A2_22, Max,
- sum(prob * p_s[s,sc] * C_s[s] for sc=1:SC, s=1:S) 
+ sum(prob * alpha_bid[sc,k]*alpha_bid_fix[k]*d[k,sc] for sc=1:SC, k=1:K) 
- sum(prob * alpha_offer_o[sc,o]*alpha_offer_o_fix[o]*p_o[o,sc] for sc=1:SC, o=1:O)
- sum(prob * mu_up_k[k,sc]*D_max_k[k]*demand[sc,k] for sc=1:SC, k=1:K) 
- sum(prob * mu_up_o[o,sc]*P_max_o[o] for sc=1:SC, o=1:O)
- sum(prob * mu_up_nm[sc,n,m]*F[n,m] for sc=1:SC,n=1:N,m=1:N if Omega[n,m]==1)
- sum(prob * mu_down_nm[sc, n,m]*F[n,m] for sc=1:SC,n=1:N,m=1:N if Omega[n,m]==1) #maybe redundant
)


#************************************************************************
# Constraints

#1_KKT_conditions
#@constraint(A2_22,[k=1:K],-alpha_bid[k]-mu_down_k[k]+mu_up_k[k]+lambda[indexin(1, psi_k[k,:])]==0)  
@constraint(A2_22,[sc=1:SC, k=1:K],-alpha_bid[sc,k]*alpha_bid_fix[k]-mu_down_k[k,sc]+mu_up_k[k,sc]+lambda[findall(x->x==1, psi_k[k,:])[1],sc]==0) 

@constraint(A2_22,[sc=1:SC, s=1:S],alpha_offer_s[s]-mu_down_s[s,sc]+mu_up_s[s,sc]-lambda[findall(x->x==1, psi_s[s,:])[1],sc]==0)

@constraint(A2_22,[sc=1:SC, o=1:O],alpha_offer_o[sc,o]*alpha_offer_o_fix[o]-mu_down_o[o,sc]+mu_up_o[o,sc]-lambda[findall(x->x==1, psi_o[o,:])[1],sc]==0)

@constraint(A2_22,[sc=1:SC, n=1:N], sum(Sys_power_base*B[n,m]*(lambda[n,sc]-lambda[m,sc]) for m=1:N if Omega[n,m]==1) + sum(Sys_power_base*B[n,m]*(mu_up_nm[sc,n,m]-mu_up_nm[sc,m,n]) for m=1:N if Omega[n,m]==1) + (n == 1 ? gamma[1,sc] : 0) ==0) 
#@constraint(A2_22,[n=1:N], sum(Sys_power_base*B[n,m]*(lambda[n]-lambda[m]) for m=1:N if Omega[n,m]==1) + sum(Sys_power_base*B[n,m]*(-mu_down_nm[n,m]+mu_down_nm[m,n]) for m=1:N if Omega[n,m]==1) + (n == 1 ? gamma[1] : 0) ==0) 


#2_KKT_conditions
@constraint(A2_22,[sc=1:SC,n=1],theta[n,sc]==0)  

@constraint(A2_22,[sc=1:SC, n=1:N],sum(d[k,sc] for k=1:K if psi_k[k,n]==1) +sum(Sys_power_base*B[n,m]*(theta[n,sc]-theta[m,sc]) for m=1:N if Omega[n,m]==1) -sum(p_s[s,sc] for s=1:S if psi_s[s,n]==1)- sum(p_o[o,sc] for o=1:O if psi_o[o,n]==1)==0)


#3_KKT_conditions_linearized
@constraint(A2_22,[k=1:K, sc=1:SC],d[k,sc]<=u_down_k[k,sc]*M[1])
@constraint(A2_22,[s=1:S, sc=1:SC],p_s[s,sc]<=u_down_s[s,sc]*M[2]) 
@constraint(A2_22,[o=1:O, sc=1:SC],p_o[o,sc]<=u_down_o[o,sc]*M[3]) 

@constraint(A2_22,[k=1:K, sc=1:SC],mu_down_k[k,sc]<=(1-u_down_k[k,sc])*M[4])
@constraint(A2_22,[s=1:S, sc=1:SC],mu_down_s[s,sc]<=(1-u_down_s[s,sc])*M[5])
@constraint(A2_22,[o=1:O, sc=1:SC],mu_down_o[o,sc]<=(1-u_down_o[o,sc])*M[6])

    #Network constraints

#Network constraints
#@constraint(A2_22,[n=1:N,m=1:N; m!=n],Sys_power_base*B[n,m]*(theta[n]-theta[m])+F[n,m]>=0)  
#@constraint(A2_22,[n=1:N,m=1:N; m!=n],Sys_power_base*B[n,m]*(theta[n]-theta[m])+F[n,m]<=u_down_nm[n,m]*M) 
#@constraint(A2_22,[n=1:N,m=1:N; m!=n],mu_down_nm[n,m]<=(1-u_down_nm[n,m])*M) 

#Network constraints


@constraint(A2_22,[sc=1:SC,n=1:N,m=1:N;Omega[n,m]==1],Sys_power_base*B[n,m]*(theta[n,sc]-theta[m,sc])+F[n,m]>=0)  
@constraint(A2_22,[sc=1:SC,n=1:N,m=1:N;Omega[n,m]==1],Sys_power_base*B[n,m]*(theta[n,sc]-theta[m,sc])+F[n,m]<=u_down_nm[sc,n,m]*M[7]) 
@constraint(A2_22,[sc=1:SC,n=1:N,m=1:N;Omega[n,m]==1],mu_down_nm[sc,n,m]<=(1-u_down_nm[sc,n,m])*M[8]) 


@constraint(A2_22,[sc=1:SC, k=1:K],D_max_k[k]*demand[sc,k]-d[k,sc]>=0)
@constraint(A2_22,[sc=1:SC, s=1:S],P_max_s[s]-p_s[s,sc]>=0)
@constraint(A2_22,[sc=1:SC, o=2:O],P_max_o[o]-p_o[o,sc]>=0)
@constraint(A2_22,[sc=1:SC, o=1],P_max_o[o]*wind_prod[sc,1]-p_o[o,sc]>=0)

@constraint(A2_22,[sc=1:SC, k=1:K],D_max_k[k]*demand[sc,k]-d[k,sc]<=u_up_k[k,sc]*M[9])
@constraint(A2_22,[sc=1:SC, s=1:S],P_max_s[s]-p_s[s,sc]<=u_up_s[s,sc]*M[10])
@constraint(A2_22,[sc=1:SC, o=2:O],P_max_o[o]-p_o[o,sc]<=u_up_o[o,sc]*M[11])
@constraint(A2_22,[sc=1:SC, o=1],P_max_o[o]*wind_prod[sc,1]-p_o[o,sc]<=u_up_o[o,sc]*M[11])

@constraint(A2_22,[sc=1:SC, k=1:K],mu_up_k[k,sc]<=(1-u_up_k[k,sc])*M[12])
@constraint(A2_22,[sc=1:SC, s=1:S],mu_up_s[s,sc]<=(1-u_up_s[s,sc])*M[13])
@constraint(A2_22,[sc=1:SC, o=1:O],mu_up_o[o,sc]<=(1-u_up_o[o,sc])*M[14])

@constraint(A2_22,[sc=1:SC,n=1:N,m=1:N;Omega[n,m]==1],-Sys_power_base*B[n,m]*(theta[n,sc]-theta[m,sc])+F[n,m]>=0)  
@constraint(A2_22,[sc=1:SC,n=1:N,m=1:N;Omega[n,m]==1],-Sys_power_base*B[n,m]*(theta[n,sc]-theta[m,sc])+F[n,m]<=u_up_nm[sc,n,m]*M[15]) 
@constraint(A2_22,[sc=1:SC,n=1:N,m=1:N;Omega[n,m]==1],mu_up_nm[sc,n,m]<=(1-u_up_nm[sc,n,m])*M[16]) 

#************************************************************************


#************************************************************************
# Solve
solution = optimize!(A2_22)
println("Termination status: $(termination_status(A2_22))")
if termination_status(A2_22) == MOI.OPTIMAL
    flow = zeros(N, N)
    for n=1:N
        for m=1:N ;Omega[n,m]==1
        flow[n,m]= sum(prob * Sys_power_base*B[n,m]*(value.(theta[n,sc])-value.(theta[m,sc])) for sc=1:SC)
        end
    end

    #=
    hold_c = zeros(N, N)
    hold_c2 = zeros(N, N)
    for n=1:N
        for m=1:N if Omega[n,m]==1
        hold_c[n,m]=value.(mu_up_nm[n,m])
        hold_c2[n,m]=(1-value.(u_up_nm[n,m]))*M[16]
        end
        end
    end
    =#

    SW= sum(prob * alpha_bid[sc,k]*alpha_bid_fix[k]*value.(d[k,sc]) for k=1:K, sc=1:SC) 
        - sum(prob * alpha_offer_o[sc,o]*alpha_offer_o_fix[o]*value.(p_o[o,sc]) for o=1:O, sc=1:SC)
        - sum(prob * value.(alpha_offer_s[s])*value.(p_s[s,sc]) for s=1:S, sc=1:SC)

    expected_profit = zeros(N)
    for n=1:N
        expected_profit[n] = sum(prob * value.(p_s[s,sc]).*(value.(psi_s[s,n])*value.(lambda[n,sc])-C_s[s]) for s=1:S, sc=1:SC)
    end

    DC_flow_df=DataFrame(value.(flow[:, :]),nodes)
    Ps_nodal_df=DataFrame(value.(p_s[:,:]')*psi_s,nodes)
    Po_nodal_df=DataFrame(value.(p_o[:,:]')*psi_o,nodes)
    Dk_nodal_df=DataFrame(value.(d[:,:]')*psi_k,nodes)
    Clearing_df= DataFrame(value.(lambda[:,:]),:auto)
    Price_s_df= DataFrame([value.(alpha_offer_s[:])], :auto)
    #Price_o_df= DataFrame(Alpha_offer_o=(value.(alpha_offer_o[:])*), P_o=value.(p_o[:]))
    #Bid_d_df= DataFrame(Alpha_bid=value.(alpha_bid[:]), D=value.(d[:]))
    SW_vs_Prof_df=DataFrame(Social_welfare=SW, Profit_max= sum(expected_profit))
    Profit_df= DataFrame([value.(profit[:])],:auto)

else
    println("No optimal solution available")
end
#************************************************************************

#************************************************************************
if(isfile("A2_results_step_2_4.xlsx"))
    rm("A2_results_step_2_4.xlsx")
end

XLSX.writetable("A2_results_step_2_4.xlsx",
    DC_flow_df=(collect(eachcol(DC_flow_df)), names(DC_flow_df)),
    Ps_nodal_df=(collect(eachcol(Ps_nodal_df)), names(Ps_nodal_df)),
    Po_nodal_df=(collect(eachcol(Po_nodal_df)), names(Po_nodal_df)),
    Dk_nodal_df=(collect(eachcol(Dk_nodal_df)), names(Dk_nodal_df)),
    Clearing_df= (collect(eachcol(Clearing_df)), names(Clearing_df)),
    Price_s_df= (collect(eachcol(Price_s_df)), names(Price_s_df)),
    #Price_o_df= (collect(eachcol(Price_o_df)), names(Price_o_df)),
    #Bid_d_df= (collect(eachcol(Bid_d_df)), names(Bid_d_df)),
    SW_vs_Prof_df=(collect(eachcol(SW_vs_Prof_df)), names(SW_vs_Prof_df)),
    Profit_df= (collect(eachcol(Profit_df)), names(Profit_df))
    )

#************************************************************************