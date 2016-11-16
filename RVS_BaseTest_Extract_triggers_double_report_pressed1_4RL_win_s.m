% Analyzing EEG dataset for RVS - Base - Test data. 
% A program to analyze behavioral data, for Double condition, double
% report. 
% 01.11.2016 Analyzing in double report, how many subjects pressed first
% the 80Hh position when there was 80Hh -20Lh
% Works well, gives output in excel. COuld not work on subject 124. 
% Maria Stavrinou. 
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
bad_subject_list=[16, 26]; %[7, 9, 13, 16, 17, 19, 20, 24, 30];
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
    % jj=1 for Base, jj=2 for Test
    for jj=1:length(Sessions)
        session_temp=Sessions{jj};
        cd(Raw_Path);
        cd(temp22{jjk,:});
        cd(temp22{jjk,:});
        %mkdir(session_temp); %%???
        cd(session_temp);%%% ????
        %TODO change the name into Analyzed_path_folder_session, and
        %Raw_path_folder_session
        Analyzed_path_folder=[Analyzed_path temp22{jjk,:} '\'  session_temp '\'];
        Raw_path_folder=[Raw_Path temp22{jjk,:} '\' temp22{jjk,:} '\' session_temp '\'];
        
        % Go to Raw_path_folder
        cd(Raw_path_folder);
        if jjk>3
            %disp('Subject104 and up')
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
%         Mask_CRESP=T(2:end, 84);
%         Mask1_RESP=T(2:end, 80);
%         Mask2_RESP=T(2:end, 89);
%         RewPair=T(2:end, 104);
        
         %% Automate start
        % Find which row in the T table is Condition, and the StimTwoACC.
        % Find it iteratively:
        all_headers=T(1,:);
        all_headers2=table2cell(all_headers);
        clear all_headers
        Mask_CRESP=eprime_to_matlab( T, all_headers2, 'Mask.CRESP');
        Mask1_RESP=eprime_to_matlab( T, all_headers2, 'Mask.RESP');
        Mask2_RESP=eprime_to_matlab( T, all_headers2,'Mask2.RESP');
        RewPair=eprime_to_matlab( T, all_headers2,'RewPair');
        [T1RewConting] = eprime_to_matlab( T, all_headers2, 'T1RewConting');
        [T2RewConting]=eprime_to_matlab(T, all_headers2, 'T2RewConting');
        [TotalAcc]=eprime_to_matlab(T, all_headers2, 'TotACC');

        %% Calculate the total number of triggers we have 
        Num_triggers=size(Mask_CRESP); 
        Num_triggers=Num_triggers(1);

         %% Find accuracy=2 and this is our condition
        double_index_temp=zeros(Num_triggers, 1);
        for kkt=1:Num_triggers
            if jjk<4
                if TotalAcc{kkt,1}==2 
                    double_index_temp(kkt,1)=kkt;
                end
            elseif jjk>3
                if strcmp(TotalAcc(kkt,1),'2')==1
                    double_index_temp(kkt,1)=kkt;
                end
            end
        end
          
        double_report=double_index_temp(double_index_temp>0); % 87x 1
        clear double_index_temp kkt
        
        %% Select from the double_report those who are 8020 or 2080.
        index8020=zeros(length(double_report),1);
        if length(double_report)>0
            for kkm=1:length(double_report)
               temp_index=double_report(kkm);
               temp_rewpair=RewPair{temp_index,1};% '50Lh20Lh'
               switch temp_rewpair
                   case {'80Hh20Lh', '20Lh80Hh'}
                       %disp('20Hh80Hh here')
                       index8020(kkm,1)=temp_index;
                   case {'80Hh50Lh', '50Lh80Hh','80Hh50Hh', '50Hh80Hh'}
                       index8050(kkm,1)=temp_index;
               end
            end
        elseif length(double_report)==0
            index8020=0;
            index8050=0;
        end
        index8020=index8020(index8020>0);
        index8050=index8050(index8050>0);
        
        clear kkm temp_index temp_rewpair
        
        %% For those 8020 or 2080, do some calculations to find out which one they pressed more. 
        if length(index8020)>0
            for kkm=1:length(index8020)
                temp_index=index8020(kkm);
                % Find the correct response
                temp_Mask_CRESP=Mask_CRESP{temp_index, 1}; % char
    %           % Make it string and divide it in two parts 
    %            temp_MCRESP_string = temp_Mask_CRESP{1};
                % Now divide it into two parts. 
                temp_MCRESP_parts = strsplit(temp_Mask_CRESP, ',');
                % Part 1
                temp_MCRESP_position1=temp_MCRESP_parts(1);
                % Part 2
                temp_MCRESP_position2=temp_MCRESP_parts(2);

                % What did the subject pressed: 
               temp_pressed1=Mask1_RESP{temp_index,:};
               temp_pressed2=Mask2_RESP{temp_index,:};

               % What were the reward contingencies of position 1 (from the
               % CRESP)
               temp_position1=T1RewConting{temp_index,:};
               temp_position2=T2RewConting{temp_index,:};
               
               %RewContingPressed1_80_20=[];
               if strcmp(temp_pressed1, temp_MCRESP_position1)==1
                   RewContingPressed1_80_20{kkm,:}=temp_position1;
               elseif strcmp(temp_pressed1, temp_MCRESP_position2)==1
                  RewContingPressed1_80_20{kkm,:}=temp_position2;
               end  
               clear temp_rewpair temp_pressed1 temp_pressed2 temp_position1 temp_position2 temp_index temp_MCRESP_position2 temp_MCRESP_position1 temp_MCRESP_parts ...
                   temp_Mask_CRESP%15.9.2016
                   end

                %% Initialize for 80     
                count80=0;
                for kk=1:length(RewContingPressed1_80_20); 
                    if strcmp(RewContingPressed1_80_20(kk,1), '80Hh')==1; 
                        count80=count80+1; 
                    end; 
                end; 
                clear kk  

                Total_percentage80=count80*100/length(index8020); 
                disp([( Folder_name) '_' (session_temp) ': Total_percentage of 80Hh is: ' num2str(Total_percentage80)])
                clear count80

                %% Initialize for 20
                count20=0;
                for kk=1:length(RewContingPressed1_80_20); 
                    if strcmp(RewContingPressed1_80_20(kk,1), '20Lh')==1; 
                        count20=count20+1; 
                    end; 
                end; 
                clear kk 

                Total_percentage20=count20*100/length(index8020); 
                clear count20
                disp([( Folder_name) '_' (session_temp) ': Total_percentage of 20Hh is: ' num2str(Total_percentage20)])
                    results_press1.(Folder_name).(session_temp).press80=Total_percentage80;
                    results_press1.(Folder_name).(session_temp).press20=Total_percentage20;
%                clear Total_percentage20 Total_percentage80 
%                clear RewContingPressed1_80_20
        elseif length(double_report)==0,
            results_press1.(Folder_name).(session_temp).press80=0;
            results_press1.(Folder_name).(session_temp).press20=0;
        end %if length index8020>0
     end % Sessions
  end % For folders
        

cd(Analyzed_path)
save results_press1 results_press1

%TODO
%write an excel
clear T
%% Write components to a txt file - NEW
header_raw={'Subject_name,' 'Base_80Hh','_Base_20Lh','_Test_80Hh','_Test_20Hh'};


    for hh=1:length(header_raw);
        temp=header_raw{1, hh};
        temp_new=[temp];
        header_new{1,1}=header_raw{1,1};
        header_new{1,hh}=temp_new;
    end

T(1, :)=header_new;

% Define which subjects are good and which are bad. 
bad_subject_list=[16, 24, 26]; %[7, 9, 13, 16, 17, 19, 20, 24, 30];
% Old correct_folders=[startfolder 2:6 8:12 14 15 18 21:29 31:33];
good_subj_list=[]; 
for kk=1:33% Num_folders, 
    if ~ismember(kk, bad_subject_list), 
        good_subj_list=[good_subj_list kk]; 
    end; 
end
clear kk 
    
    for jjk=[good_subj_list]
     % For every subject - folder
        Folder_name=temp22{jjk,:};
        T(jjk+1,1)={Folder_name(5:end)};
        column_counter=0;
        for kk=1:length(Sessions) % For every condition : Correct,Wrong, HR, LR
            session_temp=Sessions(kk);
            session_temp_char=char(session_temp); 
                disp(column_counter)
                conditions={'press80', 'press20'};
                for hh=1:length(conditions)
                    conditions_temp=conditions(hh);
                    conditions_temp_char=char(conditions_temp);
                    column_counter=column_counter+1;
                    temp_peak_results=results_press1.(Folder_name).(session_temp_char). (conditions_temp_char);
                T(jjk+1,1+column_counter)=num2cell(temp_peak_results);
                end
             end % End for sessions 
    end % End for every subject

    cd(Analyzed_path)
    Tnew=cell2table(T)%, 'VariableNames', header_new);
    %filename_to_save_txt=[chanlocs_temp '_' type name_component '_results.txt'];
    filename_to_save_xls=['Double_report_FirstPressed_results.xls'];
    %writetable(Tnew, filename_to_save_txt);
    writetable(Tnew, filename_to_save_xls);
    clear T header_new Tnew
    
% 
% write_peak_component_to_txt_1_report_4rewlev( header_raw, startfolder, good_subj_list , temp22, ...
%     selected_channels, Sessions, Peak_results, chanlocs, name_component, temp23, type)
% clear Peak_results






%               
%                % The temp_MCRESP_part1 position in found at the
%                % T1RewContig. 
%                
%                
%                    % Choose only some combinations
%                    case {'50Lh50Hh', '50Hh50Lh'}
% %                        double_50L_50H(kkm)=temp_index;
% %                        if strcmp(temp_detrewcont, '50Lh')==1
% %                            double_50L_50H_50L(kkm)=temp_index;
% %                            [ temp_left, temp_right ] =  detect_left_right_vhf(kkm, temp_index, double_one_corr, temp_detposition );
% %                            double_50L_50H_50L_left(kkm)=temp_left;
% %                            double_50L_50H_50L_right(kkm)=temp_right;
% %                            clear temp_left temp_right
% %                        elseif strcmp(temp_detrewcont, '50Hh')==1
% %                             double_50L_50H_50H(kkm)=temp_index;
% %                             [ temp_left, temp_right ] =  detect_left_right_vhf(kkm, temp_index, double_one_corr, temp_detposition );
% %                             double_50L_50H_50H_left(kkm)=temp_left;
% %                             double_50L_50H_50H_right(kkm)=temp_right;
% %                             clear temp_left temp_right
% %                        end
%                    case {'80Hh20Lh', '20Lh80Hh'}
%                        disp('20Hh80Hh here')
%                        if strcmp(temp_pressed1, temp_MCRESP_part1)==1
%                            RewContingPressed1_80_20{kkm,:}=temp_position1;
%                        elseif strcmp(temp_pressed1, temp_MCRESP_part2)==1
%                           RewContingPressed1_80_20{kkm,:}=temp_position2;
%                        end           
%                    case '80Hh80Hh'
% %                        double_80_80(kkm)=temp_index;
% %                        [ temp_left, temp_right ] =  detect_left_right_vhf(kkm, temp_index, double_one_corr, temp_detposition );
% %                        double_80_80_left(kkm)=temp_left;
% %                        double_80_80_right(kkm)=temp_right;
% %                        clear temp_left temp_right
%                    case '20Lh20Lh'
% %                        double_20_20(kkm)=temp_index;
% %                        [ temp_left, temp_right ] =  detect_left_right_vhf(kkm, temp_index, double_one_corr, temp_detposition );
% %                        double_20_20_left(kkm)=temp_left;
% %                        double_20_20_right(kkm)=temp_right;
% %                        clear temp_left temp_right
% %                end
% %                clear temp_rewpair temp_pressed1 temp_pressed2 temp_position1 temp_position2 temp_index %15.9.2016
% %            end % for kkm 
% %            clear kkm
% 
% 
% 
% count=0;
% for kk=1:length(RewContingPressed1_80_20); 
%     if strcmp(RewContingPressed1_80_20(kk,1), '80Hh')==1; 
%         count=count+1; 
%     end; 
% end; 
% disp(count);
% 
% Total_percentage80=count*100/length(index8020); 
% disp(['Total_percentage of 80Hh is: ' num2str(Total_percentage80)])
% 
% 
% count=0;
% for kk=1:length(RewContingPressed1_80_20); 
%     if strcmp(RewContingPressed1_80_20(kk,1), '20Lh')==1; 
%         count=count+1; 
%     end; 
% end; 
% disp(count);
% 
% Total_percentage20=count*100/length(index8020); 
% disp(['Total_percentage of 20Hh is: ' num2str(Total_percentage20)])