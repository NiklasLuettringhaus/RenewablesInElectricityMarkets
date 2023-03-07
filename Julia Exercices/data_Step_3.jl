#***********************************************
#                   This is the data file for step two
#************************************************
using LinearAlgebra

#Bid prices for demand d
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
#Wind farm production

WF_cap = [300 300 10 20 50 30]

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


WF_prod =  WF_forecast .* WF_cap

#Maximum load of demand
Cap_d = [67.48173, 60.37839, 111.877605, 46.17171, 44.395875, 85.24008, 78.13674, 106.5501, 108.325935, 120.75678, 165.152655, 120.75678, 197.117685, 62.154225, 207.772695, 113.65344, 79.912575]

#Index sets for demands and gener
D = size(U_d, 2)

G = length(C_g)

#Hours in a day
T = size(U_d, 1)

#Number of wind turbines
W = 6

#Outputs
DA_price = zeros(T)




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
