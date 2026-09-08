%% Electropysiology & Optogenetics Analysis (Voltage clamp)
% Project: Nucleus Accumbens Core D2 Medium Spiny Neurons
% VC Analysis: IPSC amplitude
% Cocktails: ACSF Calcium Free (Baseline), CTAP (Drug 1), Gabazine (Drug 2);  
% Updated 9.8.2026 Isaac Guillen 

tic;
clear;clc;

% 1. Loading previous saved data 
load(fullfile('Ephys/MatrixData2.mat'));
load(fullfile('Ephys/TableData3.mat'));


% Select Cells to analyze. See examples:

% Store Results (Example: store the table in a cell array)
RecordedCells_Traces= (allDataMatrix);
Cells= linspace(1, size(RecordedCells_Traces,1), size(RecordedCells_Traces,1))';
t= table(Cells,RecordedCells_Traces);
disp(t);
allSpecificData= cell(length(allDataMatrix),2);

N=length(RecordedCells_Traces); % return number of recorded cells (every Sheet from excelfile)

%% Select cells to analyze (example: 1 , 1:N, or [2 5 6])

Select_exp_number= 6; 


%% 2.Initialize a cell array to store results if needed

for f= Select_exp_number % Select sheets number to analyze or write 2:N to do a full analysis 
    CurrentFile= RecordedCells_Traces{f};

% Import data from excel file into matlab
  disp(['Analyzing Evoked_IPSC, Ra, Ri, IHolding & sIPSC: ', 'Cell #',num2str(Cells(f))]);

% Import data from excel file into matlab
CellData = allDataMatrix{f};             % Imports data from selected excel file & spreadsheet in array(matrix) format
CellData2 = allDataTable{f};             % Imports data from selected excel file & spreadsheet in table format

%% 3. Mouse information: Genotype, Substance, Gender & Age
Substance= CellData(1,1);                       % Saline or Cocaine
GenoType= cell2mat(table2array(CellData2(2,1)));% Return mouse genotype:'1= Drd1a-Cre or 2= D1Morf
Age= CellData(3,1);                             % Return mouse age (in weeks)
Protocol= cell2mat(table2array(CellData2(4,1)));
Gender= cell2mat(table2array(CellData2(5,1)));

if Substance == 1
    substance=('Saline');
    disp(['Substance: ',substance]);
    disp(['Genotype: ',GenoType]);
    disp(['Gender: ',Gender]);
    disp(['Protocol: ',Protocol]);
    disp(['Mouse age: ',num2str(Age),' weeks']);
    TitleColor= 'k';
elseif Substance == 2
    substance=('Cocaine');
    disp(['Substance: ',substance]);
    disp(['Genotype: ',GenoType]);
    disp(['Gender: ',Gender]);
    disp(['Protocol: ',Protocol]);
    disp(['Mouse age: ',num2str(Age),' weeks']);
    TitleColor= 'r';
end
%disp(CellData2(6:15,1));          % Display mouse & experiment info

%% 4. Assigning variables to the data  

% Full pA traces & OptoGenetic stimulation 
Stim= CellData(2:end,2);        % Full OptoStim trace
x= CellData(2:end,3);           % Time in ms
y= CellData(2:end,4:end);       % Full current traces

% Selecting Sweeps for ACSF, ACSFCaFree, CTAP & Gabazine
ACSF= CellData(16,1):CellData(17,1)+6;        
ACSFCaFree= CellData(18,1)+6:CellData(19,1)+6;   
CTAP= CellData(20,1)+6:CellData(21,1)+6;       
Gabazine= CellData(22,1)+9:CellData(23,1);    

% Placement of cursors to analyze regions (time in ms)
Cursor1= 0;   Cursor2= 90;      % Baseline 
Cursor3= 330; Cursor4= 337;     % Region #1 (Ra)
Cursor5= 400; Cursor6= 510;     % Region #2 (Ri)
Cursor7= 937; Cursor8= 976;     % Region #3 (Evoke Response) #937 & 976

Cursors= table([Cursor1, Cursor2], [Cursor3, Cursor4],...
    [Cursor5,Cursor6],[Cursor7,Cursor8],'VariableNames',...
    {'Cursor 1 & 2','Cursor 3 & 4','Cursor 5 & 6','Cursor 7 & 8'});
% disp(Cursors)

