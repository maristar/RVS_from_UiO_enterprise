for kk=1:length(double_one_corr),
       temp_index=double_one_corr(kk);
       temp_rewpair=RewPair{temp_index,1}; % '50Lh20Lh'
       if strcmp(temp_rewpair, '50Lh50Hh')==1 | strcmp(temp_rewpair, '50Hh50Lh')==1
               double_50L_50H(kk)=temp_index;
               if strcmp(DetRewCont{temp_index,1}, '50Lh')==1
                   double_50L_50H_50L(kk)=temp_index;
               else double_50L_50H_50H(kk)=temp_index;
               end
       elseif strcmp(temp_rewpair, '80Hh20Lh')==1 | strcmp(temp_rewpair, '20Lh80Hh')==1;
               double_80_20(kk)=temp_index;
               if strcmp(DetRewCont{temp_index,1}, '80Hh')==1
                   double_80_20_80(kk)=temp_index;
               else double_80_20_20(kk)=temp_index;
               end
       elseif strcmp(temp_rewpair, '50Lh20Lh')==1 | strcmp(temp_rewpair, '20Lh50Lh')==1;
           double_50L_20(kk)=temp_index;
           if strcmp(DetRewCont{temp_index,1}, '50Lh')==1
                   double_50L_20_50L(kk)=temp_index;
               else double_50L_20_20(kk)=temp_index;
           end
       elseif strcmp(temp_rewpair, '50Hh20Lh')==1 | strcmp(temp_rewpair, '20Lh50Hh')==1;
           double_50H_20(kk)=temp_index;
           if strcmp(DetRewCont{temp_index,1}, '50Hh')==1
                   double_50H_20_50H(kk)=temp_index;
               else double_50H_20_20(kk)=temp_index;
           end
       elseif strcmp(temp_rewpair, '80Hh80Hh')==1
           double_80_80(kk)=temp_index;
       elseif strcmp(temp_rewpair, '20Lh20Lh')==1
           double_20_20(kk)=temp_index;
       end