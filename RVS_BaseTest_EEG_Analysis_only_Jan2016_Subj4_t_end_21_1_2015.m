% Analyzing EEG dataset for RVS - Base - Test data. 
% 30 November 2015, Maria L. Stavrinou at PSI, UiO
% 14 January 2016, MLS

% This program fills the tabs of the edat2 file: Detection (T.Var49)
% DetType,(T.Var52)
% DetRewCont (T.Var51), 
% DetPosition (T.Var50)
% You need to have the eeglab open and with the respective dataset loaded.
% You also need to have the edat2 file exported in SPSS format (.txt).



% Load the exported edat2 file (later named Tfinal).
[FileName,Raw_Path] = uigetfile('*.*','Select the MATLAB T table (Tfinal) file "txt", or "mat" ');
cd(Raw_Path)

T = readtable((FileName),...
'Delimiter','\t','ReadVariableNames',false);

%TODO TO rename Analyzed_datasets/Subject101 -> RVS_Subject101
% Define if there is big StimOnsetDelay
disp(T(1, 107))
StimOnsetDelay=T(2:end, 107);
counter=0;
for kk=1:size(StimOnsetDelay,1),
    if strcmp(StimOnsetDelay{kk,1},'0')==1 | strcmp(StimOnsetDelay{kk,1},'1')==1
    else
        counter=counter+1;
        indexes_StimOnsetDelay_toobig(counter)=kk;
    end
end
disp(['StimOnsetDelay: Found ' num2str(counter) ' delays bigger than 1']);
% Subject101 Baseline: Subject101_Base1.txt'
% Subject101 path of Baseline /Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/RVS_Subject101/BaseTest
% Subject101 Test: RVSBaseTest_EEG-101-2matlab.txt'
% Subject102: 'RVSBaseTest_EEG-102-2matlab'
% Subject103: 'RVSBaseTest_EEG-103-2matlab.txt'

%% Get some values from the T table from eprime and do the ACC
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
%
%% No need from Subject104 and down
% % Total acc = T.Var130
% for kkj=2:(Num_triggers+1),
%     m_index=kkj-1;
%     T.Var130{kkj}=str2double(Masc1_ACC{m_index,1})+str2double(Masc2_ACC{m_index,1});
% end
% clear kkj

%% Find the double or single cases-occurances of triggers 

%% Find the Target Condition: 1 or 2 stimuli presented.
% Important 1! 
% From TargetCond
single_index_temp=zeros(Num_triggers,1);
double_index_temp=zeros(Num_triggers, 1);
for kk=1:Num_triggers
    %isequalX=strcmp(TargetCond{kk,1},'1');
    %if isequalX==1; 
    if strcmp(TargetCond{kk,1}, '1')==1
        single_index_temp(kk,1)=kk;
    elseif strcmp(TargetCond{kk,1}, '2')==1
        
        double_index_temp(kk,1)=kk;
    end
end

