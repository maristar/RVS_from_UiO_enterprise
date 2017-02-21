% This program makes the butterfly plot from the GA and then plots the
% topoplots for the desired time windows. 
% It has to load the grandaverage data from exa,.-
% <FiguresGA_RVS_FRN_noparts_accLuck -TODO to fix that. 
% 17.10.2016 MLS

% First you have to load the dataset in MATLAB AND eegLAB

text_for_condition='double_report_base';
text_for_condition='stim 20 '
text_for_condition='stim 80 - 20 '
% Part 1. Butterfly plot
[nchan ntimepoints]=size(EEG.data);
data=EEG.data;
fig3=figure;

for kk=1:nchan
    tempchan=data(kk,:);
plot(timeVec_msec, tempchan); ylim([-12 14]);set(gca,'fontsize', 16); hold on;
end
clear kk
xlabel('Time(ms)'); ylabel('Amplitude (uV)'); title(['GA ' text_for_condition]);
temp_save_name_fig=['Butterfly_plot_' text_for_condition];
saveas(fig3, temp_save_name_fig, 'tiff');
saveas(fig3, temp_save_name_fig, 'fig');
%close(fig3)


%% Define time limits and ask for them 
name_component='P3b, peak 700 msec';
timeinmsec=700.00;
topoplots_maria(name_component, timeinmsec, timeVec_msec, EEG, text_for_condition)


%% Define time limits and ask for them 
name_component='P3a';
timeinmsec=351;
topoplots_maria(name_component, timeinmsec, timeVec_msec, EEG, text_for_condition)


%% Define time limits and ask for them 
name_component='N1';
text_for_condition='Test'
timeinmsec=175.8;
topoplots_maria(name_component, timeinmsec, timeVec_msec, EEG, text_for_condition)