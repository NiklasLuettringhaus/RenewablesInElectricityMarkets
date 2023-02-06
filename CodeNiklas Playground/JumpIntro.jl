
#=
plot(rand(100), label = "line 1", linewidth=5)
plot!(fill(0.2,100), label = "line 2" , lw =2)
plot!(size=(500,200)) 
plot!(xlable= "this is a lable", title="and this is a title")
=#


using JuMP, Gurobi

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
print(my_model)
optimize!(my_model)