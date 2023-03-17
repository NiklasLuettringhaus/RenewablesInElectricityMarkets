#***********************************************
#                   This is the data file for step two
#************************************************
using StatsBase
using CSV
using LinearAlgebra

#Bid prices for demand d
U_d = [3.88	4.65 14.61	22.59	36.93	45.00	16.37	32.82	22.61	38.34	13.74	17.00	6.41	19.58	3.54	16.53	47.94]
#=
U_d = [
3.88	4.65	14.61	22.59	36.93	45.00	16.37	32.82	22.61	38.34	13.74	17.00	6.41	19.58	3.54	16.53	47.94
3.18	28.43	11.42	16.25	22.07	49.73	15.58	8.55	9.05	0.72	18.64	31.17	38.30	20.69	28.92	41.52	19.66
1.05	18.69	26.45	32.23	17.27	28.33	18.68	10.85	1.30	1.35	49.74	32.59	24.53	15.56	7.99	36.59	23.94
25.23	45.78	41.96	36.73	23.95	16.41	30.38	42.10	17.92	24.10	40.28	39.03	22.94	36.83	10.14	1.32	19.79
50.00	30.60	0.49	26.21	7.81	44.26	18.17	6.95	32.74	34.43	0.77	32.45	26.52	17.75	18.57	28.02	44.02
34.77	5.97	40.26	34.10	17.37	31.20	42.83	30.88	18.12	4.15	14.86	38.14	15.07	48.51	3.30	6.95	33.84
27.57	23.91	5.27	28.48	27.65	38.01	11.95	9.53	3.72	40.18	7.76	11.83	49.36	6.15	22.52	44.83	11.90
12.03	7.53	45.50	13.71	35.31	32.40	46.15	0.03	26.69	33.92	28.55	48.73	25.14	10.18	13.91	37.01	47.59
12.01	8.35	2.87	19.30	33.45	11.66	19.80	18.72	1.43	37.85	41.70	12.96	22.71	18.94	42.21	4.94	20.49
13.01	22.54	10.17	21.45	13.68	17.29	9.18	5.65	25.13	42.51	16.02	40.40	49.90	42.30	36.04	39.48	18.01
40.45	47.34	35.28	32.73	25.40	15.03	19.03	37.75	0.83	11.14	1.29	5.12	2.98	32.61	17.70	46.14	26.61
13.22	27.98	47.44	6.21	6.03	36.94	2.59	32.99	16.85	41.81	39.00	39.42	7.22	13.74	26.73	45.50	34.04
31.02	17.84	48.92	32.26	41.17	15.88	37.78	43.70	16.39	33.94	32.82	18.51	39.84	44.14	5.45	49.08	12.61
34.59	4.03	49.63	23.87	44.08	27.51	31.52	39.83	34.36	14.62	7.69	33.34	15.09	11.24	23.15	28.15	29.02
35.37	40.95	0.63	0.52	38.97	39.96	1.89	38.23	37.15	33.87	5.83	19.53	49.25	17.18	18.59	35.20	43.42
38.27	24.26	4.34	13.78	30.75	19.00	12.79	17.51	8.46	36.10	43.38	17.50	23.22	7.38	2.40	49.07	17.93
32.67	24.37	4.25	44.82	15.06	31.07	30.14	22.83	30.81	43.30	2.20	10.96	14.40	3.75	21.66	25.46	35.48
45.61	5.32	23.24	20.74	18.23	38.61	22.99	32.06	8.32	3.44	5.01	0.42	32.72	2.93	36.39	21.08	28.21
20.36	2.16	19.95	41.10	15.75	10.53	39.53	23.85	26.02	46.80	14.48	41.40	11.61	5.94	44.83	13.71	30.37
38.76	18.45	11.76	41.32	41.80	23.21	32.55	36.83	31.98	0.50	30.96	19.89	41.75	3.04	30.41	33.99	49.41
19.85	38.02	26.99	34.23	3.85	15.79	30.02	32.90	32.17	3.29	11.71	46.29	10.38	18.83	11.98	37.98	36.17
30.06	17.64	48.35	44.58	26.51	15.58	4.70	6.15	41.64	45.38	46.94	37.78	30.87	46.92	11.06	46.45	14.29
40.03	32.92	40.59	41.94	27.30	11.83	7.10	26.07	45.97	23.70	32.32	17.92	35.18	15.89	40.87	16.28	24.81
44.67	41.34	40.53	42.10	39.08	46.67	17.37	7.68	26.60	5.07	43.51	0.79	46.41	0.03	16.38	9.91	39.35
]
=#


