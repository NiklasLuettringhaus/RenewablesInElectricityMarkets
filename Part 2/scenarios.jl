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



# print the result
display(State_Dictionary)

#*****************************************
#   DA Price matrix
#*****************************************

data_price = CSV.read("..\\RenewablesInElectricityMarkets\\Scenario_files\\Input_Prices.csv", DataFrame)
>>>>>>> d97db2b1db2a9581367850ca7768c0d46f577c10
