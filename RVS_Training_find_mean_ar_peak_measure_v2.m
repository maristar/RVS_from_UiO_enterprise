function [ final_peak_measure ] = RVS_Training_find_mean_ar_peak_measure_v2(meantempGo, peak_start_time, peak_end_time, Fs, timeVec_msec, type )
% The function gives the peak value. 
% Revised from previous version and it is advised to use that. 
% Was used in 22 June 2016, for Base-Test, double one corr, 4 rewlev
%
% Input arguments
% - meantempGo: the average waveform (timepoints x 1)?
% - peak_start_time: the time to start looking for the peak, in msec
% - peak_end_time: the time to stop looking for the peak, in msec
% - time_start: positive or negative integer, in msec, time that the epoch begins for example
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
            peakFRN=mean(meantempGo(peak_start_time_index:peak_end_time_index)); %SOS ,1 added 28.sept.
        
        case 'base_peak'
            % This is designed for the FRN peak as described by Hajcak,
            % 2006. This gives the difference between the maximum value in
            % a certain interval and the most negative point between this
            % maximum and the 350 ms following feedback onset. 
            
            % Start time to look for positive maximum wave (P2)
            start_point_basepeak=150; % ms after feedback
            find_starting_basepeak=find(timeVec_msec>start_point_basepeak);
            start_point_basepeak_index=min(find_starting_basepeak);
            
            % End time to look for positive maximum wave (P2) 
            P2_peak_end_time=260;% msec after visual inspection of FZ grandaverage plot HR-LR
            find_P2_peak_end_time=find(timeVec_msec>P2_peak_end_time);
            P2_peak_end_time_index=min(find_P2_peak_end_time);
            
            % Find the max point (P2 peak) between 150 ms and 260 ms
            max_P2_value=max(meantempGo(start_point_basepeak_index:P2_peak_end_time_index));
            % What is its index
            max_P2_index=find(meantempGo==max_P2_value);
            % Renes suggestion, make the mean value of this. 
            mean_P2=mean(meantempGo(peak_start_time_index:peak_end_time_index)); %SOS
            
            % Find the min between this max and the 'peak_end_time -meaning our signal of interest the FRN here'
            FRN_min_peak=min(meantempGo(max_P2_index:peak_end_time_index));
            FRN_peak_base=meantempGo(max_P2_index)-FRN_min_peak;
            peakFRN=FRN_peak_base;
            % tested on 19122016 subject101 HR part_a
            case 'base_peak_YoungSanfey'
            % This is designed for the FRN peak as described by Hajcak,
            % 2006. This gives the difference between the maximum value in
            % a certain interval and the most negative point between this
            % maximum and the 350 ms following feedback onset. 
            start_point_basepeak=150; % ms after feedback
            find_starting_basepeak=find(timeVec_msec>start_point_basepeak);
            start_point_basepeak_index=min(find_starting_basepeak);
            
            % Here we defined the P1 as the maximum peak in the area, and
            % its before the FRN 
            P2_peak_end_time=260;% msec after visual inspection of FZ grandaverage plot HR-LR
            %P2_max_peak=max(meantempGo(start_point_basepeak_index:peak_end_time_index));
            
            find_P2_peak_end_time=find(timeVec_msec>P2_peak_end_time);
            P2_peak_end_time_index=min(find_P2_peak_end_time);
            
            % Step 1. Find the max point between 150 ms and 'P2
            % peak_end_time - 260 msec' (the P1 peak!*)
            % What is the max amplitude value
            max_P2_value=max(meantempGo(start_point_basepeak_index:P2_peak_end_time_index));
            % What is its index
            max_P2_index=find(meantempGo==max_P2_value);
                       
           
            
            
            % Step 2. Find the max of the following peaks
            P3_start_ms=300;
            P3_start_indexes=find(timeVec_msec>300);
            P3_start_index=min(P3_start_indexes);
            
            P3_end_ms=500;
            P3_end_indexes=find(timeVec_msec>500);
            P3_end_index=min(P3_end_indexes);
            
            P3_max_peak=max(meantempGo(P3_start_index:P3_end_index));
            
            % Find the difference between FRN and the preceding following peaks. 
            FRN_min_peak=min(meantempGo(max_P2_index:peak_end_time_index));
            FRN_peak_base_YS=P3_max_peak+max_P2_value-FRN_min_peak;
            % Yeung % Sanfey 2004
            peakFRN=FRN_peak_base;
            % tested on 19122016 subject101 HR part_a
            case 'base_peak_P3'
            % This is designed for the P3 peak, taking into consideration
            % the peak in 
            start_point_basepeak=230; % ms after feedback
            find_starting_basepeak=find(timeVec_msec>start_point_basepeak);
            start_point_basepeak_index=min(find_starting_basepeak);
            
            % The FRN should be before the P3. So lets find the minimum in
            % the interval 230 - 300
            FRN_peak_end_time=300;% msec after visual inspection of FZ grandaverage plot HR-LR
            find_FRN_peak_end_time=find(timeVec_msec>FRN_peak_end_time);
            FRN_peak_end_time_index=min(find_FRN_peak_end_time);
            
            % Step 1. Find the min point between 230 - 500 ms
            FRN_value=min(meantempGo(start_point_basepeak_index:P2_peak_end_time_index));
            % What is its index
            max_P2_index=find(meantempGo==max_P2_value);
                       
            % Step 2. Find the min between this max and the 'peak_end_time'
            FRN_min_peak=min(meantempGo(max_P2_index:peak_end_time_index));
            FRN_peak_base=meantempGo(max_P2_index)-FRN_min_peak;
            peakFRN=FRN_peak_base;
            
            case 'base_peak_general'
            % TODO general based on Hajzak and the FR�N calculation before
            % This gives the difference between the maximum value in
            % a certain interval and the most negative point between this
            % maximum and the peak_start_time of the peak we want to measure.  
            % The mean difference between peaks is found to be 66 ms. The
            % peak_start_time is 25 ms before the peak so we give to the
            % program 66+25 = 91 ms before to start looking for the
            % previous positive peak which will be the maximum value. 
            start_point_basepeak=peak_start_time-66; % ms after feedback
            find_starting_basepeak=find(timeVec_msec>start_point_basepeak);
            start_point_basepeak_index=min(find_starting_basepeak);
            
            P1_peak_end_time=peak_start_time;% msec after visual inspection of FZ grandaverage plot HR-LR
            find_P1_peak_end_time=find(timeVec_msec>P1_peak_end_time);
            P1_peak_end_time_index=min(find_P1_peak_end_time);
            
            % Step 1. Find the max point between 150 ms and 'P1
            % peak_end_time - 260 msec' (the P1 peak!*)
            % What is the max amplitude value
            max_P1_value=max(meantempGo(start_point_basepeak_index:P1_peak_end_time_index));
            % What is its index
            max_P1_index=find(meantempGo==max_P1_value);
                       
            % Step 2. Find the min between this max and the 'peak_end_time'
            FRN_min_peak=min(meantempGo(max_P1_index:peak_end_time_index));
            FRN_peak_base=meantempGo(max_P1_index)-FRN_min_peak;
            peakFRN=FRN_peak_base;
    end
    final_peak_measure=peakFRN;
% For unfiltered signals, you can uncomment the following. 
%     % Add -/+2 values around the peak 
%     final_peak_measure=(meantempGo(peakP300_index)+ ...
%     meantempGo(peakP300_index+1)+meantempGo(peakP300_index+2)+...
%         meantempGo(peakP300_index-1)+meantempGo(peakP300_index-2))/5;

end

