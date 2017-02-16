function [ latency_max  amplitude_max electrode_max] = RVS_find_max_fromGA( data, chanlocs, timeVec_msec );
%Finds where is the max amplitude
%   This function gives the max amplitude and which electrode it comes from
%   input is data: chan x timepoints
%   chanlocs from EEG.chanlocs
%   timeVec_msec is the
% Find max value
amplitude_max=max(max(data));
% Find indexes of max data column is channel and 
[index_chan index_time]=find(data==amplitude_max);

latency_max=timeVec_msec(index_time);
electrode_max=chanlocs(index_chan).labels;

display(['Maximum electrode: ' electrode_max ' Maximum amplitude (uV): ' num2str(amplitude_max) ' at (msec): ' num2str(latency_max) ])

end

