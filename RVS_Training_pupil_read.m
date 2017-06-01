% Reading pupil data
% 29.05.2017
% Step1. 
clear all 
close all

cd('M:\pc\Dokumenter\MATLAB\Programs\For_RVS\Pupil_data_prestimulus_0_300ms');
datap=xlsread('stimulus_locked_baselines_trials_sessions.xls');
% datap double 29598 x 3

Sessions={'Training1', 'Training2'};

% Get the subject numbers from first column of datap
Subject_numbers=unique(datap(:,1));

% 
Raw_Path='Y:\Prosjekt\RVS_43_subjects\Raw_datasets\DataRVS\';
Analyzed_path='Y:\Prosjekt\RVS_43_subjects\Analyzed_datasets\';

cd(Raw_Path)
% Define list of folders 
listing_raw=dir('RVS_Subject*');
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
 end
clear kk 
% 

%DataPupil_all=[];
for kk=2:length(Subject_numbers)
    Subject_number=Subject_numbers(kk);
    Subject_filename_char=['RVS_Subject' num2str(Subject_number)]
    display(['Working for subject number ' num2str(Subject_number)])

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
        triggers_from_session_data=Session_data(:,3);
        
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
                    if ismember(triggers_from_session_data(mmm), temp_trials)==1
                        temp_trials_pupil=[temp_trials_pupil triggers_from_session_data(mmm)];
                        end
                end
                clear mmm
                DataPupil_all.(Subject_filename_char).(Session).(trial_type_char)=Session_data(temp_trials_pupil,:,:,:);
                
                % get the mean and put it on another structure
                temp_pupil_only=Session_data(:,4)
                % HERE
                temp_datap=temp_pupil_only(temp_trials_pupil)
                pupil_only=temp_datap(:,4);
                mean_pupil=mean(pupil_only);
                DataPupil_all_mean.(Subject_filename_char).(Session).(trial_type_char)=mean_pupil;
                clear temp_datap pupil_only mean_pupil temp_trials_pupil;
            end
            clear trial_type_temp trial_type_char temp_trials temp_trials_pupil
        end
        clear kkj
    end
    clear jj Session_data
end
clear kk

