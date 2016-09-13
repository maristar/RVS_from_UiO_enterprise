function [ Tnew ] = write_peak_component_to_txt( header_raw, startfolder, correct_folders, temp22,  ...
    selected_channels, Sessions, trigger_temp, Peak_results, chanlocs, name_component )
%Writes the components to a txt file easy to be imported to excel.
%   This function gets the Peak_results for a component and makes a cell T
%   in which it puts the results, following the order set in header.
%   Usually it is Subject Num, Condition 1, Condition 2, or etc. 
%   
%   Input arguments
%   header_raw={'Subject_Num','_Base_double_report','_Test_double_report'};
%   startfolder=1;
%   correct_folders=[startfolder 2:6 8 10:12 14 15 18 21:23 25:29 31:33];
%   selected_channels=[14, 18, 15, 6, 23, 10, 8, 25, 9];
%% Write to a cell, to be a table and then exported to file - to be opened with comma delimiter in excel
% Header sent by Thomas
%header={'Subject_Num','CPz_Correct_a','CPz_Correct_b', 'CPz_Correct_c',	'CPz_Correct_d', 'CPz_Incorrect_a',	'CPz_Incorrect_b',	'CPz_Incorrect_c',	'CPz_Incorrect_d','CPz_HR_a', 'CPz_HR_b','CPz_HR_c','CPz_HR_d',	'CPz_LR_a',	'CPz_LR_b',	'CPz_LR_c',	'CPz_LR_d'};
for cc=[selected_channels]
    chanlocs_temp=chanlocs(cc).labels;   
    chanlocs_temp_char=char(chanlocs_temp);   
    %% Make new header
    for hh=2:length(header_raw);
        temp=header_raw{1, hh};
        temp_new=[chanlocs_temp temp];
        header_new{1,1}=header_raw{1,1};
        header_new{1,hh}=temp_new;
    end
    T(1, :)=header_new;
    
    for jjk=[correct_folders]
     % For every subject - folder
        Folder_name=temp22{jjk,:};
        T(jjk+1,1)={Folder_name(5:end)};
        column_counter=0;
        for kk=1:length(Sessions) % For every condition : Correct,Wrong, HR, LR
            session_temp=Sessions(kk);
            session_temp_char=char(session_temp); 
            column_counter=column_counter+1;
            %trigger_temp='double_both_corr';
            trigger_temp_char=char(trigger_temp);
               temp_peak_results=Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp);
               T(jjk+1,1+column_counter)=num2cell(temp_peak_results);
        end % End for sessions 
    end % End for every subject
    %% Save the cell into a table and then export to txt, which can be imported in 
    % excel as a comma delimiter
    Tnew=cell2table(T, 'VariableNames', header_new);
    filename_to_save=[chanlocs_temp '_' name_component '_results.txt'];
    writetable(Tnew, filename_to_save);
end % End for chanlocs


end

