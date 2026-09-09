Experimental arrangement: 
<img width="4071" height="2294" alt="Picture2" src="https://github.com/user-attachments/assets/d25d9d88-8ea5-459e-81e7-9a5bdac749a4" />

    Cell #    RecordedCells_Traces
    _____    ____________________

      6       {20002×163 double} 

Analyzing Evoked_IPSC, Ra, Ri, IHolding & sIPSC: Cell #6

Substance: Cocaine

Mouse Info: Treated group

Gender: Female

Protocol: Voltage Clamp

Mouse age: 14 weeks

Figure #1. (Top image) Raw traces & (Bottom image) regions to analyze in red (baseline, Resistant access (Ra), Resistant Input (Ri) and optogentic evoked response (IPSC).

<img width="1762" height="821" alt="Figure1" src="https://github.com/user-attachments/assets/7f211165-a08b-41a2-8155-2c99e341b8ea" />

Figure #2. Single trace for visualization purposes. 

<img width="1750" height="821" alt="Figure2" src="https://github.com/user-attachments/assets/05dbd247-1010-46de-92a2-aa00ef1a00f1" />

Figure #3. Results. (Top left) Shows holding current over the wash-in solutions. Solid circles represent individual sweeps of 20 seconds duration. 
(Bottom Left) Represents optogenetic-evoked responses (IPSC, solid circles) and resistance access (Ra, open circles) over wash-in solutions. 
(Top right) Normalized IPSC over the last 5 minutes of calcium-free solution (used as baseline) through the last drug. Every solid circle is the average of every 3 IPSC sweeps. (Bottom right) Sample figure showing IPSCs over different wash-in solutions.   

<img width="1740" height="811" alt="Figure3" src="https://github.com/user-attachments/assets/192da9fc-1692-427a-a650-a3ce74ce85b9" />

Results sheet from MATLAB script:

    ACSFCaFree(last 5 min)    CTAP (drug 1)    Gabazine (Drug 2)
    ______________________    _____________    _________________

           84    98             99    142         146    160    

              Wash-in            IPSC (Normalized), Ra (MOhms), Ri (MOhms), Holding I (mV)
    _________________________    _________________________________________________________

    {'Baseline 01 (Control)'}           0.92365       25.12      202.55     -77.653       
    {'Baseline 02'          }           0.96053      24.651      186.99     -77.929       
    {'Baseline 03'          }            1.0281      24.744       159.7     -76.609       
    {'Baseline 04'          }            1.0187      23.478      188.84     -77.168       
    {'Baseline 05'          }             1.069        24.5      179.22     -77.392       
    {'CTAP 01 (Drug 1)'     }            1.1243      25.192      188.42     -78.125       
    {'CTAP 02'              }           0.47942      25.256      184.82     -73.381       
    {'CTAP 03'              }           0.45963       25.26      186.57     -74.709       
    {'CTAP 04'              }           0.36616      25.627      195.22     -76.283       
    {'CTAP 05'              }           0.48214          25       184.6     -76.715       
    {'CTAP 06'              }           0.44005      24.171      179.02     -74.952       
    {'CTAP 07'              }           0.38386      24.586      185.61     -75.559       
    {'CTAP 08'              }           0.67481      26.003      182.94     -75.015       
    {'CTAP 09'              }           0.65722      24.223      201.75     -78.742       
    {'CTAP 10'              }           0.65124      24.873      179.67     -76.222       
    {'CTAP 11'              }           0.62257      25.159      169.43     -78.349       
    {'CTAP 12'              }           0.69688       24.13      169.26     -78.737       
    {'CTAP 13'              }           0.75665      23.156      175.49     -82.485       
    {'CTAP 14'              }           0.80783      23.206      137.87     -83.278       
    {'GZ 01 (Drug 2)'       }           0.04505      21.542      250.23     -62.422       
    {'GZ 02'                }           0.04061      23.007      232.78     -67.058       
    {'GZ 03'                }          0.042411      22.625      240.66     -70.163       
    {'GZ 04'                }          0.046471      22.071      232.11     -73.224       
    {'GZ 05'                }          0.048677       21.94      211.21     -78.823       

Analyzing criteria if Ra is >20% MOhms or <-20% MOhms:

    Ra_Criteria%   Ri_Criteria%   I_Holding_Criteria%
    ___________    ___________    __________________

      5.7634         46.916            -6.7543      

            wash-in         A_TableResults4_GraphPad
    ____________________    ________________________

                                      IPSC          
                                    ________        
                                                    
    {'Baseline_5min'                1        
    {'Drug#1_10min~15min'}          0.61448        
    {'Drug#1_Last_2min'}            0.78224        
    {'Drug#2_5min_10min'}           0.04269        
    {'Drug#2_Last_2min'}            0.047574        

Finished analysis
elapsed time is: 6.930058 seconds.
