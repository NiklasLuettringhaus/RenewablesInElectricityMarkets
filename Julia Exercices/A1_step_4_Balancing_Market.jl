#************************************************************************
# Incredible Chairs, Simple LP
using JuMP
using Gurobi
using DataFrames
using LinearAlgebra
import XLSX

#import Pkg; Pkg.add("XLSX")
#import Pkg; Pkg.add("DataFrames")

#************************************************************************

#************************************************************************
#PARAMETERS
include("data_Step_4_2.jl")

#************************************************************************

#************************************************************************
# Model
FN = Model(Gurobi.Optimizer)

@variable(FN, p_d[d=1:D]>=0) #covered demand DA

@variable(FN, up_bal[g=1:G]>=0) # up balancing action of gens
@variable(FN, down_bal[g=1:G]>=0) # down balancing action of gens

@variable(FN,p_w_grid_DA[w=1:W]>=0) #wind farm production to grid from DA
@variable(FN,p_w_H2_DA[w=1:W]>=0) #wind farm production to electrolyzer from DA

@variable(FN,p_g[g=1:G]>=0) #power scheduled DA of generetor g



@objective(FN, Max, sum(U_d[d]*p_d[d] for d=1:D)                    #Revenue from demand
            - sum(C_g[g]*p_g[g] for g=1:G)                          #Production cost + start-up cost conventional generator
            - sum(up_bal[g]*(DA_price+0.12*C_g[g]) for g=1:G)       #cost for upbalancing > lowering consumption
            - sum(down_bal[g]*(DA_price-0.15*C_g[g]) for g=1:G))    #cost for downbalancing > increasing consumption

#Capacity Limits
@constraint(FN,[d=1:D], p_d[d] <= Cap_d[t,d]) #Demand limits constraint
#@constraint(FN,[g=1:G], p_g[g] <= Cap_g[g]) #Generation limits constraint
@constraint(FN,[g=1:G], p_g[g] + up_bal[g] <= Cap_g[g]) #Generation limits constraint
@constraint(FN,[g=1:G], p_g[g] - down_bal[g] >= 0) #Generation limits constraint
@constraint(FN,[w=1:W], p_w_grid_DA[w] + p_w_H2_DA[w] <= transpose(WF_prod[w])) #Weather-based limits constraint WF from DA market

# DA Power Balance
@constraint(FN, Balance, sum(p_d[d] for d=1:D) - sum(p_w_grid_DA[w] for w=1:W) - sum(p_g[g] for g=1:G) ==0)

#Electrolyzer constraints
@constraint(FN,[w=1:2], 0.01*(WF_cap[w]/2) <= p_w_H2_DA[w] <= WF_cap[w]/2)
@constraint(FN,[w=1:2], sum(p_w_H2_DA[w]*H2_prod for t=1:T) >= H2_cap)

#Balancing action
@constraint(FN, [w=1:W; outage_sum >= 0], outage_sum == sum(down_bal[g] for g=1:G))    #down balancing action of electrolyzer needs to match WF error
@constraint(FN, [w=1:W; outage_sum < 0], abs(outage_sum) == sum(up_bal[g] for g=1:G))  #up balancing action of electrolyzer needs to match WF error
@constraint(FN, p_g[9] == Cap_g[9])
@constraint(FN, down_bal[9] == 0)
@constraint(FN, up_bal[9] == 0)

#print(FN) #print model to screen (only usable for small models)