#Offer prices of generator g
C_g = [13.32, 13.32, 20.7, 20.93, 26.11, 10.52, 10.52, 6.02, 5.47, 0, 10.52, 10.89]

#Startup Cost of generator
C_st = [1430.4, 1430.4, 1725, 3056.7, 437, 312, 312, 0, 0, 0, 624, 2298]

#Ramp up capactiy of generator g
Ramp_g_u = [120, 120, 350, 240, 60, 155, 155, 280, 280, 300, 1380, 240]

#Ramp down capacity of generator g
Ramp_g_d = [120, 120, 350, 240, 60, 155, 155, 280, 280, 300, 1380, 240]

#Initial capacitiy of generator g
Cap_g_init = [76, 76, 0, 0, 0, 0, 124, 240, 240, 240, 248, 280]

#Capactiy of generator
Cap_g = [152, 152, 350, 591, 60, 155, 155, 400, 400, 300, 310, 350]

#Cost of load curtailment
cost_load_cur = 500         #$/MWh

#Wind farm production

WF_cap = [300 300 10 20 50 30]  

#Windfarm production

H2_prod = 18 # kg/MW
H2_cap = 30000 #kg
H2_price = 3 # $/kg

WF_forecast = [
0.384460432	0.507700265	0.464001468	0.476854388	0.480010191	0.354536609
0.334138265	0.454994581	0.54583715	0.539685808	0.518080915	0.563091923
0.392110218	0.584795108	0.714400615	0.673901003	0.641382393	0.669161281
0.320718433	0.671243011	0.797851152	0.668318094	0.714843169	0.77116669
0.511097833	0.727537368	0.80471868	0.826516316	0.720152	0.807447889
0.670195009	0.655562455	0.78511441	0.809137828	0.723180757	0.776111428
0.732582857	0.768348637	0.707830387	0.799635018	0.764298474	0.768020472
0.715879043	0.816961955	0.776469662	0.854023534	0.793214381	0.821533153
0.81648375	0.722400861	0.863191232	0.926590171	0.75450382	0.832787658
0.863173498	0.520111023	0.833182002	0.890071784	0.748322057	0.751472883
0.834677138	0.444935503	0.774479239	0.936281889	0.818448146	0.73702784
0.809602492	0.224880141	0.641340054	0.822665473	0.772781998	0.764897388
0.779704416	0.146453659	0.626471977	0.76582145	0.716743791	0.743455941
0.737250633	0.498119723	0.687403887	0.725455842	0.747518233	0.643461258
0.720228322	0.595258429	0.68155346	0.711411711	0.74479002	0.486981318
0.745210235	0.52309738	0.656027907	0.727362719	0.714129447	0.545111969
0.682319242	0.5766993	0.653150108	0.732590528	0.698494334	0.482333177
0.656484829	0.726077589	0.673278471	0.737030766	0.714711641	0.450140018
0.73425636	0.784294397	0.490773235	0.783363368	0.663606741	0.553687782
0.724073595	0.816551028	0.604189638	0.768001549	0.741312682	0.655756572
0.736487841	0.81846392	0.69315734	0.73262652	0.816838864	0.679762973
0.631564115	0.785237702	0.816531333	0.774745004	0.759589336	0.640565479
0.624393969	0.614665034	0.816363695	0.758243479	0.802241398	0.319509819
0.689311008	0.763958131	0.807860049	0.643279473	0.790233348	0.160219534
]


WF_prod = (WF_cap) .* WF_forecast 


