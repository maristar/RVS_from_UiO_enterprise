
function data_filt = DC_offset_removal(data);
%% DC offset removal. 21.10.2011 Maria L. Stavrinou
%a)solution 1
%% 1. load the EEG.data and save it as another set
%  Data should be as nchan x timeduration_all
%% 2 Low pass filter 
h=fdesign.lowpass('Fp,Fst,Ap,Ast',0.001,0.05,1,6,250);
d=design(h,'butter');
fvtool(d)
% % check on a single channel
% ch1=double(data(1,:));
% y=filter(d, ch1);%y=filtfilt(d.Numerator,1,ch1);
% figure; plot(ch1); hold on; plot(y, 'r')
% hold on; plot((ch1-y), 'g')

%% remove DC from all channels
nchan=size(data,1);
for k=1:nchan
temp=double(data(k,:));
%temp_filt=filtfilt(d.Numerator,1,temp);
temp_filt=filter(d,temp);
data_filt(k,:)=data(k,:)-temp_filt;

%data_filt(k,:)=(data_filt(k,:)-mean(data_filt(k,:)))
clear temp temp_filt
end

%% 4 check on one file & decide how to cut the file.
% %% see an example file
% ch12=data_filt([1],:); % 62 72 106 129],:);
% figure(100);
% nn=size(ch12,1);
% for kk=1:nn
%     a=squeeze(ch12(kk,:));
%     plot(a);hold on;
%     clear a
% end
% hold on;
% raw_ch12=data([1],:);
% for kk=1:nn
%     a=squeeze(raw_ch12(kk,:));
%     plot(a, 'g');hold on;legen1=legend('green=raw blue=filtered')
%     clear a
% end

% disp('Write down how to cut from the start in datapoints')
%% 5 reload the filtered back to the EEGLAB structure

