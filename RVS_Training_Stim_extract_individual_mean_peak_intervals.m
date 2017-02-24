% This program extracts the individual peak values for each component, in 
% the two training sessions from the excel file that contains them. 
% It reads the excel file, the range that each peak has its peak value in,
% and gives an interval around this peak with [peak-25 peak+25]. This
% interval is for each Training session, so for P1 component we have 
%  - interval_P1_1 for Training 1
%  - interval_P1_2 for Training 2
% and a general one:
%  interval_P1
% this general one is when we do calculations for the recordings united and
% not separated in days, or 4 blocks. 


% 20 February 2017. 
% MLS

% Be in the directory of the excel file. 
excel_filename='List_of_peaks_TrainingStim.xlsx'
excel_sheet='List_Subjects_full_Training'

%% P1
% P1 Training 1
xlrange='I4:I45';
[ peak_P1_tr1 interval_P1_1] = read_excel_peak_values( excel_filename, excel_sheet, xlrange);
clear xlrange

% P1 Train2
xlrange='Q4:Q45';
[ peak_P1_tr2 interval_P1_2] = read_excel_peak_values( excel_filename, excel_sheet, xlrange);
clear xlrange
% This general interval is useful when we use no parts. 
interval_P1=[(interval_P1_1+interval_P1_2)/2];
%% P2
% P2 Training 1
xlrange='K4:K45';
[ peak_P2_tr1 interval_P2_1] = read_excel_peak_values( excel_filename, excel_sheet, xlrange);
clear xlrange

% P2 Train2
xlrange='S4:S45';
[ peak_P2_tr2 interval_P2_2] = read_excel_peak_values( excel_filename, excel_sheet, xlrange);
clear xlrange
interval_P2=[(interval_P2_1+interval_P2_2)/2];
%% P3a
% P3a Training 1
xlrange='M4:M45';
[ peak_P3a_tr1 interval_P3a_1 ] = read_excel_peak_values( excel_filename, excel_sheet, xlrange);
clear xlrange

% P3a Train2
xlrange='U4:U45';
[ peak_P3a_tr2 interval_P3a_2 ] = read_excel_peak_values( excel_filename, excel_sheet, xlrange);
clear xlrange
interval_P3a=[(interval_P3a_1+interval_P3a_2)/2];

%% P3b
% P3b Training 1
xlrange='O4:O45';
[ peak_P3b_tr1 interval_P3b_1 ] = read_excel_peak_values( excel_filename, excel_sheet, xlrange);
clear xlrange

% P3b Train2
xlrange='W4:W45';
[ peak_P3b_tr2 interval_P3b_2 ] = read_excel_peak_values( excel_filename, excel_sheet, xlrange);
clear xlrange
interval_P3b=[(interval_P3b_1+interval_P3b_2)/2];
%% N1
% N1 Training 1
xlrange='J4:J45';
[ peak_N1_tr1 interval_N1_1 ] = read_excel_peak_values( excel_filename, excel_sheet, xlrange);
clear xlrange

%N1 Train2
xlrange='R4:R45';
[ peak_N1_tr2 interval_N1_2 ] = read_excel_peak_values( excel_filename, excel_sheet, xlrange);
clear xlrange

interval_N1=[(interval_N1_1+interval_N1_2)/2];
%% N2
% N2 Training 1
xlrange='L4:L45';
[ peak_N2_tr1 interval_N2_1 ] = read_excel_peak_values( excel_filename, excel_sheet, xlrange);
clear xlrange

% P3a Train2
xlrange='T4:T45';
[ peak_N2_tr2 interval_N2_2 ] = read_excel_peak_values( excel_filename, excel_sheet, xlrange);
clear xlrange

interval_N2=[(interval_N2_1 +interval_N2_2)/2];
%% N3
%  Training 1
xlrange='N4:N45';
[ peak_N3_tr1 interval_N3_1] = read_excel_peak_values( excel_filename, excel_sheet, xlrange);
clear xlrange

% P3a Training 2
xlrange='V4:V45';
[ peak_N3_tr2 interval_N3_2 ] = read_excel_peak_values( excel_filename, excel_sheet, xlrange);
clear xlrange

interval_N3=[(interval_N3_1+interval_N3_2)/2];