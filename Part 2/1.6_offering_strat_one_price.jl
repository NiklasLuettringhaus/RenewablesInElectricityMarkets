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
include("A2_data_step_1.6.jl")

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

#for random.seed(1234)
#p_DA_scen = repeat([150 0 0 150 0 150 0 0 0 0 0 150 150 150 0 0 150 0 0 0 0 0 0 0],n2, 1)
#p_DA = [150 0 0 150 0 150 0 0 0 0 0 150 150 150 0 0 150 0 0 0 0 0 0 0]

#for random.seed(1234) but n = 50
#p_DA_scen = repeat([150.0 0.0 0.0 150.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 150.0 150.0 150.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0],n2, 1)
#p_DA = [150.0 0.0 0.0 150.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 150.0 150.0 150.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]

#for random.seed(1234) but n = 300
#p_DA_scen = repeat([150.0 0.0 0.0 150.0 0.0 150.0 0.0 0.0 0.0 0.0 0.0 150.0 150.0 150.0 0.0 0.0 150.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0],n2, 1)
#p_DA = [150.0 0.0 0.0 150.0 0.0 150.0 0.0 0.0 0.0 0.0 0.0 150.0 150.0 150.0 0.0 0.0 150.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]

#for random.seed(5678)
p_DA = [0.0 0.0 0.0 150.0 0.0 0.0 150.0 0.0 0.0 150.0 0.0 0.0 150.0 150.0 150.0 0.0 0.0 0.0 0.0 0.0 150.0 0.0 0.0 0.0]
p_DA_scen = repeat([0.0 0.0 0.0 150.0 0.0 0.0 150.0 0.0 0.0 150.0 0.0 0.0 150.0 150.0 150.0 0.0 0.0 0.0 0.0 0.0 150.0 0.0 0.0 0.0],n2, 1)
# Calculating mismatch between day ahead dispatch and real production of remaining 400 scenarios
delta = p_nom .* wind_real - p_DA_scen

# Calculating the balancing profit based on each out of sample scenario across 24 hours
bal_profit = (1 .- sys_stat) .* coef_high .* lambda_da .* delta + sys_stat .* coef_low .* lambda_da .* delta

# Calculating the balancing profit from DA market
da_profit = mean(lambda_da,dims=1) .* p_DA


# Calculate the mean over each row
hourly_bal_profit = transpose(mean(bal_profit, dims=1))
scenario_balance_profit = mean(bal_profit, dims=2)

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

if(isfile("A2_results_step1.6_oneprice.xlsx"))
    rm("A2_results_step1.6_oneprice.xlsx")
end

XLSX.writetable("A2_results_step1.6_oneprice.xlsx",
    profit_dis = (collect(eachcol(profit_dis_df)), names(profit_dis_df)),
    da_profit_df = (collect(eachcol(da_profit_df)), names(da_profit_df)),
    outofsample_profit_hourly_df = (collect(eachcol(outofsample_profit_hourly_df)), names(outofsample_profit_hourly_df)),
    )

#*****************************************************
