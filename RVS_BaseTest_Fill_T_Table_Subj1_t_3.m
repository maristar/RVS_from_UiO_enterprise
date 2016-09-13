% Analyzing EEG dataset for RVS - Base - Test data. 
% Filling in the T table for Subjects 1 - 3
% This program fills the tabs of the edat2 file: Detection (T.Var49)
% DetType,(T.Var52)
% DetRewCont (T.Var51), 
% DetPosition (T.Var50)
% You need to have the eeglab open and with the respective dataset loaded.
% You also need to have the edat2 file exported in SPSS format (.txt).
% 30 November 2015, Maria L. Stavrinou at PSI, UiO
% 14 January 2016, MLS
% 19 June 2016, MLS
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
clear listing_raw
Sessions={'Base', 'Test'};

%% Start the new part 
% It has to start from number 1-3 and down because the 101-103 datasets have
% not TOTACC in their T table.
for kkf=1:3
    Folder_name=temp22{kkf,:};
    % Define on which subject we are working 
    % Work for each session independently 
    for jj=1:length(Sessions)
        session_temp=Sessions{jj};
        cd(Raw_Path);
        cd(temp22{kkf,:});
        cd(temp22{kkf,:});
        %mkdir(session_temp); %%???
        cd(session_temp);%%% ????
        Analyzed_path_folder=[Analyzed_path temp22{kkf,:} '/'  session_temp '/'];
        Raw_path_folder=[Raw_Path temp22{kkf,:} '/' temp22{kkf,:} '/' session_temp '/'];
        
        % Go to Raw_path_folder
        cd(Raw_path_folder);
        
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

        %TODO TO rename Analyzed_datasets/Subject101 -> RVS_Subject101
        % Define if there is big onset Delay 
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
        clear kk
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

        % Calculate the total Accuracy 
        Num_triggers=size(Mask_CRESP); 
        Num_triggers=Num_triggers(1);

        % Total acc = T.Var130
        for kkj=2:(Num_triggers+1),
            m_index=kkj-1;
            T.Var130{kkj}=str2double(Masc1_ACC{m_index,1})+str2double(Masc2_ACC{m_index,1});
        end
        clear kkj

        %% Find the double or single cases-occurances of triggers 

        %% Find the single accuracies
        single_index_temp=zeros(Num_triggers,1);
        double_index_temp=zeros(Num_triggers, 1);
        for kk=1:Num_triggers
            isequalX=strcmp(TargetCond{kk,1},'1');
            if isequalX==1; 
                single_index_temp(kk,1)=kk;
            else
                double_index_temp(kk,1)=kk;
            end
        end
        clear kk
        single_index=find(single_index_temp>0);
        double_index=find(double_index_temp>0); % Double condition index

         %% Find accuracies
         % Find accuracy of single target. 
         % Go through the indexes of single accuracy and check them for 1 correct.
         single_indexes_correct=zeros(1, length(single_index));
             for kk=1:length(single_index), 
                 temp_index=single_index(kk);
                good_answer=Mask_CRESP{kk,1};  % for example a cell, 'd,4'
                g1=good_answer{1}; % d,4
                CRESP=strsplit(g1, ',');
                CRESP_1=CRESP{1}; 
                CRESP_2=CRESP{2};
                 if ((strcmp(Masc1_ACC{temp_index,1},'1')==1) || (strcmp(Masc2_ACC{temp_index,1},'1')==1))
                     single_indexes_correct(kk)=single_index(kk);

                 else
                     single_indexes_wrong(kk)=single_index(kk);
                 end;
             end
            clear kk 
            % Find only non zeros
            single_acc_indexes=single_indexes_correct(single_indexes_correct>0);

            % Find percentages
