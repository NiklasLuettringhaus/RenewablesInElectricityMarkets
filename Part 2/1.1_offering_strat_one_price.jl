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
include("A2_data_step_1.1.jl")

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

#************************************************************************
# Model
A2_11 = Model(Gurobi.Optimizer)

@variable(A2_11, p_DA[t=1:T]>=0)                #production sold in DA market
@variable(A2_11, delta_up[t=1:T,s=1:n]>=0)     #up balancing sold in balancing market
@variable(A2_11, delta_down[t=1:T, s=1:n]>=0)   #down balancing sold in balancing market
@variable(A2_11, delta[t=1:T, s=1:n])        #total balancing in real time needed in balancing market


@objective(A2_11, Max, sum(prob[s] *    (lambda_da[s,t] * p_DA[t] 
                                        + (1-sys_stat[s,t]) * coef_high * lambda_da[s,t] * (delta_up[t,s] - delta_down[t,s])
                                        + sys_stat[s,t] * coef_low * lambda_da[s,t] * (delta_up[t,s] - delta_down[t,s])) for t=1:T, s=1:n))

#= Another way to do it just using delta for one price scheme
@objective(A2_11, Max, sum(prob[s] *    (lambda_da[s,t] * p_DA[t] 
                                        + (1-sys_stat[s,t]) * coef_high * lambda_da[s,t] * (delta[t,s])
                                        + sys_stat[s,t] * coef_low * lambda_da[s,t] * (delta[t,s])) for t=1:T, s=1:n))
=# 

@constraint(A2_11,[t=1:T], 0 <= p_DA[t] <= p_nom)                                                       #capacity limit constraint for WF
@constraint(A2_11,[t=1:T, s=1:n], delta[t,s] == wind_real[s,t] * p_nom - p_DA[t])     #balancing need
@constraint(A2_11,[t=1:T, s=1:n], delta_up[t,s] - delta_down[t,s] == delta[t,s])        #composition of balancing
@constraint(A2_11,[t=1:T, s=1:n], delta_up[t,s] <= p_nom)
@constraint(A2_11,[t=1:T, s=1:n], delta_down[t,s] <= p_nom)

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
            + (1-value.(sys_stat[s,t])) * coef_high * lambda_da[s,t] * (value.(delta_up[t,s]) - value.(delta_down[t,s]))
            + value.(sys_stat[s,t]) * coef_low * lambda_da[s,t] * (value.(delta_up[t,s]) - value.(delta_down[t,s]))
            ) for t=1:T)
        end
    p_DA_df=DataFrame([value.(p_DA)],:auto)
    delta_df=DataFrame(value.(delta[:, :]),:auto)
    delta_up_df=DataFrame(value.(delta_up[:, :]),:auto)
    delta_down_df=DataFrame(value.(delta_down[:, :]),:auto)
    profit_df=DataFrame([value.(profit)],:auto)
    sys_stat_df=DataFrame(sys_stat[:,:]',:auto)
else
    println("No optimal solution available")
end

#*****************************************************
if(isfile("A2_results_step1.xlsx"))
    rm("A2_results_step1.xlsx")
end

XLSX.writetable("A2_results_step1.xlsx",
    p_DA = (collect(eachcol(p_DA_df)), names(p_DA_df)),
    sys_stat = (collect(eachcol(sys_stat_df)), names(sys_stat_df)),
    delta = (collect(eachcol(delta_df)), names(delta_df)),
    delta_up = (collect(eachcol(delta_up_df)), names(delta_up_df)),
    delta_down = (collect(eachcol(delta_down_df)), names(delta_down_df)),
    profit = (collect(eachcol(profit_df)), names(profit_df))
    )

#*****************************************************
