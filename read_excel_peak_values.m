function [ peak_values texts raw] = read_excel_peak_values( excel_filename, excel_sheet, xlrange, interval)
% Copies peak latency from excel to a matlab array 
% We have written down the peak values of each ERP component in our RVS
% project
 [peak_values, texts, raw] = xlsread(excel_filename,excel_sheet, xlrange );
 
 interval_P1_tr2=[peak_P1_Tr2-25 peak_P1_Tr2+25]

end