WF_prod_rt = [5.76690648 137.07907155 7.656024222 7.152815820000001 40.800866235 14.890537577999998; 
120.2897754 272.9967486 1.910430025 11.333401967999999 38.856068625 29.5623259575;
135.27802521 236.84201874000004 7.858406765 10.782416048000002 38.48294358 4.014967686;
168.37717732500002 201.3729033 6.382809216 0.0 33.9550505275 28.918750875000004;
99.66407743500001 207.34814988 10.0 13.224261056000001 39.608360000000005 6.0558591674999995;
170.899727295 177.00186285 5.103243665000001 9.709653936 9.0397594625 23.28334284;
131.86491426 115.25229555 9.5557102245 19.191240432 19.10746185 20.736552744;
171.81097032000002 232.834157175 10.0 11.102305942 50.0 30.0;
183.70884375 151.70418081 3.8843605439999997 20.0 35.838931450000004 30.0; 
168.31883211000002 179.438302935 10.0 20.0 46.770128562500005 18.035349192; 
37.560471209999996 193.54694380499998 9.6809904875 10.299100779 50.0 2.2110835200000003;
109.29633642 47.22482961 6.734070567000001 20.0 5.795864985 30.0; 
292.38915599999996 15.377634195 6.26471977 13.01896465 32.253470594999996 27.8795977875; 
176.94015192000003 201.738487815 5.1555291525 20.0 42.982298397499996 16.408262079;
291.69247041 89.28876435000001 2.04466038 2.1342351330000002 22.343700600000002 0.7304719770000001;
300.0 117.69691049999997 9.512404651499999 20.0 50.0 9.812015442;
214.93056123000002 17.300979 8.490951404 13.919220032 1.7462358350000002 11.575996248000001; 
236.33453844000002 239.60560437 8.752620123000002 20.0 30.375244742499998 16.205040647999997; 
66.0830724 247.05273505500003 5.1531189675 20.0 50.0 4.983190037999999; 
184.638766725 269.46183924 5.739801561 16.128032529 50.0 19.672697160000002;
154.66244661 300.0 8.31788808 19.04828952 50.0 5.0982222974999996; 
132.62846414999999 200.23561401 7.7570476635 17.819135092 26.585626759999997 7.686785748000002;
159.220462095 92.1997551 10.0 15.923113059 32.089655920000006 11.981618212499999; 
248.15196287999999 252.10618323000003 4.039300245 18.655104716999997 29.633750550000002 3.8452688160000004]

WF_error = WF_prod - WF_prod_rt

outage_sum = sum(WF_error[1,w] for w=1:W)

#***************************************
#   DO NOOT TOUCH THIS WILL GENERATE A NEW ACTUAL PRODUCTION OF ALL WINDFARMS SO DO NOT DUCKING TOUCH
#***************************************
#=
WF_prod_rt = zeros(24,6)
for t=1:T
    for w=1:W
        WF_temp[t,w] = sample(rt_wind, Weights(prob)) * WF_prod[t,w] #Weighted error value for each hour and windfarm
        if WF_temp[t,w] > WF_cap[w]
            WF_prod_rt[t,w] = WF_cap[w]
        else
            WF_prod_rt[t,w] = WF_temp[t,w]
        end 
    end
end
=#


#Maximum load of demand
Cap_d = [67.48173, 60.37839, 111.877605, 46.17171, 44.395875, 85.24008, 78.13674, 106.5501, 108.325935, 120.75678, 165.152655, 120.75678, 197.117685, 62.154225, 207.772695, 113.65344, 79.912575]

#Index sets for demands and gener
D = size(U_d, 2)

G = length(C_g)

#Hours in a day
T = size(U_d, 1)
Hours_in_day = string.([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24])
#Number of wind turbines
 W = 6
 Wind_turbines = string.(["W1","W2","W3","W4","W5","W6"])
 
 Loads = Array{String}(undef, 17 , 1)
 for d in 1 : size(U_d, 2)
    Loads[d] = "Load $(d)"
 end
Loads

#Outputs
DA_price = 0




