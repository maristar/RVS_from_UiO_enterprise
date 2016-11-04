% Analyzing EEG dataset for RVS - Base - Test data. 
% 30 November 2015, Maria L. Stavrinou at PSI, UiO
% 14 January 2016, MLS
% 17 June 2016 making a loop for all subjects. Including only a subset of
% triggers. Final results.
% 01.11.2016 Analyzing in double report, how many subjects pressed first
% the 80Hh position when there was 80Hh -20Lh
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
for kk=1:33%Num_folders
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
for kk=1:33% Num_folders, 
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
    for jj=2% 1:1%length(Sessions)
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
            disp('Subject104 and up')
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
        
        
        % Automate this TODO
        Mask_CRESP=T(2:end, 84);
        Mask1_RESP=T(2:end, 80);
        Mask2_RESP=T(2:end, 89);
        RewPair=T(2:end, 104);
        
         %% Automate start
        % Find which row in the T table is Condition, and the StimTwoACC.
        % Find it iteratively:
        all_headers=T(1,:);
        all_headers2=table2cell(all_headers);
        clear all_headers
        
        [ T1RewConting_2 ] = eprime_to_matlab( T, all_headers2, 'T1RewConting')
        %% Find for the T1RewContig %% TODO TO make it a function
        for jjj=1:length(all_headers2)
            a=strcmp(all_headers2{1,jjj}, 'T1RewConting');
            if a==1
                indexT1RewConting=jjj;
            end
        end
        clear a jjj % OK

        T1RewConting_table=T(2:end, indexT1RewConting); % 131 for JackLoe, tested first!
        T1RewConting=table2cell(T1RewConting_table);
        
        %% Find for the T1RewContig %% TODO TO make it a function
        for jjj=1:length(all_headers2)
            a=strcmp(all_headers2{1,jjj}, 'T2RewConting');
            if a==1
                indexT2RewConting=jjj;
            end
        end
        clear a jjj % OK

        T2RewConting_table=T(2:end, indexT2RewConting); % 131 for JackLoe, tested first!
        T2RewConting=table2cell(T2RewConting_table);
               
        %% Find for the Total.ACC
        for jjj=1:length(all_headers2)
            a=strcmp(all_headers2{1,jjj}, 'TotACC');
            if a==1
                indexTotalAcc=jjj;
            end
        end
         clear a jjj 
        
        TotalAcc_table=T(2:end, indexTotalAcc); % 131 for JackLoe, tested first!
        TotalAcc=table2cell(TotalAcc_table);
        clear indexStimACC
              
        
        %% End automate
        %% Calculate the total number of triggers we have 
        Num_triggers=size(Mask_CRESP); 
        Num_triggers=Num_triggers(1);

         %% Find accuracy=2 and this is our condition

        double_index_temp=zeros(Num_triggers, 1);
        for kkt=1:Num_triggers
            if TotalAcc{kkt,1}==2
                double_index_temp(kkt,1)=kkt;
            end
        end
          
        double_report=double_index_temp(double_index_temp>0); %
        clear double_index_temp kkt
        
        % Start, from now on we have as num_triggers the
        % length(double_report) Nov2016
        

        
        for kkm=1:length(double_report)
               temp_index=double_report(kkm);
               temp_rewpair=RewPair{temp_index,1};% '50Lh20Lh'
               temp_pressed1=Mask1_RESP{temp_index,:};
               temp_pressed2=Mask2_RESP{temp_index,:};
               temp_position1=T1RewConting{temp_index,:};
               temp_position2=T2RewConting{temp_index,:};

               % Find the correct response
               temp_Mask_CRESP=Mask_CRESP{temp_index, 1}; % CELL
               % Make it string and divide it in two parts 
               temp_MCRESP_string = temp_Mask_CRESP{1};
               % Now divide it into two parts. 
               temp_MCRESP_parts = strsplit(temp_MCRESP_string, ',');
               % Part 1
               temp_MCRESP_part1=temp_MCRESP_parts(1)
               % Part 2
               temp_MCRESP_part2=temp_MCRESP_parts(2)
               
               % The temp_MCRESP_part1 position in found at the
               % T1RewContig. 
               
               switch temp_rewpair{:}
                   % Choose only some combinations
                   case {'50Lh50Hh', '50Hh50Lh'}
%                        double_50L_50H(kkm)=temp_index;
%                        if strcmp(temp_detrewcont, '50Lh')==1
%                            double_50L_50H_50L(kkm)=temp_index;
%                            [ temp_left, temp_right ] =  detect_left_right_vhf(kkm, temp_index, double_one_corr, temp_detposition );
%                            double_50L_50H_50L_left(kkm)=temp_left;
%                            double_50L_50H_50L_right(kkm)=temp_right;
%                            clear temp_left temp_right
%                        elseif strcmp(temp_detrewcont, '50Hh')==1
%                             double_50L_50H_50H(kkm)=temp_index;
%                             [ temp_left, temp_right ] =  detect_left_right_vhf(kkm, temp_index, double_one_corr, temp_detposition );
%                             double_50L_50H_50H_left(kkm)=temp_left;
%                             double_50L_50H_50H_right(kkm)=temp_right;
%                             clear temp_left temp_right
%                        end
                   case {'80Hh20Lh', '20Lh80Hh'}
                       disp('20Hh80Hh here')
                       if strcmp(temp_pressed1, temp_MCRESP_part1)==1
                           RewContingPressed1_80_20{kkm,:}=temp_position1;
                       elseif strcmp(temp_pressed1, temp_MCRESP_part2)==1
                          RewContingPressed1_80_20{kkm,:}=temp_position2;
                       end           
                   case '80Hh80Hh'
%                        double_80_80(kkm)=temp_index;
%                        [ temp_left, temp_right ] =  detect_left_right_vhf(kkm, temp_index, double_one_corr, temp_detposition );
%                        double_80_80_left(kkm)=temp_left;
%                        double_80_80_right(kkm)=temp_right;
%                        clear temp_left temp_right
                   case '20Lh20Lh'
%                        double_20_20(kkm)=temp_index;
%                        [ temp_left, temp_right ] =  detect_left_right_vhf(kkm, temp_index, double_one_corr, temp_detposition );
%                        double_20_20_left(kkm)=temp_left;
%                        double_20_20_right(kkm)=temp_right;
%                        clear temp_left temp_right
               end
               clear temp_rewpair temp_pressed1 temp_pressed2 temp_position1 temp_position2 temp_index %15.9.2016
           end % for kkm 
           clear kkm

    end % For sessions 
    clear T   
end % For folders

count=0;
for kk=1:length(RewContingPressed1_80_20); 
    if strcmp(RewContingPressed1_80_20(kk,1), '20Lh')==1; 
        count=count+1; 
    end; 
end; 
disp(count);

Total_percentage=count*100/length(RewContingPressed1_80_20); 
disp(Total_percentage)

