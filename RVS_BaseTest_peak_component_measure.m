function [ Peak_results, Tnew ] = RVS_BaseTest_peak_component_measure(peak_start_time, peak_end_time, ...
    time_start, type, selected_channels, startfolder, correct_folders, temp22, Sessions, trigger_temp, name_component )
% NOT WORKING

%This function extracts the peak amplitude for all subjects, sessions in
% Base - Test.
%   Input arguments
% peak_start_time: number, in msecs time to start looking for the peak
%         for example: peak_start_time=270;
% peak_end_time: number, in msecs, time to end looking for the peak, 
%         for ex. peak_end_time=300;
% time_start: number, time that the trial starts, 
%         for ex. time_start=-200;
% type: string, can take the values 'min' or 'max'
% selected_channels: an array of integers indicating the channels to extract peaks for.
%                     for example: selected_channels=[14, 18, 15, 6, 23, 10, 8, 25, 9];
% startfolder=1, an integer, indicating the folder/subject index from which to start the analysis
% correct_folders: an array that contains the folders/subjects to be included in the analysis
%         for ex.  correct_folders=[startfolder 2:6 8:12 14 15 18 21:29 31:33];
% name_component: a string, indicating the name of the component to be checked, for ex. 
%       name_component='N1';
% Output arguments
% Peak_results: a structure that contains the results for each subject and session and trigger type. 
%         The structure is formed like this:
%         Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)

%% Search for the N2  
% Define time limits for the peak detection 

for jjk=[correct_folders]  % For every subject - folder
   Folder_name=temp22{jjk,:};
   Folder_name_char=char(Folder_name);
   for kk=1:length(Sessions) % For every condition : Wrong, Correct,HR, LR
       session_temp=Sessions(kk);
       session_temp_char=char(session_temp);        
       %trigger_temp='double_both_corr';
       trigger_temp_char=char(trigger_temp);                
       dataAllchannels=Mean_Subjects_BT_DR.(Folder_name).(session_temp_char).(trigger_temp);
       if length(dataAllchannels)>0
            for cc=[selected_channels];
                chanlocs_temp=chanlocs(cc).labels;
                chanlocs_temp_char=char(chanlocs_temp);
                temp_chan=dataAllchannels(cc,:);
                %Here
                [ final_peak_measure ] = RVS_Training_find_peak_measure(temp_chan, peak_start_time, peak_end_time,time_start, Fs, timeVec_msec, type);
                Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)=final_peak_measure;
                clear temp_chan chanlocs_temp
            end % For channels
       end % if data not empty
   end % For all sessions
end % For all subjects 
cd(Analyzed_path)
cd ('Mean_All_Subjects')
save Peak_results_N2 Peak_results

%% Write components to a txt file 
header_raw={'Subject_Num','_Base_double_report','_Test_double_report'};

[ Tnew ] = write_peak_component_to_txt( header_row, startfolder, correct_folders, ...
    selected_channels, Sessions, trigger_temp, Peak_results, chanlocs, name_component )
end

