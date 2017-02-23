function [ Peak_results, Tnew] = peak_detection_all_individ( name_component, type, peak_start_time, peak_end_time, time_start, time_end, Mean_Subjects, data_Properties )
%Peak detection function with individual peaks and limits
%   Peak detection
% Input arguments: 
%   - name_component='N2';
%   - type= 'base_peak' (only for FRN); 
%     'min', 
%     'max',
%     'mean', 
%     'base_peak_general', new option for negative deflection waves. 
%   - peak_start_time=250; In milliseconds, when it is individual peak then
%       put this as zero. 
%   - peak_end_time=300;
%    The time start and time_end refer to the time the epoch starts. 
%   - time_start=new_pre_trigger; %was -200 % MLS 08.09.2+16 changed % In msec -there is abs(time_start) in the function so the minus is disgarted
%   - time_end=new_post_trigger; %600; % TODO sth here why it is deleted 
%   - data_Properties is a structure giving all the necessary parameters.
% Output arguments
%   -  Peak_results
%   -  Tnew

%% Start by getting the parameters out from the data_Properties structure. 
good_subj_list=data_Properties.good_subj_list;
temp22=data_Properties.temp22;
conditions=data_Properties.conditions;
part_names_all=data_Properties.part_names_all;
numchans=data_Properties.numchans;
chanlocs=data_Properties.chanlocs;
Fs=data_Properties.Fs;
timeVec_msec=data_Properties.timeVec_msec;

% Load the component's general interval around its individuaL peak. It is
% saved inside the data_Properties. 
% New addition, as in 20.02.2017
name_interval=['interval_' name_component];
interval_temp=data_Properties.(name_interval);

%% Start the loop
for mkk=1:(length(good_subj_list)) % For every subject ( in good_subj_list)
    jjk=good_subj_list(mkk);
    Folder_name=temp22{jjk,:}; 
                           
    % Define individual limits (average of the two Training sessions)
    peak_start_time=interval_temp(jjk,1);
    peak_end_time=interval_temp(jjk,2);
   
   % For every condition
   for kk=1:length(conditions)%  : Correct,HR, LR, Wrong
       temp_condition=conditions(kk);
       temp_condition_char=char(temp_condition);   
       % For all the parts
       if length(part_names_all)>0 % Parts --
            for gg=1:length(part_names_all)
                part_name_temp=part_names_all{gg};
                part_name_temp_char=char(part_name_temp);         
                data4channels=Mean_Subjects.(Folder_name).(temp_condition_char).(part_name_temp_char);
                % Here somewhere to add to select the individual limits
                % Febr2017
                % Detect the individual limits
                % If the general limits exist, lets take the individual
                % limits for each Training session. 
                if ~isempty(interval_temp)
                    if (gg==1  ||  gg==2)
                        name_interval=['interval_' name_component '_1'];
                        interval_temp=eval(name_interval);
                        peak_start_time=interval_temp(mkk, 1);
                        peak_end_time=interval_temp(mkk,2);
                        clear name_interval interval_temp
                    elseif (gg==3 || gg==4)
                        name_interval=['interval_' name_component '_2'];
                        interval_temp=eval(name_interval);
                        peak_start_time=interval_temp(mkk, 1);
                        peak_end_time=interval_temp(mkk,2);
                        clear name_interval interval_temp
                    end
                end 
                % For all the channels
                for cc=1:length(numchans); % Channels 
                    chanlocs_temp=chanlocs(cc).labels;
                    temp_chan=data4channels(cc,:);
                    [ final_peak_measure ] = RVS_Training_find_mean_ar_peak_measure_v2(temp_chan, peak_start_time, peak_end_time, Fs, timeVec_msec, type);
                    Peak_results.(Folder_name).(temp_condition_char).(part_name_temp_char).(chanlocs_temp)=final_peak_measure;
                    clear temp_chan chanlocs_temp
                end
            end % End for gg / all parts if they are many
       elseif isempty(part_names_all);
           part_name_temp_char='allparts';
           data4channels=Mean_Subjects.(Folder_name).(temp_condition_char).(part_name_temp_char);
           % For all the channels
            for cc=1:length(numchans); 
                chanlocs_temp=chanlocs(cc).labels;
                temp_chan=data4channels(cc,:);        
                [ final_peak_measure ] = RVS_Training_find_mean_ar_peak_measure_v2(temp_chan, peak_start_time, peak_end_time, Fs, timeVec_msec, type);
                Peak_results.(Folder_name).(temp_condition_char).(part_name_temp_char).(chanlocs_temp)=final_peak_measure;
                clear temp_chan chanlocs_temp
            end
            %clear part_name_temp part_name_temp_char data4channels 
       end % For all parts if "if length(part_names_all)>0"           
   end % Conditions 
