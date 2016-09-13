% RVS project. MLS
% Load the EEG data 
% First
dataTest_D2_1c=EEG.data;
% Load the test data num_channels*1_trial_length*num_trials
dataBase_D2_1c=EEG.data;

%% Get channel P1, number 20 
P1_base=squeeze(dataBase_D2_1c(20,:,:));
P1_test=squeeze(dataTest_D2_1c(20,:,:));

% Get mean 
P1_Base_mean=mean(P1_base, 2);
P1_test_mean=mean(P1_test, 2);

% Plot
fs=512;
timeVec=-500:(1000/fs):4000-(1000/fs);

figure; plot(timeVec, P1_Base_mean, 'r');
axis('tight')
set(gca,'fontsize',18)
hold on; plot(timeVec, P1_test_mean, 'b');
title('Channel P1');
legend on; 
legend('Base','Test');
hold off;
%% Get channel o1, number 27
P1_base=squeeze(dataBase_D2_1c(27,:,:));
P1_test=squeeze(dataTest_D2_1c(27,:,:));

% Get mean 
P1_Base_mean=mean(P1_base, 2);
P1_test_mean=mean(P1_test, 2);

% Plot
fs=512;
timeVec=-500:(1000/fs):4000-(1000/fs);

figure; plot(timeVec, P1_Base_mean, 'r');
axis('tight')
set(gca,'fontsize',18)
hold on; plot(timeVec, P1_test_mean, 'b');
title('Channel O1');
legend on; 
legend('Base','Test');
hold off;

% Plot zoom
figure; plot(timeVec(1:1000), P1_Base_mean(1:1000), 'r');
axis('tight')
set(gca,'fontsize',18)
hold on; plot(timeVec(1:1000), P1_test_mean(1:1000), 'b');
title('Channel O1');
legend on; 
legend('Base','Test');
hold off;

%% Plot FC2, num 46
P1_base=squeeze(dataBase_D2_1c(64,:,:));
P1_test=squeeze(dataTest_D2_1c(64,:,:));

% Get mean 
P1_Base_mean=mean(P1_base, 2);
P1_test_mean=mean(P1_test, 2);

% Plot
fs=512;
timeVec=-500:(1000/fs):4000-(1000/fs);

figure; plot(timeVec, P1_Base_mean, 'r');
axis('tight')
set(gca,'fontsize',18)
hold on; plot(timeVec, P1_test_mean, 'b');
title('Channel O2');
legend on; 
legend('Base','Test');
hold off;

% Plot zoom
figure; plot(timeVec(1:1000), P1_Base_mean(1:1000), 'r');
axis('tight')
set(gca,'fontsize',18)
hold on; plot(timeVec(1:1000), P1_test_mean(1:1000), 'b');
title('Channel O2');
legend on; 
legend('Base','Test');
hold off;
