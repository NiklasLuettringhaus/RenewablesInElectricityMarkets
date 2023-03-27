using CSV
using DataFrames
using Random
using Distributions

#Set seed for reproducibility
Random.seed!(123)

#Generate 3 scenarios with 24 random binary variables
power_balance1 = rand(Bernoulli(0.5), 24)
power_balance2 = rand(Bernoulli(0.5), 24)
power_balance3 = rand(Bernoulli(0.5), 24)

#Append them all in a matrix
matrix=hcat(power_balance1,power_balance2,power_balance3)

# print the result
println(matrix)