function [ output ] = find_eprime_column( all_headers2, T, column_header_text )
%UNTITLED Summary of this function goes here
%   Maria L. Stavrinou, 15.9.2016, not put in any program so far. 
        % Find for the Feedback Onset delay
        for jjj=1:length(all_headers2)
            a=strcmp(all_headers2{1,jjj}, 'Feedback.OnsetDelay');
            if a==1
                indexFeedbackDelay=jjj;
            end
        end
        clear a jjj % OK

        Feedback_OnsetDelay_table=T(2:end, indexFeedbackDelay); % 131 for JackLoe, tested first!
        FeedbackDelay=table2cell(Feedback_OnsetDelay_table);
        output=FeedbackDelay
end

