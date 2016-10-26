function create_triggers_in_txt(name1, array1)
% Make a txt file to store the trigger indexes
% Maria L. Stavrinou, 20.1.2016
% x=1;
% vname=@x inputname(1);
% name_of_variable=vname(array_of_trigger);

filename_tosave=[name1 '.txt'];
fileID = fopen((filename_tosave),'w');
fprintf(fileID,'%i ',array1);
fclose(fileID);

end