%             single_acc_percentage=length(single_acc_indexes)*100/length(single_index);
%             disp('Single correct percentage : ')
%             disp(single_acc_percentage)
            single_acc_indexes_wrong=single_indexes_wrong(single_indexes_wrong>0);
            
        %% Fill the 'Detection' column (T.Var49)
           for kk=2:(Num_triggers+1)
               m_index=kk-1; % matlab_index because the T table's row 1=headers
               good_answer=Mask_CRESP{m_index,1};  % for example a cell, 'd,4'
                g1=good_answer{1}; % d,4
                CRESP=strsplit(g1, ',');
                CRESP_1=CRESP{1}; % or in string format CRESP(1)
                CRESP_2=CRESP{2}; % or in string format CRESP(2)
                total_acc_temp=T.Var130{kk}; % It is ?
                switch total_acc_temp
                    case 0 %if T.Var130{kk}==0, % If TotalACC==0
                        T.Var49{kk}='NONE'; % Detection{kk}='NONE'
                    case 2 % T.Var130{kk}==2 % If TotalACC==2
                        T.Var49{kk}='BOTH'; % Detection{kk}='BOTH'
                    case 1 %  T.Var130{kk}==1,
                    if strcmp(T.Var80{kk},CRESP(1))==1, % If Mask1_RESP=Target1
                        T.Var49{kk}=CRESP(1); % Detection{kk}=Target1
                    elseif strcmp(T.Var80{kk},CRESP(2))==1, % If Mask1_RESP=Target2
                            T.Var49{kk}=CRESP(2);% Detection{kk}=Target2
                    elseif strcmp(T.Var89{kk}, CRESP(1))==1, % If Mask2_RESP=Target1
                                T.Var49{kk}=CRESP(1); % Detection{kk}=Target1
                    elseif strcmp(T.Var89{kk}, CRESP(2))==1, % If Mask2_RESP=Target2
                                    T.Var49{kk}=CRESP(2);% Detection{kk}=Target2
                    end
               end
           end % Num_triggers
%         save T T 
        clear kk

        %% Fill the DetType(T.Var52), Detection (T.Var49)
             %T.Var130{641} = 2;
           for kk=2:(Num_triggers+1)
               m_index=kk-1; % matlab_index because the T table's row 1=headers
               good_answer=Mask_CRESP{m_index,1};  % for example a cell, 'd,4'
                g1=good_answer{1}; % d,4
                CRESP=strsplit(g1, ',');
                CRESP_1=CRESP{1}; % or in string format CRESP(1)
                CRESP_2=CRESP{2}; % or in string format CRESP(2)
                total_acc_temp=T.Var130{kk};
                switch total_acc_temp
                    case 0 %if T.Var130{kk}==0, % If TotalACC==0
                        T.Var49{kk}='NONE'; % Detection{kk}='NONE'
                        T.Var52{kk}='NONE';
                    case 2 % T.Var130{kk}==2 % If TotalACC==2
                        T.Var49{kk}='BOTH'; % Detection{kk}='BOTH'
                        T.Var52{kk}=T.Var129{kk}; % DetType{kk}=TargetType{kk}
                    case 1 %  T.Var130{kk}==1,
                    if strcmp(T.Var80{kk},CRESP(1))==1, % If Mask1_RESP=Target1
                        T.Var49{kk}=CRESP(1); % Detection{kk}=Target1
                    elseif strcmp(T.Var80{kk},CRESP(2))==1, % If Mask1_RESP=Target2
                            T.Var49{kk}=CRESP(2);% Detection{kk}=Target2
                    elseif strcmp(T.Var89{kk}, CRESP(1))==1, % If Mask2_RESP=Target1
                                T.Var49{kk}=CRESP(1); % Detection{kk}=Target1
                    elseif strcmp(T.Var89{kk}, CRESP(2))==1, % If Mask2_RESP=Target2
                                    T.Var49{kk}=CRESP(2);% Detection{kk}=Target2

                    end
               end
           end % Num_triggers
           clear kk
%            save T T 
   
           %% Fill the DetPosition(T.Var50), DetRewCont(T.Var51), DetType(T.Var52)
           for kk=2:(Num_triggers+1)
               m_index=kk-1; % matlab_index because the T table's row 1=headers
               if strcmp(T.Var49{kk}, T.Var122{kk})==1, % If Detection =Target1
                   T.Var52{kk}=T.Var119{kk};
                   T.Var51{kk}=T.Var118{kk};
                   T.Var50{kk}=T.Var124{kk};
               elseif (strcmp(T.Var49{kk}, T.Var125{kk})==1)% IF Detection =Target2
                   T.Var52{kk}=T.Var121{kk};
                   T.Var51{kk}=T.Var120{kk};
                   T.Var50{kk}=T.Var127{kk};
               elseif (strcmp(T.Var49{kk}, 'BOTH')==1),
                   T.Var51{kk}=T.Var104{kk};
               end

           end
   clear kk
   cd(Analyzed_path_folder)
   save T T 
   clear T
