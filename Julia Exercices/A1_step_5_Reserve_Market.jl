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
include("data_Step_5_Reserve_Market.jl")

#************************************************************************

#************************************************************************
# Model
FN = Model(Gurobi.Optimizer)

@variable(FN,up_g[t=1:T,g=1:G]>=0) #up reserve generators
@variable(FN,down_g[t=1:T,g=1:G]>=0) #down reserve generators
@variable(FN,up_e[t=1:T,w=1:2]>=0) #up reserve electrolyser
@variable(FN,down_e[t=1:T,w=1:2]>=0) #down reserve electrolyser


@objective(FN, Min, sum(up_g[t,g] * c_res_g[t,g] for t=1:T, g=1:G)
                    + sum(down_g[t,g] * c_res_g[t,g] for t=1:T, g=1:G)
                    + sum(up_e[t,w] * c_res_e[t,w] for t=1:T, w=1:2)
                    + sum(down_e[t,w] * c_res_e[t,w] for t=1:T, w=1:2)
)

#Capacity Limits
@constraint(FN,[t=1:T, d=1:D], sum(up_g[t,g] + down_e[t,w] for g=1:G, w=1:2) == sum(Cap_d[t,d] for d=1:D)*0.2)      #up reserve requirements     
@constraint(FN,[t=1:T, d=1:D], sum(down_g[t,g] + up_e[t,w] for g=1:G, w=1:2) == sum(Cap_d[t,d] for d=1:D)*0.15) #down reserve  limits constraint

@constraint(FN,[t=1:T,g=1:G], up_g[t,g] <= 0.1 * Cap_g[g])        #Generation limits constraint
@constraint(FN,[t=1:T,g=1:G], down_g[t,g] <= 0.1 *  Cap_g[g])      #Generation limits constraint
@constraint(FN,[t=1:T,w=1:2], up_e[t,w] <= 0.1 * WF_cap[w]/2)     #capacity-based limits constraint WF
@constraint(FN,[t=1:T,w=1:2], down_e[t,w] <=  0.1 * WF_cap[w]/2)   #capacity-based limits constraint WF

#=
#Ramping up and down constraints
@constraint(FN,[t=1:T,g=1:G], abs(up_g[t,g])-abs((t-1<1 ? Cap_g_init[g] : up_g[t-1,g]))<=Ramp_g_d[g])
@constraint(FN,[t=1:T,g=1:G], p_g[t,g] >= (t-1<1 ? Cap_g_init[g] : p_g[t-1,g]) - Ramp_g_d[g]) #ramp down constraint
=#

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

Up_Gen=DataFrame(value.(up_g[:,:]), :auto)
Down_Gen=DataFrame(value.(down_g[:,:]), :auto)
Up_El=DataFrame(value.(up_e[:,:]), :auto)
Down_El=DataFrame(value.(down_e[:,:]), :auto)
println("/n Up reserve generators")
print(Up_Gen)
println("/n Down reserve generators")
print(Down_Gen)
println(" /n Up reserve hydrolysers")
print(Up_El)
println(" /n Downs reserve hydrolysers")
print(Down_El)

    

else
    println("No optimal solution available")
end
#=
println(Load_Curtailment_df)
#************************************************************************

#**************************

if(isfile("results_step4_zonal.xlsx"))
    rm("results_step4_zonal.xlsx")
end

XLSX.writetable("results_step4_H2_zonal.xlsx",
    DA_Prices = (collect(eachcol(DA_price_df)), names(DA_price_df)),
    Flows = (collect(eachcol(Flows_df)), names(Flows_df)),
    Generation = (collect(eachcol(PG_df)), names(PG_df)),
    Demand=(collect(eachcol(PD_df)), names(PD_df)),
    Wind_to_Grid=(collect(eachcol(PW_Grid_df)), names(PW_Grid_df)),
    Zonal_Generation=(collect(eachcol(PG_zonal_df)), names(PG_zonal_df)),
    Zonal_Demand=(collect(eachcol(PD_zonal_df)), names(PD_zonal_df)),
    Zonal_Wind=(collect(eachcol(PW_Grid_zonal_df)), names(PW_Grid_zonal_df)),

=#
#*****************************************************