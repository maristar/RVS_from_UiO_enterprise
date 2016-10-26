% Analyzing EEG dataset for RVS - Base - Test data. 
% 30 November 2015, Maria L. Stavrinou at PSI, UiO
% 14 January 2016, MLS
% 17 June 2016 making a loop for all subjects. Including only a subset of
% triggers. Final results.
% Revising it for use 15. Sept. 2016. Updating the comments with Olga and 
% dividing in left and right visual hemifield. 
clear all 
close all 
tic
Raw_Path='Z:\RVS\RAW_datasets\DataRVS\';

Analyzed_path='Z:\RVS\Analyzed_datasets\';

%% Define list of folders 
cd(Raw_Path)
listing_raw=dir('RVS_Subject*');
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
end

%% Define Sessions
Sessions={'Base', 'Test'};

%% Start the new part 
% Define which subjects to keep in the analysis for FRN here
bad_subject_list=[7, 9, 13, 16, 17, 19, 20, 24, 26, 30];
good_subj_list=[]; 
for ssf=1:Num_folders, 
    if ~ismember(ssf, bad_subject_list), 
        good_subj_list=[good_subj_list ssf]; 
    end; 
end
clear ssf 

% Define sessions
Sessions={'Base', 'Test'};
%% Start load
for mkk=1:length(good_subj_list)
    kk=good_subj_list(mkk);
    Folder_name=temp22{kk,:};
    % Declare on which subject we are working 
    fprintf(' ***  Working on subject %s: %s\n', num2str(mkk), Folder_name)
    % IMPORTANT_NOTICE: It has to start from number 4 and down because the 101-103 datasets have
    % not TOTACC in their T table.
    % Work for each session independently 
    for jj=1:length(Sessions)
        session_temp=Sessions{jj};
        cd(Raw_Path);
        cd(temp22{kk,:});
        cd(temp22{kk,:});
        % Define path with folder name 
        Analyzed_path_folder=[Analyzed_path temp22{kk,:} '\'  session_temp '\'];
        Raw_path_folder=[Raw_Path temp22{kk,:} '\' temp22{kk,:} '\' session_temp '\'];
        
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
        % To see the heaader of the column: disp(T(1, 107));
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
        TotAcc=T{2:end, 130};
        
        % Calculate the total number of triggers we have 
        Num_triggers=size(Mask_CRESP); 
        Num_triggers=Num_triggers(1);
        
        % {'Detection';'NONE';'NONE';'NONE';'NONE';'NONE';'NONE';'NONE';'NONE';'NONE';'d';'NONE';'7'}
           Detection=T{2:end,49};
          % This is the pair that is presented
           RewPair=T(2:end, 104);
           % Which one they have found. If they found something wrong, this
           % column showns ? so, nothing. 
           DetRewCont=T(2:end, 51);
           
          % This is the position in space, for left - right visual
          % hemifield
           DetPosition=T(2:end, 50); % '1','2', etc, '8'; 
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
        clear single_index_temp double_index_temp
        %% Look at Single target accuracy. So we find from single report how many are correct.
         % Find accuracies
         % Find accuracy of single target. 
         % Go through the indexes of single accuracy and check them for 1 correct.
         % Use the total accuracy 'TotAcc'.
         single_indexes_correct=zeros(1, length(single_index));
             for kkt=1:length(single_index), 
                 temp_index=single_index(kkt);
                 % 15.9.2016. It turned out that TotAcc{temp_index,1} for
                 % kk=1:3 is a number, so we have to turn it into a string. 
                 % For 4-3nd indexes? it is a char
                 %TODO to make a loop to differential these:
                 if kk>3
                     temp_acc=TotAcc{temp_index,1};
                 elseif kk<4
                     temp_acc=num2str(TotAcc{temp_index,1}); 
                 end
                 if strcmp(temp_acc, '1')==1
                     single_indexes_correct(kkt)=temp_index;
                 elseif strcmp(temp_acc, '0')==1
                     single_indexes_wrong(kkt)=temp_index;
                 end;
                 clear temp_acc
             end
            % Find only non zeros
            single_acc_indexes=single_indexes_correct(single_indexes_correct>0);

            % Find percentages
            single_acc_percentage=length(single_acc_indexes)*100/length(single_index);
            disp('Single correct percentage : ')
            disp(single_acc_percentage)

            single_acc_indexes_wrong=single_indexes_wrong(single_indexes_wrong>0);
           
            %% From double stimulus -> see double report, single report, null report. 
           %  presentation select all three categories BOTH; ONE('g' or '7' etc); NONE 
           % Use Detection from T table
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
               clear temp_detection temp_index
           end
           clear kkm
           
           % Alternatively, go to TargetCond, see if it is '2' (=double
           % target condition), then see the TotAcc if it is '1', then this
           % means single report. If it is '0' this is null-report. If it
           % is '2' then it is double report. This is another way. 
           
           % Double report
           double_both_corr=double_both(double_both>0);
           Number_double_both=length(double_both_corr);
           percentage_double_both=Number_double_both*100/length(double_index);
           disp(['Detection Double percentage (%): ' num2str(percentage_double_both)]);
           
           % Null report
           double_none_corr=double_none(double_none>0);
           Number_double_none=length(double_none_corr);
           percentage_double_none=Number_double_none*100/length(double_index);
           disp(['Detection None percentage (%): ' num2str(percentage_double_none)]);
            
           % Single report
           double_one_corr=double_one(double_one>0); % TODO is it an index 15.9.2016?
           Number_double_one=length(double_one_corr);
           percentage_double_one=Number_double_one*100/length(double_index);
           disp(['Detection One percentage (%): ' num2str(percentage_double_one)]);
           clear Number_double_one Number_double_none Number_double_both
           
           %% From the Double condition (Stimulus), 1 detected (single report), 
           %  extract more categories
           % From the double condition, detect those that are in the 6 category
           % 50Hh-50Lh(RewPair,Var 104), 80-80, 20-20, 50-80, 50-20, 80-20
           % From those separate those that have detected the Hh (High hemifield) or Lh (Low hemifield), for ex. 
           % 50-50-50Hh or 50-50-50Lh (From DetRewCont, T(2:end, 51)). For
           % half of the subjects, we have Hh the right hemifield, for the
           % other half it is the left hemifield.
           
           % This is the pair that is presented
           RewPair=T(2:end, 104);
           % Which one they have found. If they found something wrong, this
           % column showns ? so, nothing. 
           DetRewCont=T(2:end, 51);
           
          % This is the position in space, for left - right visual
          % hemifield
           DetPosition=T(2:end, 50); % '1','2', etc, '8'; 
           %% Definitions
           % Case 50-50
           % Level 1
           double_50_50=zeros(1, length(double_one_corr));

           %Level 2
           double_50L_50H=zeros(1, length(double_one_corr));
           % Level 3
           double_50L_50H_50L=zeros(1, length(double_one_corr));
           double_50L_50H_50H=zeros(1, length(double_one_corr));

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
           
           double_80_20_80_left=zeros(1, length(double_one_corr));
           double_80_20_80_right=zeros(1, length(double_one_corr));
           double_80_20_20_left=zeros(1, length(double_one_corr));
           double_80_20_20_right=zeros(1, length(double_one_corr));
        %% Geting the triggers
           for kkm=1:length(double_one_corr),
               temp_index=double_one_corr(kkm);
               temp_rewpair=RewPair{temp_index,1};% '50Lh20Lh'
               temp_detrewcont=DetRewCont{temp_index,1};
               temp_detposition=DetPosition{temp_index, 1};
               switch temp_rewpair{:}
                   % Choose only some combinations
                   case {'50Lh50Hh', '50Hh50Lh'}
                       double_50L_50H(kkm)=temp_index;
                       if strcmp(temp_detrewcont, '50Lh')==1
                           double_50L_50H_50L(kkm)=temp_index;
                           [ temp_left, temp_right ] =  detect_left_right_vhf(kkm, temp_index, double_one_corr, temp_detposition );
                           double_50L_50H_50L_left(kkm)=temp_left;
                           double_50L_50H_50L_right(kkm)=temp_right;
                           clear temp_left temp_right
                       elseif strcmp(temp_detrewcont, '50Hh')==1
                            double_50L_50H_50H(kkm)=temp_index;
                            [ temp_left, temp_right ] =  detect_left_right_vhf(kkm, temp_index, double_one_corr, temp_detposition );
                            double_50L_50H_50H_left(kkm)=temp_left;
                            double_50L_50H_50H_right(kkm)=temp_right;
                            clear temp_left temp_right
                       end
                   case {'80Hh20Lh', '20Lh80Hh'}
                       double_80_20(kkm)=temp_index;
                       if strcmp(temp_detrewcont, '80Hh')==1
                           double_80_20_80(kkm)=temp_index;
                           [ temp_left, temp_right ] =  detect_left_right_vhf(kkm, temp_index, double_one_corr, temp_detposition );
                           double_80_20_80_left(kkm)=temp_left;
                           double_80_20_80_right(kkm)=temp_right;
                           clear temp_left temp_right
                       elseif strcmp(temp_detrewcont, '20Lh')==1
                           double_80_20_20(kkm)=temp_index;
                           [ temp_left, temp_right ] =  detect_left_right_vhf(kkm, temp_index, double_one_corr, temp_detposition );
                           double_80_20_20_left(kkm)=temp_left;
                           double_80_20_20_right(kkm)= temp_right;
                           clear temp_left temp_right
                       end           
                   case '80Hh80Hh'
                       double_80_80(kkm)=temp_index;
                       [ temp_left, temp_right ] =  detect_left_right_vhf(kkm, temp_index, double_one_corr, temp_detposition );
                       double_80_80_left(kkm)=temp_left;
                       double_80_80_right(kkm)=temp_right;
                       clear temp_left temp_right
                   case '20Lh20Lh'
                       double_20_20(kkm)=temp_index;
                       [ temp_left, temp_right ] =  detect_left_right_vhf(kkm, temp_index, double_one_corr, temp_detposition );
                       double_20_20_left(kkm)=temp_left;
                       double_20_20_right(kkm)=temp_right;
                       clear temp_left temp_right
               end
               clear temp_rewpair temp_detrewcont temp_detposition %15.9.2016
           end % for kkm double_one_corr
           clear kkm

           %% Keep only the indexes and kick the zeros out.
           double_50_50_corr=double_50_50(double_50_50>0);
           clear double_50_50

           % Level 2 (and 1 for 80-20, 80-80, 20-20)
           double_50L_50H_corr=double_50L_50H(double_50L_50H>0);
           double_50L_50H_50L_corr=double_50L_50H_50L(double_50L_50H_50L>0);
           double_50L_50H_50H_corr=double_50L_50H_50H(double_50L_50H_50H>0);
           double_50L_50H_50L_left_corr=double_50L_50H_50L_left(double_50L_50H_50L_left>0);
           double_50L_50H_50L_right_corr=double_50L_50H_50L_right(double_50L_50H_50L_right>0);
           double_50L_50H_50H_left_corr=double_50L_50H_50H_left(double_50L_50H_50H_left>0);
           double_50L_50H_50H_right_corr=double_50L_50H_50H_right(double_50L_50H_50H_right>0);
                      
           double_80_20_corr=double_80_20(double_80_20>0);
           double_80_20_80_corr=double_80_20_80(double_80_20_80>0);
           double_80_20_20_corr=double_80_20_20(double_80_20_20>0);
           
           double_80_20_80_left_corr=double_80_20_80_left(double_80_20_80_left>0);
           double_80_20_80_right_corr=double_80_20_80_right(double_80_20_80_right>0);
           double_80_20_20_left_corr=double_80_20_20_left(double_80_20_20_left>0);
           double_80_20_20_right_corr=double_80_20_20_right(double_80_20_20_right>0);
                     
           double_80_80_corr=double_80_80(double_80_80>0);
           double_80_80_left_corr=double_80_80_left(double_80_80_left>0);
           double_80_80_right_corr=double_80_80_right(double_80_80_right>0);
           
           double_20_20_corr=double_20_20(double_20_20>0);
           double_20_20_left_corr=double_20_20_left(double_20_20_left>0);
           double_20_20_right_corr=double_20_20_right(double_20_20_right>0);
           clear double_80_80 double_20_20
            clear double_80_20 ...
                double_80_20_80 ...
                double_80_20_20 ...
                double_80_20_80_right ...
                double_80_20_80_left ...
               double_80_20_20_right ...
               double_80_20_20_left
           clear double_50L_50H ...
               double_50L_50H_50H ...
               double_50L_50H_50L ...
               double_50L_50H_50L_right ...
               double_50L_50H_50L_left ...
               double_50L_50H_50H_left 
           %% Right - Left visual hemifield of the detected target!!!- 15.9.2016
           % From Double condition, one target, just detect (for the N2pc) the right visual
           % hemifield target detected or the left visual hemifield target
           % detected. Afterwards see notes for N2pc calculated based on Luck
           % and not based on Kiss!!!

           % This is the position in space
           %  DetPosition=T(2:end, 50); defined above

            % Define an empty matric: left visual hemifield,
            % double_one_left_vhf
            % and right visual hemifield: double_one_right_vhf
            double_one_left_vhf=zeros(1, length(double_one_corr));
            double_one_right_vhf=zeros(1, length(double_one_corr));
            % Geting the triggers
           for kkb=1:length(double_one_corr),
               temp_index=double_one_corr(kkb);
               temp_detposition=DetPosition{temp_index,1};% '1'         
               [left_vhf, right_vhf]=detect_left_right_vhf(kkb, temp_index, double_one_corr, temp_detposition );
               double_one_left_vhf(kkb)=left_vhf;
               double_one_right_vhf(kkb)=right_vhf;
               clear left_vhf right_vhf
           end
           clear kkb
            %Now we have to get rid of the zeros
            double_one_left_vhf_corr=double_one_left_vhf(double_one_left_vhf>0);
            clear double_one_left_vhf
            double_one_right_vhf_corr=double_one_right_vhf(double_one_right_vhf>0);
            clear double_one_right_vhf
            % Fixed 16.09.2016 MLS
            
            
            %% Detect hemifield -15.9.2016 High or Low
            % >Find which from double condition, single report, have found the
            % High hemifield or the Low hemifield.
            double_one_Low_hemifield=zeros(1, length(double_one_corr));
            double_one_High_hemifield=zeros(1, length(double_one_corr));

            % We will need this DetRewCont=T(2:end, 51);
            % to see what they have chosen. 

            for kkg=1:length(double_one_corr),
                   temp_index=double_one_corr(kkg);
                   temp_rewpair=RewPair{temp_index,1};% '50Lh20Lh'
                   temp_detrewcont=DetRewCont{temp_index,1};
                   First_Letter=temp_rewpair{1,1}(3);
                   Second_Letter=temp_rewpair{1,1}(7);
                   Two_Letters=[First_Letter Second_Letter];
                   switch Two_Letters
                       case {'LH', 'HL'}      
                           %if strfind(Two_Letters, 'L')>0
                           if strcmp(temp_detrewcont{1,1}(3),'L')==1
                            double_one_Low_hemifield(kkg)=temp_index;
                            % Add to separate left and right visual hemifields
                            [temp_left_vhf, temp_right_vhf]=detect_left_right_vhf(kkg, temp_index, double_one_corr, temp_detposition );
                            double_one_Low_hemifield_left_vhf(kkg)=temp_left_vhf;
                            double_one_Low_hemifield_right_vhf(kkg)=temp_right_vhf;
                            clear temp_left_vhf temp_right_vhf
                           elseif strcmp(temp_detrewcont{1,1}(3),'H')==1 
                               double_one_High_hemifield(kkg)=temp_index;
                            % Add to separate left and right visual hemifields
                            [temp_left_vhf, temp_right_vhf]=detect_left_right_vhf(kkg, temp_index, double_one_corr, temp_detposition );
                            double_one_High_hemifield_left_vhf(kkg)=temp_left_vhf;
                            double_one_High_hemifield_right_vhf(kkg)=temp_right_vhf;
                            clear temp_left_vhf temp_right_vhf
                           end
                   end
            end
            clear kkg

            double_one_Low_hemifield_corr=double_one_Low_hemifield(double_one_Low_hemifield>0);
            double_one_High_hemifield_corr=double_one_High_hemifield(double_one_Low_hemifield>0);
            
            double_one_Low_hemifield_left_vhf_corr=double_one_Low_hemifield_left_vhf(double_one_Low_hemifield_left_vhf>0);
            double_one_Low_hemifield_right_vhf_corr=double_one_Low_hemifield_right_vhf(double_one_Low_hemifield_right_vhf>0);
            double_one_High_hemifield_left_vhf_corr=double_one_High_hemifield_left_vhf(double_one_High_hemifield_left_vhf>0);
            double_one_High_hemifield_right_vhf_corr=double_one_High_hemifield_right_vhf(double_one_High_hemifield_right_vhf>0);
            clear double_one_High_hemifield ...
                double_one_High_hemifield_left_vhf ...
                double_one_Low_hemifield_right_vhf ...
                double_one_Low_hemifield
                
        %TODO exei problima. 
        %% Make a directory to save all the relevant triggers
        cd(Analyzed_path_folder) 
        mkdir('Triggers')
        cd Triggers
        % delete *.txt
       % Create_triggers_in_txt(name, index_trigger_X_final)

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

        create_triggers_in_txt('double_80_80_corr', double_80_80_corr)
        create_triggers_in_txt('double_20_20_corr', double_20_20_corr)

        
        %% Create triggers for the High and Low hemifield
        create_triggers_in_txt('double_one_Low_hemifield_corr', double_one_Low_hemifield_corr);
        create_triggers_in_txt('double_one_High_hemifield_corr', double_one_High_hemifield_corr);
        
        create_triggers_in_txt('double_one_Low_hemifield_left_vhf_corr', double_one_Low_hemifield_left_vhf_corr);
        create_triggers_in_txt('double_one_Low_hemifield_right_vhf_corr', double_one_Low_hemifield_right_vhf_corr);
        
        create_triggers_in_txt('double_one_High_hemifield_left_vhf_corr', double_one_High_hemifield_left_vhf_corr);
        create_triggers_in_txt('double_one_High_hemifield_right_vhf_corr', double_one_High_hemifield_right_vhf_corr);
        
        %% Create triggers for the Left and Right visual hemifields 
        create_triggers_in_txt('double_one_left_vhf_corr', double_one_left_vhf_corr);
        create_triggers_in_txt('double_one_right_vhf_corr', double_one_right_vhf_corr);
       
            
        %% Create triggers for the 80_20_20_left and 80_20_80_left etc 15*9*2016
        create_triggers_in_txt('double_80_20_80_left_corr', double_80_20_80_left_corr);
        create_triggers_in_txt('double_80_20_80_right_corr', double_80_20_80_right_corr);
        
        create_triggers_in_txt('double_80_20_20_left_corr', double_80_20_20_left_corr);
        create_triggers_in_txt('double_80_20_20_right_corr', double_80_20_20_right_corr);
        
         create_triggers_in_txt('double_50L_50H_50L_left_corr', double_50L_50H_50L_left_corr);
         create_triggers_in_txt('double_50L_50H_50L_right_corr', double_50L_50H_50L_right_corr);
        
         create_triggers_in_txt('double_50L_50H_50H_left_corr', double_50L_50H_50L_left_corr);
         create_triggers_in_txt('double_50L_50H_50H_right_corr', double_50L_50H_50L_right_corr);
         
        create_triggers_in_txt('double_80_80_left_corr', double_80_80_left_corr);
        create_triggers_in_txt('double_80_80_right_corr', double_80_80_right_corr);
        
        create_triggers_in_txt('double_20_20_left_corr', double_20_20_left_corr);
        create_triggers_in_txt('double_20_20_right_corr', double_20_20_right_corr);
        
        clear double* %% TOFOFOFOOFOFOF
        
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
        clear jj

    end % For sessions 
end % For folders

%Cut

           % Level 1
        %    double_50_20_corr=double_50_20(double_50_20>0);
        %    double_80_50_corr=double_80_50(double_80_50>0);
        

        %    %Level 2 - wont use those 
        %    double_50L_50L=zeros(1, length(double_one_corr));
        %    %double_50H_50H=double_
        %    double_50H_50H=zeros(1, length(double_one_corr));



        %    double_80_50L_corr=double_80_50L(double_80_50L>0);
        %    double_80_50L_50L_corr=double_80_50L_50L(double_80_50L_50L>0);
        %    double_80_50L_80_corr=double_80_50L_80(double_80_50L_80>0);
        %    clear double_80_50L double_80_50L_50L double_80_50L_80
        %    
        %    double_80_50H_corr=double_80_50H(double_80_50H>0);
        %    double_80_50H_50H_corr=double_80_50H_50H(double_80_50H_50H>0);
        %    double_80_50H_80_corr=double_80_50H_80(double_80_50H_80>0);
        %    clear double_80_50H double_80_50H_50H double_80_50H_80

        
        %    double_50H_20_corr=double_50H_20(double_50H_20>0);
        %    double_50H_20_20_corr=double_50H_20_20(double_50H_20_20>0);
        %    double_50H_20_50H_corr=double_50H_20_50H(double_50H_20_50H>0);
        %    clear double_50H_20 double_50H_20_20 double_50H_20_50H
        %    
        %    double_50L_20_corr=double_50L_20(double_50L_20>0);
        %    double_50L_20_50L_corr=double_50L_20_50L(double_50L_20_50L>0);
        %    double_50L_20_20_corr=double_50L_20_20(double_50L_20_20>0);
        %    clear double_50L_20 double_50L_20_50L double_50L_20_20
        

        % create_triggers_in_txt('double_50H_20_corr', double_50H_20_corr)
        % create_triggers_in_txt('double_50H_20_50H_corr', double_50H_20_50H_corr)
        % create_triggers_in_txt('double_50H_20_20_corr', double_50H_20_20_corr)
        % 
        % create_triggers_in_txt('double_50L_20_corr', double_50L_20_corr)
        % create_triggers_in_txt('double_50L_20_50L_corr', double_50L_20_50L_corr)
        % create_triggers_in_txt('double_50L_20_20_corr', double_50L_20_20_corr)

        % create_triggers_in_txt('double_80_50L_corr', double_80_50L_corr)
        % create_triggers_in_txt('double_80_50L_50L_corr', double_80_50L_50L_corr)
        % create_triggers_in_txt('double_80_50L_80_corr', double_80_50L_80_corr)
        % 
        % create_triggers_in_txt('double_80_50H_corr', double_80_50H_corr)
        % create_triggers_in_txt('double_80_50H_50H_corr', double_80_50H_50H_corr)
        % create_triggers_in_txt('double_80_50H_80_corr', double_80_50H_80_corr);

        % create_triggers_in_txt('double_Low_hemif_corr', double_Low_hemif_corr);
        % create_triggers_in_txt('double_High_hemif_corr', double_High_hemif_corr);