#Assignment 2, Data file Step 1.1

using CSV
using DataFrames
using Random
using Distributions


#*****************************************
# SCENARIO GENERATION
#*****************************************

data_price = CSV.read("Part 2/Scenario_files/Input_Prices.csv", DataFrame)
data_states = CSV.read("Part 2/Scenario_files/State_scenarios.csv", DataFrame)
data_wind = CSV.read("Part 2/Scenario_files/Wind_scenarios.csv", DataFrame)

data_states_dict = Dict(i => vec(c) for (i, c) in enumerate(eachcol(data_states)) if i <= 3)
data_price_dict = Dict(i => vec(c) for (i, c) in enumerate(eachcol(data_price)) if i <= 20)
data_wind_dict = Dict(i => vec(c) for (i, c) in enumerate(eachcol(data_wind)) if i <= 10)

#Create an empty main dictionary for all 600 scnearios
scenarios = Dict()
#loop through each dictionary for wind, power and state. Write the keys of each as a string to create a unique key that lets us identify each scenario and grab the values (arrays) of each dictionary
#=
for w in 1:length(data_wind_dict)
    for p in 1:length(data_price_dict)
        for s in 1:length(data_states_dict)
            scenarios_dict["w$w p$p s$s"] = [get(data_wind_dict, w,0), get(data_price_dict, p,0),get(data_states_dict, s,0) ]
        end
    end
end
=#

i_d=1
for w in 1:length(data_wind_dict)
    global i_d
    for p in 1:length(data_price_dict)
        for s in 1:length(data_states_dict)
            scenarios[i_d] = [get(data_wind_dict, w,0), get(data_price_dict, p,0),get(data_states_dict, s,0) ]
            i_d+=1
        end
    end
end

#sort it so it is easier to see
sorted_scenarios = sort(scenarios)
#CSV.write("Part 2/Scenario_files/sorted_scenarios_dict.csv", sorted_scenarios_dict)

#*****************************************
# REDUCING SCENARIOS
#*****************************************

n=200

# Create an empty set to store the values
set_values = Set{Int}()

# Generate random values until the set contains n unique values
Random.seed!(1234)
while length(set_values) < n
    value = rand(1:600)
    push!(set_values, value)
end

# Convert the set to an array and sort it
generated_values = sort(collect(set_values))

# Create an array with all possible values and remove the generated ones
all_values = collect(1:600)
new_values = setdiff(all_values, generated_values)

#=
for s in generated_values
    println((scenarios[s]), "\n")
end
=#

#*****************************************
# PARAMETERS
#*****************************************

prob = fill(0.005,600)
p_nom = 150 #MW
S = length(generated_values)
T = length(scenarios[1][1])
beta = 0.7                # Coefficient -> non negative value. Is the risk preference :=0 means risk neutral (term equates to zero)
alpha = 0.9             # confidence level -> lies between 0 and 1. Evaluate for difference alphas combined with beta (i.e. 0.8 and 0.95)


