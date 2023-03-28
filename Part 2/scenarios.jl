using CSV
using DataFrames
using Random
using Distributions

#=
#*****************************************
#   State matrix
#*****************************************

#Set seed for reproducibility
Random.seed!(123)

#Generate 3 scenarios with 24 random binary variables
power_balance1 = rand(Bernoulli(0.5), 24)
power_balance2 = rand(Bernoulli(0.5), 24)
power_balance3 = rand(Bernoulli(0.5), 24)

#Append them all in a matrix
statedata=hcat(power_balance1,power_balance2,power_balance3)



# print the result
display(State_Dictionary)
=#


data_price = CSV.read("Part 2/Scenario_files/Input_Prices.csv", DataFrame)
data_states = CSV.read("Part 2/Scenario_files/State_scenarios.csv", DataFrame)
data_wind = CSV.read("Part 2/Scenario_files/Wind_scenarios.csv", DataFrame)

data_states_dict = Dict(i => vec(c) for (i, c) in enumerate(eachcol(data_states)) if i <= 3)
data_price_dict = Dict(i => vec(c) for (i, c) in enumerate(eachcol(data_price)) if i <= 20)
data_wind_dict = Dict(i => vec(c) for (i, c) in enumerate(eachcol(data_wind)) if i <= 10)

scenarios_dict = Dict()
for w in 1:length(data_wind_dict)
    for p in 1:length(data_price_dict)
        for s in 1:length(data_states_dict)
            scenarios_dict["w$w p$p s$s"] = [get(data_wind_dict, w,0), get(data_price_dict, p,0),get(data_states_dict, s,0) ]
        end
    end
end

sorted_scenarios_dict = sort(scenarios_dict)

CSV.write("Part 2", sorted_scenarios_dict)