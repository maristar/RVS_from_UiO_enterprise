function butterfies_and_topoplots( data, text_for_condition, chanlocs, timeVec_msec )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% This program makes the butterfly plot from the GA and then plots the
% topoplots for the desired time windows. 
% It has to load the grandaverage data from exa,.-
% <FiguresGA_RVS_FRN_noparts_accLuck -TODO to fix that. 
% 17.10.2016 MLS

% First you have to load the dataset in MATLAB AND eegLAB.

% Part 1. Butterfly plot
[nchan ntimepoints]=size(EEG.data);
data=EEG.data;
fig4=figure;

for kk=1:nchan
    tempchan=data(kk,:);
plot(timeVec_msec, tempchan); ylim([-12 14]);set(gca,'fontsize', 16); hold on;
end
clear kk
xlabel('Time(ms)'); ylabel('Amplitude (uV)'); title(['GA ' text_for_condition]);
temp_save_name_fig=['Butterfly_plot_' text_for_condition];
saveas(fig4, temp_save_name_fig, 'tiff');
saveas(fig4, temp_save_name_fig, 'fig');
%close(fig3)


%% Define time limits and ask for them 
name_component='P3b2, peak 519.5 msec';
timeinmsec=519.50;
topoplots_maria(name_component, timeinmsec, timeVec_msec, EEG, text_for_condition)


%% Define time limits and ask for them 
name_component='P3b1';
timeinmsec=386.7;
topoplots_maria(name_component, timeinmsec, timeVec_msec, EEG, text_for_condition)


%% Define time limits and ask for them 
name_component='N1';
text_for_condition='20L'
timeinmsec=164.1;
topoplots_maria(name_component, timeinmsec, timeVec_msec, EEG, text_for_condition)


%% Define time limits and ask for them 
name_component='N2';
text_for_condition='20L'
timeinmsec=296.9;
topoplots_maria(name_component, timeinmsec, timeVec_msec, EEG, text_for_condition)


%% Define time limits and ask for them 
name_component='N3';
text_for_condition='80H'
timeinmsec=468.8
topoplots_maria(name_component, timeinmsec, timeVec_msec, EEG, text_for_condition)


%% Define time limits and ask for them 
name_component='P1';
text_for_condition='20L'
timeinmsec=105.5;
topoplots_maria(name_component, timeinmsec, timeVec_msec, EEG, text_for_condition)


%% Define time limits and ask for them 
name_component='P2';
text_for_condition='20L'
timeinmsec=203.1;
topoplots_maria(name_component, timeinmsec, timeVec_msec, EEG, text_for_condition)

end

