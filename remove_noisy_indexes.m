function [ clean_index ] = remove_noisy_indexes( Noisy, raw_index )
% Check the indexes 
       

% Set to zero the indexes that belong to the condition under consideration but also belong
% to Noisy    

    for mm=1:length(raw_index),
        if ismember(raw_index(mm), Noisy)==1,
            raw_index(mm)=0;
        end
    end

        % Remove the zeros (which are noisy epochs)
        indexfinal1=find(raw_index>0);
        indexfinal=raw_index(indexfinal1);

clean_index=indexfinal;
end

