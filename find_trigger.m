function [trigger_index trigger_latency]=find_trigger(All_triggers, All_triggers2, trigger_name);
%trigger_name=1;  
 index=zeros(1,length(All_triggers)); % Should be 640 in our case
    for kk=1:length(All_triggers); 
        if All_triggers(kk).type==trigger_name;
            index_1(kk)=1; 
            latency_1(kk)=All_triggers(kk).latency;
        end;
    end;

    index_1_correct=find(index_1>0);
    trigger_index=index_1_correct;
    trigger_latency=latency_1(latency_1>0);
    
    