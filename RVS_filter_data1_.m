function filtered_data=RVS_filter_data1_(data,from,to)
%%%from=5; to=45
fs=512;
data=EEG.data;
[xr,xc]=size(data);
nrchan=min(xr,xc);
figure;subplot(1,2,1);plot(data(1,4000:8000))
[p,f]=pwelch(data(3,:),[],[],[],fs);
subplot(1,2,2);hold on;plot(f,10*log10(p))
from=1;
to=100;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% band pass filtering data in 5 -45
for k=3; %1:nrchan
    filtered_data(k,:) = pop_eegfiltnew(data(k,:), fs, from, to);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(1,2,1);hold on;plot(filtered_data(3,4000:8000),'r');legend('orig','filtered')
xlabel('time')
ylabel('Ampl')

[p,f]=pwelch(data(1,:),[],[],[],fs);
subplot(1,2,2);hold on;plot(f,10*log10(p),'r');axis tight
xlabel('frequency [Hz]')
ylabel('PSD')
