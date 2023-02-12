
#=
plot(rand(100), label = "line 1", linewidth=5)
plot!(fill(0.2,100), label = "line 2" , lw =2)
plot!(size=(500,200)) 
plot!(xlable= "this is a lable", title="and this is a title")
=#


using JuMP, Gurobi, Printf

#Exercise 1
##############################################
#Model
my_model = Model(Gurobi.Optimizer)
#Variables
@variable(my_model, x)
@variable(my_model, y)
#Objective
@objective(my_model, Max,-x+3y)
#Constraints
@constraint(my_model, const1, x + y <= 6)
@constraint(my_model, x-y >= 2)
@constraint(my_model, x >= 3)
@constraint(my_model, y >= 0)
#Solve
#print(my_model)
#optimize!(my_model)


#Julias Exercise
##############################################
juliasModel = Model(Gurobi.Optimizer)

#Variables
@variable(juliasModel, 11 <= amountA)
@variable(juliasModel, 5 <= amountB)
@variable(juliasModel, 15 <= amountC)

@variable(juliasModel, maxTimeMachineA <= 50)
@variable(juliasModel, maxTimeMachineB <= 35)

#Objective
@objective(juliasModel, Max, 15*amountA + 7.5*amountB + 12*amountC)

#Constraints
@constraint(juliasModel, machineTimeA, (10/60)*amountA + 
                                (32/60)*amountB + 
                                (27/60)*amountC <= maxTimeMachineA)
@constraint(juliasModel, machineTimeB ,(60/60)*amountA + 
                                (24/60)*amountB + 
                                (40/60)*amountC <=maxTimeMachineB)


#print(juliasModel)
optimize!(juliasModel)


#Check if optimal solution was found 
#=
if termination_status(juliasModel) == MOI.OPTIMAL
    println("Optimal solution found")

    #Print out variable values and objective value
    println("Variable values:")
    @printf "Product A: %0.3f\n" value.(amountA)
    @printf "Product B: %0.3f\n" value.(amountB)
    @printf "Product C: %0.3f\n" value.(amountC)

    # Compute machine time used
    machineTimeA = (10/60)*value(amountA) + (32/60)*value(amountB) + (27/60)*value(amountC)
    machineTimeB = (60/60)*value(amountA) + (24/60)*value(amountB) + (40/60)*value(amountC)

     # Print machine time used
    print("\n")
    @printf("Machine A time used %0.3f hours out of %0.3i hours \n", machineTimeA, value(maxTimeMachineA))
    @printf("Machine B time used %0.3f hours out of %0.3i hours \n", machineTimeB, value(maxTimeMachineB))

   #println(value(maxTimeMachineA))
   # @printf("%0.3i\n",value(maxTimeMachineA))
   # @printf("%i",machineTime)
 

    @printf "\nObjective value: %0.3f\n" objective_value(juliasModel)
else
    error("No solution.")
end
=#

#Janns Exercise
jannsModel = Model(Gurobi.Optimizer)

#Setting factors
minimumAmountOfVegetable = 12
maximumAmountTomatoes = 50
maximumAmountCarrots = 40
maximumAmountOnions = 100

costOfWater = 0.2
#Variables
@variable(jannsModel, minimumAmountOfVegetable <= amountTomatoes <= maximumAmountTomatoes)
@variable(jannsModel, minimumAmountOfVegetable <= amountCarrots <= maximumAmountCarrots)
@variable(jannsModel, minimumAmountOfVegetable <= amountOnions <= maximumAmountOnions)
@variable(jannsModel, maxRowLength <= 20)

#Objective
@objective(jannsModel, Max, (2-5*costOfWater) * amountTomatoes + (1.5-3*costOfWater) * amountCarrots + (1.25-2*costOfWater) * amountOnions)

#Constraionts
@constraint(jannsModel, row1, (0.5/20)*amountTomatoes + (0.25/20)*amountCarrots + (0.5/20)*amountOnions <= maxRowLength)
@constraint(jannsModel, row2, (0.5/20)*amountTomatoes + (0.25/20)*amountCarrots + (0.5/20)*amountOnions <= maxRowLength)
@constraint(jannsModel, row3, (0.5/20)*amountTomatoes + (0.25/20)*amountCarrots + (0.5/20)*amountOnions <= maxRowLength)

optimize!(jannsModel)

if termination_status(jannsModel) == MOI.OPTIMAL
    println("Optimal solution found")

    #Print out variable values and objective value
    println("Variable values:")
    @printf "Product A: %0.3f\n" value.(amountTomatoes)
    @printf "Product B: %0.3f\n" value.(amountCarrots)
    @printf "Product C: %0.3f\n" value.(amountOnions)

    # Compute row usage
    row1 = (0.5/20)*value(amountTomatoes) + (0.25/20)*value(amountCarrots) + (0.5/20)*value(amountOnions) 
    row2 = (0.5/20)*value(amountTomatoes) + (0.25/20)*value(amountCarrots) + (0.5/20)*value(amountOnions) 
    row3 = (0.5/20)*value(amountTomatoes) + (0.25/20)*value(amountCarrots) + (0.5/20)*value(amountOnions) 
   
    #Print row usage
    @printf("Row 1 uses %0.3f m out of %0.3i meters \n", row1, value(maxRowLength))
    @printf("Row 2 uses %0.3f m out of %0.3i meters \n", row2, value(maxRowLength))
    @printf("Row 3 uses %0.3f m out of %0.3i meters \n", row3, value(maxRowLength))
    


    @printf "\nObjective value: %0.3f\n" objective_value(jannsModel)
else
    error("No solution.")
end

