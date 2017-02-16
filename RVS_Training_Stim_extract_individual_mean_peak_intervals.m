

excel_filename='List_of_peaks_TrainingStim.xlsx'
excel_sheet='List_Subjects_full_Training'

%% P1
% P1 Train 1
xlrange='I4:I45'
[ peak_P1_1 interval_P1_1 textsP1_1 rawP1_1] = read_excel_peak_values( excel_filename, excel_sheet, xlrange);


% P1 Train2
xlrange='Q4:Q45'
[ peak_P1_2 interval_P1_2 textsP1_2 rawP1_2] = read_excel_peak_values( excel_filename, excel_sheet, xlrange);
