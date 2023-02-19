#***********************************************
#                   This is the data file for step two
#************************************************
#Bid prices for demand d
U_d = [17.93875424, 24.42616924, 4.749346522, 21.18061301, 2.951325259, 11.02942244, 13.33877397, 12.30192194, 16.97765831, 22.95542703, 2.598026883, 16.71032337, 11.91189354, 16.98398964, 12.96682873, 11.388699587, 18.51956607]

#Offer prices of generator g
C_g = [13.32, 13.32, 20.7, 20.93, 26.11, 10.52, 10.52, 6.02, 5.47, 0, 10.52, 10.89]

#Startup Cost of generator
C_st = [1430.4, 1430.4, 1725, 3056.7, 437, 312, 312, 0, 0, 0, 624, 2298]

#Capactiy of generator
Cap_g = [152, 152, 350, 591, 60, 155, 155, 400, 400, 300, 310, 350] 
#Wind farm production
WF_prod = [
    7.7	15.2	4.6	47.7	24	14.2;
    6.7	13.6	5.5	54	25.9	22.5;
    7.8	17.5	7.1	67.4	32.1	26.8;
    6.4	20.1	8	66.8	35.7	30.8;
    10.2	21.8	8	82.7	36	32.3;
    13.4	19.7	7.9	80.9	36.2	31;
    14.7	23.1	7.1	80	38.2	30.7;
    14.3	24.5	7.8	85.4	39.7	32.9;
    16.3	21.7	8.6	92.7	37.7	33.3;
    17.3	15.6	8.3	89	37.4	30.1;
    16.7	13.3	7.7	93.6	40.9	29.5;
    16.2	6.7	6.4	82.3	38.6	30.6;
    15.6	4.4	6.3	76.6	35.8	29.7;
    14.7	14.9	6.9	72.5	37.4	25.7;
    14.4	17.9	6.8	71.1	37.2	19.5;
    14.9	15.7	6.6	72.7	35.7	21.8;
    13.6	17.3	6.5	73.3	34.9	19.3;
    13.1	21.8	6.7	73.7	35.7	18;
    14.7	23.5	4.9	78.3	33.2	22.1;
    14.5	24.5	6	76.8	37.1	26.2;
    14.7	24.6	6.9	73.3	40.8	27.2;
    12.6	23.6	8.2	77.5	38	25.6;
    12.5	18.4	8.2	75.8	40.1	12.8;
    13.8	22.9	8.1	64.3	39.5	6.4;]

#Maximum load of demand
Cap_d = [67.48173, 60.37839, 111.877605, 46.17171, 44.395875, 85.24008, 78.13674, 106.5501, 108.325935, 120.75678, 165.152655, 120.75678, 197.117685, 62.154225, 207.772695, 113.65344, 79.912575]

#Index sets for demands and gener
D = length(U_d)
G = length(C_g)

#Hours in a day
T = 24

#Number of wind turbines
W = 6

