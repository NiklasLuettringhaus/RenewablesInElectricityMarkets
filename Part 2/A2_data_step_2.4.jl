#Assignment 2, Data file Step 1.1

using CSV
using DataFrames
using Random
using Distributions

#Generation units operationals details
P_max_s=[155, 100, 155, 197]
P_max_o=[450, 350 ,210 ,80]


Random.seed!(1234)

# Offer prices Demands 8 different scenarios
bid_prices = zeros(8,4)

for i=1:8
    for j=1:4
    value = rand(5:15)/10
    bid_prices[i,j] = value
    end
end

bid_prices_dict= Dict()
for i in 1:size(bid_prices, 1)
    # Create a vector with the row contents
    row_vec = bid_prices[i, :]
    # Add the vector to the dictionary with the row number as the key
    bid_prices_dict[i] = row_vec
end


# Amount of demand 10 different possibilities

amount_demand_factor = zeros(10,4)

for i=1:10
    for j=1:4
    value = rand(3:11)/10
    amount_demand_factor[i,j] = value
    end
end

amount_demand_factor_dict= Dict()
for i in 1:size(amount_demand_factor, 1)
    # Create a vector with the row contents
    row_vec = amount_demand_factor[i, :]
    # Add the vector to the dictionary with the row number as the key
    amount_demand_factor_dict[i] = row_vec
end


# Wind forecast has 25 different possibilities
wind_factor = zeros(25)

for i=1:25
    value = rand(10:75)/100
    wind_factor[i] = value
end

wind_factor_dict= Dict()
for i in 1:size(wind_factor, 1)
    # Create a vector with the row contents
    row_vec = wind_factor[i, :]
    # Add the vector to the dictionary with the row number as the key
    wind_factor_dict[i] = row_vec
end


# Offer Prices non Strat producers 5 different scenarios
offer_price_non_stra = zeros(5,4)

for i=1:5
    for j=1:4
    value = rand(5:15)/10
    offer_price_non_stra[i,j] = value
    end
end

offer_price_non_stra_dict= Dict()
for i in 1:size(offer_price_non_stra, 1)
    # Create a vector with the row contents
    row_vec = offer_price_non_stra[i, :]
    # Add the vector to the dictionary with the row number as the key
    offer_price_non_stra_dict[i] = row_vec
end


# Sum all parts to one dictionary with all scenarios
scenarios=Dict()
i_d=1
for w in 1:length(bid_prices_dict)
    global i_d
    for p in 1:length(amount_demand_factor_dict)
        for s in 1:length(wind_factor_dict)
            for o in 1:length(offer_price_non_stra_dict)
            scenarios[i_d] = [get(bid_prices_dict, w,0),
                              get(amount_demand_factor_dict, p,0),
                              get(wind_factor_dict, s,0), 
                              get(offer_price_non_stra_dict, o, 0) ]
                i_d+=1
            end
        end
    end
end

sorted_scen = sort(scenarios)

SC = 20
prob = 1/SC
set_values = Set{Int}()

# Generate random values until the set contains n unique values
Random.seed!(1234)
while length(set_values) < SC
    value = rand(1:10000)
    push!(set_values, value)
end

# Convert the set to an array and sort it
generated_values = sort(collect(set_values))

# Create an array with all possible values and remove the generated ones
all_values = collect(1:10000)
new_values = setdiff(all_values, generated_values)


wind_prod=zeros(SC,1)
alpha_bid=zeros(SC, 4)
demand=zeros(SC, 4)
alpha_offer_o=zeros(SC, 4)
for i in 1:SC
    wind_prod[i,:]= scenarios[generated_values[i]][3]
    alpha_bid[i,:]=scenarios[generated_values[i]][1]
    demand[i,:]=scenarios[generated_values[i]][2]
    alpha_offer_o[i,:]=scenarios[generated_values[i]][4]
end

C_s=[15.2, 23.4, 15.2, 19.1]
alpha_offer_o_fix= [0, 5, 20.1, 24.7]

ramp_up_down_limit = [90, 85, 90, 120, 0 , 350, 170, 80]

#Demand details
D_max_k =  [200, 400, 300, 250]
alpha_bid_fix = [26.5, 24.7, 23.1, 22.5]

random = []



Omega = [ #n rows and m columns
    0 1 1 0 0 0 
    1 0 1 1 0 0 
    1 1 0 0 0 1
    0 1 0 0 1 1
    0 0 0 1 0 1
    0 0 1 1 1 0
]

F = Omega .* 600 #Transmission line capacity in MW
B = Omega .* 50 #Suceptance in per unit
Sys_power_base = 337.5  # MVA


S = 4
O = 4
N = 6
K = 4
nodes=["N1", "N2", "N3", "N4", "N5", "N6"]

psi_s = Int.(zeros(S, N)) #location of the generators in the node
psi_s[1,1]=1;
psi_s[2,2]=1;
psi_s[3,3]=1;
psi_s[4,6]=1;

psi_o = Int.(zeros(O, N)) #location of the generators in the node
psi_o[1,1]=1;
psi_o[2,2]=1;
psi_o[3,3]=1;
psi_o[4,5]=1;

psi_k = Int.(zeros(K, N)) #location of the demand in the node
psi_k[1,3]=1;
psi_k[2,4]=1;
psi_k[3,5]=1;
psi_k[4,6]=1;

#Big M constraint

#=M=[100000 
100000 
100000
 100 
 100000 
 100000 
 100000 
 100000 
 100000 
 100000 
 80 
 100000 
 100000 
 100000 
 100000 
 100000]
 =#

M=[100000 
 100000 
 100000
 100000 
 100000 
 100000 
 100000 
 100000 
 100000 
 100000 
 100000
 100000 
 100000 
 100000 
 100000 
 100000]
 