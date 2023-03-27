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
matrix=hcat(power_balance1,power_balance2,power_balance3)

#creating an empty dictionary
State_Dictionary = Dict()

for i in 1:size(matrix, 2)
    # Create a string key for the dictionary
    key = string(i)
    
    # Convert the column to a string array and join it with commas
    value = join(string.(matrix[:, i]), ",")
    
    # Add the key-value pair to the dictionary
    State_Dictionary[key] = value
end
# print the result
display(matrix)

