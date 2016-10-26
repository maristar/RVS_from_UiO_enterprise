function RVS_BaseTest_plotter_80_20_2080_N2pc(good_subj_list, Pooled_means, temp22, Sessions, timeVec_msec)

%27,9,2016 TODO to be improved.
%   Detailed explanation goes here
% Made it to calculate the grandaverage in Base and Test in contra and
% means. Corrected to just plot the conta vs the ipsi.

orientation_text={'means_contra', 'means_ipsi'};
orientation_text_char=char(orientation_text);
fieldnames_new_temp={'case20', 'case80'};

% We need to calculate the GA for the N2pc, 07.10.2016
% Initialize it. 
for yyy=1:length(Sessions) % 4
    session_temp=Sessions(yyy);
    session_temp_char=char(session_temp);
    % Fieldnames_temp is defined above the start of the loop
    for nnn=1:length(fieldnames_new_temp)
        fieldname_temp_1_char2=char(fieldnames_new_temp{nnn});
        for gg=1:length(orientation_text);
            orientation_text_char=char(orientation_text{gg});
            dataGA_BT_N2pc.(session_temp_char).(fieldname_temp_1_char2).(orientation_text_char)=[];
        end
    end
end
clear yyy nnn gg session_temp session_temp_char fieldnames_t

%% Fill the structure with Grand Average, with contra and ipsi. 
counter=0;
for jjk=[good_subj_list]
    Folder_name=temp22{jjk,:};
    disp([' -- ' (Folder_name)])
    for kk=1:length(Sessions) % For every session
        session_temp=Sessions(kk);
        session_temp_char=char(session_temp); 
        disp([' ---- ' (session_temp_char)])
        % Get the fields automatically from Pooled_means.
        sample=Pooled_means.(Folder_name).(session_temp_char);
        fieldnames_temp=fieldnames(sample);
        % For every field, give a new name and continue
        for ffk=1:length(fieldnames_temp)
            fieldnames_temp_1=fieldnames_temp(ffk);
            fieldnames_temp_1_char=char(fieldnames_temp_1);
            disp([' ------ ' (fieldnames_temp_1_char)])
            % rename the double_80_20_20_left_corr and double_80_20_20_right_corr to case20 and analogous for the case80 
            if strcmp(fieldnames_temp_1_char(8:15),'80_20_20')==1,
                fieldname_new='case20';
            elseif strcmp(fieldnames_temp_1_char(8:15),'80_20_80')==1,
                fieldname_new='case80';
            end
            disp(fieldname_new)
            counter=counter+1;
            for gg=1%:length(orientation_text)
                % We know there are two orientations:
                orientation_temp_contra=orientation_text{1,gg};
                orientation_temp_contra_char=char(orientation_temp_contra);   
                    
                orientation_temp_ipsi=orientation_text{1,gg+1};
                orientation_temp_ipsi_char=char(orientation_temp_ipsi);
                
                % Get the data ftom Pooled_means
                temp_means_data_contra=Pooled_means.(Folder_name).(session_temp_char).(fieldnames_temp_1_char).(orientation_temp_contra_char);
                temp_means_data_ipsi=Pooled_means.(Folder_name).(session_temp_char).(fieldnames_temp_1_char).(orientation_temp_ipsi_char);
                % Make the GA
                % First for the contra.
                dataGA_BT_N2pc.(session_temp_char).(fieldname_new).(orientation_temp_contra_char)=cat(3, dataGA_BT_N2pc.(session_temp_char).(fieldname_new).(orientation_temp_contra_char), temp_means_data_contra);                 
                % Second for the ipsi. 
                dataGA_BT_N2pc.(session_temp_char).(fieldname_new).(orientation_temp_ipsi_char)=cat(3, dataGA_BT_N2pc.(session_temp_char).(fieldname_new).(orientation_temp_ipsi_char), temp_means_data_ipsi);                 
            end
        end % for fieldnames
    end % for sessions
