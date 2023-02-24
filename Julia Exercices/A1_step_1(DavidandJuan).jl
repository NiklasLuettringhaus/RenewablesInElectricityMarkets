#************************************************************************
# Incredible Chairs, Simple LP
using JuMP
using Gurobi
using Plots
#************************************************************************

#************************************************************************
#PARAMETERS
include("data_Step_1.jl")

#************************************************************************



#************************************************************************
# Model
FN = Model(Gurobi.Optimizer)

@variable(FN,p_d[d=1:D]>=0) #load of demand
@variable(FN,p_w[w=1:W]>=0) #wind farm production
@variable(FN,p_g[g=1:G]>=0) #power scheduled of generetor g

@objective(FN, Max, sum(U_d[d]*p_d[d] for d=1:D)  #Revenue from demand
            - sum(C_g[g]*p_g[g] for g=1:G) # Production cost + start-up cost conventional generator
            - sum(0*p_w[w] for w=1:W)) #Maximize the social whalefare, /# Production cost Wind farm


@constraint(FN,[d=1:D], p_d[d] <= Cap_d[d]) #Demand limits constraint
@constraint(FN,[g=1:G], p_g[g] <= Cap_g[g]) #Generation limits constraint
@constraint(FN,[w=1:W], p_w[w] <= WF_prod[w]) #Weather-based limits constraint WF
@constraint(FN, Balance, sum(p_d[d] for d=1:D) - sum(p_w[w] for w=1:W) - sum(p_g[g] for g=1:G)==0) #Power balance constraint

#print(FN) #print model to screen (only usable for small models)

#************************************************************************
# Plotting is fun 👍

#************************************************************************
# Solve
solution = optimize!(FN)
println("Termination status: $(termination_status(FN))")
#************************************************************************

#************************************************************************
# Solution
if termination_status(FN) == MOI.OPTIMAL
    println("Optimal objective value: $(objective_value(FN))")
    println("Solution: ")
    DA_price = -dual.(Balance) #Equilibrium price
    println("Market clearing price:")
    println(DA_price)  #Print equilibrium price
    println("\n")
    println("Profit of each generator:")
    for g=1:G
        println("G$g:", round(Int,value(p_g[g])*(DA_price - C_g[g])))
    end

    print("\n Generated power of each Generator")

    for g=1:G
        println("G$g:  ", round(Int,value(p_g[g])))
    end

    for w=1:W
        println("Windfarm $w: ", round(Int,value(p_w[w])))
    end

    total_generated = value(sum(p_g)+sum(p_w))
    total_demand = sum(Cap_d)
    println("Total generated power: $total_generated")
    println("Supplied demand = $(round((total_generated/total_demand)*100)) % ")
    

    println("\n")
    println("Profit of each wind farm:")
    for w=1:W
        println("W $w:", round(Int,value(p_w[w])*(DA_price - 0)))
    end
    println("\n")
    println("Utility of each demand:")
    for d=1:D
        println("D$d:", round(Int, value(p_d[d])*(U_d[d] - DA_price)))
    end
else
    println("No optimal solution available")
end
#************************************************************************

#Creating a dictionary for generators with a tuple that includes their offer price and then their maximum capacity
Generator_dictionary = Dict{Int, Tuple{Float64, Float64}}()
for g in 1:G
    Generator_dictionary[g] = (C_g[g], Cap_g[g])
end
#Creating a dictionary for demands with a tuple that includes their offer price and then their maximum capacity
Demand_Dictionary = Dict{Int, Tuple{Float64, Float64}}()
for d in 1:D
    Demand_Dictionary[d] = (U_d[d], Cap_d[d])
end

#=
# Sort generators by ascending order of their offer price
sorted_generators = sort(collect(Generator_dictionary), by=x->x[2][1])

# Sort demands by descending order of their offer price
sorted_demands = sort(collect(Demand_Dictionary), by=x->-x[2][1])

# Collect the sorted capacities and prices of generators and demands
generator_capacities = [x[2][2] for x in sorted_generators]
generator_prices = [x[2][1] for x in sorted_generators]
demand_capacities = [x[2][2] for x in sorted_demands]
demand_prices = [x[2][1] for x in sorted_demands]

#************************************* 
#Version 1 line graphs which suck

# Compute the cumulative sum of generator and demand capacities
cumulative_generator_capacities = cumsum(generator_capacities)
cumulative_demand_capacities = cumsum(demand_capacities)

# Plot the merit order curve
plot(cumulative_generator_capacities, generator_prices, label="Generator", xlabel="Capacity", ylabel="Price", legend=:topleft)
plot!(cumulative_demand_capacities, demand_prices, label="Demand")

#***************************
#Version 2 start and end points but can't merge the graphs to one
# Compute the start and end coordinates for each generator and demand
generator_starts = [sum(generator_capacities[1:g-1]) for g in 1:G]
generator_ends = [sum(generator_capacities[1:g]) for g in 1:G]
#demand_starts = [sum(demand_capacities[1:d-1]) + 1 for d in 1:G]
#demand_ends = [sum(demand_capacities[1:g]) for g in 1:G]



# Plot the merit order curve
scatter([generator_starts, generator_ends], generator_prices )


scatter([generator_starts; generator_ends], repeat(generator_prices, inner=[1]), label="Generator", xlabel="Capacity", ylabel="Price", legend=:topleft)
#plot!([demand_starts; demand_ends], repeat(demand_prices, inner=[2]), label="Demand") =#