%% Data analysis using wavelets,
% for github, 28 11 2014
% Make sample M-channel signal, here we have 3 channels
% Maria L. Stavrinou 


% Raw_Path='/Volumes/MY PASSPORT/EEG/RVS/RAW_datasets/'%RVS_Subject104/Base/';
% %'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/'; 
% Analyzed_path='/Volumes/MY PASSPORT/EEG/RVS/Analyzed_datasets/'

Fs=512;
dt=1/Fs;

% Load Base
load('BaseGA.mat')
dataGA_Base=dataGA;
Mean_Base_Ch=mean(dataGA_Base,3);
MeanBase=mean(dataGA, 3);
clear dataGA

% Load Test
load('TestGA.mat')
dataGA_Test=dataGA;
Mean_Test_Ch=mean(dataGA_Test,3);
MeanTest=mean(dataGA,3);
clear dataGA

% Define necessities 
[nchan ntime]=size(MeanBase);
Fs=512;
pre_trigger = 500; %msec  200 700
post_trigger = 4000; %msec 1100 1600
data_pre_trigger = floor(pre_trigger*Fs/1000);
data_post_trigger = floor(post_trigger*Fs/1000);
timeVec = (-(data_pre_trigger):(data_post_trigger-1));
timeVec = timeVec';
timeVec_msec = timeVec.*(1000/Fs);
names_chan={'Iz', 'Oz', 'POZ', 'Pz', 'CPZ', 'FPZ', 'FCZ', 'CZ', 'AFZ', 'FZ'}

data_all=data; %data_all= zeros(ntimepoints, nchan, ntrig);
% data=nchan x nntime x ntrig 
% for nc=1:nchan,
%     for kk=1:ntrig,
%         new1=squeeze(channels(kk,:,nc)); % take channel1 for kk=1
%         data_all(:,nc,kk)=new1;
%         clear new1;
%     end
% end

% % Evaluate that we have the correct single trials on the correct channel
% for nc=1:2,
% figure; for kk=1:3, subplot(3,1,kk); plot(squeeze(data_all(:,nc,kk)));end
% end



%% Useful params 
ndata=1;
collect_chans_L=data_all;

% The general form  of the input data will be [ntimepoints x nchan x ntrig]
[nchan ntimepoints ntrig]=size(data);
% General form of timevector 
timeVec=(1:length(data)).*1/Fs;
%timeVec=t;

% %% Visualize data
% figure;
% for cc=1:nchan,
%     ctemp=[];
%     subplot(nchan, 1, cc); plot(timeVec, data_all(:,cc,1));
%     xlabel('time (ms)'); ylabel(['Channel ' num2str(cc)]);
% end
% suptitle('Our signal - first trial plotted');
% clear kk

%% Analysis starts:

%% analysis characteristics %%%%
freqN = input('frequency to start?        ');
repeats = input('For how many times -subsequent frequency bands?   ');
tic
%% Define frequencies
for q = 1:repeats
    freq1=freqN;
    freqN=freq1+20;  
    step=0.2;
    freqVec =freq1:step:freqN; % 2:0.05:16
    disp(freq1)
    disp(freqN)
    width=6;
    for k=1:ndata;
        TFR_array=zeros(length(freqVec), length(timeVec), nchan);
        RHO=0;
        for n=1:nchan  %start for every source - channel
        % Lets select the single trials and detrend them
            collect_sts=zeros(ntimepoints, ntrig-1);   
            collect_sts=data(n,:,:);
            collect_sts=squeeze(collect_sts);
            collect_sts=collect_sts'; % ntrig x ntimepoints

            for m=1:ntrig,
                buffer=collect_sts(m, :);
                buffer2=detrend(buffer(:));
                collect_sts(m,:)=buffer2;
                clear buffer buffer2
            end

            B = zeros(length(freqVec), ntimepoints); %% freqVec x timeLength
            PH = zeros(length(freqVec), ntimepoints); %% freqVec x timeLength
            TFR=[]; % empties the variable TFR
            for r=1:ntrig,  % for every single trial     
                for j=1:length(freqVec)  % for every frequency
                    a=squeeze(data(n,:,r))';
                      enrg= energyvec(freqVec(j), collect_sts(r,:),Fs, width);
                      %PH(j,:)=ph;
                      B(j,:)=enrg +B(j,:);
                      %B(j, :) = (energyvec(freqVec(j), a, Fs, width)) + B(j,:);
                      clear a
                end % for every frequency
                clear j
                temp(r,n,:,:)=PH(:,:);
            end % for every trigger
            clear r
            TFR = B/ntrig;  % TFR is mean value of B
            
            % or minus one 3marzo2004
            TFR_array(:,:,n) = TFR;
        end   % end for every source -channel
        clear n
  %TFR_all:  ndatasets x nfreqs x ntimepoints x nchan
  TFR_all(k,:,:,:)=TFR_array;
    end % for every data
    clear TFR
    x_array=zeros(ndata, length(timeVec));
    recon_array = zeros(length(freqVec), length(timeVec), nchan);
    for d = 1:nchan
        for f = 1:(length(freqVec))
            x_array = TFR_all(:,f,:,d);  % or TFR_all(k,f,:,d)
            mx_array = mean(x_array, 1);
            recon_array(f,:,d) = mx_array;
        end
        clear f
    end
    clear d
    %end % for repeats
clear q
%% Forming the general name of the dataset 
   %pathname1='C:\Users\Maria\Desktop\1stdatas';
    filename1='sample_data';
    len_1 = length(filename1); 
    save_name=[filename1 '_ANALYSIS_'];    
    stemp1 = [save_name '_' num2str(freq1) '_' num2str(freqN) '_' 'step' num2str(step) '_' 'recon_array_width' num2str(width)]; 
    stempext = ('.mat'); 
    stemp2 = [stemp1 stempext]; 
    pathname_save=pwd; % Or any other path 
    cd(pathname_save)%
    mkdir(stemp1); % 
    cd(stemp1); % 
    eval(['save ' stemp2 ' recon_array freqVec timeVec step filename1 stemp1 ndata nchan'])
    
    %% Visualize results
    figure;
    for kk=1:nchan,
        subplot(nchan, 1, kk);
        Btemp=recon_array(:,:,kk);
        imagesc(timeVec, freqVec, Btemp);
        xlabel('time (sec)');
        ylabel('frequency (Hz)');
        clear Btemp
    end
    % channel 5 is F3, and i see beta. 
    Btemp=recon_array(15:end,100:end,5);
    figure; imagesc(timeVec(200:end), freqVec(15:end), Btemp)
    clear kk
    cd(pathname_save)
end  
    %%if we had multiple repeats and datasets here would be the end of
    %%%the first loop
toc    


