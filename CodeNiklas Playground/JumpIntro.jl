
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

@variable(juliasModel, timeMachineA)
@variable(juliasModel, timeMachineB)

#Objective
@objective(juliasModel, Max, 15*amountA + 7.5*amountB + 12*amountC)

#Constraints
@constraint(juliasModel, machineTime1, (10/60)*amountA + 
                                (32/60)*amountB + 
                                (27/60)*amountC <= 50)
@constraint(juliasModel, machineTime2 ,(60/60)*amountA + 
                                (24/60)*amountB + 
                                (40/60)*amountC <=35)


#print(juliasModel)
optimize!(juliasModel)


#Check if optimal solution was found
if termination_status(juliasModel) == MOI.OPTIMAL
    println("Optimal solution found")

    #Print out variable values and objective value
    println("Variable values:")
    @printf "Product A: %0.3f\n" value.(amountA)
    @printf "Product B: %0.3f\n" value.(amountB)
    @printf "Product C: %0.3f\n" value.(amountC)
    @printf "\nObjective value: %0.3f\n" objective_value(juliasModel)
else
    error("No solution.")
end

