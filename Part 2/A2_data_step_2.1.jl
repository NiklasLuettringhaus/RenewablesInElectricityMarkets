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

data_wind
#Create an empty main dictionary for all 600 scnearios
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
scenarios=Dict()
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
data_wind_dict
data_price_dict
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

#Generation units operationals details
Cap_g = [155, 100, 155, 197, 337.5, 350 ,210 ,80]
cg = [15.2, 23.4, 15.2, 19.1, 0, 5, 20.1, 24.7]
ramp_up_down_limit = [90, 85, 90, 120, 0 , 350, 170, 80]

#Demand details
Cap_d =  [200, 400, 300, 250]
U_d = [26.5, 24.7, 23.1, 22.5]



connection_matrix = [ 
    1 1 1 0 0 0 
    1 1 1 1 0 0 
    1 1 1 0 0 1
    0 1 0 1 1 1
    0 0 0 1 1 1
    0 0 1 1 1 1
]

F = connection_matrix .* 400
B = connection_matrix .* 50

Sys_power_base = 337.5

G = 8
N = 6
D = 4
nodes=["N1", "N2", "N3", "N4", "N5", "N6"]
psi_O = Int.(zeros(G, N)) #location of the generators in the node
psi_O[1,1]=1;
psi_O[2,2]=1;
psi_O[3,3]=1;
psi_O[4,5]=1;
psi_O[5,1]=1;
psi_O[6,2]=1;
psi_O[7,3]=1;
psi_O[8,6]=1;

psi_D = Int.(zeros(D, N))
psi_D[1,3]=1;
psi_D[2,4]=1;
psi_D[3,5]=1;
psi_D[4,6]=1;

hour_one_production_wind = 0.75 * 450
#*****************************************
# PARAMETERS
#*****************************************

prob = fill(0.005,600)
p_nom = 150 #MW
S = length(generated_values)
T = length(scenarios[1][1])
coef_low=0.9
coef_high=1.2

