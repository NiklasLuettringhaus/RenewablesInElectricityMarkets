# ---------------------------------------------------------------------------- #
#                             JANN'S PROBLEM                                 #
# ---------------------------------------------------------------------------- #


using Gurobi,JuMP,Printf

model_ex3 = Model(Gurobi.Optimizer)

### Sets ###
Vegetables = ["Tomatoes", "Carrots", "Onions"]
V = [i for i in 1:length(Vegetables)] ; println(V)

### Parameters ###
Matrix = [ [0.50,0.25,0.50] [5,3,2] [2,1.5,1.25] ] # min/unit
println(Matrix,size(Matrix))

Space = Matrix[:,1] ; println(Space) # m/unit
Water = Matrix[:,2] ; println(Water) # L/unit   
Price = Matrix[:,3] ; println(Price) # $/unit

Cost_per_Water = 0.2 # $/L
Total_Space = 3 * 20 # m
Max_Number_Of_Units = [50 40 100] # Max number of units for specific Vegetable
Min_Number_Of_Units = [12 12 12]  # Min number of unit for specific Vegetable


@variable(model_ex3, x[V] >= 0 )        # Amount of the specific product

@objective(model_ex3, Max, sum( (Price[v] - Water[v]*Cost_per_Water) *x[v] for v in V ) ) 

@constraint(model_ex3, Space_con, sum(Space[v]*x[v] for v in V) <= Total_Space) # Space constraint

@constraint(model_ex3, Vegetable_con[v in V], Min_Number_Of_Units[v] <= x[v] <= Max_Number_Of_Units[v]) # Vegetable constraint

optimize!(model_ex3)

#Check if optimal solution was found
if termination_status(model_ex3) == MOI.OPTIMAL
    println("Optimal solution found")

    #Print out variable values and objective value
    println("Variable values:")
    for v in V
        println(Vegetables[v] ,": ", value.(x[v]) )
    end   
    @printf "\nObjective value: %0.3f\n" objective_value(model_ex3)
else
    error("No solution.")
end

