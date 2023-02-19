# ---------------------------------------------------------------------------- #
#                             JULIA'S PROBLEM                                 #
# ---------------------------------------------------------------------------- #

using Gurobi,JuMP,Printf

model_ex2 = Model(Gurobi.Optimizer)

### Sets ###
Products = ["A", "B", "C"]
P = [i for i in 1:length(Products)] ; println(P)
Machines = ["M1", "M2"]
M = [i for i in 1:length(Machines)] ; println(M)

### Parameters ###
Matrixs = [ [10,60] [32,24] [27,40] ] # min/unit
Matrix_hour = Matrixs/60
println(Matrix_hour,size(Matrix_hour))

ProfitProduct = [ 15 7.5 12 ] # $/unit
println(ProfitProduct,size(ProfitProduct))

MachineAvailability = [ 50 , 35] # hours
println(MachineAvailability,size(MachineAvailability))

PrePurchase = [11 5 15]

@variable(model_ex2, product[P] >= 0 ) # Amount of the specific product

# Objective is to maximize profit
@objective(model_ex2, Max, sum(ProfitProduct[p]*product[p] for p in P ))

@constraint(model_ex2, Availability_con[m in M], sum(Matrix_hour[m,p]*product[p] for p in P) <= MachineAvailability[m]) #

@constraint(model_ex2, PrePurchase_con[p in P], product[p] >= PrePurchase[p]) #

optimize!(model_ex2)

#Check if optimal solution was found
if termination_status(model_ex2) == MOI.OPTIMAL
    println("Optimal solution found")

    #Print out variable values and objective value
    println("Variable values:")
    for p in P
        println("Product ", Products[p] ,": ", value.(product[p]) )
    end   
    @printf "\nObjective value: %0.3f\n" objective_value(model_ex2)
else
    error("No solution.")
end
