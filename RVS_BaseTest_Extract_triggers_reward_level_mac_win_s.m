% Analyzing EEG dataset for RVS - Base - Test data. 
% 30 November 2015, Maria L. Stavrinou at PSI, UiO
% 14 January 2016, MLS
% 17 June 2016 making a loop for all subjects. Including only a subset of
% triggers. Final results.

clear all 
close all 
tic
%% Path information
Raw_Path='Z:\RVS\RAW_datasets\DataRVS\';
Analyzed_path='Z:\RVS\Analyzed_datasets\';


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
fid=fopen('RVS_BT_4rewlevs_counts_of_triggers.txt', 'wt');
fprintf(fid, '%s\t%s\n', 'Name of trigger ',' Number of trials');
%% Start the mega loop for analysis 

% Define sessions
Sessions={'Base', 'Test'};

% Define which subjects are good and which are bad. 
bad_subject_list=[7, 9, 13, 16, 17, 19, 20, 24, 30];
% Old correct_folders=[startfolder 2:6 8:12 14 15 18 21:29 31:33];
good_subj_list=[]; 
for kk=1:Num_folders, 
    if ~ismember(kk, bad_subject_list), 
        good_subj_list=[good_subj_list kk]; 
    end; 
end
clear kk 

%% Start load
startfolder=1;

