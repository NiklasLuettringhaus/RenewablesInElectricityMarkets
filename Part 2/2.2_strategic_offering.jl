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
include("A2_data_step_2.2.jl")

#************************************************************************

#************************************************************************
# Model
A2_22 = Model(Gurobi.Optimizer)

#Decision_variables
@variable(A2_22, alpha_offer_s[s=1:S]>=0)
@variable(A2_22, d[k=1:K]>=0)
@variable(A2_22, p_s[s=1:S]>=0)
@variable(A2_22, p_o[o=1:O]>=0)

@variable(A2_22, mu_up_k[k=1:K]>=0)
@variable(A2_22, mu_up_s[s=1:S]>=0)
@variable(A2_22, mu_up_o[o=1:O]>=0)
@variable(A2_22, mu_up_nm[n=1:N,m=1:N;Omega[n,m]==1]>=0)

@variable(A2_22, mu_down_k[k=1:K]>=0)
@variable(A2_22, mu_down_s[s=1:S]>=0)
@variable(A2_22, mu_down_o[o=1:O]>=0)
@variable(A2_22, mu_down_nm[n=1:N,m=1:N;Omega[n,m]==1]>=0)


@variable(A2_22, lambda[n=1:N])    
@variable(A2_22, gamma[n=1])     

@variable(A2_22, u_down_k[k=1:K],Bin)
@variable(A2_22, u_down_s[s=1:S],Bin)
@variable(A2_22, u_down_o[o=1:O],Bin)
@variable(A2_22, u_down_nm[n=1:N,m=1:N;Omega[n,m]==1],Bin)


@variable(A2_22, u_up_k[k=1:K],Bin)
@variable(A2_22, u_up_s[s=1:S],Bin)
@variable(A2_22, u_up_o[o=1:O],Bin)
@variable(A2_22, u_up_nm[n=1:N,m=1:N;Omega[n,m]==1],Bin)

@variable(A2_22, theta[n=1:N])

#Objective function
@objective(A2_22, Max,
- sum(p_s[s]*C_s[s] for s=1:S) 
+ sum(alpha_bid[k]*d[k] for k=1:K) 
- sum(alpha_offer_o[o]*p_o[o] for o=1:O)
- sum(mu_up_k[k]*D_max_k[k] for k=1:K) 
- sum(mu_up_o[o]*P_max_o[o] for o=1:O)
)


#************************************************************************
# Constraints

#1_KKT_conditions
#@constraint(A2_22,[k=1:K],-alpha_bid[k]-mu_down_k[k]+mu_up_k[k]+lambda[indexin(1, psi_k[k,:])]==0)  
@constraint(A2_22,[k=1:K],-alpha_bid[k]-mu_down_k[k]+mu_up_k[k]+lambda[findall(x->x==1, psi_k[k,:])[1]]==0) 

@constraint(A2_22,[s=1:S],alpha_offer_s[s]-mu_down_s[s]+mu_up_s[s]-lambda[findall(x->x==1, psi_s[s,:])[1]]==0)

@constraint(A2_22,[o=1:O],alpha_offer_o[o]-mu_down_o[o]+mu_up_o[o]-lambda[findall(x->x==1, psi_o[o,:])[1]]==0)


@constraint(A2_22,[n=1:N], sum(Sys_power_base*B[n,m]*(lambda[n]-lambda[m]) for m=1:N if Omega[n,m]==1) + sum(Sys_power_base*B[n,m]*(mu_up_nm[n,m]-mu_up_nm[m,n]) for m=1:N if Omega[n,m]==1) + (n == 1 ? gamma[1] : 0) ==0) 
#@constraint(A2_22,[n=1:N], sum(Sys_power_base*B[n,m]*(lambda[n]-lambda[m]) for m=1:N if Omega[n,m]==1) + sum(Sys_power_base*B[n,m]*(-mu_down_nm[n,m]+mu_down_nm[m,n]) for m=1:N if Omega[n,m]==1) + (n == 1 ? gamma[1] : 0) ==0) 


#2_KKT_conditions
@constraint(A2_22,[n=1],theta[n]==0)  

@constraint(A2_22,[n=1:N],sum(d[k] for k=1:K if psi_k[k,n]==1) +sum(Sys_power_base*B[n,m]*(theta[n]-theta[m]) for m=1:N if Omega[n,m]==1) -sum(p_s[s] for s=1:S if psi_s[s,n]==1)- sum(p_o[o] for o=1:O if psi_o[o,n]==1)==0)


#3_KKT_conditions_linearized
@constraint(A2_22,[k=1:K],d[k]<=u_down_k[k]*M)
@constraint(A2_22,[s=1:S],p_s[s]<=u_down_s[s]*M) 
@constraint(A2_22,[o=1:O],p_o[o]<=u_down_o[o]*M) 

@constraint(A2_22,[k=1:K],mu_down_k[k]<=(1-u_down_k[k])*M)
@constraint(A2_22,[s=1:S],mu_down_s[s]<=(1-u_down_s[s])*M)
@constraint(A2_22,[o=1:O],mu_down_o[o]<=(1-u_down_o[o])*M)

    #Network constraints

@constraint(A2_22,[n=1:N,m=1:N;Omega[n,m]==1],Sys_power_base*B[n,m]*(theta[n]-theta[m])+F[n,m]>=0)  
@constraint(A2_22,[n=1:N,m=1:N;Omega[n,m]==1],Sys_power_base*B[n,m]*(theta[n]-theta[m])+F[n,m]<=u_down_nm[n,m]*M) 
@constraint(A2_22,[n=1:N,m=1:N;Omega[n,m]==1],mu_down_nm[n,m]<=(1-u_down_nm[n,m])*M) 


@constraint(A2_22,[k=1:K],D_max_k[k]-d[k]>=0)
@constraint(A2_22,[s=1:S],P_max_s[s]-p_s[s]>=0)
@constraint(A2_22,[o=1:O],P_max_o[o]-p_o[o]>=0)

@constraint(A2_22,[k=1:K],D_max_k[k]-d[k]<=u_up_k[k]*M)
@constraint(A2_22,[s=1:S],P_max_s[s]-p_s[s]<=u_up_s[s]*M)
@constraint(A2_22,[o=1:O],P_max_o[o]-p_o[o]<=u_up_o[o]*M)

@constraint(A2_22,[k=1:K],mu_up_k[k]<=(1-u_up_k[k])*M)
@constraint(A2_22,[s=1:S],mu_up_s[s]<=(1-u_up_s[s])*M)
@constraint(A2_22,[o=1:O],mu_up_o[o]<=(1-u_up_o[o])*M)

@constraint(A2_22,[n=1:N,m=1:N;Omega[n,m]==1],-Sys_power_base*B[n,m]*(theta[n]-theta[m])+F[n,m]>=0)  
@constraint(A2_22,[n=1:N,m=1:N;Omega[n,m]==1],-Sys_power_base*B[n,m]*(theta[n]-theta[m])+F[n,m]<=u_up_nm[n,m]*M) 
@constraint(A2_22,[n=1:N,m=1:N;Omega[n,m]==1],mu_up_nm[n,m]<=(1-u_up_nm[n,m])*M) 

#************************************************************************


#************************************************************************
# Solve
solution = optimize!(A2_22)
println("Termination status: $(termination_status(A2_22))")
if termination_status(A2_22) == MOI.OPTIMAL
    flow = zeros(N, N)
    for n=1:N
        for m=1:N ;Omega[n,m]==1
        flow[n,m]=Sys_power_base*B[n,m]*(value.(theta[n])-value.(theta[m]))
        end
    end

else
    println("No optimal solution available")
end
#************************************************************************
