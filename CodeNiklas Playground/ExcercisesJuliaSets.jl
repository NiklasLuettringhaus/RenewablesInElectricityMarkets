using Gurobi,JuMP,Printf
#_____________________________________________________________________________________________________
                                            #Janns Sets
#_____________________________________________________________________________________________________

jannsSets = Model(Gurobi.Optimizer)


#Defing Sets
Vegetables = ["Tomatoes", "Carrots", "Onions"]

vis = [i for i in 1:length(Vegetables)]; println(vis)

#Parameters
factors = [[0.50, 0.25, 0.50] [5, 3, 2] [2, 1.5, 1.25]]
println(factors,size(factors))

#conversion to vectors
space = factors[:,1] ; println(space) # m unit
water = factors[:,2] ; println(water) # l unit
price = factors[:,3] ; println(price) # $ unit

waterCost = 0.2 # $/L
totalSpace = 20 * 3 # m

maxNumberofUnits = [50, 40, 100]
minNumberofUnits = [12, 12, 12]

#Variables

@variable(jannsSets, x[vis] >= 0)

@objective(jannsSets, Max, sum((price[i] - water[i] * waterCost) * x[i] for i in vis))

@constraint(jannsSets,spaceConstraint, sum(space[i]*x[i] for i in vis) <= totalSpace)
@constraint(jannsSets, vegetableConstraint[i in vis], minNumberofUnits[i] <= x[i] <= maxNumberofUnits[i])

optimize!(jannsSets)


if termination_status(jannsSets) == MOI.OPTIMAL
    println("Optimal solution found")

    #Print out variable values and objective value
    println("Variable values:")
    for i in vis
        println(Vegetables[i] ,": ", value.(x[i]) )
    end   
    @printf "\nObjective value: %0.3f\n" objective_value(jannsSets)
else
    error("No solution.")
end

#_____________________________________________________________________________________________________
                                            #Julias Sets
#_____________________________________________________________________________________________________

juliasSets = Model(Gurobi.Optimizer)


#Defining Sets
products = ["A", "B", "C"]
pIS = [i for i in 1:length(products)] #defining the product index set [1,2,3...]

machines = ["M1", "M2"]
mIS = [i for i in 1:length(machines)]

#parameters
machineTimes = [[10,60] [32,24] [27,40]]
machineTimesHours = machineTimes/60

println(machineTimesHours)

machinetimeA = factors[:,1]
machinetimeB = factors[:,2]
machinetimeC = factors[:,3]

