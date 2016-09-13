% Analyzing EEG dataset for RVS - Training data. 
% November 2015, Maria Stavrinou at PSI, UiO
% January 2016. This program makes a directory where it saves the different
% triggers needed for further EEG analysis. For now the selection done is
% refering to: 
% 'Correct
% 'Wrong
% 'Low Reward
% 'High Reward
% First we should have these triggers, and then we should check for noisy
% epochs? Yes 
%
% Read the exported e-prime file:
% GOTO raw directory
RAW_dir='/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/RVS_Subject101/Training2';
cd(RAW_dir)
T = readtable('RVSTraining_EEG_pupil-101-2matlab.txt',...
'Delimiter','\t','ReadVariableNames',false);

% Define if there is big onset Delay 
% TODO
StimOnsetDelay=T(2:end, 102);
counter=0;
for kk=1:size(StimOnsetDelay,1),
    if strcmp(StimOnsetDelay{kk,1},'0')==1 | strcmp(StimOnsetDelay{kk,1},'1')==1
    else
        counter=counter+1;
        indexes_StimOnsetDelay_toobig(counter)=kk;
    end
end
disp(['StimOnsetDelay: Found ' num2str(counter) ' delays bigger than 1']);


% Define if there is big onset Delay for Feedback
% TODO
StimOnsetDelay=T(2:end, 42);
counter=0;
store_delayed=zeros(1, size(StimOnsetDelay,1));
for kk=1:size(StimOnsetDelay,1),
    if strcmp(StimOnsetDelay{kk,1},'0')==1 | strcmp(StimOnsetDelay{kk,1},'1')==1
    else
        counter=counter+1;
        indexes_Feedback_delay_toobig(counter)=kk;
    end
end
disp(['FeedbackOnsetDelay: Found ' num2str(counter) ' delays bigger than 1']);
FeedbackOnsetDelay=StimOnsetDelay;

% Get Accuracy, Reward from table
StimAcc=T(2:end, 99);% Previously was 103? why? TODOCHECK
Reward=T(2:end, 88); % Previously was 92 ? why? TODOCHECK

Num_triggers=size(Reward); 
Num_triggers=Num_triggers(1);

%% Find correct or wrong answers - indexes
correct_index_temp=zeros(Num_triggers,1);
wrong_index_temp=zeros(Num_triggers, 1);
for kk=1:Num_triggers
    isequalX=strcmp(StimAcc{kk,1},'1');
    if isequalX==1; 
        correct_index_temp(kk,1)=kk;
    else
        wrong_index_temp(kk,1)=kk;
    end
end

correct_index=find(correct_index_temp>0);
wrong_index=find(wrong_index_temp>0); % Double condition index

%% From the correct indexes, select the HighReward (HR) and LowReward (LR)
Num_correct = length(correct_index);

HR_index_temp=zeros(Num_correct,1);
LR_index_temp=zeros(Num_correct, 1);
for kk=1:Num_correct
    isequalX=strcmp(Reward{kk,1},'H');
    if isequalX==1; 
        HR_index_temp(kk,1)=kk;
    else %if strcmp(Reward{kk,1},'L')==1;
        LR_index_temp(kk,1)=kk;
    end
end

HR_index=find(HR_index_temp>0);
LR_index=find(LR_index_temp>0);

clear *temp


%% Save the triggers

dataset_info=EEG.filepath(74:end)
Dataset_name=dataset_info(1:10) % Subject_X
Dataset_set=dataset_info(12:(end))  % Training



RAW_filepath=['/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets' '/RVS_' (Dataset_name) '/' ]
cd(RAW_filepath) 
cd(Dataset_set)
mkdir('Triggers')
cd Triggers
fileID = fopen('correct_index_training1.txt','w');
fprintf(fileID,'%i ',correct_index);
fclose(fileID);

fileID = fopen('wrong_index_training1.txt','w');
fprintf(fileID,'%i ',wrong_index);
fclose(fileID);

fileID = fopen('LowReward_training1.txt','w');
fprintf(fileID,'%i ',LR_index);
fclose(fileID);

fileID = fopen('HighReward_training2.txt','w');
fprintf(fileID,'%i ',HR_index);
fclose(fileID);

