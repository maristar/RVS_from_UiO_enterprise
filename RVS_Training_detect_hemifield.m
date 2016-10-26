% Scratch. detect hemifield 
double_Low_hemifield=zeros(1, length(double_one_corr));
double_High_hemifield=zeros(1, length(double_one_corr));

for kk=1:length(double_one_corr),
       temp_index=double_one_corr(kk);
       temp_rewpair=RewPair{temp_index,1};% '50Lh20Lh'
       temp_detrewcont=DetRewCont{temp_index,1};
       First_Letter=temp_rewpair{1,1}(3);
       Second_Letter=temp_rewpair{1,1}(7);
       Two_Letters=[First_Letter Second_Letter]
       switch Two_Letters
           case {'LH', 'HL'}
               if strcmp(temp_detrewcont{1,1}(3),'L')==1
               double_Low_hemifield(kk)=temp_index;
               elseif strcmp(temp_detrewcont{1,1}(3),'H')==1
                  double_High_hemifield(kk)=temp_index;
               end
       end
end

double_Low_hemif=double_Low_hemifield(double_Low_hemifield>0);
clear double_Low_hemifield
double_High_hemif=double_High_hemifield(double_High_hemifield>0);
clear double_High_hemifield