# ---------------------------------------------------------------------------- #
#                             JANN'S PROBLEM                                 #
# ---------------------------------------------------------------------------- #

# PACKAGE IMPORT
using JuMP
using Gurobi
using Printf

# DECLARE MODEL
model_Jann = Model(Gurobi.Optimizer)

#Declare variables
@variable(model_Jann, 12<=x1<=50)
@variable(model_Jann, 12<=x2<=40)
@variable(model_Jann, 12<=x3<=100)

#Declare maximization of costs objective function
@objective(model_Jann, Max, (2-5*0.20)*x1 + (1.5-3*0.20)*x2 + (1.25-2*0.20)*x3)

#Declare constraint for Space composition
@constraint(model_Jann, Space, 0.5x1 + 0.25x2 + 0.5x3 <= 60)

#Optimize model
optimize!(model_Jann)

#Check if optimal solution was found
if termination_status(model_Jann) == MOI.OPTIMAL
    println("Optimal solution found")

    #Print out variable values and objective value
    println("Variable values:")
    @printf "Tomatoes: %0.3f\n" value.(x1)
    @printf "Carrots: %0.3f\n" value.(x2)
    @printf "Onions: %0.3f\n" value.(x3)
    @printf "\nObjective value: %0.3f\n" objective_value(model_Jann)
else
    error("No solution.")
end
