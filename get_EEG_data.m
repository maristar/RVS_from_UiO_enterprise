function [ data, meandata ] = get_EEG_data( temp_condition_char, part_name_temp_char, temp_sets, new_pre_trigger, new_post_trigger )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
        % Find where the condition starts in the filename
        B=strfind(temp_sets{:}, temp_condition_char);        
        %1
        name1=temp_sets{:}(1:(B-1));%'Subject_103_25_512_ch_DC_epochs_tr2_autotriggers'; %AX.txt;
        name2=[temp_condition_char]
        name3a=[part_name_temp_char];
        name3b='.set';
        name_file=[name1 name2 '_' name3a name3b]; %Subject101_Training1_512_ch_DC_epochs_50_triggers_Correct.txt3ch.set
        name_data=[name1 name2]; %Subject101_Training1_512_ch_DC_epochs_50_triggers_Correct
        
        AreWeRight=strcmp(name_file, temp_sets{:});
        if AreWeRight==1, 
            disp(['Working on file ' temp_sets{:} ' for condition ' temp_condition_char]);
            EEG = pop_loadset('filename',name_file,'filepath',Analyzed_path_folder);
            EEG = eeg_checkset( EEG );
            eeglab redraw
            
            % Select smaller timepoints 
            if (jjk==startfolder & mm==1 & kk==1)
                Fs=EEG.srate;
                pre_trigger = -EEG.xmin*1000; %msec  200 700
                post_trigger = EEG.xmax*1000; %msec 1100 1600
                data_pre_trigger = floor(pre_trigger*Fs/1000);
                data_post_trigger = floor(post_trigger*Fs/1000);
                timeVec = (-(data_pre_trigger):(data_post_trigger));
                timeVec = timeVec';
                timeVec_msec = timeVec.*(1000/Fs);
                
%                 new_pre_trigger=-200;
%                 new_post_trigger=700;
                find_new_pre_trigger=find(timeVec_msec>new_pre_trigger);
                new_pre_trigger_index=min(find_new_pre_trigger);
                
                find_new_post_trigger=find(timeVec_msec<new_post_trigger);
                new_post_trigger_index=max(find_new_post_trigger);
                disp('Epoch new shorter duration done')
                timeVec_msec_new=timeVec_msec(new_pre_trigger_index:new_post_trigger_index);
                clear timeVec_msec
                timeVec_msec=timeVec_msec_new;
                clear timeVec_msec_new;
            end
            
            % Save the EEG.data with smaller epoch

                
                        data=EEG.data(:, new_pre_trigger_index:new_post_trigger_index, :);
                        nchanGA=size(data, 1);
                     if nchanGA>5
                         
                         data2=EEG.data(numchans, new_pre_trigger_index:new_post_trigger_index, :);
                         clear data
                         data=data2;
                     end
                     
                    % Save the EEG.data with smaller epoch
                    data=EEG.data(:, new_pre_trigger_index:new_post_trigger_index, :); 
                    meandata=mean(data, 3);
        end
end

