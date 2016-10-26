function [index_specific] = find_index_intime(timeVec_msec, timeinmsec)
%Looks for the index of the given time in msec
indexes=find(timeVec_msec>timeinmsec);
index_specific=min(indexes);

end

