% This program compares 


CPZ_none_B=dataGA_BT_none_report.Base.double_none_corr_GA(30,:);
CPZ_none_T=dataGA_BT_none_report.Test.double_none_corr_GA(30,:);
CPZ_one_correct_B=dataGA_BT_one_correct.Base.double_one_corr_GA(30,:);
CPZ_one_correct_T=dataGA_BT_one_correct.Test.double_one_corr_GA(30,:);
CPZ_double_report_B=dataGA_BT_double_report.Base.double_both_corr_GA(30,:);
CPZ_double_report_T=dataGA_BT_double_report.Test.double_both_corr_GA(30,:);

 
figure; % For BASE 
set(gca,'colororder',[0 0 1;0 1 1; 1 0 0],'nextplot','add');
set(gca,'fontsize', 16);

plot(timeVec_msec, CPZ_none_B);hold on; 
plot(timeVec_msec, CPZ_one_correct_B); hold on; 
plot(timeVec_msec, CPZ_double_report_B);

legend('no report Base', 'single report Base', 'double report Base', 'Location','southeast' );
title('Base POZ')

figure; % For tEST 
set(gca,'colororder',[0 0 1;0 1 1; 1 0 0],'nextplot','add');
set(gca,'fontsize', 16);

plot(timeVec_msec, CPZ_none_T);hold on; 
plot(timeVec_msec, CPZ_one_correct_T); hold on; 
plot(timeVec_msec, CPZ_double_report_T);

legend('no report Test', 'single report Test', 'double report Test', 'Location','southeast' );
title('Test POZ')