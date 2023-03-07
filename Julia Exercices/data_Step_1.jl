#************************************************************************
using DataFrames

#PARAMETERS
#Bid price of demand d
U_d = [17.93875424, 24.42616924, 4.749346522, 21.18061301, 2.951325259, 11.02942244, 13.33877397, 12.30192194, 16.97765831, 22.95542703, 2.598026883, 16.71032337, 11.91189354, 16.98398964, 12.96682873, 11.388699587, 18.51956607]

#Offer price of generator g
C_g = [13.32, 13.32, 20.7, 20.93, 26.11, 10.52, 10.52, 6.02, 5.47, 10, 10.52, 10.89]

#Startup Cost of generator 
C_st = [1430.4, 1430.4, 1725, 3056.7, 437, 312, 312, 0, 0, 0, 624, 2298]

#Capacity of generator g
Cap_g = [152, 152, 350, 591, 60, 155, 155, 400, 400, 300, 310, 350] 

#Wind farm production for each time step(hour) t and wind farm w
WF_cap = [150, 150, 10, 20, 50, 30]
WF_forecast = [0.384460432	0.507700265	0.464001468	0.476854388	0.480010191	0.354536609]

WF_prod =  WF_cap* WF_forecast

#maximum load of demand 
Cap_d = [67.48173, 60.37839, 111.877605, 46.17171, 44.395875, 85.24008, 78.13674, 106.5501, 108.325935, 120.75678, 165.152655, 120.75678, 197.117685, 62.154225, 207.772695, 113.65344, 79.912575]

# Sets
D = length(U_d)
G = length(C_g)
#Number of WF
W = 6

Demands = collect(1:D)
#************************************************************************

Generators = DataFrame(zeros(Float64, 12, 4), Colum_Names_generators)
# Set generator index in column one
Generators[:, 1] = collect(1:12)
# Set generator costs in column two
Generators[:, 2] = C_g
# Set generator capacity in column three
Generators[:, 3] = Cap_g
# Sort generators by cost (second column)
Generators = Generators[sortperm(Generators[:, 2]), :]
# Set cumulative capacity in column four
Generators[!, 4] = cumsum(Generators[!,:Capacity])
# Make names for colums
Colum_Names_generators = ["no", "Cost", "Capacity", "Cumulative Capacity"]


bar(Generators[:,"Cumulative Capacity"], Generators[:,"Cost"], 
    bar_width=Generators[:,"Capacity"],
    xlabel="Cumulative Capacity", ylabel="Cost",
    legend=false, title="Generator Cost by Cumulative Capacity")