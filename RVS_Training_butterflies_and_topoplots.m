% This program makes the butterfly plot from the GA and then plots the
% topoplots for the desired time windows. 
% It has to load the grandaverage data from exa,.-
% 
% 17.10.2016 MLS

% First you have to load another dataset in MATLAB AND eegLAB, where you
% will take the channel locations. 
% Second you import the data saved as Matlab file (.mat) and add 
% 1) the sampling rate
% 2) the starting time of the epoch (for ex. -0.5 msec) 
% 3) the locations from the previous loaded dataset (for ex. 1)
% Edited 24.05.2017
% 
% text_for_condition='double_report_base';
% text_for_condition='stim 20 '
% text_for_condition='stim 80 - 20 '

%% Define the text_for_condition
text_for_condition='Probe AY'

% Part 1. Butterfly plot
[nchan ntimepoints]=size(EEG.data);
data=EEG.data;

fig3=figure;

for kk=1:nchan
    tempchan=data(kk,:);
plot(timeVec_msec, tempchan); 
ylim([-30 50]);set(gca,'fontsize', 16); hold on;
end
clear kk
xlabel('Time(ms)'); 
ylabel('Amplitude (uV)'); 
title(['GA ' text_for_condition]);
temp_save_name_fig=['Butterfly_plot_' text_for_condition];
saveas(fig3, temp_save_name_fig, 'tiff');
saveas(fig3, temp_save_name_fig, 'fig');
close(fig3)



%% TOPOPLOTS

%% Define time limits and ask for them 
name_component='N1 125ms';
timeinmsec=125;
topoplots_maria(name_component, timeinmsec, timeVec_msec, EEG, text_for_condition)

%% Define time limits and ask for them 
name_component='P2 187ms';
timeinmsec=187;
topoplots_maria(name_component, timeinmsec, timeVec_msec, EEG, text_for_condition)

% Define time limits and ask for them 
name_component='N2 339 ms';
timeinmsec=339;
topoplots_maria(name_component, timeinmsec, timeVec_msec, EEG, text_for_condition)


%% Define time limits and ask for them 
name_component='P3a 534ms';
timeinmsec=534;
topoplots_maria(name_component, timeinmsec, timeVec_msec, EEG, text_for_condition)

%% Define time limits and ask for them 
% name_component='LatePos1 695ms';
% timeinmsec=695;
% topoplots_maria(name_component, timeinmsec, timeVec_msec, EEG, text_for_condition)

%% Define time limits and ask for them 
name_component='LatePos2 808ms';
timeinmsec=808;
topoplots_maria(name_component, timeinmsec, timeVec_msec, EEG, text_for_condition)

%% Define time limits and ask for them 
name_component='Late Negativity 1250s';
timeinmsec=1250;
topoplots_maria(name_component, timeinmsec, timeVec_msec, EEG, text_for_condition)

% %% Define timei limits 
% name_component='CNV 1800ms';
% timeinmsec=1800;
% topoplots_maria(name_component, timeinmsec, timeVec_msec, EEG, text_for_condition)