single_index=single_index_temp(single_index_temp>0);
double_index=double_index_temp(double_index_temp>0); % 448, correct! Double condition index
% Look at Single target accuracy

 %% Find accuracies
 % Find accuracy of single target. 
 % Go through the indexes of single accuracy and check them for 1 correct.
 TotAcc=T{2:end, 130};
 single_indexes_correct=zeros(1, length(single_index));
     for kk=1:length(single_index), 
         temp_index=single_index(kk);
         
         if TotAcc{temp_index,1}==1
             single_indexes_correct(kk)=temp_index;
             
         else
             single_indexes_wrong(kk)=temp_index;
         end;
     end
        
    % Find only non zeros
    single_acc_indexes=single_indexes_correct(single_indexes_correct>0);
    
    % Find percentages
    single_acc_percentage=length(single_acc_indexes)*100/length(single_index);
    disp('Single correct percentage : ')
    disp(single_acc_percentage)
    
    single_acc_indexes_wrong=single_indexes_wrong(single_indexes_wrong>0);


   %% 25.11.2015
   % From double condition select all three categories 
   % {'Detection';'NONE';'NONE';'NONE';'NONE';'NONE';'NONE';'NONE';'NONE';'NONE';'d';'NONE';'7'}
   Detection=T{2:end,49};
   double_both=zeros(1, length(double_index));
   double_none=zeros(1, length(double_index));
   double_one=zeros(1, length(double_index));
   for kk=1:length(double_index),
       temp_index=double_index(kk);
       temp_detection=Detection{temp_index};
       if strcmp(temp_detection, 'BOTH')
               double_both(kk)=temp_index;
       elseif strcmp(temp_detection, 'NONE');
               double_none(kk)=temp_index;
       else
           double_one(kk)=temp_index;
       end
   end
   
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
   
   %% Checked and its fine, 14.1.2016 til here. 
   
   %% TODO add more categories 14 Jan 2016
   % From the double condition, detect those that are in the category
   % 50Hh-50Lh(RewPair,Var 104). From those separate those that have detected the 50Hh. Then
   % those that have detected the 50Lh (DetRewCont).
   RewPair=T(2:end, 104);
   DetRewCont=T(2:end, 51);
   % Case 50-50
   double_50_50=zeros(1, length(double_one_corr));
   double_50_50_50L=zeros(1, length(double_one_corr));
   double_50_50_50H=zeros(1, length(double_one_corr));
   
   % Case 80-20 (it will be always 80Hh, 20Lh)
   double_80_20=zeros(1, length(double_one_corr));
   double_80_20_80=zeros(1, length(double_one_corr));
   double_80_20_20=zeros(1, length(double_one_corr));
   
   % Case  50Hh-20
   double_50H_20=zeros(1, length(double_one_corr));
   double_50H_20_20=zeros(1, length(double_one_corr));
   double_50H_20_50H=zeros(1, length(double_one_corr));
  
   % Case 50Lh-20
   double_50L_20=zeros(1, length(double_one_corr));
   double_50L_20_50L=zeros(1, length(double_one_corr));
   double_50L_20_20=zeros(1, length(double_one_corr));
   
   for kk=1:length(double_one_corr),
       temp_index=double_index(kk);
       temp_detection=RewPair{temp_index,1}; % '50Lh20Lh'
       if strcmp(temp_detection, '50Lh50Hh')==1 | strcmp(temp_detection, '50Hh50Lh')==1
               double_50_50(kk)=temp_index;
               if strcmp(DetRewCont{temp_index,1}, '50Lh')==1
                   double_50_50_50L(kk)=temp_index;
               else double_50_50_50H(kk)=temp_index;
               end
       elseif strcmp(temp_detection, '80Hh20Lh')==1 | strcmp(temp_detection, '20Lh80Hh')==1;
               double_80_20(kk)=temp_index;
               if strcmp(DetRewCont{temp_index,1}, '80Hh')==1
                   double_80_20_80(kk)=temp_index;
               else double_80_20_20(kk)=temp_index;
               end
       elseif strcmp(temp_detection, '50Lh20Lh')==1 | strcmp(temp_detection, '20Lh50Lh')==1;
           double_50L_20(kk)=temp_index;
           if strcmp(DetRewCont{temp_index,1}, '50Lh')==1
                   double_50L_20_50L(kk)=temp_index;
               else double_50L_20_20(kk)=temp_index;
           end
         elseif strcmp(temp_detection, '50Hh20Lh')==1 | strcmp(temp_detection, '20Lh50Hh')==1;
           double_50H_20(kk)=temp_index;
           if strcmp(DetRewCont{temp_index,1}, '50Hh')==1
                   double_50H_20_50H(kk)=temp_index;
               else double_50H_20_20(kk)=temp_index;
           end
       end
   end
   
   double_50_50_corr=double_50_50(double_50_50>0);
   double_50_50_50L_corr=double_50_50_50L(double_50_50_50L>0);
   double_50_50_50H_corr=double_50_50_50H(double_50_50_50H>0);
     
   double_80_20_corr=double_80_20(double_80_20>0);
   double_80_20_80_corr=double_80_20_80(double_80_20_80>0);
   double_80_20_20_corr=double_80_20(double_80_20>0);
   
   double_50H_20_corr=double_50H_20(double_50H_20>0);
   double_50H_20_20_corr=double_50H_20_20(double_50H_20_20>0);
   double_50H_20_50H_corr=double_50H_20_50H(double_50H_20_50H>0);
   
   double_50L_20_corr=double_50L_20(double_50L_20>0);
   double_50L_20_50L_corr=double_50L_20_50L(double_50L_20_50L>0);
   double_50L_20_20_corr=double_50L_20_20(double_50L_20_20>0);

   
   %% Make a directory to save all the relevant triggers
