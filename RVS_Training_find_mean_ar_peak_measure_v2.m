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
% - type: a string containing the words 
%   a) 'min', 
%   b) 'max' 
%   c) 'mean'.
%   d) 'base_peak'
%   e) 'mean_base_mean_peak'
%   f) 'base_peak_YoungSanfey'
%   g) 'base_peak_P3'
%   h) 'base_peak_general' % not working currently 
% 
% Then the program
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
                       
            % Find the min between this max and the 'peak_end_time -meaning our signal of interest the FRN here'
            FRN_min_peak=min(meantempGo(max_P2_index:peak_end_time_index));
            FRN_peak_base=meantempGo(max_P2_index)-FRN_min_peak;
            peakFRN=FRN_peak_base;
            % tested on 19122016 subject101 HR part_a
            
         case 'mean_base_mean_peak'
            % Here we define the max of the preceding P2 value and we
            % calculate the mean area around this
            % that 
            
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
            
            % The desired interval around FRN is 50 msec (+,- 25 msec from
            % peak. So we need to define the timepoints in datapoints for
            % 25 msec.
            interval25ms_todp=floor(25*msec_to_dp); % 6 datapoints for 25 msec
            
            mean_P2=mean(meantempGo((max_P2_index-interval25ms_todp):(max_P2_index+interval25ms_todp))); %:) Jepp! thanks bestfm!
            
            % Find the min between this max and the 'peak_end_time -meaning our signal of interest the FRN here'
            FRN_min_peak=min(meantempGo(max_P2_index:peak_end_time_index));
            % What is the index of the min of FRN wave -different for each
            % subject:
            FRN_min_peak_index=find(meamtempGo==FRN_min_peak);
            mean_FRN=mean(meantempGo((FRN_min_peak_index-interval25ms_todp):(FRN_min_peak_index+interval25ms_todp)));
            
            FRN_mpeak_mbase=meanP2-meanFRN;
            peakFRN=FRN_mpeak_mbase;
           
            % MLS, 24.04.2017
            % Instead of taking the interval for P2, (200-250) and getting
            % the mean value out of it, we take the min in this interval,
            % and calculate the mean -,+25 msec around this. The same for
            % the FRN: instead of calculating the mean value of the 250-300
            % msec, we find the min of this interval and then we calculate
            % the mean -25,+25 around this value (its index). It is a bit
            % more detailed than just subtracting the means, which could
            % have been calculated from simply subtracting the mean of FRN
            % and the mean of P2. 
            
            
        case 'base_peak_YoungSanfey'
            % This is designed for the FRN peak as described by Y and S.
            % Step 1. Find the max of the preceding to FRN peak
            start_point_basepeak=150; % ms after feedback
            find_starting_basepeak=find(timeVec_msec>start_point_basepeak);
            start_point_basepeak_index=min(find_starting_basepeak);
            
            % Here we defined the P2 as the maximum peak before FRN
            P2_peak_end_time=260;% msec after visual inspection of FZ grandaverage plot HR-LR
            find_P2_peak_end_time=find(timeVec_msec>P2_peak_end_time);
            P2_peak_end_time_index=min(find_P2_peak_end_time);
            clear find_P2_peak_end_time
            
            max_P2_value=max(meantempGo(start_point_basepeak_index:P2_peak_end_time_index));
            max_P2_index=find(meantempGo==max_P2_value);
                       
            % Step 2. Find the max of the following to the FRN peak
            P3_start_ms=300;
            P3_start_indexes=find(timeVec_msec>300);
            P3_start_index=min(P3_start_indexes);
            clear P3_start_indexes
            
            P3_end_ms=500;
            P3_end_indexes=find(timeVec_msec>500);
            P3_end_index=min(P3_end_indexes);
            clear P3_end_indexes
            
            P3_max_peak=max(meantempGo(P3_start_index:P3_end_index));
            
            % Find the difference between FRN and the preceding following peaks. 
            % First, find the FRN as the minimum between the P2peak and the
            % defined min value
            FRN_min_peak=min(meantempGo(max_P2_index:peak_end_time_index));
            % FrN as the difference of this and the preceding+post peaks
            FRN_peak_base_YS=P3_max_peak+max_P2_value-FRN_min_peak;
            % Reference to Yeung % Sanfey 2004
            peakFRN=FRN_peak_base;
            % finished 24.04.2017, MLS
            
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
            FRN_value=min(meantempGo(start_point_basepeak_index:FRN_peak_end_time_index));
            % What is its index
            % FRN_min_index=find(meantempGo==FRN_value);
                       
            % Step 2. Find the max between this min and the 'peak_end_time'
            % which for P300 can be the 430 msec or later (500 msec)
            P3_max_peak=max(meantempGo(FRN_min_index:peak_end_time_index));
            P3_base_peak=P3_max_peak-FRN_min_value;
            peakFRN=P3_base_peak;
            
            case 'base_peak_general' % NOT Done yet
            % TODO general based on Hajzak and the FR¤N calculation before
            % This gives the difference between the maximum value in
            % a certain interval and the most negative point between this
            % maximum and the peak_start_time of the peak we want to measure.  
            % The mean difference between peaks is found to be 66 ms. The
            % peak_start_time is 25 ms before the peak so we give to the
            % program 66+25 = 91 ms before to start looking for the
            % previous positive peak which will be the maximum value. 
            
            % We have the 
            %    peak_start_time
            % We have the 
            %       peak_end_time 
            % of the peak of interest. 
            
            start_point_basepeak=peak_start_time-66; % ms after feedback
            find_starting_basepeak=find(timeVec_msec>start_point_basepeak);
            start_point_basepeak_index=min(find_starting_basepeak);
            clear find_starting_basepeak;
            
            Previous_peak_end_time=peak_start_time;% msec 
            Previous_peak_end_time_indexes=find(timeVec_msec>Previous_peak_end_time);
            Previous_peak_end_time_index=min(find_Previous_peak_end_time);
            clear Previous_peak_end_time_indexes
            
            % Step 1. Find the max point between 150 ms and 'P1
            % peak_end_time - 260 msec' (the P1 peak!*)
            % What is the max amplitude value
            max_Previous_peak_value=max(meantempGo(start_point_basepeak_index:Previous_peak_end_time_index));
            % What is its index
            max_Previous_peak_index=find(meantempGo==max_Previous_peak_value);
                       
            % Step 2. Find the min between this max and the 'peak_end_time'
            % Peak Of Interest (POF)
            POF_min_peak=min(meantempGo(max_Previous_peak_index:peak_end_time_index));
            POF_peak_base=max_Previous_peak_value-POF_min_peak;
            peakFRN=POF_peak_base;
    end
    final_peak_measure=peakFRN;
% For unfiltered signals, you can uncomment the following. 
%     % Add -/+2 values around the peak 
%     final_peak_measure=(meantempGo(peakP300_index)+ ...
%     meantempGo(peakP300_index+1)+meantempGo(peakP300_index+2)+...
%         meantempGo(peakP300_index-1)+meantempGo(peakP300_index-2))/5;

end

