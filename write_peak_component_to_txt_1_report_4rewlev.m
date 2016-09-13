function [ Tnew ] = write_peak_component_to_txt_1_report_4rewlev(header_raw, startfolder, correct_folders, temp22,  ...
    selected_channels, Sessions, Peak_results, chanlocs, name_component, temp23)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
% %% Write to a cell, to be a table and then exported to file - to be opened with comma delimiter in excel
% % Header sent by Thomas
% %header={'Subject_Num','CPz_Correct_a','CPz_Correct_b', 'CPz_Correct_c',	'CPz_Correct_d', 'CPz_Incorrect_a',	'CPz_Incorrect_b',	'CPz_Incorrect_c',	'CPz_Incorrect_d','CPz_HR_a', 'CPz_HR_b','CPz_HR_c','CPz_HR_d',	'CPz_LR_a',	'CPz_LR_b',	'CPz_LR_c',	'CPz_LR_d'};
%header_raw={'Subject_Num','_Base_20L','_Base_50H','_Base_50L','_Base_80H','_Test_20L','_Test_50H','_Test_50L','_Test_80H'};

temp23_new={temp23{1,:}, temp23{3,:}, temp23{2,:}, temp23{4,:}}; % startfolder=1;
% correct_folders=[startfolder 2:6 8 10:12 14 15 18 21:23 25:29 31:33];
% selected_channels=[14, 18, 15, 6, 23, 10, 8, 25, 9];
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
            
            for hh=1:length(temp23_new)
                trigger_temp=temp23_new{1,hh}(1:end-4);
                trigger_temp_char=char(trigger_temp);
                column_counter=column_counter+1;
                disp(column_counter)
                temp_peak_results=Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp);
                T(jjk+1,1+column_counter)=num2cell(temp_peak_results);
            end% triggers
        end % End for sessions 
    end % End for every subject

    %% Save the cell into a table and then export to txt, which can be imported in 
    % excel as a comma delimiter
    Tnew=cell2table(T, 'VariableNames', header_new);
    filename_to_save=[chanlocs_temp '_' name_component '_results.txt'];
    writetable(Tnew, filename_to_save);
end % End for chanlocs


end

