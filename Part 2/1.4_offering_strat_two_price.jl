#************************************************************************
# Step 1.1
using JuMP
using Gurobi
using Plots
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

#************************************************************************
# Model
A2_11 = Model(Gurobi.Optimizer)

@variable(A2_11, p_DA[t=1:T]>=0)                #production sold in DA market
@variable(A2_11, delta_up[t=1:T,s=1:n]>=0)      #up balancing sold in balancing market
@variable(A2_11, delta_down[t=1:T, s=1:n]>=0)   #down balancing sold in balancing market
@variable(A2_11, delta[t=1:T, s=1:n])           #total balancing in real time needed in balancing market
@variable(A2_11, zeta)                          #auxilary variable
@variable(A2_11, eta[s=1:n] >= 0)


@objective(A2_11, Max, sum(prob[s] *    (lambda_da[s,t] * p_DA[t] 
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
    println("CVAR: ", value.(zeta - 1/(1-alpha) * sum(prob[s] * eta[s] for s=1:n)))
    for s in 1:n
        profit[s]=sum((lambda_da[s,t] * value.(p_DA[t]) 
        + (1-value.(sys_stat[s,t])) * (value.(delta_up[t,s]) * lambda_da[s,t] - value.(delta_down[t,s]) * coef_high * lambda_da[s,t])  
        + value.(sys_stat[s,t]) * (value.(delta_up[t,s]) * coef_low * lambda_da[s,t] - value.(delta_down[t,s]) * lambda_da[s,t])
        ) for t=1:T)
        end

    p_DA_df=DataFrame([value.(p_DA)],:auto)
    #delta_df=DataFrame(value.(delta[:,[generated_values]]),:auto)
    p_DA_df=DataFrame([value.(p_DA)],:auto)
    delta_df=DataFrame(value.(delta[:, :]),:auto)
    delta_up_df=DataFrame(value.(delta_up[:, :]),:auto)
    delta_down_df=DataFrame(value.(delta_down[:, :]),:auto)
    profit_df=DataFrame([value.(profit)],:auto)
else
    println("No optimal solution available")
end

#*****************************************************
if(isfile("A2_results_step1.4_two_price.xlsx"))
    rm("A2_results_step1.4_two_price.xlsx")
end

XLSX.writetable("A2_results_step1.4_two_price.xlsx",
    p_DA = (collect(eachcol(p_DA_df)), names(p_DA_df)),
    delta = (collect(eachcol(delta_df)), names(delta_df)),
    delta_up = (collect(eachcol(delta_up_df)), names(delta_up_df)),
    delta_down = (collect(eachcol(delta_down_df)), names(delta_down_df)),
    profit = (collect(eachcol(profit_df)), names(profit_df))
    )

#*****************************************************