end % for subjects 
clear gg ffk kk jjk

%% Plot the GAs differences for Base 20, Base80, Test20, Test80
fig_count=1;
for kk=1:length(Sessions) % For every session
        session_temp=Sessions(kk);
        session_temp_char=char(session_temp); 
        disp([' ---- ' (session_temp_char)])
        for jjk=1%:length(fieldnames_new_temp)% |case 20 case 80
            fieldnames_new_temp_1=fieldnames_new_temp{:, jjk};
            fieldnames_new_temp_2=fieldnames_new_temp{:, jjk+1};
            
            % For 20
            temp_contra=dataGA_BT_N2pc.(session_temp_char).(fieldnames_new_temp_1).means_contra;
            temp_contra=squeeze(temp_contra);
            temp_mean_contra=mean(temp_contra, 2);

            temp_ipsi=dataGA_BT_N2pc.(session_temp_char).(fieldnames_new_temp_1).means_ipsi;
            temp_ipsi=squeeze(temp_ipsi);
            temp_mean_ipsi=mean(temp_ipsi, 2);
            
            temp_mean_diff=temp_mean_contra - temp_mean_ipsi;
            
            % For 80
            temp_contra2=dataGA_BT_N2pc.(session_temp_char).(fieldnames_new_temp_2).means_contra;
            temp_contra2=squeeze(temp_contra2);
            temp_mean_contra2=mean(temp_contra2, 2);

            temp_ipsi2=dataGA_BT_N2pc.(session_temp_char).(fieldnames_new_temp_2).means_ipsi;
            temp_ipsi2=squeeze(temp_ipsi2);
            temp_mean_ipsi2=mean(temp_ipsi2, 2);
            
            temp_mean_diff2=temp_mean_contra2 - temp_mean_ipsi2;
            
            fig_count=fig_count+1;
            disp(['Figure count is ' num2str(fig_count+1)]);
            fig=figure; plot(timeVec_msec, temp_mean_diff,'b'); hold on; plot(timeVec_msec, temp_mean_diff2,'r');
            %ylim[()]
            title([ 'Differences of GA for N2pc contra-ispi ' session_temp_char ',' char(fieldnames_new_temp_2)]);
            legend('diff 20', 'diff 80');
            temp_save_name_fig=[ ' Differences_GA_N2pc' session_temp_char '_' char(fieldnames_new_temp_2)];
            xlabel('Time (ms)'); ylabel('Amplitude (uV)')
            
            saveas(fig, temp_save_name_fig, 'png');
            saveas(fig, temp_save_name_fig, 'fig');
        end % for fieldnames 
            clear session_temp_char session_temp
end % For Sessions 

