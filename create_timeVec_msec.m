function [ timeVec_msec ] = create_timeVec_msec( pre_trigger, post_trigger, Fs )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
   
    data_pre_trigger = floor(pre_trigger*Fs/1000);
    data_post_trigger = floor(post_trigger*Fs/1000);
    timeVec = (-(data_pre_trigger):(data_post_trigger));
    timeVec = timeVec';
    timeVec_msec = timeVec.*(1000/Fs);

end

