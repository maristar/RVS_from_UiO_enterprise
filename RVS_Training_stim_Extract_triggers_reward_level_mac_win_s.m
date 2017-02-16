% Analyzing EEG dataset for RVS - Base - Test data. 
% 30 November 2015, Maria L. Stavrinou at PSI, UiO
% 14 January 2016, MLS
% 17 June 2016 making a loop for all subjects. Including only a subset of
% triggers. Final results.
% 28.10. for Stimulus-training analysis IT cannot be run until the noisy
% triggers are written down. 
% Updated, checked 17.11.2016

clear all 
close all 
tic
%% Path information
% Raw_Path='Z:\RVS\RAW_datasets\DataRVS\';
% Analyzed_path='Z:\RVS\Analyzed_datasets\';
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
%% Make a document to write the number of triggers in each condition
cd(Analyzed_path)
fid=fopen('RVS_Training_stim_4rewlevs_counts_of_triggers.txt', 'wt');
fprintf(fid, '%s\t%s\n', 'Name of trigger ',' Number of trials');
% 02.01.2017, unfinished it doesnt fill that with anything. 
%% Start the mega loop for analysis 

% Define sessions
Sessions={'Training1', 'Training2'};

%% Define which subjects to keep in the analysis 
bad_subject_list=[1, 4, 8, 18, 22, 26, 30]; % ch 02.01.2017
good_subj_list=[]; for kk=1:Num_folders, if ~ismember(kk, bad_subject_list), good_subj_list=[good_subj_list kk]; end; end

%% Start load
startfolder=15;