%% Plot the GAs contra and ipsi in one plot for Base 20, Base80, and one plot for contra and ipsi for Test20, Test80
fig_count=1;
for kk=1:length(Sessions) % For every session
        session_temp=Sessions(kk);
        session_temp_char=char(session_temp); 
        disp([' ---- ' (session_temp_char)])
        for jjk=1%:length(fieldnames_new_temp)% |case 20 case 80
            fieldnames_new_temp_1=fieldnames_new_temp{:, jjk}; % case 20
            fieldnames_new_temp_2=fieldnames_new_temp{:, jjk+1}; % case 80
            
            % For 20
            temp_contra=dataGA_BT_N2pc.(session_temp_char).(fieldnames_new_temp_1).means_contra;
            temp_contra=squeeze(temp_contra);
            temp_mean_contra=mean(temp_contra, 2);

            temp_ipsi=dataGA_BT_N2pc.(session_temp_char).(fieldnames_new_temp_1).means_ipsi;
            temp_ipsi=squeeze(temp_ipsi);
            temp_mean_ipsi=mean(temp_ipsi, 2);
            
                        
            % For 80
            temp_contra2=dataGA_BT_N2pc.(session_temp_char).(fieldnames_new_temp_2).means_contra;
            temp_contra2=squeeze(temp_contra2);
            temp_mean_contra2=mean(temp_contra2, 2);

            temp_ipsi2=dataGA_BT_N2pc.(session_temp_char).(fieldnames_new_temp_2).means_ipsi;
            temp_ipsi2=squeeze(temp_ipsi2);
            temp_mean_ipsi2=mean(temp_ipsi2, 2);
            
                     
            fig_count=fig_count+1;
            disp(['Figure count is ' num2str(fig_count+1)]);
            fig=figure; plot(timeVec_msec, temp_mean_contra,'b'); hold on; plot(timeVec_msec, temp_mean_ipsi,'r');
            hold on; plot(timeVec_msec, temp_mean_contra2, 'b--'); hold on; plot(timeVec_msec, temp_mean_ipsi2, 'r--');
            %ylim[()]
            title([ 'GA for N2pc contra-ispi ' session_temp_char ',' char(fieldnames_new_temp_2)]);
            legend('case 20 contra', 'case 20 ipsi', 'case 80 contra', 'case 80 ipsi');
            temp_save_name_fig=[ ' GA_N2pc' session_temp_char '_' 'case 20_case80_contra_ipsi_11_10'];
            xlabel('Time (ms)'); ylabel('Amplitude (uV)')
            ylim([-6 15])
            saveas(fig, temp_save_name_fig, 'png');
            saveas(fig, temp_save_name_fig, 'fig');
        end % for fieldnames 
            clear session_temp_char session_temp
end % For Sessions 


%      %%  Plot for every subject
%      counter=0;
% for jjk=[good_subj_list]
%     Folder_name=temp22{jjk,:};
%     disp([' -- ' (Folder_name)])
%     for kk=1:length(Sessions) % For every session
%         session_temp=Sessions(kk);
%         session_temp_char=char(session_temp); 
%         disp([' ---- ' (session_temp_char)])
%         % Get the fields automatically from Pooled_means.
%         sample=Pooled_means.(Folder_name).(session_temp_char);
%         fieldnames_temp=fieldnames(sample);
%         % For every field, give a new name and continue
%         for ffk=1%:length(fieldnames_temp)
%             fieldnames_temp_1=fieldnames_temp(ffk);
%             fieldnames_temp_1_char=char(fieldnames_temp_1);
%             fieldnames_temp_2=fieldnames_temp(ffk+1);
%             fieldnames_temp_2_char=char(fieldnames_temp_2);
%             disp([' ------ ' (fieldnames_temp_1_char)])
%                    fig=figure; 
%                    set(gca,'colororder',[0 0 1; 1 0 0],'nextplot','add'); 
%                    set(gca,'fontsize', 16);
%                    plot(timeVec_msec, temp_means_data_contra); hold on; plot(timeVec_msec, temp_means_data_ipsi);
%                    text_title1=[Folder_name(12:14) '_' session_temp_char '_' fieldname_new '_N2pc'  ];
%                    text_title2=strrep(text_title1, '_', '-');
%                    title(text_title2);
%                    xlabel('Time (ms)'); ylabel('Amplitude (uV)')
%                    legend('means contra', 'means ipsi', 'Location', 'best');             
%                    saveas(fig, text_title1, 'fig');
%                    %saveas(fig, text_title1, 'fig');
%                    
%                 clear orientation_temp_contra ...
%                     orientation_temp_contra_char ...
%                     orientation_temp_ipsi orientation_temp_ipsi_char ...
%                     temp_means_data_contra temp_means_data_ipsi
%                end % for orientation contra, ipsi 
%         clear fieldname_new fieldname_temp_1 fieldname_temp_1_char 
%         end % for fieldnames in Pooled_data               
%         clear session_temp session_temp_char
%      end % Sessions
%      clear Folder_name
% end % For Subjects 

