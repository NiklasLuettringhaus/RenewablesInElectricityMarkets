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

<<<<<<< HEAD
State_Dictionary = Dict()
for i in 1:size(statedata, 2)
    # Create a string key for the dictionary
    key = string(i) * "S"
    
    # Convert the column to a string array and join it with commas
    value = join(string.(statedata[:, i]), ",")
    
    # Add the key-value pair to the dictionary
    State_Dictionary[key] = value
end

123 State_Dictionary[1]WIND[2]

# print the result
display(State_Dictionary)



#*****************************************
#   DA Price matrix
#*****************************************

data_price = CSV.read("..\\RenewablesInElectricityMarkets\\Part 2\\Scenario_files\\Input_Prices.csv", DataFrame)
<<<<<<< HEAD
show(data_price)


#*****************************************
#   Wind matrix
#*****************************************

data_wind= CSV.read("..\\RenewablesInElectricityMarkets\\Part 2\\Scenario_files\\Wind_scenarios.csv", DataFrame)
show(data_wind)

data_price[:, "s6"]
=======
using CSV
using DataFrames
using Random
using Distributions


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

State_Dictionary = Dict()
for i in 1:size(statedata, 2)
    # Create a string key for the dictionary
    key = string(i) * "S"
    
    # Convert the column to a string array and join it with commas
    value = join(string.(statedata[:, i]), ",")
    

    # Add the key-value pair to the dictionary
    State_Dictionary[key] = value
end

=======
>>>>>>> cb1d76cd4a204d8f5bf1e32e16f0cf8bc10e855f


# print the result
display(State_Dictionary)
=#



data_price = CSV.read("Part 2/Scenario_files/Input_Prices.csv", DataFrame)
data_states = CSV.read("Part 2/Scenario_files/State_scenarios.csv", DataFrame)
data_wind = CSV.read("Part 2/Scenario_files/Wind_scenarios.csv", DataFrame)

data_states_dict = Dict(i => vec(c) for (i, c) in enumerate(eachcol(data_states)) if i <= 3)
data_price_dict = Dict(i => vec(c) for (i, c) in enumerate(eachcol(data_price)) if i <= 20)
data_wind_dict = Dict(i => vec(c) for (i, c) in enumerate(eachcol(data_wind)) if i <= 10)

#Create an empty main dictionary for all 600 scnearios
scenarios_dict = Dict()
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
            scenarios_dict[i_d] = [get(data_wind_dict, w,0), get(data_price_dict, p,0),get(data_states_dict, s,0) ]
            i_d+=1
        end
    end
end

#sort it so it is easier to see
#sorted_scenarios_dict = sort(scenarios_dict)
CSV.write("Part 2/Scenario_files/sorted_scenarios_dict.csv", sorted_scenarios_dict)
<<<<<<< Updated upstream
=======

>>>>>>> Stashed changes

#**************************************************************************************

#REDUCING SCENARIOS

n=200

# Create an empty set to store the values
set_values = Set{Int}()

# Generate random values until the set contains n unique values
while length(set_values) < n
    value = rand(1:600)
    push!(set_values, value)
end

# Convert the set to an array and sort it
generated_values = sort(collect(set_values))

# Create an array with all possible values and remove the generated ones
all_values = collect(1:600)
new_values = setdiff(all_values, generated_values)

<<<<<<< Updated upstream
for s in generated_values
    println((scenarios_dict[s]), "\n")
end
=======
sorted_values=sort(values)


>>>>>>> Stashed changes
