#Assignment 2, Data file Step 1.1

using CSV
using DataFrames
using Random
using Distributions

#Generation units operationals details
P_max_s=[155, 100, 155, 197]
P_max_o=[ 337.5, 350 ,210 ,80]

Random.seed!(123)

# Offer prices Demands 8 different scenarios
offer_price_factors = rand(0.5:0.1:1.5, 5)

# Amount of demand 10 different possibilities

# Wind forecast has 25 different possibilities

# Offer Prices non Strat producers 5 different scenarios


C_s=[15.2, 23.4, 15.2, 19.1]
alpha_offer_o= [0, 5, 20.1, 24.7]

ramp_up_down_limit = [90, 85, 90, 120, 0 , 350, 170, 80]

#Demand details
D_max_k =  [200, 400, 300, 250]
alpha_bid = [26.5, 24.7, 23.1, 22.5]

random = []



Omega = [ #n rows and m columns
    0 1 1 0 0 0 
    1 0 1 1 0 0 
    1 1 0 0 0 1
    0 1 0 0 1 1
    0 0 0 1 0 1
    0 0 1 1 1 0
] 

F = Omega .* 400 #Transmission line capacity in MW
B = Omega .* 50 #Suceptance in per unit
Sys_power_base = 337.5  # MVA


S = 4
O = 4
N = 6
K = 4
nodes=["N1", "N2", "N3", "N4", "N5", "N6"]

psi_s = Int.(zeros(S, N)) #location of the generators in the node
psi_s[1,1]=1;
psi_s[2,2]=1;
psi_s[3,3]=1;
psi_s[4,6]=1;

psi_o = Int.(zeros(O, N)) #location of the generators in the node
psi_o[1,1]=1;
psi_o[2,2]=1;
psi_o[3,3]=1;
psi_o[4,5]=1;

psi_k = Int.(zeros(K, N)) #location of the demand in the node
psi_k[1,3]=1;
psi_k[2,4]=1;
psi_k[3,5]=1;
psi_k[4,6]=1;

M=100000 #Big M constraint
