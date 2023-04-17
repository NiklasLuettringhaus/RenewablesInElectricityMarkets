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
include("A2_data_step_1.5.jl")

wind_real=zeros(n2, 24)
lambda_da=zeros(n2, 24)
lambda_da_old = zeros(n,24)
sys_stat=zeros(n2, 24)
profit=zeros(n2)
for i in 1:n2
    wind_real[i,:]=scenarios[new_values[i]][1][:]
    lambda_da[i,:]=scenarios[new_values[i]][2][:]
    sys_stat[i,:]=scenarios[new_values[i]][3][:]
end

for j in 1:n
    lambda_da_old[j,:]=scenarios[generated_values[j]][2][:]
end

#p_DA from 1.4 two price scheme, with beta = 200 and alpha = 0.9
p_DA_scen_two_price = repeat([52.5 7.5 7.5 121.50000000000001 9.0 48.0 28.5 18.0 0.0 49.5 10.500000000000002 31.5 150.0 93.0 31.5 6.0 31.5 0.0 13.5 16.5 51.00000000000001 0.0 16.5 12.0],400, 1)
p_DA = [52.5 7.5 7.5 121.50000000000001 9.0 48.0 28.5 18.0 0.0 49.5 10.500000000000002 31.5 150.0 93.0 31.5 6.0 31.5 0.0 13.5 16.5 51.00000000000001 0.0 16.5 12.0]
# Calculating mismatch between day ahead dispatch and real production of remaining 400 scenarios
delta = p_nom .* wind_real - p_DA_scen_two_price

# seperate delta into up and down balancing needs into two different matrixes for each hour and scenarion
delta_up= zeros(400,24)
delta_down= zeros(400,24)

for s in 1:400
    for t in 1:24
        if delta[s,t] > 0
            delta_up[s,t] = delta[s,t]
            delta_down[s,t] = 0
        elseif delta[s,t] < 0
            delta_up[s,t] = 0
            delta_down[s,t] = delta[s,t]
        else
            delta_up[s,t] = 0
            delta_down[s,t] = 0
        end
    end
end

 
#@objective(A2_11, Max, sum(prob[s] *    (lambda_da[s,t] * p_DA[t] 
#                                       + (1-sys_stat[s,t]) * (delta_up[t,s] * lambda_da[s,t] - delta_down[t,s] * coef_high * lambda_da[s,t])  
#                                      + sys_stat[s,t] * (delta_up[t,s] * coef_low * lambda_da[s,t] - delta_down[t,s] * lambda_da[s,t])) for t=1:T, s=1:n))


# Calculating the balancing profit based on each out of sample scenario across 24 hours
bal_profit = (1 .- sys_stat) .* (delta_up .* lambda_da + delta_down .* coef_high .* lambda_da)  + sys_stat .* (delta_up .* coef_low .* lambda_da + delta_down .* lambda_da)

# Calculate the mean over each row
hourly_bal_profit = transpose(mean(bal_profit, dims=1))
scenario_balance_profit = mean(bal_profit, dims=2)

# Calculating the balancing profit from DA market
da_profit = mean(lambda_da,dims=1) .* p_DA      #change everywhere to new lambda_da

# Profit distribution over scenarios
profit_dis = sum(da_profit) .+ scenario_balance_profit

# Out of sample profit for every hour
outofsample_profit_hourly = hourly_bal_profit + transpose(da_profit)
# Out of sample profit total
outofsample_profit = sum(hourly_bal_profit) + sum(da_profit)

#*****************************************************
profit_dis_df=DataFrame(profit_dis,:auto)
da_profit_df=DataFrame(da_profit,:auto)
outofsample_profit_hourly_df=DataFrame(outofsample_profit_hourly,:auto)

if(isfile("A2_results_step1.5_twoprice_1.4.xlsx"))
    rm("A2_results_step1.5_twoprice_1.4.xlsx")
end

XLSX.writetable("A2_results_step1.5_twoprice_1.4.xlsx",
    profit_dis = (collect(eachcol(profit_dis_df)), names(profit_dis_df)),
    da_profit_df = (collect(eachcol(da_profit_df)), names(da_profit_df)),
    outofsample_profit_hourly_df = (collect(eachcol(outofsample_profit_hourly_df)), names(outofsample_profit_hourly_df)),
    )
#*****************************************************