for mkk=1:length(good_subj_list)
    jjk=good_subj_list(mkk);
    Folder_name=temp22{jjk,:};
    fprintf(' ***  Working on subject %s: %s\n', num2str(mkk), Folder_name)
    Analyzed_path_folder=[Analyzed_path temp22{jjk,:} '\'];
    Raw_path_folder=[Raw_Path temp22{jjk,:} '\'];
    cd(Raw_path_folder);
    for jj=1:length(Sessions)
        session_temp=Sessions{jj};
        cd(Raw_Path);
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
            load('T.mat')
        end

        Mask_CRESP=T(2:end, 84);
        TargetCond=T(2:end, 128); 
        TargetType=T(2:end, 129); % For ex. 'LD' Letter - Digit

        % Calculate the total number of triggers we have 
        Num_triggers=size(Mask_CRESP); 
        Num_triggers=Num_triggers(1);

        %% Find the Target Condition: 1 or 2 stimuli presented.
        % Find the double or single cases-occurances of triggers 
        % Important 1! 
        % From TargetCond
        single_index_temp=zeros(Num_triggers,1);
        double_index_temp=zeros(Num_triggers, 1);
        for kkt=1:Num_triggers
            if strcmp(TargetCond{kkt,1}, '1')==1
                single_index_temp(kkt,1)=kkt;
            elseif strcmp(TargetCond{kkt,1}, '2')==1
                double_index_temp(kkt,1)=kkt;
            end
        end
        clear kkt
        single_index=single_index_temp(single_index_temp>0); % 192 should it be
        double_index=double_index_temp(double_index_temp>0); % 448, correct! Double condition index
        % Look at Single target accuracy

         %% Find accuracies
         % Find accuracy of single target. 
         % Go through the indexes of single accuracy and check them for 1 correct.
         TotAcc=T{2:end, 130};
         single_indexes_correct=zeros(1, length(single_index));
             for kkt=1:length(single_index), 
                 temp_index=single_index(kkt);
                 if strcmp(TotAcc{temp_index,1}, '1')==1
                     single_indexes_correct(kkt)=temp_index;
                 else
                     single_indexes_wrong(kkt)=temp_index;
                 end;
             end
            clear kkt
            % Find only non zeros
            single_acc_indexes=single_indexes_correct(single_indexes_correct>0);
            single_acc_indexes_wrong=single_indexes_wrong(single_indexes_wrong>0);
           %% From double stimulus presentation 
           %select all three categories BOTH; ONE; NONE 
           % {'Detection';'NONE';'NONE';'NONE';'NONE';'NONE';'NONE';'NONE';'NONE';'NONE';'d';'NONE';'7'}
           Detection=T{2:end,49};
           double_both=zeros(1, length(double_index));
           double_none=zeros(1, length(double_index));
           double_one=zeros(1, length(double_index));
           for kkm=1:length(double_index),
               temp_index=double_index(kkm);
               temp_detection=Detection{temp_index};
               if strcmp(temp_detection, 'BOTH')
                       double_both(kkm)=temp_index;
               elseif strcmp(temp_detection, 'NONE');
                       double_none(kkm)=temp_index;
               else
                   double_one(kkm)=temp_index;
               end
           end
           clear kkm
           
           double_both_corr=double_both(double_both>0);
           Number_double_both=length(double_both_corr);
           percentage_double_both=Number_double_both*100/length(double_index);
           disp(['Detection Double percentage (%): ' num2str(percentage_double_both)]);

           double_none_corr=double_none(double_none>0);
           Number_double_none=length(double_none_corr);
           percentage_double_none=Number_double_none*100/length(double_index);
           disp(['Detection None percentage (%): ' num2str(percentage_double_none)]);

           double_one_corr=double_one(double_one>0);
           Number_double_one=length(double_one_corr);
           percentage_double_one=Number_double_one*100/length(double_index);
           disp(['Detection One percentage (%): ' num2str(percentage_double_one)]);

        %% From the Double condition, 1 detected, extract more categories
           DetRewCont=T(2:end, 51);
           
           %% Definitions           
           double_one_80H=zeros(1,length(double_one_corr));
           double_one_50H=zeros(1,length(double_one_corr));
           double_one_50L=zeros(1,length(double_one_corr));
           double_one_20L=zeros(1,length(double_one_corr));
             
%% Geting the triggers
           for kkm=1:length(double_one_corr),
               temp_index=double_one_corr(kkm);
               temp_detrewcont=DetRewCont{temp_index,1};
               switch temp_detrewcont{:}
                   case '80Hh'
                       double_one_80H(kkm)=temp_index;
                   case '50Hh'
                       double_one_50H(kkm)=temp_index;
                   case '50Lh'
                        double_one_50L(kkm)=temp_index;
                   case '20Lh'
                        double_one_20L(kkm)=temp_index;
               end
           end
           clear kkm

        % Keep the non zero elemennts 
        double_one_80H_corr=double_one_80H(double_one_80H>0);
        double_one_50H_corr=double_one_50H(double_one_50H>0);
        double_one_50L_corr=double_one_50L(double_one_50L>0);
        double_one_20L_corr=double_one_20L(double_one_20L>0);
  

           %% Make a directory to save all the relevant triggers
        %RAW_path=['/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets' '/RVS_' (Dataset_name) '/' ]
        cd(Analyzed_path_folder) 
        mkdir('Triggers')
        cd Triggers
        %create_triggers_in_txt(name, index_trigger_X_final)
        create_triggers_in_txt('double_one_80H_corr', double_one_80H_corr)
        create_triggers_in_txt('double_one_50H_corr', double_one_50H_corr)
        create_triggers_in_txt('double_one_50L_corr', double_one_50L_corr)
        create_triggers_in_txt('double_one_20L_corr', double_one_20L_corr)
        disp([Folder_name  ' Triggers created']);
        %% TODO compare and remove the NOISY epochs

        %% Select the noisy and unite them with wrong_index 
        cd(Analyzed_path_folder);
        % Find the txt with 'Subject'
        list_txt=dir('Subject*txt');
        Noisy_temp=list_txt.name;
        Noisy=load(Noisy_temp);
        %% End select the Noisy 

        cd('Triggers')
        listing = dir('double_one_*0*_corr.txt'); % this creates a structure with all the names of the triggers
        for jj=1:length(listing)
            temp_name=listing(jj).name;
            temp_triggers=load(temp_name);
            new_temp_triggers=remove_noisy_triggers(Noisy, temp_triggers);
            create_triggers_in_txt(temp_name(1:end-4), new_temp_triggers);
        end
clear T
    end % For sessions 
    clear T
end % For folders