% Optogenetic stimulation duration (ms)
OptoStimDur= [932.6 936.6];    % 4ms duration

% Baseline (control) selection from time values. Five minutes= 15 sweeps
% Example: 56 is the 1st bsln trace and 70 is the last bsln trace.
% Code reads: Sweeps: 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70;
bsln_5Min= 14;  % Last baseline sweep is 70-14= 56;    

% Formula to adjust current: d= detrend(signal, n); n>2 removes complex, highly curved trends
% These functions allow for modeling complex, smooth, and non-linear data. 

Polyn= 7; % if number is higher than 2 is consider higher order polynomial. 

% Filtering signal (Lowpass). Same as clamp-fit does it.
Fs= 10000;    % Sampling frequency in hertz (Hz)
fpass= 1000;  % Passband freq of the filter in hertz -3dB cutoff range (Hz)
[y2, df]= lowpass(y,fpass,Fs); % Filtering n of traces; df= digital filter properties info

% Selecting minutes bin to show in final table of the Normalized IPSC evoke response
Bsln_Bin= 5;
CTAP_Bin= 'end';
Gz_Bin= 7;

%% 5. Filtering traces & Searching regions for analysis
%  Find baseline, Ra, Ri & OptoStim Response (pA units)

% Logical index using time
ind_Baseline= x>=Cursor1 & x<=Cursor2;   % Logical index of time (using ms) in baseline
ind_Ra= x>=Cursor3 & x<=Cursor4;         % Logical index of time (using ms) in Ra 
ind_Ri= x>=Cursor5 & x<=Cursor6;         % Logical index of time (using ms) in Ri
ind_OptoResp=  x>Cursor7 & x<=Cursor8;   % Logical index of time (using ms) in OptoStim response

% Finding time values of Baseline, Ra, Ri and OptoStim of selected segment
x2 = x(ind_Baseline);              % Indexing time (in ms)for selected traces below
x3 = x(ind_Ra);                    % Indexing time (in ms)for selected traces below
x4 = x(ind_Ri);                    % Indexing time (in ms)for selected traces below
x5 = x(ind_OptoResp);              % Indexing time (in ms)for selected traces below

% Finding current values from baseline, Ra, Ri & OptoStim Response of selected segment
BaselineData = y2(ind_Baseline,1:end);   % Indexing all pA values for Baseline
Ra_Data = y2(ind_Ra,1:end);              % Indexing all pA values for Ra
Ri_Data = y2(ind_Ri,1:end);              % Indexing all pA values for Ri
Response_Data = y2(ind_OptoResp,1:end);  % Indexing all pA for OptoStim response



%% 6. Figure #1. Filtering traces
Gray= [0.5 0.5 0.5];        % color

f1= figure('Visible', 'on');
ax1= subplot(2,1,1);
xline(936.2,'b-',{'OptoStim: 4ms'},'LabelOrientation','horizontal');
hold on
plot(x,y2,'Color',Gray,'LineStyle',':');
ylabel('pA');
formatSpec = 'Sweeps %d to %d.';
A1 = ACSF(1,1);
A2 = Gabazine(:,end);
str = sprintf(formatSpec,A1,A2);
lgd= legend('OptoStim',str,'Location','southeast','box','off');
title(lgd,RecordedCells_Traces(f));
title( GenoType,'Voltage Clamp: Synaptic Response');
box off;

