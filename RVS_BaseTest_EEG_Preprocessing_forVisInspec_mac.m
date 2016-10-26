% Makes the 4-5 preprocesing steps automatically.
clear all 
close all 
tic
%% Path information
% Raw_Path='/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/RVS/'; 
% %'/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/'%RVS_Subject104/Base/';
% %'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/'; 
% Analyzed_path='/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/Analyzed_datasets/RVS/';
% %'/Volumes/EEG2_MARIA/EEG/RVS/Analyzed_datasets_B_T/';
% %'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/Analyzed_datasets/';
Raw_Path='Z:\RVS\RAW_datasets\DataRVS\';
Analyzed_path='Z:\RVS\Analyzed_datasets\';

cd(Raw_Path)
% Define list of folders 
listing_raw=dir('RVS_Subject210*');
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
end
clear kk listing_raw
%% Instruction: The folder name should be the same and as defined above
 % Lets start the mega loop
for kk=1%1:Num_folders
    Folder_name=temp22{kk,:};
    Analyzed_path_folder=[Analyzed_path temp22{kk,:} '\'];
    Raw_path_folder=[Raw_Path temp22{kk,:} '\' temp22{kk,:} '\'];
    cd(Raw_path_folder); % Go into the Raw but out of the Base/Test folder
    sessions={'Base','Test'};
    for kkj=1%1%:length(sessions)
        current_session=sessions{kkj};
        Raw_path_folder_session=[Raw_path_folder current_session '\'];
        
        Analyzed_path_folder_session=[Analyzed_path_folder current_session '\'];
        Name_Subject_session=[Folder_name(5:end) '_' sessions{kkj}];
        %% Find the bdf files inside the Raw_path_folder_session
        
        cd(Raw_path_folder_session);
        % Find the EEG recording, look for the *bdf files 
        listing_rawbdf=dir('*.bdf');
        
        Num_filesbdf=length(listing_rawbdf);
        if Num_filesbdf>1
            display('Warning, 2 data bdfs found')
        elseif Num_filesbdf==0
            display('No EEG *.bdf file found')
        end

        %% Load the raw dataset 
        [ALLEEG EEG CURRENTSET ALLCOM]=eeglab;
        %EEG= pop_biosig(); % '/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/MariaLoizou/Maria1.bdf', 'ref',[65 66] ,'refoptions',{'keepref' 'off'});
        % 'ref',[65 66] ,'refoptions',{'keepref' 'off'});
        Raw_path_folder_data=[Raw_path_folder_session listing_rawbdf(1).name];
        EEG= pop_biosig(Raw_path_folder_data, 'ref',[65 66] ,'refoptions',{'keepref' 'off'});
        EEG.setname=Name_Subject_session;
        eeglab redraw
        EEG = eeg_checkset( EEG );

%         %% Detect noisy channels
%         hfigure=pop_eegplot( EEG, 1, 1, 1);
%         f=warndlg('Scroll the data and select the noisy channels. Close this window only when you are done to continue', 'A warning dialog');
%         disp('This prints immediately');
%         drawnow
%         waitfor(f);
%         disp('This prints when you finished closing the window');

%% Select channels
        EEG = pop_select( EEG,'nochannel',{'EXG5' 'EXG6' 'EXG7' 'EXG8'});
        %EEG = pop_select( EEG,'channel',{'C1' 'CP3' 'PO7' 'Oz' 'O1' 'O2' 'POz' 'Pz' 'CPz' 'Fpz' 'AFz' 'Fz' 'FCz' 'Cz' 'C2' 'CP4' 'PO8' 'F3' 'F4' 'FC4' 'FC3' 'C5' 'C6' 'P4' 'P5'});
        EEG = eeg_checkset( EEG );
        eeglab redraw
        
 %% TODO to run the DC offset filter -i run it after


        
        %% Apply DC filter 
        % Check the sampling frequency
        Fs=EEG.srate;
        %  Run the DCoffset_removal_21_10_2011_a_final.m made as function
        input_data=EEG.data;
        data_filt=DC_offset_removal(input_data,Fs);
        EEG.data=data_filt;
        clear input_data;
        % EEG.setname=[temp_setname_resample '_DC']
        eeglab redraw
        
        %% Resample
        fs_new=1024;
        EEG = pop_resample( EEG, fs_new);
        temp_setname_resample=[Name_Subject_session '_' num2str(fs_new)];
        EEG.setname=temp_setname_resample;
        EEG = eeg_checkset( EEG );
        eeglab redraw
%         % TODO - Add filtering 0.1 - 100 Hz
%         data_filt_smoot=eegfilt(EEG.data, fs_new, 1, 1);
%         EEG.data=data_filt_smooth;
        %% Added  filtering as in the training 17.8.2016
%                  %% Apply low pass filter
%         data=data_filt;
%         clear data_filt
%         filter_from=0.01;
%         filter_to=20;
%         lowpass_filt=eegfiltfft(data, fs_new, filter_from, filter_to);
%         EEG.data=lowpass_filt;
%         clear input_data filter_from filter_to
%         EEG.setname=[temp_setname_resample '_ch_DC']
%         eeglab redraw
        
        %%  Epoch
        temp_epochname=[Name_Subject_session '_' num2str(fs_new)  '_1024nofilt_epochs_tr2' ];
        % TODO check if it accepts the temp_epochname below
        EEG = pop_epoch( EEG, {  '2'  }, [-0.3 0.7], 'newname', temp_epochname, 'epochinfo', 'yes');
        EEG = eeg_checkset( EEG ); % epoching was [-0.3 0.7]
        EEG = pop_rmbase( EEG, [-300 0]);% [-500 -400]
        EEG.setname=temp_epochname;
        eeglab redraw
        
%          Make a directory and save
%         cd(Analyzed_path)
%         mkdir(temp22{kk,1})
%         cd(temp22{kk,1})
%         % Make a directory for each session -Training1 or Training2
%         mkdir(current_session)
%         cd(current_session)
        EEG = pop_saveset( EEG, 'filename',temp_epochname,'filepath', Analyzed_path_folder_session);
    end
end
toc