%%%
%% Plotting contra vs ipsi for all subjects DOES NOT WORK 
counter=0;
for jjk=[good_subj_list]
    Folder_name=temp22{jjk,:};
    for kk=1:length(Sessions) % For every session
        session_temp=Sessions(kk);
        session_temp_char=char(session_temp); 
        % Get the fields automatically from Pooled_means.
        sample=Pooled_means.(Folder_name).(session_temp_char);
        fieldnames_temp=fieldnames(sample);
        % For every field, give a new name and continue
        for ffk=1%:length(fieldnames_temp)
            fieldnames_temp_1=fieldnames_temp(ffk);
            fieldnames_temp_1_char=char(fieldnames_temp_1);
            fieldnames_temp_2=fieldnames_temp(ffk+1);
            fieldnames_temp_2_char=char(fieldnames_temp_2);
            % rename the double_80_20_20_left_corr and double_80_20_20_right_corr to case20 and analogous for the case80 
            if strcmp(fieldnames_temp_1_char(8:15),'80_20_20')==1,
                fieldname_new='case20';
            elseif strcmp(fieldnames_temp_1_char(8:15),'80_20_80')==1,
                fieldname_new='case80';
            end
            disp(fieldname_new)
            counter=counter+1;
            for gg=1%:length(orientation_text)
                % We know there are two orientations:
                orientation_temp_contra=orientation_text{1,gg};
                orientation_temp_contra_char=char(orientation_temp_contra);   
                    
                orientation_temp_ipsi=orientation_text{1,gg+1};
                orientation_temp_ipsi_char=char(orientation_temp_ipsi);
                
                % Get the data ftom Pooled_means
                temp_means_data_contra=Pooled_means.(Folder_name).(session_temp_char).(fieldnames_temp_1_char).(orientation_temp_contra_char);
                temp_means_data_ipsi=Pooled_means.(Folder_name).(session_temp_char).(fieldnames_temp_1_char).(orientation_temp_ipsi_char);
                %temp_means_diff_contra-ipsi=temp_means_data_contra-temp_means_data_ipsi; 
                %                 % Make the GA
%                 % First for the contra.
%                 dataGA_BT_N2pc.(session_temp_char).(fieldname_new).(orientation_temp_contra_char)=cat(3, dataGA_BT_N2pc.(session_temp_char).(fieldname_new).(orientation_temp_contra_char), temp_means_data_contra);                 
%                 % Second for the ipsi. 
%                 dataGA_BT_N2pc.(session_temp_char).(fieldname_new).(orientation_temp_ipsi_char)=cat(3, dataGA_BT_N2pc.(session_temp_char).(fieldname_new).(orientation_temp_ipsi_char), temp_means_data_ipsi);                 

                % Plot for every subject
                   fig=figure(counter); 
                   set(gca,'colororder',[0 0 1; 1 0 0],'nextplot','add'); 
                   set(gca,'fontsize', 16);
                   plot(timeVec_msec, temp_means_data_contra); hold on; plot(timeVec_msec, temp_means_data_ipsi);
                   text_title1=[Folder_name(12:14) '_' session_temp_char '_' fieldname_new '_N2pc_11_10'  ];
                   text_title2=strrep(text_title1, '_', '-');
                   title(text_title2);
                   xlabel('Time (ms)'); ylabel('Amplitude (uV)')
                   legend('means contra', 'means ipsi', 'Location', 'best');             
                   saveas(fig, text_title1, 'tiff');
                   %saveas(fig, text_title1, 'fig');
                   close(fig);
                clear orientation_temp_contra ...
                    orientation_temp_contra_char ...
                    orientation_temp_ipsi orientation_temp_ipsi_char ...
                    temp_means_data_contra temp_means_data_ipsi
               end % for orientation contra, ipsi 
        clear fieldname_new fieldname_temp_1 fieldname_temp_1_char 
        end % for fieldnames in Pooled_data               
        clear session_temp session_temp_char
     end % Sessions
     clear Folder_name
end % For Subjects 
% 
% 
% 


end
% 
