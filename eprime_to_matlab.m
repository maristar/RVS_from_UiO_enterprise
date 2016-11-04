function [ String_name_incell ] = eprime_to_matlab( T, all_headers2, String_name )
%eprime_to_matlab gets the edat2 file and extracts the column of interest
%   input arguments 
%   - T the table imported from eprime
%   - all_headers2: the headers of the edat2 file
%   - String_name: the column title for example 'TotalACC'
%   output arguments
%   output_fromT_cell: a cell array with the contents of the column named
%   String_name
%   03.11.2016 Maria Stavrinou

        %% Find for the T1RewContig %% TODO TO make it a function
        for jjj=1:length(all_headers2)
            a=strcmp(all_headers2{1,jjj}, String_name);
            if a==1
                indexString_name=jjj;
            end
        end
        clear a jjj % OK

        String_name_table=T(2:end, indexString_name); % 131 for JackLoe, tested first!
         String_name_incell=table2cell(String_name_table);

end