%RAW_path=['/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets' '/RVS_' (Dataset_name) '/' ]
cd(Raw_Path) 
mkdir('Triggers')
cd Triggers

create_triggers_in_txt('double_target_1_corr', double_one_corr)
% fileID = fopen('double_target_1_corr.txt','w');
% fprintf(fileID,'%i ',double_one_corr);
% fclose(fileID);

create_triggers_in_txt('double_target_2_corr', double_both_corr)
% fileID = fopen('double_target_2_corr.txt','w');
% fprintf(fileID,'%i ',double_both_corr);
% fclose(fileID);

create_triggers_in_txt('double_target_null', double_none_corr)
% fileID = fopen('double_target_null.txt','w');
% fprintf(fileID,'%i ',double_none_corr);
% fclose(fileID);

create_triggers_in_txt('single_target_1_corr', single_acc_indexes)
% fileID = fopen('single_target_1_corr.txt','w');
% fprintf(fileID,'%i ',single_acc_indexes);
% fclose(fileID);

create_triggers_in_txt('double_50_50', double_50_50_corr);
create_triggers_in_txt('double_50_50_50L', double_50_50_50L_corr);
create_triggers_in_txt('double_50_50_50H', double_50_50_50H_corr);

create_triggers_in_txt('double_80_20', double_80_20_corr)
create_triggers_in_txt('double_80_20_80', double_80_20_80_corr)
create_triggers_in_txt('double_80_20_20', double_80_20_20_corr)

create_triggers_in_txt('double_50H_20', double_50H_20)
create_triggers_in_txt('double_50H_20_50H', double_50H_20_50H)
create_triggers_in_txt('double_50H_20_20', double_50H_20_20_corr)

create_triggers_in_txt('double_50L_20', double_50L_20_corr)
create_triggers_in_txt('double_50L_20_50L', double_50L_20_50L_corr)
create_triggers_in_txt('double_50L_20_20', double_50L_20_20_corr)


% Now one would proceed with epoching. 

   %% Make a good filename -check this every time 
dataset_info=EEG.filepath
parts_temp1 = strsplit(dataset_info, '/');

Dataset_name=parts_temp1{8};
Dataset_set=p;

% ANother approach that does not need EEGLAB
parts = strsplit(Raw_Path, '/');
Subject_Name=parts{8}

%% Do this if we need behavioral data 
% cd /Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets
% load all_results
% 
% all_results.(Dataset_name).(Dataset_set).Double=percentage_double_both;
% all_results.(Dataset_name).(Dataset_set).None=percentage_double_none;
% all_results.(Dataset_name).(Dataset_set).One=percentage_double_one;
% 
% save all_results all_results
% 
% %% TODO to make it for all- not necessary as it adds the behav data but can be useful 
% % when collecting triggers or adding triggers for ERPS
% all_results.Total.(Dataset_set).Double=(all_results.Subject101.Base.Double+all_results.Subject102.Base.Double+all_results.Subject103.Base.Double)/3;
% all_results.Total.(Dataset_set).None=(all_results.Subject101.Base.None+all_results.Subject102.Base.None+all_results.Subject103.Base.None)/3;
% all_results.Total.(Dataset_set).One=(all_results.Subject101.Base.One+all_results.Subject102.Base.One+all_results.Subject103.Base.One)/3;  

