function [ temp_left_vhf, temp_right_vhf ] = detect_left_right_vhf(kkm, temp_index, double_one_corr, temp_detposition )
%UNTITLED2 Summary of this function goes here
%   Given an index that belongs to the indexes of double_one_corr, it
%   detects if this target belonged to the right or the left visual
%   hemifield. It checks for one temp_index so it must be included in a
%   loop.Now it gives the number 0 
% 11.10.2016, Corrected to view only lateral positions which we will try
% later. 
% Maria Stavrinou 15.09.2016
        temp_left_vhf=0; 
        temp_right_vhf=0;
        switch temp_detposition{:}
            case {'1', '2', '3', '4'}
                   temp_left_vhf=temp_index;
            case { '2', '3'}
                temp_left_vhf_lateral=temp_index;
            case {'5', '6', '7', '8'}
                   temp_right_vhf=temp_index;
             case {'6', '7'}  
                 temp_right_vhf_lateral=temp_index;
        end
end

