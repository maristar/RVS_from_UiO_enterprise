function [ peaks, interval] = read_excel_peak_values( excel_filename, excel_sheet, xlrange, interval)
% Copies peak latency from excel to a matlab array 
% We have written down the peak values of each ERP component in our RVS
% project
 [peak_values_num, texts, raw] = xlsread(excel_filename,excel_sheet, xlrange );
 clear peak_values_num texts
 % Peak_values_num does not record the first cell contents if this cell is
 % empty. It leads to some peaks having 41 values. 
 
 peaks=cell2mat(raw);
 interval=[peaks-25 peaks+25];

end
 