ax2= subplot(2,1,2);
xline(936.2,'b-',{'OptoStim: 4ms'},'LabelOrientation','horizontal');
hold on;
plot(x,y2,'Color', Gray','LineStyle',':');
hold on;
plot(x2,BaselineData,'r','linewidth',1);
hold on;
plot(x3,Ra_Data,'r','linewidth',1);
hold on;
plot(x4,Ri_Data,'r','linewidth',1);hold on;
hold on;
plot(x5,Response_Data,'r','linewidth',1);
ylabel('pA');
xlabel('Time (ms)');
lgd= legend('OptoStim',str,'Location','southeast','box','off');
title(lgd,RecordedCells_Traces(f));
title('Regions to analyze in red: Baseline, Ra, Ri & IPSC response');
box off;

linkaxes([ax1, ax2], 'y');

f2= figure('Visible', 'on');
% (filtering traces verification: 1 single trace for visualization purposes) 
Trace= ACSF(end);     % Select single trace for visualization purposes

plot(x,y2(:,Trace),'k','Linewidth',2);
xr = xregion(920, 936.6,FaceColor=[0.3010 0.7450 0.9330]);
ylim padded;
xlabel('Time (ms)');
ylabel('pA');
str1= sprintf('Sweep #%.0f  ',Trace);
lgd= legend(str1,'OptoStim','Location','northeast','box','off');
title(lgd, RecordedCells_Traces(f));
box off;
title( GenoType, 'Voltage Clamp: D2-MSN Synaptic Response');

%% 7. Statistics: baseline, Ra, Ri and Opto Response (IPSC)

% BASELINE
Avg_Baseline_Ihold= mean(BaselineData)';            % Mean of the baseline (pA)
Median_Baseline_Ihold=  median(Avg_Baseline_Ihold(ACSFCaFree(end)-bsln_5Min:Gabazine(end))); % Median of the Avg_Baseline_Ihold (pA)
STD_Baseline_Ihold= std(Avg_Baseline_Ihold(ACSFCaFree(end)-bsln_5Min:Gabazine(end)));         % std of the Avg_Baseline_Ihold (pA)

% RESISTANCE ACCESS (Ra)
% Peak Amplitude: This is the distance from the baseline to the highest (or lowest) point in a search region.
% Formula: Amplitude= |Peak Value - Baseline Value|
Ra_Baseline= (Ra_Data(1,:)');               % Ra baseline (pA) 
Ra_Peak= min(Ra_Data)';                     % Ra Peak (pA)
Ra_PeakAmplitude= (Ra_Peak)-(Ra_Baseline);  % Ra Peak amplitude (pA)
% Ra (Ohms Law: V=IR) Solve for R= mV/pA
Ra= ((-0.005)./(Ra_PeakAmplitude))*(1000000);  % ExcelFormula: says =IF(PeakAmp<0, 1000000*(-0.005)/(PeakAmp),"") 

% RESISTANCE INPUT (Ri)
% Ri mean (pA)
Ri_Mean= (mean(Ri_Data)')-(Avg_Baseline_Ihold);             
% Ri (Ohms Lab: V=IR) Solve for R= mV/pA
Ri= ((-0.005)./ (Ri_Mean))*(1000000);          % ExcelFormula: says =IF(PeakAmp<0, 1000000*(-0.005)/(PeakAmp),"")      

% OPTO GENETIC RESPONSE (IPSC)
% OptoStim Response #1
Resp_Peak= min(Response_Data)';      % Find min value OptoStim resposnse (peak PA)
Resp_PeakAmplitude= (Resp_Peak)-(Avg_Baseline_Ihold);

%% 8. Normalizing Ra & IPSC response peaks to baseline (Average 5 minutes of baseline)
Bsln_AVERAGE_Ra= mean(Ra_PeakAmplitude(ACSFCaFree(end)-bsln_5Min:ACSFCaFree(end)));     % Ra
Bsln_AVERAGE_Resp= mean(Resp_PeakAmplitude(ACSFCaFree(end)-bsln_5Min:ACSFCaFree(end)),'omitnan'); % IPSC (Evoked response)

Normalized_Ra= (Ra_PeakAmplitude)/(Bsln_AVERAGE_Ra);
Normalized_IPSC= (Resp_PeakAmplitude)/(Bsln_AVERAGE_Resp);

A_TableResults1_ExcelSheet= table(Normalized_Ra,Normalized_IPSC); % Ra and IPSC normalized to baseline(5 minutes duration)

% Formula to exclude >1.2 and <0.8 traces relative to the baseline Ra.
Traces= linspace(1,numel(Normalized_Ra),numel(Normalized_Ra))';

[row1, cols1]= find(Normalized_Ra > 1.2);     % finding values >1.2
[row2, cols2]= find(Normalized_Ra < 0.8);     % finding values <0.8
Sweeps= vertcat(row1 ,row2);

Condition_Ra= Normalized_Ra(Sweeps);
Condition_IPSC= Normalized_IPSC(Sweeps);

%Table format for verification purposes 
A_Table_Condition_Ra_IPSC= table(Traces, Normalized_Ra,Normalized_IPSC);
A_Table_Condition_Ra_IPSC(Sweeps,2:3) = {NaN}; % Substitute values (traces) with NaN in table format

% Matrix format for analyses purposes (Matlab works w/matrices to operate)
Normalized_Ra(Sweeps) = NaN;                  
Normalized_IPSC(Sweeps) = NaN;                

%% 9. Results
A_TableResults2_ExcelSheet= table(Ra_PeakAmplitude, Resp_PeakAmplitude, Ri_Mean,Ri,...
    Avg_Baseline_Ihold,Ra_PeakAmplitude,Ra);  % Should be very similar to excel spreadsheet results

% Indexing 1st trace of bsln to last trace of bsln (Example: 56 to 70 of ACSFCaFree w/strontium)
Bsln= [Ra_PeakAmplitude, Resp_PeakAmplitude, Normalized_IPSC, Ri, Avg_Baseline_Ihold, Ra];                                                           

Bsln_Range= Bsln(ACSFCaFree(end)-bsln_5Min:ACSFCaFree(end),[3 6 4 5]); % ACSFCaFree (last 5 minutes)
CTAP_Range= Bsln(CTAP(1):CTAP(end),[3 6 4 5]);                          % CTAP
GZ_Range= Bsln(Gabazine(1):Gabazine(end),[3 6 4 5]);                    % Gabazine

Selected_Traces= table([ACSFCaFree(end)-bsln_5Min, ACSFCaFree(end)], [CTAP(1), CTAP(end)],...
    [Gabazine(1),Gabazine(end)],'VariableNames', {'ACSFCaFree(last 5 min)', 'CTAP (drug 1)','Gabazine (Drug 2)'});
disp(Selected_Traces)

%% Matrix will be use to do average every 3 rows (evoke IPSC data) starting from baseline to Gabazine

Matrices= {Bsln_Range, CTAP_Range, GZ_Range};  
Result_Tables= cell(1,numel(Matrices));     % Creating table to add results from new matrices

for k = 1:numel(Matrices)
    current_Matrix= Matrices{k};
    
    % Finding average of every 3 rows for IPSC, Ra, Ri and Holding
    r  = 3;
    n  = size(current_Matrix, 1);             % Length of first dimension
    nc = n - mod(n, r);                       % Multiple of p
    np = nc / r;                              % Length of result
    rs = reshape(current_Matrix(1:nc, :), r, np, []); % [p x np x size(x,2)]
    Avg_3rows  = sum(rs, 1,'omitnan')/r;              % Mean over 1st dim
    Avg_3rows  = reshape(Avg_3rows, np, []);  % Remove leading dim of length 1

    Avg_3rows_data= [Avg_3rows];
    new_Matrices= Avg_3rows_data;

    Avg_3rows_results{k} = new_Matrices;
    
    if k== 1
        name= 'ACSF-CaFree (Last 5 min)';
    elseif k==2
        name= 'CTAP (Drug 1)';
    elseif k==3
        name= 'Gabazine (Drug 2)';
    end
    
    disp(name)
    disp(Avg_3rows);
end

% Avg 3 rows of Normalize IPSC, Ra, Ri, Holding
Bsln_avg3rows= Avg_3rows_results{1,1};     % Bsln last 5 minutes
CTAP_avg3rows= Avg_3rows_results{1,2};     % CTAP total time 
GZ_avg3rows= Avg_3rows_results{1,3};       % GZ total time

C= [Bsln_avg3rows; CTAP_avg3rows; GZ_avg3rows];

%% FIGURE #2 Baseline verification through all traces (pA vs traces)
f3= figure('Visible', 'on');
subplot(2,2,1);
plot(Avg_Baseline_Ihold,'-ko','LineWidth',1,...
    'MarkerSize',8,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor',[0.5,0.5,0.5]);
ylim([Median_Baseline_Ihold-250 100]);
xticks([ACSF(1)-.5 ACSFCaFree(1)-.5 CTAP(1)-.5 Gabazine(1)-.5]);
xticklabels({'ACSF','ACSF-CaFree','Drug 1','Drug 2'});
yline(0,'--k','linewidth',1);
ylabel('pA');
% xlabel('Traces');

hold on;
n1= numel(Avg_Baseline_Ihold(ACSFCaFree(end)-bsln_5Min:Gabazine(end)));
V=zeros(n1,1) + Median_Baseline_Ihold;
plot(ACSFCaFree(end)-bsln_5Min:Gabazine(end),V,'-r','LineWidth',2);
str = sprintf(formatSpec,ACSF(1),A2);
apstr= sprintf('median: %.1f pA',Median_Baseline_Ihold);
lgd= legend(str,'',apstr,'Location','northeast','fontsize',14,'box','off');
title(lgd,RecordedCells_Traces(f));
title('Baseline (pA): Imemb')
grid on;
box off;

subplot(2,2,3);
plot(Resp_PeakAmplitude,'-ko','LineWidth',1,...
    'MarkerSize',8,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor',[0.5,0.5,0.5]);
hold on;
plot(Ra_PeakAmplitude,'-ko','LineWidth',1,...
    'MarkerSize',8,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','w');
ylim padded;
xticks([ACSF(1)-.5 ACSFCaFree(1)-.5 CTAP(1)-.5 Gabazine(1)-.5]);
xticklabels({'ACSF','ACSF-CaFree','Drug 1','Drug 2'});
yline(0,'--k','linewidth',1);
ylabel('pA');
xlabel('Traces');
grid on;
box off;
legend('IPSC amplitude','Ra amplitude','Location','best','fontsize',14,'box','off');

sgt= sgtitle(['D2-MSN',' / ','Mouse: ', Gender, ' / ',num2str(14),' weeks',' / ', substance]);
sgt.Color = TitleColor;

%% figuring how many minutes of recording for each cocktail

% for BSLN:
if size(Bsln_avg3rows,1) >= 5          % Aiming for the last 5 min recording             
    N_Bsln= Bsln_Bin;
elseif size(Bsln_avg3rows,1) < 10
    N_Bsln= size(Bsln_avg3rows,1);
end

% for CTAP
if size(CTAP_avg3rows,1) >= 10          % Aiming between 10 to N min recording             
    N_CTAP= size(CTAP_avg3rows,1);
elseif size(CTAP_avg3rows,1) < 10
    N_CTAP= size(CTAP_avg3rows,1);
end

% for Gabazine
if size(GZ_avg3rows,1) >= 7             % Aiming for at least 7 min recording
    N_GZ= Gz_Bin;
elseif size(GZ_avg3rows,1) < 7
    N_GZ= size(GZ_avg3rows,1);
end

% Average
Bsln_5min= mean(Bsln_avg3rows(1:5,1),'omitnan');     
CTAP_10min_15min= mean(tail(CTAP_avg3rows(:,1),N_CTAP),'omitnan');
CTAP_2min= mean(tail(CTAP_avg3rows(:,1),2),'omitnan');

GZ_5min= flipud(GZ_avg3rows);       
GZ_5min= mean(GZ_5min(3:N_GZ,1),'omitnan');

GZ_2min= mean(tail(GZ_avg3rows(:,1),2),'omitnan');  

% Analyzing if Ra is >20% MOhms or <-20% MOhms
Ra_Criteria= ((Bsln_avg3rows(1,2))/(CTAP_avg3rows(end,2))*100)-100;
Ri_Criteria= ((Bsln_avg3rows(1,3))/(CTAP_avg3rows(end,3))*100)-100;
I_Holding_Criteria= ((Bsln_avg3rows(1,4))/(CTAP_avg3rows(end,4))*100)-100;

% RESULTS
% Normalized data, set to baseline range and averaged into 1 minute time bins
Wash1= {'Baseline 01 (Control)';'Baseline 02';'Baseline 03';'Baseline 04';'Baseline 05'};
Wash2= {'CTAP 01 (Drug 1)';'CTAP 02';'CTAP 03';'CTAP 04';'CTAP 05';'CTAP 06';...
    'CTAP 07';'CTAP 08';'CTAP 09';'CTAP 10';'CTAP 11';'CTAP 12';'CTAP 13';'CTAP 14'...
    ;'CTAP 15';'CTAP 16';'CTAP 17';'CTAP 18'};
Wash3= {'GZ 01 (Drug 2)';'GZ 02';'GZ 03';'GZ 04';'GZ 05';'GZ 06';'GZ 07'};

wash= {'Baseline_5min';'CTAP_10min~15min';'CTAP_2min';'GZ_5min~10min';'GZ_2min'};

% Final table with Avg_3rows data:
% (Bsln= 5min, CTAP= last 10min, GZ= last 7)

%Concatenating Bsln, CTAP & GZ tables
varNames = {'Wash','IPSC (Normalized), Ra (MOhms), Ri (MOhms), Holding I (mV)'};
Table1= table(Wash1(1:N_Bsln),tail(Bsln_avg3rows,N_Bsln),'VariableNames',varNames);
Table2= table(Wash2(1:N_CTAP),tail(CTAP_avg3rows,N_CTAP),'VariableNames',varNames);
Table3= table(Wash3(1:N_GZ), tail(GZ_avg3rows,N_GZ),'VariableNames',varNames);

A_TableResults3_Command=[Table1; Table2; Table3];
rowsToReplace = A_TableResults3_Command{:,varNames(:,2)} == 0;
A_TableResults3_Command{:,varNames(:,2)}(rowsToReplace) = NaN;

A_TableResults3_GraphPad= array2table([A_TableResults3_Command{:,varNames(:,2)}],...
    'VariableNames',{'IPSC (Normalized)', 'Ra (MOhms)', 'Ri (MOhms)', 'Holding I (mV)'});


A_TableResults4_GraphPad= array2table([Bsln_5min,CTAP_10min_15min,CTAP_2min,GZ_5min,GZ_2min]'...
    ,'VariableNames',{'IPSC'}); % IPSC
rowsToReplace1 = A_TableResults4_GraphPad.IPSC == 0;
A_TableResults4_GraphPad.IPSC(rowsToReplace1) = NaN;

Table4= table(wash,A_TableResults4_GraphPad);
Table5_Criteria= table(Ra_Criteria,Ri_Criteria,I_Holding_Criteria);

disp(A_TableResults3_Command);
disp(Table5_Criteria);
disp(Table4);

%% Sample figures
num_x1= 6000;
num_x2= 14000;

Reg= ACSF(end-12);
bs= ACSFCaFree(end-19);
CT= CTAP(end-11);
GBz= Gabazine(end);
xxx= x(num_x1:num_x2,1);
Line= 0.5;

Reg_centered = y2(num_x1:num_x2,Reg) - mean(y2(num_x1:num_x2,Reg));
bsln_centered = y2(num_x1:num_x2,bs) - mean(y2(num_x1:num_x2,bs));
CTAP_centered = y2(num_x1:num_x2,CT) - mean(y2(num_x1:num_x2,CT));
GB_centered = y2(num_x1:num_x2,GBz) - mean(y2(num_x1:num_x2,GBz));

figure(f3);
subplot(2,2,4)
plot(xxx,Reg_centered,'k','LineWidth',Line)
hold on;
plot(xxx,bsln_centered,'b','LineWidth',Line); 
hold on;
plot(xxx,CTAP_centered,'Color',Gray,'LineWidth',Line);
hold on;
plot(xxx,GB_centered,'r','LineWidth',Line);
xr = xregion(920, 936.6,FaceColor=[0.3010 0.7450 0.9330]);
ylim padded;
xlim padded;
xlabel('Time (ms)');
ylabel('pA');
lgd= legend ('ACSF','ACSF CaFree','Drug 1','Drug 2','Opto Stim','Location','Best','fontsize',12,'box','off');
title(lgd, RecordedCells_Traces(f));
box off;

subplot(2,2,2)
plot(C(:,1),'-ko','LineWidth',1,...
    'MarkerSize',10,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor',[0.5,0.5,0.5]);
xline(size(Bsln_avg3rows,1)+.5,'--k','linewidth',1);         % Bsln end point
xline(size(CTAP_avg3rows,1)+size(Bsln_avg3rows,1)+.5,'--k','linewidth',1);        % CTAP end point
ylim padded;
ylabel('Normalized IPSC');
xlabel('Time (min)');
xticks([0 size(Bsln_avg3rows,1)+.5 size(CTAP_avg3rows,1)+size(Bsln_avg3rows,1)+.5]);
xticklabels({'CaFree(last-5min)','Drug 1','Drug 2'});
lgd= legend('Normalized IPSC','Location','northeast','fontsize',14,'box','off');
title(lgd,RecordedCells_Traces(f));
box off;

% Store specific data (example: Response Peak Amplitude) 
allSpecificData{f}= Resp_PeakAmplitude; % Store specific data (as needed)
% allDataMatrix{f}= CellData;                  % Data from Time & all raw sweeps (a must)
% allDataTable{f}= CellData2;                  % Data from mouse info and cocktail sweeps (a must) 

end

%%
disp('Finished analysis'), toc;

