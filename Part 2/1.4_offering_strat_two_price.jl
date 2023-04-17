#************************************************************************
# Step 1.1
using JuMP
using Gurobi
using Plots
using CSV
using DataFrames
using XLSX
#************************************************************************

#************************************************************************
#PARAMETERS
include("A2_data_step_1.4.jl")

wind_real=zeros(n, 24)
lambda_da=zeros(n, 24)
sys_stat=zeros(n, 24)
profit=zeros(n)
for i in 1:n
wind_real[i,:]=scenarios[generated_values[i]][1][:]
lambda_da[i,:]=scenarios[generated_values[i]][2][:]
sys_stat[i,:]=scenarios[generated_values[i]][3][:]
end

#************************************************************************
beta_range = 0:0.01:1
#Defining the global data frame for results
CVAR_df = DataFrame(CVAR=Float64[], Exp_profit=Float64[], Beta=Float64[])
for (index, beta) in enumerate(beta_range)
    println("Beta: ",value.(beta))

    #************************************************************************
    # Model
    A2_11 = Model(Gurobi.Optimizer)

    @variable(A2_11, p_DA[t=1:T]>=0)                #production sold in DA market
    @variable(A2_11, delta_up[t=1:T,s=1:n]>=0)      #up balancing sold in balancing market
    @variable(A2_11, delta_down[t=1:T, s=1:n]>=0)   #down balancing sold in balancing market
    @variable(A2_11, delta[t=1:T, s=1:n])           #total balancing in real time needed in balancing market
    @variable(A2_11, zeta)                          #auxilary variable
    @variable(A2_11, eta[s=1:n] >= 0)


    @objective(A2_11, Max, (1-beta)*sum(prob[s] *    (lambda_da[s,t] * p_DA[t] 
                                            + (1-sys_stat[s,t]) * (delta_up[t,s] * lambda_da[s,t] - delta_down[t,s] * coef_high * lambda_da[s,t])  
                                            + sys_stat[s,t] * (delta_up[t,s] * coef_low * lambda_da[s,t] - delta_down[t,s] * lambda_da[s,t])) for t=1:T, s=1:n)
                                            + beta * (zeta - 1/(1-alpha) * sum(prob[s] * eta[s] for s=1:n)))

    # Constraints for Balancing
    @constraint(A2_11,[t=1:T], 0 <= p_DA[t] <= p_nom)                                                       #capacity limit constraint for WF
    @constraint(A2_11,[t=1:T, s=1:n], delta[t,s] == wind_real[s,t] * p_nom - p_DA[t])     #balancing need
    @constraint(A2_11,[t=1:T, s=1:n], delta_up[t,s] - delta_down[t,s] == delta[t,s])        #composition of balancing

    @constraint(A2_11,[t=1:T, s=1:n], delta_up[t,s] <= p_nom)
    @constraint(A2_11,[t=1:T, s=1:n], delta_down[t,s] <= p_nom)

    # Constraint for zeta and eta
    @constraint(A2_11,[s=1:n], -sum(prob[s] *    (lambda_da[s,t] * p_DA[t] 
                                + (1-sys_stat[s,t]) * (delta_up[t,s] * lambda_da[s,t] - delta_down[t,s] * coef_high * lambda_da[s,t])  
                                + sys_stat[s,t] * (delta_up[t,s] * coef_low * lambda_da[s,t] - delta_down[t,s] * lambda_da[s,t])) for t=1:T)
                                + zeta - eta[s] <= 0)


    #************************************************************************
    # Solve
    solution = optimize!(A2_11)
    println("Termination status: $(termination_status(A2_11))")
    #************************************************************************

    #************************************************************************
    # Solution
    if termination_status(A2_11) == MOI.OPTIMAL
        println("Optimal objective value: $(objective_value(A2_11))")
        for s in 1:n
            profit[s]=sum((lambda_da[s,t] * value.(p_DA[t]) 
            + (1-value.(sys_stat[s,t])) * (value.(delta_up[t,s]) * lambda_da[s,t] - value.(delta_down[t,s]) * coef_high * lambda_da[s,t])  
            + value.(sys_stat[s,t]) * (value.(delta_up[t,s]) * coef_low * lambda_da[s,t] - value.(delta_down[t,s]) * lambda_da[s,t])
            ) for t=1:T)
            end
        
        #Calculating the results to be exported outside the loop
        CVAR=value.(zeta) - 1/(1-alpha) * sum(prob[s] * value.(eta[s]) for s=1:n)
        Exp_profit=sum(prob[s] *    (lambda_da[s,t] * value.(p_DA[t]) 
        + (1-sys_stat[s,t]) * (value.(delta_up[t,s]) * lambda_da[s,t] - value.(delta_down[t,s]) * coef_high * lambda_da[s,t])  
        + sys_stat[s,t] * (value.(delta_up[t,s]) * coef_low * lambda_da[s,t] - value.(delta_down[t,s]) * lambda_da[s,t])) for t=1:T, s=1:n)

        #Create a local data frame with the results of each iteration and append it to the global dataframe
        CVAR_temp_df = DataFrame(CVAR=CVAR, Exp_profit=Exp_profit, Beta=beta)
        append!(CVAR_df, CVAR_temp_df)
    else
        println("No optimal solution available")
    end

#*****************************************************
end

if(isfile("A2_results_step1.4_two_price.xlsx"))
    rm("A2_results_step1.4_two_price.xlsx")
end

XLSX.writetable("A2_results_step1.4_two_price.xlsx",
    CVAR = (collect(eachcol(CVAR_df)), names(CVAR_df))
    )

#*****************************************************