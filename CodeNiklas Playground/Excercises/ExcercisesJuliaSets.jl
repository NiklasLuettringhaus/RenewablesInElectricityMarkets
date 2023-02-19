using Gurobi,JuMP,Printf
#_____________________________________________________________________________________________________
                                            #Julias Sets
#_____________________________________________________________________________________________________

juliasSets = Model(Gurobi.Optimizer)


#Defining Sets
products = ["A", "B", "C"]
pIS = [i for i in 1:length(products)] #defining the product index set [1,2,3...]

machines = ["M1", "M2"]
mIS = [i for i in 1:length(machines)] #defining the machine index set [1,2,]

#parameters
machineTimes = [[10,60] [32,24] [27,40]] #setting up the machine times for each product
machineTimesHours = machineTimes/60 #converting min into hours

maxMachineTimes = [50, 35] #defining maximum hours per machine
println(machineTimesHours)

profitProduct = [15, 7.5, 12] #defining profits per product

minimumUnits = [ 11, 5, 15] #defining minimum number of units that have to be sold for each product

#numberProducts = [] #creating empty vector for the final number of products


@variable(juliasSets, numberProducts[pIS] >= 0 )

#Objective function
@objective(juliasSets, Max, sum(profitProduct[p] * numberProducts[p] for p in pIS))

@constraint(juliasSets,minimumUnitsCon[p in pIS], numberProducts[p] >= minimumUnits[p])

@constraint(juliasSets, machineCon[m in mIS],sum(machineTimesHours[m, p] * numberProducts[p] for p in pIS) <= maxMachineTimes[m])

optimize!(juliasSets)

for m in mIS
    machineTimeUsed = zeros[length[mIS]]
    for p in pIS
        machineTimeUsed[m] += value(machineTimeUsed[m,p])*value(numberProducts[p])
    end
    println("Machine ", machines[m], " used ", machineTimeUsed, " hours")
end



for m in mIS
    machineTime = 0 
    for p in pIS
        machineTime[m] += value(machineTimesHours[m,p])*value(numberProducts[p])
    end
end





println(sum(machineTimesHours[1,:]))
#compute machine times
for p in numberProducts
    machineTimeUsed = numberProducts[p] * machineTimes[:, ]

end
if termination_status(juliasSets) == MOI.OPTIMAL
    println("Optimal Solution Found")


    println("Variable Values:")
        for p in pIS
            println("Product ", products[p], ": ", value.(numberProducts[p]))
        end
    println("Machine Times:")
        for m in mIS
            println("Machine ", machines[m], " used ", machineTimesHours)


        end
    @printf "\nObjective value is: %0.3f\n" objective_value(juliasSets)
else
    error("No solution found")

end
