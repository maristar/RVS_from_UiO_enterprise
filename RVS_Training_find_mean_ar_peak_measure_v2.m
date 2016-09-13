function [ final_peak_measure ] = RVS_Training_find_mean_ar_peak_measure_v2(meantempGo, peak_start_time, peak_end_time, Fs, timeVec_msec, type )
% The function gives the peak value. 
% Revised from previous version and it is advised to use that. 
% Was used in 22 June 2016, for Base-Test, double one corr, 4 rewlev
%
% Input arguments
% - meantempGo: the average waveform
% - peak_start_time: the time to start looking for the peak
% - peak_end_time: the time to stop looking for the peak
% - time_start: integer, in msec, time that the epoch begins for example
%               -200 msec
% - time_end: the time that the epoch ends in msec.
% - Fs: sampling frequency
% - timeVec_msec: the vector containing the time of the new (SOS!!!!!! NOTICE here) epoch.
% - type: a string containing the words 'min', 'max' or 'mean'. Then the program
%       finds the minimum or maximum or mean of the desired time interval as defined between
%       peak_start_time, peak_end_time  
    
% Output arguments
% - final_peak_measure: the peak value and the -/+2 values around the peak
% Maria L. Stavrinou


msec_to_dp=Fs/1000;
    
% %% Calculate here the new time vector, with the NEW time limits
%     pre_trigger = time_start; 
%     post_trigger = time_end;
%     data_pre_trigger = floor(pre_trigger*Fs/1000);
%     data_post_trigger = floor(post_trigger*Fs/1000);
%     timeVec = ((data_pre_trigger):(data_post_trigger));
%     timeVec = timeVec';
%     timeVec_msec = timeVec.*(1000/Fs);
    
%% Now find the indexes with start time and end time of peak (or mean) 
%  detection
    find_peak_start=find(timeVec_msec>peak_start_time);
    peak_start_time_index=min(find_peak_start);
 
   find_peak_end_time=find(timeVec_msec<peak_end_time);
   peak_end_time_index=max(find_peak_end_time);

   % I had this that worked for training but not for
%     Base.Test - Sept 12. I guess that means that 
%     timeFRN=[peak_start_time+abs(time_start), peak_end_time+abs(time_start)];
%     timeFRN_dp=ceil(timeFRN.*msec_to_dp);
    switch type
        
        case 'min'
            % Find the minimum in the previous defined time interval
            peakFRN=min(meantempGo(peak_start_time_index:peak_end_time_index));
            % Find the index(in datapoints) of the maximum
            peakFRN_index=find(meantempGo==peakFRN);
            final_peak_measure=meantempGo(peakFRN_index);
        
        case 'max'
            % Find the minimum in the previous defined time interval
            peakFRN=max(meantempGo(peak_start_time_index:peak_end_time_index));
            % Find the index(in datapoints) of the maximum
            peakFRN_index=find(meantempGo==peakFRN);
            final_peak_measure=meantempGo(peakFRN_index);
        
        case 'mean'
            % The 'peakFRN' variable now hosts the values of the mean of the 
            % predefined interval.
            peakFRN=mean(meantempGo(peak_start_time_index:peak_end_time_index));
        
        case 'base_peak'
            % This is designed for the FRN peak as described by Hajcak,
            % 2006. This gives the difference between the maximum value in
            % a certain interval and the most negative point between this
            % maximum and the 350 ms following feedback onset. 
            start_point_basepeak=150; % ms after feedback
            find_starting_basepeak=find(timeVec_msec>start_point_basepeak);
            start_point_basepeak_index=min(find_starting_basepeak);
            
            % Step 1. Find the max point between 150 ms and 'peak_end_time'
            max_temp=max(meantempGo(start_point_basepeak_index:peak_end_time_index));
            max_temp_index=find(meantempGo==max_temp);
            
            % Step 2. Find the min between this max and the 'peak_end_time'
            base_peak=min(meantempGo(start_point_basepeak_index:peak_end_time_index));
            peakFRN=base_peak;
       
    end
    final_peak_measure=peakFRN;
% For unfiltered signals, you can uncomment the following. 
%     % Add -/+2 values around the peak 
%     final_peak_measure=(meantempGo(peakP300_index)+ ...
%     meantempGo(peakP300_index+1)+meantempGo(peakP300_index+2)+...
%         meantempGo(peakP300_index-1)+meantempGo(peakP300_index-2))/5;

end

