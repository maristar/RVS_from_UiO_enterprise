% Analyzing EEG dataset for RVS - Base - Test data. 
% 30 November 2015, Maria L. Stavrinou at PSI, UiO
% 14 January 2016, MLS
% 17 June 2016 making a loop for all subjects. Including only a subset of
% triggers. Final results.

clear all 
close all 
tic
%% Path information
Raw_Path='/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/'%RVS_Subject104/Base/';
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/'; 
Analyzed_path='/Volumes/EEG2_MARIA/EEG/RVS/Analyzed_datasets_B_T/'
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/Analyzed_datasets/';

cd(Analyzed_path)
% Define list of folders 
listing_raw=dir('RVS_Subject*');
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
 
end

Sessions={'Base', 'Test'};

%% Start the new part 
% It has to start from number 4 and down because the 101-103 datasets have
% not TOTACC in their T table.
for kk=3%1:3
    Folder_name=temp22{kk,:};
    % Define on which subject we are working 
    % Work for each session independently 
    for jj=1:length(Sessions)
        session_temp=Sessions{jj};
        cd(Raw_Path);
        cd(temp22{kk,:});
        cd(temp22{kk,:});
        %mkdir(session_temp); %%???
        cd(session_temp);%%% ????
        Analyzed_path_folder=[Analyzed_path temp22{kk,:} '/'  session_temp '/'];
        Raw_path_folder=[Raw_Path temp22{kk,:} '/' temp22{kk,:} '/' session_temp '/'];
        
        % Go to Raw_path_folder
        cd(Raw_path_folder);
        if kk>3
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
        elseif kk<4
            load('T.mat')
        end

        %% Define if there are delays in Stim Presentation (check StimOnsetDelay
        disp(T(1, 107))
        StimOnsetDelay=T(2:end, 107);
        counter=0;
        for kkj=1:size(StimOnsetDelay,1),
            if strcmp(StimOnsetDelay{kkj,1},'0')==1 || strcmp(StimOnsetDelay{kkj,1},'1')==1
            else
                counter=counter+1;
                indexes_StimOnsetDelay_toobig(counter)=kkj;
            end
        end
        disp(['StimOnsetDelay: Found ' num2str(counter) ' delays bigger than 1']);
        clear kkj
        %% Get some values from the T table from E-prime and do the ACC
        Mask1_RESP=T(2:end, 80);
        Mask2_RESP=T(2:end, 89);
        Mask_CRESP=T(2:end, 84);
        TargetCond=T(2:end, 128); 
        TargetType=T(2:end, 129); % For ex. 'LD' Letter - Digit
        RewPair=T(2:end, 104); % For ex. 50Lh20Lh

        % Use the accuracies from the e-prime file. 
        Masc1_ACC=T(2:end, 74);
        Masc2_ACC=T(2:end, 83);

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
            %isequalX=strcmp(TargetCond{kk,1},'1');
            %if isequalX==1; 
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

            % Find only non zeros
            single_acc_indexes=single_indexes_correct(single_indexes_correct>0);

            % Find percentages
            single_acc_percentage=length(single_acc_indexes)*100/length(single_index);
            disp('Single correct percentage : ')
            disp(single_acc_percentage)

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
           % From the double condition, detect those that are in the 6 category
           % 50Hh-50Lh(RewPair,Var 104), 80-80, 20-20, 50-80, 50-20, 80-20
           % From those separate those that have detected the Hh or Lh, for ex. 
           % 50-50-50Hh or 50-50-50Lh (From DetRewCont, T(2:end, 51)).
           RewPair=T(2:end, 104);
           DetRewCont=T(2:end, 51);
           
           %% Definitions
           
           double_one_reward_level=zeros(1,length(double_one_corr));
           % Case 50-50
           % Level 1
           double_50_50=zeros(1, length(double_one_corr));

           %Level 2
           double_50L_50H=zeros(1, length(double_one_corr));
           % Level 3
           double_50L_50H_50L=zeros(1, length(double_one_corr));
           double_50L_50H_50H=zeros(1, length(double_one_corr));

        %    %Level 2 - wont use those 
        %    double_50L_50L=zeros(1, length(double_one_corr));
        %    %double_50H_50H=double_
        %    double_50H_50H=zeros(1, length(double_one_corr));

           % Case 20-20
           % Level 1 (=Level 2, Level 3)
           double_20_20=zeros(1, length(double_one_corr));

           % Case 80-80
           % Level 1 (=Level 2, Level 3)
           double_80_80=zeros(1, length(double_one_corr));

           % Case 80-20 (it will be always 80Hh, 20Lh)
           % Level 1 (& Level 2)
           double_80_20=zeros(1, length(double_one_corr));
            % Level 3
           double_80_20_80=zeros(1, length(double_one_corr));
           double_80_20_20=zeros(1, length(double_one_corr));

        %% Geting the triggers
           for kkm=1:length(double_one_corr),
               temp_index=double_one_corr(kkm);
               temp_rewpair=RewPair{temp_index,1};% '50Lh20Lh'
               temp_detrewcont=DetRewCont{temp_index,1};
               switch temp_rewpair{:}
                   case {'50Lh50Hh', '50Hh50Lh'}
                       double_50L_50H(kkm)=temp_index;
                       if strcmp(DetRewCont{temp_index,1}, '50Lh')==1
                           double_50L_50H_50L(kkm)=temp_index;
                       elseif strcmp(DetRewCont{temp_index,1}, '50Hh')==1
                            double_50L_50H_50H(kkm)=temp_index;
                       end
                   case {'80Hh20Lh', '20Lh80Hh'}
                       double_80_20(kkm)=temp_index;
                       if strcmp(DetRewCont{temp_index,1}, '80Hh')==1
                           double_80_20_80(kkm)=temp_index;
                       elseif strcmp(DetRewCont{temp_index,1}, '20Lh')==1
                           double_80_20_20(kkm)=temp_index;
                       end           
                   case '80Hh80Hh'
                   double_80_80(kkm)=temp_index;
                   case '20Lh20Lh'
                   double_20_20(kkm)=temp_index;
               end
           end
           clear kkm

%% Geting the triggers
           for kkm=1:length(double_one_corr),
               temp_index=double_one_corr(kkm);
               temp_detrewcont=DetRewCont{temp_index,1};
               switch temp_rewpair{:}
                   case {'50Lh50Hh', '50Hh50Lh'}
                       double_50L_50H(kkm)=temp_index;
                       if strcmp(DetRewCont{temp_index,1}, '50Lh')==1
                           double_50L_50H_50L(kkm)=temp_index;
                       elseif strcmp(DetRewCont{temp_index,1}, '50Hh')==1
                            double_50L_50H_50H(kkm)=temp_index;
                       end
                   case {'80Hh20Lh', '20Lh80Hh'}
                       double_80_20(kkm)=temp_index;
                       if strcmp(DetRewCont{temp_index,1}, '80Hh')==1
                           double_80_20_80(kkm)=temp_index;
                       elseif strcmp(DetRewCont{temp_index,1}, '20Lh')==1
                           double_80_20_20(kkm)=temp_index;
                       end           
                   case '80Hh80Hh'
                   double_80_80(kkm)=temp_index;
                   case '20Lh20Lh'
                   double_20_20(kkm)=temp_index;
               end
           end
           clear kkm


           % Level 1
        %    double_50_20_corr=double_50_20(double_50_20>0);
        %    double_80_50_corr=double_80_50(double_80_50>0);
           double_50_50_corr=double_50_50(double_50_50>0);
           clear double_50_50

           % Level 2 (and 1 for 80-20, 80-80, 20-20)
           double_50L_50H_corr=double_50L_50H(double_50L_50H>0);
           double_50L_50H_50L_corr=double_50L_50H_50L(double_50L_50H_50L>0);
           double_50L_50H_50H_corr=double_50L_50H_50H(double_50L_50H_50H>0);
           clear double_50L_50H double_50L_50H_50H double_50L_50H_50L

           double_80_20_corr=double_80_20(double_80_20>0);
           double_80_20_80_corr=double_80_20_80(double_80_20_80>0);
           double_80_20_20_corr=double_80_20_20(double_80_20_20>0);
           clear double_80_20 double_80_20_80 double_80_20_20

        %    double_50H_20_corr=double_50H_20(double_50H_20>0);
        %    double_50H_20_20_corr=double_50H_20_20(double_50H_20_20>0);
        %    double_50H_20_50H_corr=double_50H_20_50H(double_50H_20_50H>0);
        %    clear double_50H_20 double_50H_20_20 double_50H_20_50H
        %    
        %    double_50L_20_corr=double_50L_20(double_50L_20>0);
        %    double_50L_20_50L_corr=double_50L_20_50L(double_50L_20_50L>0);
        %    double_50L_20_20_corr=double_50L_20_20(double_50L_20_20>0);
        %    clear double_50L_20 double_50L_20_50L double_50L_20_20

           double_80_80_corr=double_80_80(double_80_80>0);
           double_20_20_corr=double_20_20(double_20_20>0);
           clear double_80_80 double_20_20
   
%    double_80_50L_corr=double_80_50L(double_80_50L>0);
%    double_80_50L_50L_corr=double_80_50L_50L(double_80_50L_50L>0);
%    double_80_50L_80_corr=double_80_50L_80(double_80_50L_80>0);
%    clear double_80_50L double_80_50L_50L double_80_50L_80
%    
%    double_80_50H_corr=double_80_50H(double_80_50H>0);
%    double_80_50H_50H_corr=double_80_50H_50H(double_80_50H_50H>0);
%    double_80_50H_80_corr=double_80_50H_80(double_80_50H_80>0);
%    clear double_80_50H double_80_50H_50H double_80_50H_80
   
%    %%% Scratch. detect hemifield 
% double_Low_hemifield=zeros(1, length(double_one_corr));
% double_High_hemifield=zeros(1, length(double_one_corr));
% 
% for kk=1:length(double_one_corr),
%        temp_index=double_one_corr(kk);
%        temp_rewpair=RewPair{temp_index,1};% '50Lh20Lh'
%        temp_detrewcont=DetRewCont{temp_index,1};
%        First_Letter=temp_rewpair{1,1}(3);
%        Second_Letter=temp_rewpair{1,1}(7);
%        Two_Letters=[First_Letter Second_Letter];
%        switch Two_Letters
%            case {'LH', 'HL'}
%                if strcmp(temp_detrewcont{1,1}(3),'L')==1
%                double_Low_hemifield(kk)=temp_index;
%                elseif strcmp(temp_detrewcont{1,1}(3),'H')==1
%                   double_High_hemifield(kk)=temp_index;
%                end
%        end
% end
% 
% double_Low_hemif_corr=double_Low_hemifield(double_Low_hemifield>0);
% clear double_Low_hemifield
% double_High_hemif_corr=double_High_hemifield(double_High_hemifield>0);
% clear double_High_hemifield
   
           %% Make a directory to save all the relevant triggers
        %RAW_path=['/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets' '/RVS_' (Dataset_name) '/' ]
        cd(Analyzed_path_folder) 
        mkdir('Triggers')
        cd Triggers



        %create_triggers_in_txt(name, index_trigger_X_final)

        create_triggers_in_txt('double_one_corr', double_one_corr)
        create_triggers_in_txt('double_both_corr', double_both_corr)
        create_triggers_in_txt('double_none_corr', double_none_corr)
        create_triggers_in_txt('single_target_1_corr', single_acc_indexes)

        create_triggers_in_txt('double_50L_50H_corr', double_50L_50H_corr);
        create_triggers_in_txt('double_50L_50H_50L_corr', double_50L_50H_50L_corr);
        create_triggers_in_txt('double_50L_50H_50H_corr', double_50L_50H_50H_corr);

        create_triggers_in_txt('double_80_20_corr', double_80_20_corr)
        create_triggers_in_txt('double_80_20_80_corr', double_80_20_80_corr)
        create_triggers_in_txt('double_80_20_20_corr', double_80_20_20_corr)

        % create_triggers_in_txt('double_50H_20_corr', double_50H_20_corr)
        % create_triggers_in_txt('double_50H_20_50H_corr', double_50H_20_50H_corr)
        % create_triggers_in_txt('double_50H_20_20_corr', double_50H_20_20_corr)
        % 
        % create_triggers_in_txt('double_50L_20_corr', double_50L_20_corr)
        % create_triggers_in_txt('double_50L_20_50L_corr', double_50L_20_50L_corr)
        % create_triggers_in_txt('double_50L_20_20_corr', double_50L_20_20_corr)

        create_triggers_in_txt('double_80_80_corr', double_80_80_corr)
        create_triggers_in_txt('double_20_20_corr', double_20_20_corr)

        % create_triggers_in_txt('double_80_50L_corr', double_80_50L_corr)
        % create_triggers_in_txt('double_80_50L_50L_corr', double_80_50L_50L_corr)
        % create_triggers_in_txt('double_80_50L_80_corr', double_80_50L_80_corr)
        % 
        % create_triggers_in_txt('double_80_50H_corr', double_80_50H_corr)
        % create_triggers_in_txt('double_80_50H_50H_corr', double_80_50H_50H_corr)
        % create_triggers_in_txt('double_80_50H_80_corr', double_80_50H_80_corr);

        % create_triggers_in_txt('double_Low_hemif_corr', double_Low_hemif_corr);
        % create_triggers_in_txt('double_High_hemif_corr', double_High_hemif_corr);

            %% TODO compare and remove the NOISY epochs

        %% Select the noisy and unite them with wrong_index 
        cd(Analyzed_path_folder);
        % Find the txt with 'Subject'
        list_txt=dir('Subject*txt');
        Noisy_temp=list_txt.name;
        Noisy=load(Noisy_temp);
        %% End select the Noisy 
        
        % load the triggers from the Analyzed_folder with another name


        %Noisy= dlmread('Noisy.rtf',' ',6,2);
        cd('Triggers')
        listing = dir('double_*'); % this creates a structure with all the names of the triggers
        for jj=1:length(listing)

            temp_name=listing(jj).name;
            temp_triggers=load(temp_name);
            new_temp_triggers=remove_noisy_triggers(Noisy, temp_triggers);
            %[pathstr, name, ext] = fileparts(temp_name);
            create_triggers_in_txt(temp_name(1:end-4), new_temp_triggers);
        % Now one would proceed with epoching. 
        end
clear T
    end % For sessions 
    clear T
end % For folders



% %%  CHECK THE BELOW FOR LATER : 25 Jan 2016
%    %% Make a good filename -check this every time 
% dataset_info=EEG.filepath;
% parts_temp1 = strsplit(dataset_info, '/');
% 
% Dataset_name=parts_temp1{8};
% Dataset_set=parts_temp1{9};
% 
% % ANother approach that does not need EEGLAB
% parts = strsplit(Raw_Path, '/');
% Subject_Name=parts{8};
% 
% %% For EEG analysis only
% % Find how many triggers are there - count the trigger number 1
%  % from the EEG recording, trial number 
%  % 1. Load the EEG set 
% % EEG =pop_loadset();
% All_triggers=EEG.urevent;
% % Checking the number of appearances of the trigger "2" 
% index_2=zeros(1,length(All_triggers)); % Should be 640 in our casedata %% no
%     for kk=1:length(All_triggers), 
%         if All_triggers(kk).type==2, 
%             index_2(kk)=1; 
%         end;
%     end
% 
%     index_2_correct=find(index_2>0);
%     
%     if Num_triggers~=length(index_2_correct)
%         disp('WARNING: NOT CORRECT NUMBER OF TRIGGERS')
%     end
%     
%     % This was an internal test to find out if the number of triggers
%     % recorded by the EEG system is the same as the number of triggers of
%     % the E-prime stimulus file. 
%     
%     %% Find the distance between 1 and 3 
%     % How to cut the epochs? Maybe by finding the minimum and max distance from 
%     % a stimulus. 
%     % 1 is the start of the epoch, 3 is the end of trial, coming after the
%     % second response. 
%    
%     % Find index and latency of trigger 1 
%    All_triggers2=All_triggers;
%    trigger_name=1;
%    [trigger_index1, trigger_latency1]=find_trigger(All_triggers, All_triggers2, trigger_name); 
%     
%     % Find index and latency of trigger 3 
%     trigger_name=3;
%    [trigger_index3, trigger_latency3]=find_trigger(All_triggers,All_triggers2, trigger_name);
% 
%     
%     Trial_duration=zeros(1, Num_triggers-1);
%     for kk=1:Num_triggers-1
%         duration(kk)=trigger_latency3(kk)-trigger_latency1(kk);
%     end
%     
%     figure; plot(duration, '*');title(Subject_Name);ylabel('Duration of epochs (ms)')
%     
%  max_duration=max(duration);
%  min_duration=min(duration);
%  mean_duration=mean(duration);
%  median_duration=median(duration);
%  disp(['Max duration of epoch is ' num2str(max_duration)])
%  disp(['Min duration of epoch is ' num2str(min_duration)])
%  disp(['Median duration of epoch is ' num2str(median_duration)])
%  
%  Basic_dataset=[EEG.setname '.set'];
%  Basic_filepath=EEG.filepath;
%  %% EEGLAB Scripting Now!
% % Get the list of triggers
% cd(Raw_Path) 
% cd Triggers 
% listing = dir('double*'); % this creates a structure with all the names of the triggers
% for jj=1:3% length(listing)
% 
%     temp_name=listing(jj).name;
%     temp_triggers=load(temp_name);
%     
%     % Load the basic dataset 
%     EEG = pop_loadset('filename',Basic_dataset,'filepath',Basic_filepath);
%     [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 1 );
%     eeglab redraw
%     
%     
%     % Epoch the basic dataset
%     cd(Raw_Path) 
%     cd Triggers 
%     newname=['EEG epoched for ' temp_name] 
%     EEG = pop_epoch( EEG, {2}, [-0.5 4], 'newname', newname, 'epochinfo', 'yes', 'eventindices', temp_triggers );
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', newname);
%     EEG = pop_rmbase( EEG, [-500 -450]); % Remove baseline
%     % Add a description of the epoch extraction to EEG.comments.
%     EEG.comments = pop_comments(EEG.comments,'','Extracted ''square'' epochs [-0.5 4] sec, and removed baseline.',1); 
%     [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);  %Modify the dataset in the EEGLAB main window
%     eeglab redraw % Update the EEGLAB window to view changes
%     newfilename=[temp_name(1:end-4) '.set'];
%     EEG = pop_saveset( EEG, 'filename',newfilename,'filepath', Basic_filepath);
%     clear temp_name temp_triggers newname
% end


%% Cut 1
%                % Case  50-20
%                % Level 1 
%                double_50_20=zeros(1, length(double_one_corr));
% 
%                % Level 2 Subcase 50Hh_20
%                double_50H_20=zeros(1, length(double_one_corr));
%                % Level 3
%                double_50H_20_20=zeros(1, length(double_one_corr));
%                double_50H_20_50H=zeros(1, length(double_one_corr));
% 
%                % Level 2 % Subcase 50Lh_20
%                double_50L_20=zeros(1, length(double_one_corr));
%                % Level 3
%                double_50L_20_50L=zeros(1, length(double_one_corr));
%                double_50L_20_20=zeros(1, length(double_one_corr));
% 
%                % Case 80-50
%                % Level 1
%                double_80_50=zeros(1, length(double_one_corr));
%                % Level 2
%                double_80_50H=zeros(1, length(double_one_corr));
%                % Level 3
%                double_80_50H_80=zeros(1, length(double_one_corr));
%                double_80_50H_50H=zeros(1, length(double_one_corr));
% 
%                % Level 2
%                double_80_50L=zeros(1, length(double_one_corr));
%                % Level 3
%                double_80_50L_50L=zeros(1, length(double_one_corr));
%                double_80_50L_80=zeros(1, length(double_one_corr));
% Cut 2
% case {'50Lh20Lh', '20Lh50Lh'};
%             double_50L_20(kk)=temp_index;
%            if strcmp(DetRewCont{temp_index,1}, '50Lh')==1
%                    double_50L_20_50L(kk)=temp_index;
%                else double_50L_20_20(kk)=temp_index;
%            end
%            case {'50Hh20Lh', '20Lh50Hh'};
%            double_50H_20(kk)=temp_index;
%            if strcmp(DetRewCont{temp_index,1}, '50Hh')==1
%                    double_50H_20_50H(kk)=temp_index;
%                else double_50H_20_20(kk)=temp_index;
%            end
%            %
%            case {'80Hh50Lh', '50Lh80Hh'};
%            double_80_50L(kk)=temp_index;
%            if strcmp(DetRewCont{temp_index,1}, '50Lh')==1
%                    double_80_50L_50L(kk)=temp_index;
%                else double_80_50L_80(kk)=temp_index;
%            end
%            %
%            case {'80Hh50Hh', '50Hh80Hh'};
%            double_80_50H(kk)=temp_index;
%            if strcmp(DetRewCont{temp_index,1}, '50Hh')==1
%                    double_80_50H_50H(kk)=temp_index;
%                else double_80_50H_80(kk)=temp_index;
%            end
%            %
% % Cut 3, line 237
%    %% Running a loop for Level 1
%    for kk=1:length(double_one_corr),
%        temp_index=double_one_corr(kk);
%        temp_rewpair=RewPair{temp_index,1};% '50Lh20Lh'
%        temp_detrewcont=DetRewCont{temp_index,1};
%        switch temp_rewpair{:}
%               % 50-20 level 1
%            case {'50Lh20Lh', '20Lh50Lh', '50Hh20Lh', '20Lh50Hh'}
%                double_50_20(kk)=temp_index;
%            case {'80Hh50Hh', '50Hh80Hh', '80Hh50Lh', '50Lh80Hh'}
%                double_80_50(kk)=temp_index;
%            case {'50Lh50Hh', '50Hh50Lh','50Hh50Hh', '50Lh50Lh'}
%                 double_50_50(kk)=temp_index;
%        end
%    end