#************************************************************************

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
    #Up_price = -dual.(Balance_up) #Equilibrium price
    #Down_price = -dual.(Balance_down) #Equilibrium price

    println("Cost of hydrogen production: ", round(value(sum(DA_price*p_w_H2_DA[w] for w=1:2)), digits = 2))
    #println("Cost of up balancing: ", round(value(sum(up_bal[g]*(DA_price+0.12*C_g[g]) for g=1:G)), digits = 2))
    #println("Cost of down balancing: ", round(value(sum(down_bal[g]*(DA_price-0.15*C_g[g]) for g=1:G)), digits = 2))

    #Market clearing price
    println("Market clearing price:", value(DA_price))#Print equilibrium price
    #println("Up balancing clearing price:", value(Up_price))#Print equilibrium price
    #println("Down balancing clearing price:", value(Down_price))#Print equilibrium price


    println("\n")
    println("Profit of each generator:")
    for g=1:G
        println("G$g: ", round(Int,value(p_g[g]*(DA_price - C_g[g]) + up_bal[g]*(DA_price+0.12*C_g[g]) + down_bal[g]*(DA_price-0.15*C_g[g]))))
        if g==9
        println("G$g: ", round(Int,value(p_g[g]*(DA_price - C_g[g])
                                        -sum(up_bal[g]*(DA_price+0.12*C_g[g]) for g=1:G)
                                        -sum(down_bal[g]*(DA_price-0.15*C_g[g]) for g=1:G))))
        end
    end
    println("\n")

    println("Scheduled DA production of each generator:")
    for g=1:G
        println("G$g: ", round(Int,value(p_g[g])))
    end
    println("\n")

    println("Up Balancing of each generator:")
    for g=1:G
        println("G$g: ", round(Int,value(up_bal[g])))
    end
    println("\n")

    println("Down Balancing of each generator:")
    for g=1:G
        println("G$g: ", round(Int,value(down_bal[g])))
    end
    println("\n")

    println("Demand:")
    for d=1:D
        println("D$d: ", round(Int,value(p_d[d])))
    end
    println("\n")

    println("Profit of windfarms:")
    for w=1:W
        println("WF $w: ", round(Int,value(p_w_grid_DA[w]*DA_price)))
    end
    println("\n")

    println("Production of windfarms:")
    for w=1:W
        println("Grid WF $w: ", round(Int,value(p_w_grid_DA[w])))
        for w=1:2
        println("H2 WF $w: ", round(Int,value(p_w_H2_DA[w])))
        end
    end
    println("\n")

    println("Production of hydrogen:")
    for w=1:2
        println("WF $w: ", round(Int,value(p_w_H2_DA[w]*H2_prod)))
    end
    println("\n")

    println("Fulfilled demand:")
    println(round(value((sum(p_d[d] for d=1:D)/sum(Cap_d[t,d] for d=1:D))*100),digits=2), "%")

    println("\n")
    
    #=
    DA_price_df=DataFrame(DA_price)
    PG_df=DataFrame(value.(p_g[:]),:auto)
    PD_df=DataFrame(value.(p_d[:]),:auto)
    PW_Grid_df=DataFrame(value.(p_w_grid_DA[:]),:auto)

    Hydrogen_Prodcution_Day_ahead_df=DataFrame(value.(p_w_H2_DA[:]), Wind_turbines)
    Down_Blancing_df=DataFrame(value.(down_bal[:]), Generators)
    Up_Blancing_df=DataFrame(value.(up_bal[:, :]), Generators)             
=#
else
    println("No optimal solution available")

end

#=
println(Down_Blancing_df)
#************************************************************************

#**************************

if(isfile("results_step4_2.xlsx"))
    rm("results_step4_2.xlsx")
end

XLSX.writetable("results_step4_2.xlsx",
    DA_Prices = (collect(eachcol(DA_price_df)), names(DA_price_df)),
    Generation = (collect(eachcol(PG_df)), names(PG_df)),
    Demand=(collect(eachcol(PD_df)), names(PD_df)),
    Wind_to_Grid=(collect(eachcol(PW_Grid_df)), names(PW_Grid_df)),

    Hydrogen_Prodcution_Day_ahead=(collect(eachcol(Hydrogen_Prodcution_Day_ahead_df)), names(Hydrogen_Prodcution_Day_ahead_df)),
    Down_Blancing=(collect(eachcol(Down_Blancing_df)), names(Down_Blancing_df)),
    Up_Blancing=(collect(eachcol(Up_Blancing_df)), names(Up_Blancing_df)),

    )
=#
#*****************************************************