#=Suceptance matrix from node n (row) to node m (column) in pu
#B =[0	0.0146	0.2253	0	0.0907	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
#0.0146	0	0	0.1356	0	0.205	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
#0.2253	0	0	0	0	0	0	0	0.1271	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0.084;
#0	0.1356	0	0	0	0	0	0	0.111	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
#0.0907	0	0	0	0	0	0	0	0	0.094	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	0.205	0	0	0	0	0	0	0	0.0642	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	0.0652	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0.0652	0	0.1762	0.1762	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0.1271	0.111	0	0	0	0.1762	0	0	0.084	0.084	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0.094	0.0642	0	0.1762	0	0	0.084	0.084	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	0.084	0.084	0	0	0.0488	0.0426	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	0.084	0.084	0	0	0.0488	0	0	0	0	0	0	0	0	0	0.0985	0;
0	0	0	0	0	0	0	0	0	0	0.0488	0.0488	0	0	0	0	0	0	0	0	0	0	0.0884	0;
0	0	0	0	0	0	0	0	0	0	0.0426	0	0	0	0	0.0594	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0.0172	0	0	0	0	0.0249	0	0	0.0529;
0	0	0	0	0	0	0	0	0	0	0	0	0	0.0594	0.0172	0	0.0263	0	0.0234	0	0	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0.0263	0	0.0143	0	0	0	0.1069	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0.0143	0	0	0	0.0132	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0.0234	0	0	0	0.0203	0	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0.0203	0	0	0	0.0112	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0.0249	0	0	0.0132	0	0	0	0.0692	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0.1069	0	0	0	0.0692	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0.0985	0.0884	0	0	0	0	0	0	0.0112	0	0	0	0;
0	0	0.084	0	0	0	0	0	0	0	0	0	0	0	0.0529	0	0	0	0	0	0	0	0	0;
]
=#



nodes=["N1", "N2", "N3", "N4", "N5", "N6", "N7", "N8", "N9", "N10", "N11", "N12", "N13", "N14", "N15", "N16", "N17", "N18", "N19", "N20", "N21", "N22", "N23", "N24"]
N=length(nodes)

areas=["A1","A2","A3"]
A=length(areas)

Sys_power_base=600 # MVA

B=zeros(N, N)
B[1,2]=500;
B[1,3]=500;
B[1,5]=500;
B[2,4]=500;
B[2,6]=500;
B[3,9]=500;
B[3,24]=500;
B[4,9]=500;
B[5,10]=500;
B[6,10]=500;
B[7,8]=500;
B[8,9]=500;
B[8,10]=500;
B[9,11]=500;
B[9,12]=500;
B[10,11]=500;
B[10,12]=500;
B[11,13]=500;
B[11,14]=500;
B[12,13]=500;
B[12,23]=500;
B[13,23]=500;
B[14,16]=500;
B[15,16]=500;
B[15,21]=500;
B[15,24]=500;
B[16,17]=500;
B[16,19]=500;
B[17,18]=500;
B[17,22]=500;
B[18,21]=500;
B[19,20]=500;
B[20,23]=500;
B[21,22]=500;
B[2,1]=500;
B[3,1]=500;
B[5,1]=500;
B[4,2]=500;
B[6,2]=500;
B[9,3]=500;
B[24,3]=500;
B[9,4]=500;
B[10,5]=500;
B[10,6]=500;
B[8,7]=500;
B[9,8]=500;
B[10,8]=500;
B[11,9]=500;
B[12,9]=500;
B[11,10]=500;
B[12,10]=500;
B[13,11]=500;
B[14,11]=500;
B[13,12]=500;
B[23,12]=500;
B[23,13]=500;
B[16,14]=500;
B[16,15]=500;
B[21,15]=500;
B[24,15]=500;
B[17,16]=500;
B[19,16]=500;
B[18,17]=500;
B[22,17]=500;
B[21,18]=500;
B[20,19]=500;
B[23,20]=500;
B[22,21]=500;


#Capacity matrix from node n (row) to node m (column)

F=[
    0	175	175	0	350	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
175	0	0	175	0	175	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
175	0	0	0	0	0	0	0	175	0	0	0	0	0	0	0	0	0	0	0	0	0	0	400;
0	175	0	0	0	0	0	0	175	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
350	0	0	0	0	0	0	0	0	350	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	175	0	0	0	0	0	0	0	175	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	350	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	350	0	175	175	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	175	175	0	0	0	175	0	0	400	400	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	350	175	0	175	0	0	400	400	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	400	400	0	0	500	500	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	400	400	0	0	500	0	0	0	0	0	0	0	0	0	500	0;
0	0	0	0	0	0	0	0	0	0	500	500	0	0	0	0	0	0	0	0	0	0	250	0;
0	0	0	0	0	0	0	0	0	0	500	0	0	0	0	250	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	500	0	0	0	0	400	0	0	500;
0	0	0	0	0	0	0	0	0	0	0	0	0	250	500	0	500	0	500	0	0	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	500	0	500	0	0	0	500	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	500	0	0	0	1000	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	500	0	0	0	1000	0	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1000	0	0	0	1000	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	400	0	0	1000	0	0	0	500	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	500	0	0	0	500	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	500	250	0	0	0	0	0	0	1000	0	0	0	0;
0	0	400	0	0	0	0	0	0	0	0	0	0	0	500	0	0	0	0	0	0	0	0	0;
]