%        %% Save T matrix (the eprime edat2file filled, with a good filename
%        temp_filename=[EEG.setname '_T_edat2.mat'];
%        save(temp_filename, 'T');
    end % End for Sessions
end % For folders
       %%  Figure of percentages -just a sample now
   %figure; y = [11.4 68.5 20.1; 0 0 0];bar(y,'stacked')
      % Polar or Compass plot
%      p = polar([2 2], [0, 33])
%  h = polarticks(8, p)  
%     polar_m([30 30], [45 45])
   
%    %% 25.11.2015
%    % From double condition select all three categories 
%    Detection=T{2:end,49};
%    double_both=zeros(1, length(double_index));
%    double_none=zeros(1, length(double_index));
%    double_one=zeros(1, length(double_index));
%    for kk=1:length(double_index),
%        temp_index=double_index(kk);
%        temp_detection=Detection{temp_index};
%        if strcmp(temp_detection, 'BOTH')
%                double_both(kk)=temp_index;
%        elseif strcmp(temp_detection, 'NONE');
%                double_none(kk)=temp_index;
%        else
%            double_one(kk)=temp_index;
%        end
%    end
%    
%    double_both_corr=double_both(double_both>0);
%    Number_double_both=length(double_both_corr);
%    percentage_double_both=Number_double_both*100/length(double_index);
%    disp(['Detection Double percentage (%): ' num2str(percentage_double_both)]);
%    
%    double_none_corr=double_none(double_none>0);
%    Number_double_none=length(double_none_corr);
%    percentage_double_none=Number_double_none*100/length(double_index);
%    disp(['Detection None percentage (%): ' num2str(percentage_double_none)]);
%    
%    double_one_corr=double_one(double_one>0);
%    Number_double_one=length(double_one_corr);
%    percentage_double_one=Number_double_one*100/length(double_index);
%    disp(['Detection One percentage (%): ' num2str(percentage_double_one)]);
% 
% %    %% Make a good filename -check this every time 
% % dataset_info=EEG.filepath(74:end)
% % Dataset_name=dataset_info(1:10);
% % Dataset_set=dataset_info(12:(end))
% % cd /Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets
% % load all_results
% % 
% % all_results.(Dataset_name).(Dataset_set).Double=percentage_double_both;
% % all_results.(Dataset_name).(Dataset_set).None=percentage_double_none;
% % all_results.(Dataset_name).(Dataset_set).One=percentage_double_one;
% % 
% % save all_results all_results
% % 
% % %% 
% % all_results.Total.(Dataset_set).Double=(all_results.Subject101.Base.Double+all_results.Subject102.Base.Double+all_results.Subject103.Base.Double)/3;
% % all_results.Total.(Dataset_set).None=(all_results.Subject101.Base.None+all_results.Subject102.Base.None+all_results.Subject103.Base.None)/3;
% % all_results.Total.(Dataset_set).One=(all_results.Subject101.Base.One+all_results.Subject102.Base.One+all_results.Subject103.Base.One)/3;  
% % 
% % % all_results.Total.Test.Double=(all_results.Subject101.Test.Double+all_results.Subject102.Test.Double+all_results.Subject103.Test.Double)/3;
% % % all_results.Total.Test.None=(all_results.Subject101.Test.None+all_results.Subject102.Test.None+all_results.Subject103.Test.None)/3;
% % % all_results.Total.Test.One=(all_results.Subject101.Test.One+all_results.Subject102.Test.One+all_results.Subject103.Test.One)/3;  
% %      
% % save all_results all_results
% %    %% Figure of Base and Test 
% %    figure; y = [all_results.Total.Base.Double all_results.Total.Base.One all_results.Total.Base.None; all_results.Total.Test.Double all_results.Total.Test.One all_results.Total.Test.None];bar(y,'stacked')  
% %    ylabel('Incidence of response types (%)'); 
% %    title('Total graph ')
% %    axis('tight')
% 
%    %% Make a directory to save all the relevant triggers
% %RAW_path=['/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets' '/RVS_' (Dataset_name) '/' ]
% cd(RAW_path) 
% cd(Dataset_set)
% mkdir('Triggers')
% cd Triggers
% fileID = fopen('double_target_1_corr.txt','w');
% fprintf(fileID,'%i ',double_one_corr);
% fclose(fileID);
% 
% fileID = fopen('double_target_2_corr.txt','w');
% fprintf(fileID,'%i ',double_both_corr);
% fclose(fileID);
% 
% fileID = fopen('double_target_null.txt','w');
% fprintf(fileID,'%i ',double_none_corr);
% fclose(fileID);
% 
% fileID = fopen('single_target_1_corr.txt','w');
% fprintf(fileID,'%i ',single_acc_indexes);
% fclose(fileID);
% 
% % Now one would proceed with epoching. 