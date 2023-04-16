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

p_DA_scen = repeat([150 0 0 150 0 150 0 0 0 0 0 150 150 150 0 0 150 0 0 0 0 0 0 0],400, 1)
# Calculating mismatch between day ahead dispatch and real production of remaining 400 scenarios
delta = p_nom .* wind_real - p_DA_scen

# Calculating the balancing profit based on each out of sample scenario across 24 hours
bal_profit = (1 .- sys_stat) .* coef_high .* lambda_da .* delta + sys_stat .* coef_low .* lambda_da .* delta

# Calculate the mean over each row
hourly_bal_profit = transpose(mean(bal_profit, dims=1))
scenario_balance_profit = mean(bal_profit, dims=2)

# Profit distribution over scenarios
profit_dis = sum(da_profit) .+ scenario_balance_profit

# Calculating the balancing profit from DA market
da_profit = transpose(mean(lambda_da_old,dims=1)) .* p_DA

# Out of sample profit for every hour
outofsample_profit = hourly_bal_profit + da_profit
# Out of sample profit total
outofsample_profit = sum(hourly_bal_profit) + sum(da_profit)

#=*****************************************************
if(isfile("A2_results_step1.1.xlsx"))
    rm("A2_results_step1.1.xlsx")
end

XLSX.writetable("A2_results_step1.1.xlsx",
    p_DA = (collect(eachcol(p_DA_df)), names(p_DA_df)),
    sys_stat = (collect(eachcol(sys_stat_df)), names(sys_stat_df)),
    delta = (collect(eachcol(delta_df)), names(delta_df)),
    delta_up = (collect(eachcol(delta_up_df)), names(delta_up_df)),
    delta_down = (collect(eachcol(delta_down_df)), names(delta_down_df)),
    profit = (collect(eachcol(profit_df)), names(profit_df))
    )

#*****************************************************
