% Reading pupil data
% 29.05.2017
% Fixing it 08.06.2017
% Step1. 
clear all 
close all

% % 1. Run with baseline as from 0 to 300 with 0 the stimulus presentation
% cd('M:\pc\Dokumenter\MATLAB\Programs\For_RVS\Pupil_data_prestimulus_0_300ms');
% datap=xlsread('stimulus_locked_baselines_trials_sessions.xls');
% datap double 29598 x 4
% 
% % 2. Run with baseline as from -200 to 0 with 0 the stimulus presentation
% cd('M:\pc\Dokumenter\MATLAB\Programs\For_RVS\Pupil_data_prestimulus_0_minus200');
% filename = 'stimulus_baselines_negative_200.xlsx';
% sheet = 1;
% xlRange = 'A1:D58591';
% datap = xlsread(filename,sheet,xlRange);

% 3. For feedback stimuli 
cd('M:\pc\Dokumenter\MATLAB\Programs\For_RVS\feedback_baselines_negative200');
filename = 'feedback_.baselines_negative200.xlsx';
sheet = 1;
xlRange = 'A1:D58591';
datap = xlsread(filename,sheet,xlRange);

Raw_Path='Y:\Prosjekt\RVS_43_subjects\Raw_datasets\DataRVS\';
Analyzed_path='Y:\Prosjekt\RVS_43_subjects\Analyzed_datasets\';

% Make directory to save results. 
% 1 Save_path_folder='RVS_Training_Pupil_Baseline_poststimulus0_300\';
Save_path_folder='RVS_Training_Pupil_Baseline_feedback_pre200_0\';


Sessions={'Training1', 'Training2'};

% Get the subject numbers from first column of datap
Subject_numbers=unique(datap(:,1));



cd(Raw_Path)
% Define list of folders 
listing_raw=dir('RVS_Subject*');
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
 end
clear kk 
% 

bad_subject_list=[108 118 122] % it is 8 , 118 and 122 but it starts from 102
good_subj_list=[];
for kk=1:length(Subject_numbers), 
    temp_subject=Subject_numbers(kk);
    
    if ~ismember(temp_subject, bad_subject_list), 
        good_subj_list=[good_subj_list temp_subject]; 
    end; 
