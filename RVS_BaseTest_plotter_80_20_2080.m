function RVS_BaseTest_plotter_80_20_2080(good_subj_list channel_number, Folder_name )
%27,9,2016 TODO to be improved.
%   Detailed explanation goes here
the80=All_trials_subjects.RVS_Subject102.Test.double_80_20_20_right_corr;
the20=All_trials_subjects.RVS_Subject102.Test.double_80_20_20_right_corr;
figure; for jj=11, meantemp=mean(the80(jj, :,:),3); plot(meantemp); hold on; meantemp20=mean(the20(jj,:,:),3); plot(meantemp20, 'r'); end
title(Folder_name)

for jjk=[good_subj_list]
 % For every subject - folder
    Folder_name=temp22{jjk,:};
    T(jjk+1,1)={Folder_name(5:end)};
    column_counter=0;
    for kk=1:length(Sessions) % For every condition : Correct,Wrong, HR, LR
        session_temp=Sessions(kk);
        session_temp_char=char(session_temp); 
        sample=Peak_results.(Folder_name).(session_temp_char);
        fieldnames_temp=fieldnames(sample);
        for ffk=1:length(fieldnames_temp)
            fieldname_temp_1=fieldnames_temp(ffk);
            fieldname_temp_1_char=char(fieldname_temp_1);
                    for gg=1:length(orientation_text)
                    orientation_temp=orientation_text{1,gg};
                    orientation_temp_char=char(orientation_temp);
                    column_counter=column_counter+1;
                    %disp(column_counter)
                    temp_peak_results=Peak_results.(Folder_name).(session_temp_char).(fieldname_temp_1_char).(orientation_temp_char);
                    T(jjk+1,1+column_counter)=num2cell(temp_peak_results);
                end % for orientation contra, ipsi 
            end               
            end % if there is trigger there
       end % End for sessions 
% End for every subject



end