end  % Subjects

% cHECKED UP HERE 23.02.2017. ONLY THING THAT THE -25 +25 DOES NOT FALL
% SYMMETRICALLY FOR oZ, p2, 102 SUBJECT. 

Analyzed_path=data_Properties.Analyzed_path;
folder_data_save=data_Properties.folder_data_save;

% Save the results 
cd(Analyzed_path)
cd(folder_data_save)
savename_temp1=['results_' name_component];
eval(['save ' savename_temp1 ' Peak_results']);
%eval(['save ' stemp2 ' recon_array freqVec timeVec step filename1 stemp1 ndata nchan names_chan'])

chanlocs=data_Properties.chanlocs;
header_raw=data_Properties.header_raw;

clear cc hh mkk kk
for cc=1:length(chanlocs)
    chanlocs_temp=chanlocs(cc).labels;    
    %% Make new header
    for hh=2:length(header_raw);
        temp=header_raw{1, hh}; % 20L
        temp_new=[chanlocs_temp '_' temp];
        header_new{1,1}=header_raw{1,1};
        header_new{1,hh}=temp_new;
    end
    T(1, :)=header_new;
    for mkk=1:(length(good_subj_list))
        jjk=good_subj_list(mkk);% For every subject - folder
        Folder_name=temp22{jjk,:};
        T(jjk+1,1)={Folder_name(5:end)};
        column_counter=0;
        for kk=1:length(conditions) % For every condition : Correct,Wrong, HR, LR
            temp_condition=conditions(kk);
            temp_condition_char=char(temp_condition);  
            if length(part_names_all)>0
                for gg=1:length(part_names_all)
                    column_counter=column_counter+1;
                    disp(column_counter)
                    part_name_temp=part_names_all{gg};
                    part_name_temp_char=char(part_name_temp); 
                    temp_peak_results=Peak_results.(Folder_name).(temp_condition_char).(part_name_temp_char).(chanlocs_temp);
                    T(jjk+1,1+column_counter)=num2cell(temp_peak_results);
                end
            elseif isempty(part_names_all)
                part_name_temp_char='allparts';
                 column_counter=column_counter+1;
                    disp(column_counter)
                    temp_peak_results=Peak_results.(Folder_name).(temp_condition_char).(part_name_temp_char).(chanlocs_temp);
                    T(jjk+1,1+column_counter)=num2cell(temp_peak_results);
           end% End for parts
        end % End for conditions 
    end % End for every subject
    %% Save the cell into a table and then export to txt, which can be imported in 
    % excel as a comma delimiter
    Tnew=cell2table(T, 'VariableNames', header_new);
    filename_to_save_txt=[chanlocs_temp '_' type '_' name_component '_results.txt'];
    filename_to_save_xls=[chanlocs_temp '_' type '_' name_component '_results.xls'];
    writetable(Tnew, filename_to_save_txt);
    writetable(Tnew, filename_to_save_xls);
    % clear T header_new Tnew
end % End for chanlocs

end

