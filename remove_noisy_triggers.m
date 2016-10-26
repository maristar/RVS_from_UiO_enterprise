function new_temp_triggers=remove_noisy_triggers( Noisy, trigger_x_indexes )
% Remove the noisy triggers from any selection of indexes
%   Detailed explanation goes here
    
    for mm=1:length(trigger_x_indexes),
        if ismember(trigger_x_indexes(mm), Noisy)==1,
            trigger_x_indexes(mm)=0;
        end
    end
    
    % Remove the zeros (which are noisy epochs)
    indexfinal=find(trigger_x_indexes>0);
    new_temp_triggers=trigger_x_indexes(indexfinal);

end

