% Plotter
% 21.9.2016 Maria Stavrinou
%  Arguments 
% Which_channel
% good_subj_list
% temp22
% trigger_type
% Mean_Subjects
% timeVec_msec
cd(Analyzed_path)
mkdir('FiguresGA_BT_double_report_new')
cd FiguresGA_BT_double_report_new

for kk=1:length(chanlocs)
    chan_names{kk,:}=chanlocs(kk).labels;
end
clear kk
chan_names=chan_names';

Which_channel='Fz'; 
Which_channel=char(Which_channel);

for kk=1:30,
if strcmp(chan_names{kk,:}, Which_channel)==1
    disp(num2str(kk))
    chan_index=kk;
end
end

close all

for kk=1:length(good_subj_list)
        kkh=good_subj_list(kk)
        Folder_name=temp22{kkh,:};
        session_temp=Sessions{:,jj}; 
        trigger_type='double_both_corr'
        temp_all_chan_base=Mean_Subjects.(Folder_name).Base.(trigger_temp_char);
        temp_all_chan_test=Mean_Subjects.(Folder_name).Test.(trigger_temp_char);
        temp_chan_base=temp_all_chan_base(chan_index,:);
        temp_chan_test=temp_all_chan_test(chan_index,:);
        fig=figure; 
        set(gca,'colororder',[0 0 1; 1 0 0],'nextplot','add'); % green 010
        set(gca,'fontsize', 16);
        plot(timeVec_msec, temp_chan_base, 'Linewidth', 2); hold on; 
        plot(timeVec_msec, temp_chan_test, 'Linewidth', 2,'LineStyle', '--'); 
        title([Folder_name '_' Which_channel])
        legend('double report Base', 'double report Test', 'Location', 'best');
        temp_save_name_fig=[chanlocs(chan_index).labels '_' Folder_name];
        saveas(fig, temp_save_name_fig, 'png');
        saveas(fig, temp_save_name_fig, 'fig');
end