% all_results.Total.Test.Double=(all_results.Subject101.Test.Double+all_results.Subject102.Test.Double+all_results.Subject103.Test.Double)/3;
% all_results.Total.Test.None=(all_results.Subject101.Test.None+all_results.Subject102.Test.None+all_results.Subject103.Test.None)/3;
% all_results.Total.Test.One=(all_results.Subject101.Test.One+all_results.Subject102.Test.One+all_results.Subject103.Test.One)/3;  
     
%save all_results all_results
%    %% Figure of Base and Test 
%    figure; y = [all_results.Total.Base.Double all_results.Total.Base.One all_results.Total.Base.None; all_results.Total.Test.Double all_results.Total.Test.One all_results.Total.Test.None];bar(y,'stacked')  
%    ylabel('Incidence of response types (%)'); 
%    title('Total graph ')
%    axis('tight')


%% For EEG analysis only
% Find how many triggers are there - count the trigger number 1
 % from the EEG recording, trial number 
 % 1. Load the EEG set 
% EEG =pop_loadset();
All_triggers=EEG.urevent;
% Checking the number of appearances of the trigger "2" 
index_2=zeros(1,length(All_triggers)); % Should be 640 in our casedata %% no
    for kk=1:length(All_triggers), 
        if All_triggers(kk).type==2, 
            index_2(kk)=1; 
        end;
    end

    index_2_correct=find(index_2>0);
    
    if Num_triggers~=length(index_2_correct)
        disp('WARNING: NOT CORRECT NUMBER OF TRIGGERS')
    end
    
    % This was an internal test to find out if the number of triggers
    % recorded by the EEG system is the same as the number of triggers of
    % the E-prime stimulus file. 
    
    %% Find the distance between 1 and 3 
    % How to cut the epochs? Maybe by finding the minimum and max distance from 
    % a stimulus. 
    % 1 is the start of the epoch, 3 is the end of trial, coming after the
    % second response. 
   
    % Find index and latency of trigger 1 
   All_triggers2=All_triggers;
   trigger_name=1;
   [trigger_index1 trigger_latency1]=find_trigger(All_triggers, All_triggers2, trigger_name); 
    
    % Find index and latency of trigger 3 
    trigger_name=3;
   [trigger_index3 trigger_latency3]=find_trigger(All_triggers,All_triggers2, trigger_name);

    
    Trial_duration=zeros(1, Num_triggers-1);
    for kk=1:Num_triggers-1
        duration(kk)=trigger_latency3(kk)-trigger_latency1(kk);
    end
    
    figure; plot(duration, '*');title(Subject_Name);ylabel('Duration of epochs (ms)')
    
 max_duration=max(duration);
 min_duration=min(duration);
 mean_duration=mean(duration);
 median_duration=median(duration);
 disp(['Max duration of epoch is ' num2str(max_duration)])
 disp(['Min duration of epoch is ' num2str(min_duration)])
 disp(['Median duration of epoch is ' num2str(median_duration)])
 
 
 %% EEGLAB Scripting Now!
EEG = pop_epoch( EEG, {2}, [-0.5 4], 'newname', 'Continuous EEG Data epochs', 'epochinfo', 'yes', 'eventindices', [double_80_20_corr] );
 
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'Continuous EEG Data epochs');
 
EEG = pop_rmbase( EEG, [-500 -450]); % Remove baseline
% Add a description of the epoch extraction to EEG.comments.
EEG.comments = pop_comments(EEG.comments,'','Extracted ''square'' epochs [-0.5 4] sec, and removed baseline.',1); 
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);  %Modify the dataset in the EEGLAB main window
eeglab redraw % Update the EEGLAB window to view changes