end
clear kk 

    
%DataPupil_all=[];
for kk=1:length(good_subj_list)
    jk=good_subj_list(kk);
    Subject_number=jk;
    % k alla leei edw 
    Subject_filename_char=['RVS_Subject' num2str(jk)];
    display(['Working for subject number ' num2str(jk)])

    % Find indices of data of subject 
     ind_subject_temp=find(datap(:,1)==Subject_number);
     Subject_data=datap(ind_subject_temp, :,:,:);
        
    for jj=1:length(Sessions)
        jjk=Sessions(jj);
        Session=char(jjk);
        display(['Working for subject number ' num2str(Subject_number) '. For Session ' Session])
        ind_session=find(Subject_data(:,2)==jj);
        ind_session=ind_session'; % gia Training2 xekinaei apo to 801
        Session_data=Subject_data(ind_session,:,:,:);
        % Get the triggers data from this column (3) because some are
        % missing (no data of pupillometry)
        triggers_from_session_data=Session_data(:,3);
        
        % Load the triggers from the e-prime file. 
        Analyzed_path_folder=[Analyzed_path Subject_filename_char '\' Session '\'];
        cd(Analyzed_path_folder)
        cd Triggers
        %% Find triggers
        listing_raw=dir('triggers*txt'); % This is for FRN, first we run for this
        % listing_raw=dir('stim*.txt'); % This is for STIM
        Num_files=length(listing_raw);
        for kkm=1:Num_files
             temp23{kkm,:}=listing_raw(kkm).name;
        end
        clear kkm
        %% End finding triggers
        %% Loop to extract each type of trigger's single trials
        
        for kkj=1:length(temp23);
            % Load the triggers
            trial_type_temp=temp23{kkj};
            trial_type_char=char(trial_type_temp(1:end-4));
            temp_trials=load(trial_type_temp);
            if ~isempty(temp_trials)
                % Check - combine temp_trials and
                % triggers_from_session_data (some triggers from pupil
                % might be missing)
                temp_trials_pupil=[];
                for mmm=1:length(triggers_from_session_data)
                    if ismember(triggers_from_session_data(mmm), temp_trials)==1 % temp_trials, triggers_from_session_data end to 800
                        temp_trials_pupil=[temp_trials_pupil triggers_from_session_data(mmm)];
                    end
                end
                clear mmm test
                % test=Session_data(temp_trials_pupil',:,:,:); % index exceeds matrix dimensions \ok
                
                % the above does not work in some cases. so 
                data_pupil=[];
                for jjk=1:length(temp_trials_pupil)
                    temp_index=temp_trials_pupil(jjk);
                    index_in_Sessiondata=find(Session_data(:,3)==temp_index);
                    data_pupil=[Session_data(index_in_Sessiondata,4) data_pupil];
                
                end
                
                test_dataPupil=data_pupil;
                
                % Get the mean of it and store it in a structure. 
                mean_test_dataPupil=mean(test_dataPupil);
            
                DataPupil_all.(Subject_filename_char).(Session).(trial_type_char)=test_dataPupil; 
              DataPupil_all_mean.(Subject_filename_char).(Session).(trial_type_char)=mean_test_dataPupil; %mean_pupil;
                clear test_dataPupil data_pupil mean_test_dataPupil 
            end % if is empty temp_trials
            clear trial_type_temp trial_type_char temp_trials temp_trials_pupil
        end % for every temp23 trigger type
        clear Session_data
    end % for every session 
    
end % for every subject 
clear kk

% Save the structures with the results 
cd(Analyzed_path)
mkdir(Save_path_folder)
cd(Save_path_folder)
save DataPupil_all_mean DataPupil_all_mean
save DataPupil_all DataPupil_all 
data_Properties.bad_subject_list=bad_subject_list;
data_Properties.good_subj_list=good_subj_list;
data_Properties.Raw_path=Raw_Path;
data_Properties.Analyzed_Path=Analyzed_path;
data_Properties.datap=datap;

save data_Properties data_Properties


% Make the excel to go into statistics. 


% 1 catch


% General header based on conditions - it works now! magic maria 
conditions=temp23';
part_names_all=[];
for jj=1:length(conditions)
    conditions_short{jj}=conditions{jj}(10:end-4);
end
clear jj
% Conditions short = ['Correct'    'HR'    'LR'    'Wrong']

conditions=temp23';
part_names_all=[];
for jj=1:length(conditions)
    conditions{jj}=conditions{jj}(1:end-4);
end
clear jj
% conditions =  'triggers_Correct'    'triggers_HR'    'triggers_LR'    'triggers_Wrong'

% Do the header
header_raw_exp=['Subject_Num_'];
for kk=1:length(conditions)
    temp_condition=conditions_short(kk);
    temp_condition_char=char(temp_condition);
    if length(part_names_all)==0
        header_raw_exp=[header_raw_exp  temp_condition ]
    elseif length(part_names_all)>0
        for jj=1:length(part_names_all)
            temp_parts=part_names_all(jj);
            temp_parts_char=char(temp_parts);
            middle_temp_name=cellstr([temp_condition_char '_' temp_parts_char]);
            header_raw_exp=[header_raw_exp middle_temp_name ]
        end
    end
end
clear kk jj
data_Properties.header_raw=header_raw_exp; 
header_raw=header_raw_exp;


% 2 catch %% New 21.04.2019 Measure also FRN from base-to-peak from P2
% Search for the FRN : 220-350 msec. 



      
    %% Make new header
%     for hh=2:length(header_raw);
%         temp=header_raw{1, hh};
%         temp_new=[chanlocs_temp temp];
%         header_new{1,1}=header_raw{1,1};
%         header_new{1,hh}=temp_new;
%     end
    T(1, :)=header_raw; % Keep
    for mkk=1:(length(good_subj_list)) % Keep
        jjk=good_subj_list(mkk);% For every subject - folder % Keep
        Subject_number=jjk;
         % k alla leei edw 
        Subject_filename_char=['RVS_Subject' num2str(jjk)];
        display(['Working for subject number ' num2str(jjk)])
        
        
        T(mkk+1,1)={Subject_filename_char};
        column_counter=0;
        for kk=1:length(conditions) % For every condition : Correct,Wrong, HR, LR
            temp_condition=conditions(kk);
            temp_condition_char=char(temp_condition);  
            % Average Training 1 AND Training 2
            for gg=1% :length(Sessions)
                Session_temp=Sessions(gg);
                Session_temp_char=char(Session_temp);
               temp_result1=DataPupil_all_mean.(Subject_filename_char).(Session_temp_char).(temp_condition_char);
               
               Session_temp2=Sessions(gg+1);
               Session_temp2_char=char(Session_temp2);
               temp_result2=DataPupil_all_mean.(Subject_filename_char).(Session_temp2_char).(temp_condition_char);
              
               temp_result=(temp_result1+temp_result2)/2;
               
               column_counter=column_counter+1;
               disp(column_counter)
%                part_name_temp=part_names_all{gg};
%                part_name_temp_char=char(part_name_temp); 
               
               T(mkk+1,1+column_counter)=num2cell(temp_result);
           end% End for sessions (can be cut)
        end % End for conditions
    end % End for every subject in good_subj_list
    %% Save the cell into a table and then export to txt, which can be imported in 
    % excel as a comma delimiter
   % Create the variables names
   %% Make new header for the table Variables names
    for hh=2:length(header_raw);
        temp=header_raw{1, hh};
        temp_new=[temp];
        header_new{1,1}=header_raw{1,1};
        header_new{1,hh}=temp_new;
    end
    
    Tnew=cell2table(T, 'VariableNames', header_new);
    filename_to_save_txt=['BaselinePupil_results.txt'];
    filename_to_save_xls=['BaselinePupil_results.xls'];
    writetable(Tnew, filename_to_save_txt);
    writetable(Tnew, filename_to_save_xls);
    clear T header_new Tnew
% End for chanlocs