for mkk=startfolder:length(good_subj_list)
    jjk=good_subj_list(mkk);
    Folder_name=temp22{jjk,:};
    fprintf(' ***  Working on subject %s: %s\n', num2str(mkk), Folder_name)
    
    Raw_path_folder=[Raw_Path temp22{jjk,:} '\'];
    cd(Raw_path_folder);
    for jj=1:length(Sessions)
        session_temp=Sessions{jj};
        cd(Raw_Path);
        % We have to move two times inside the folder with the same name to
        % find the EEG data.
        cd(temp22{jjk,:});
        cd(temp22{jjk,:});
        %mkdir(session_temp); %%???
        cd(session_temp);%%% ????
        Analyzed_path_folder=[Analyzed_path temp22{jjk,:} '\'  session_temp '\'];
        Raw_path_folder=[Raw_Path temp22{jjk,:} '\' temp22{jjk,:} '\' session_temp '\'];
        
        % Go to Raw_path_folder
        cd(Raw_path_folder);
        if jjk>3
            % Load the exported edat2 file (later named Tfinal).
            listing_raw2=dir('*matlab.txt');
            if length(listing_raw2)==0
                listing_raw2=dir('*MATLAB.txt');
            end
            if length(listing_raw2)==0
                display('No txt file for matlab found');
            end
            Edat2file=listing_raw2(1).name;
            Filename_matlab=Edat2file;

            %     [FileName, Raw_Path] = uigetfile('*.*','Select the MATLAB T table (Tfinal) file "txt", or "mat" ');
            %     cd(Raw_Path)
            T = readtable((Filename_matlab), ...
            'Delimiter','\t','ReadVariableNames',false);
            clear Filename_matlab
        elseif jjk<4
            load('Tnew.mat')
        end
        
        
        % Define where to find the relevant information. 
                %% Automate start
        % Find which row in the T table is Condition, and the StimTwoACC.
        % Find it iteratively:
        all_headers=T(1,:);
        all_headers2=table2cell(all_headers);
        clear all_headers
        
%         %% New automatic start
%         all_headers=T(1,:);
%         all_headers2=table2cell(all_headers);
%         clear all_headers
%         Mask_CRESP=eprime_to_matlab( T, all_headers2, 'Stim.OnsetDelay');
%         Mask1_RESP=eprime_to_matlab( T, all_headers2, 'Mask.RESP');
%         Mask2_RESP=eprime_to_matlab( T, all_headers2,'Mask2.RESP');
%         RewPair=eprime_to_matlab( T, all_headers2,'RewPair');
%         [T1RewConting] = eprime_to_matlab( T, all_headers2, 'T1RewConting');
%         [T2RewConting]=eprime_to_matlab(T, all_headers2, 'T2RewConting');
%         [TotalAcc]=eprime_to_matlab(T, all_headers2, 'TotACC');
        %% New automatic end
        
        % Find for the Feedback Onset delay
        for jjj=1:length(all_headers2)
            a=strcmp(all_headers2{1,jjj}, 'Stim.OnsetDelay');
            if a==1
                indexFeedbackDelay=jjj;
            end
        end
        clear a jjj % OK

        Feedback_OnsetDelay_table=T(2:end, indexFeedbackDelay); % 131 for JackLoe, tested first!
        FeedbackDelay=table2cell(Feedback_OnsetDelay_table);
        % TODO clear Feedback_OnsetDelay_table
        
        %% Find for the Stim.ACC
        for jjj=1:length(all_headers2)
            a=strcmp(all_headers2{1,jjj}, 'Stim.ACC');
            if a==1
                indexStimACC=jjj;
            end
        end
         clear a jjj 
        
        StimACC_table=T(2:end, indexStimACC); % 131 for JackLoe, tested first!
        StimAcc=table2cell(StimACC_table);
        clear indexStimACC
        
        %% Find for the RewardMap
        for jjj=1:length(all_headers2)
            a=strcmp(all_headers2{1,jjj}, 'RewardMap');
            if a==1
                indexRewMap=jjj;
            end
        end
         clear a jjj 
        
        indexRewMap_table=T(2:end, indexRewMap); % 131 for JackLoe, tested first!
        RewardMap=table2cell(indexRewMap_table);
        %clear indexRewMap
        
       
        %% Calculate the total number of triggers we have 
        Num_triggers=size(RewardMap); 
        Num_triggers=Num_triggers(1);
      
        %% Stim-Training
         % Find accuracy of target. 
         % Go through the indexes of single accuracy and check them for 1 correct.
         % Corrected 17.11.2016
         stim_correct=zeros(1, Num_triggers);
         stim_wrong=zeros(1, Num_triggers);
             for kkt=1:Num_triggers, 
                 temp_index=kkt;
                 if strcmp(StimAcc(kkt,1), '1')==1
                     stim_correct(kkt)=temp_index;
                 elseif strcmp(StimAcc(kkt,1), '0')==1
                     stim_wrong(kkt)=temp_index;
                 end;
             end
            clear kkt temp_index
            % Find only non zeros
            stim_corr_indexes=stim_correct(stim_correct>0);
            stim_wrong_indexes=stim_wrong(stim_wrong>0);
           
           %% Definitions of the 4 reward levels.         
           stim_80H=zeros(1,length(stim_corr_indexes));
           stim_50H=zeros(1,length(stim_corr_indexes));
           stim_50L=zeros(1,length(stim_corr_indexes));
           stim_20L=zeros(1,length(stim_corr_indexes));
                       
          % Geting the triggers
           for kkm=1:length(stim_corr_indexes),
               temp_index=stim_corr_indexes(kkm);
               temp_RewardMap=RewardMap{temp_index,1};
               switch temp_RewardMap
                   case '80Hh'
                       stim_80H(kkm)=temp_index;
                   case '50Hh'
                       stim_50H(kkm)=temp_index;
                   case '50Lh'
                        stim_50L(kkm)=temp_index;
                   case '20Lh'
                        stim_20L(kkm)=temp_index;
               end
               clear temp_RewardMap
           end
           clear kkm

        % Keep the non zero elemennts 
        stim_80H_corr=stim_80H(stim_80H>0);
        stim_50H_corr=stim_50H(stim_50H>0);
        stim_50L_corr=stim_50L(stim_50L>0);
        stim_20L_corr=stim_20L(stim_20L>0);
  

        %% Make a directory to save all the relevant triggers
        %RAW_path=['/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets' '/RVS_' (Dataset_name) '/' ]
        cd(Analyzed_path_folder) 
        mkdir('Triggers')
        cd Triggers
        %create_triggers_in_txt(name, index_trigger_X_final)
        create_triggers_in_txt('stim_80H_corr', stim_80H_corr)
        create_triggers_in_txt('stim_50H_corr', stim_50H_corr)
        create_triggers_in_txt('stim_50L_corr', stim_50L_corr)
        create_triggers_in_txt('stim_20L_corr', stim_20L_corr)
        disp([Folder_name  ' . Triggers created']);
        %% TODO compare and remove the NOISY epochs

        %% Select the noisy and unite them with wrong_index 
        cd(Analyzed_path_folder);
        % Find the txt with 'Subject'
        list_txt=dir('Subject*Stim*txt'); % 31.10.2016 - TODO HERE TO HAVE DONE THE NOISY TRIGGERS and TO NAME THEM Subject101_Training_stim.txt
        Noisy_temp=list_txt.name;
        Noisy=load(Noisy_temp);
        %% End select the Noisy 

        cd('Triggers')
        listing = dir('stim_*0*_corr.txt'); % this creates a structure with all the names of the triggers
        for jj=1:length(listing)
            temp_name=listing(jj).name;
            temp_triggers=load(temp_name);
            new_temp_triggers=remove_noisy_triggers(Noisy, temp_triggers);
            create_triggers_in_txt(temp_name(1:end-4), new_temp_triggers);
        end
clear T temp_index temp_name temp_triggers 
    end % For sessions 
    clear T
end % For folders

fclose(fid);
toc