psi_d= zeros(D, N) #location of the demand in the node
psi_d[1,1]=1;
psi_d[2,2]=1;
psi_d[3,3]=1;
psi_d[4,4]=1;
psi_d[5,5]=1;
psi_d[6,6]=1;
psi_d[7,7]=1;
psi_d[8,8]=1;
psi_d[9,9]=1;
psi_d[10,10]=1;
psi_d[11,13]=1;
psi_d[12,14]=1;
psi_d[13,15]=1;
psi_d[14,16]=1;
psi_d[15,18]=1;
psi_d[16,19]=1;
psi_d[17,20]=1;


psi_g= zeros(G, N) #location of the generators in the node
psi_g[1,1]=1;
psi_g[2,2]=1;
psi_g[3,7]=1;
psi_g[4,13]=1;
psi_g[5,15]=1;
psi_g[6,15]=1;
psi_g[7,16]=1;
psi_g[8,18]=1;
psi_g[9,21]=1;
psi_g[10,22]=1;
psi_g[11,23]=1;
psi_g[12,23]=1;

psi_w=zeros(W,N) #location of the wind farms in the node
psi_w[1,3]=1;
psi_w[2,5]=1;
psi_w[3,16]=1;
psi_w[4,21]=1;
psi_w[5,16]=1;
psi_w[6,21]=1;

psi_n= zeros(N, A) #location of the node n in the area a
psi_n[1,2]=1;
psi_n[2,2]=1;
psi_n[3,2]=1;
psi_n[4,2]=1;
psi_n[5,2]=1;
psi_n[6,3]=1;
psi_n[7,3]=1;
psi_n[8,3]=1;
psi_n[9,2]=1;
psi_n[10,3]=1;
psi_n[11,2]=1;
psi_n[12,3]=1;
psi_n[13,1]=1;
psi_n[14,1]=1;
psi_n[15,1]=1;
psi_n[16,1]=1;
psi_n[17,1]=1;
psi_n[18,1]=1;
psi_n[19,1]=1;
psi_n[20,1]=1;
psi_n[21,1]=1;
psi_n[22,1]=1;
psi_n[23,1]=1;
psi_n[24,2]=1;

ATC=zeros(A, A)
for a=1:A
    for b=1:A
        ATC[a,b]=sum(F[n,m] for n=1:N,m=1:N if psi_n[n,a]==1 && psi_n[m,b]==1)
        #ATC[a,b]=0.2*sum(F[n,m] for n=1:N,m=1:N if psi_n[n,a]==1 && psi_n[m,b]==1)
    end
end
ATC[diagind(ATC)[1:A]] .= 0 #Set all the diagonal elements to zero

#**********************************************************************************************************
#**********************************************************************************************************

#Step 4 - Probabilities of wind forecast error
prob = [
0.107981933
0.13123163
0.157900317
0.188098155
0.221841669
0.259035191
0.299454931
0.342737184
0.38837211
0.435704354
0.483941449
0.5321705
0.579383106
0.624507867
0.666449206
0.704130654
0.736540281
0.762775631
0.782085388
0.793905095
0.797884561
0.793905095
0.782085388
0.762775631
0.736540281
0.704130654
0.666449206
0.624507867
0.579383106
0.5321705
0.483941449
0.435704354
0.38837211
0.342737184
0.299454931
0.259035191
0.221841669
0.188098155
0.157900317
0.13123163
0.107981933]

rt_wind = [
0
0.05
0.1
0.15
0.2
0.25
0.3
0.35
0.4
0.45
0.5
0.55
0.6
0.65
0.7
0.75
0.8
0.85
0.9
0.95
1
1.05
1.1
1.15
1.2
1.25
1.3
1.35
1.4
1.45
1.5
1.55
1.6
1.65
1.7
1.75
1.8
1.85
1.9
1.95
2]
