%close all; %%%%%Modified 7 September 2006 Maria L. Stavrinou %%%%%%
%UpatrAS oslo 251102010
clc;
%load chans
[filename pathname]=uigetfile('Select the matlab file with the variables to be plotted  ');
stemp=[pathname filename];
load(stemp)
%cd ..
cd (pathname)

%%%% Comment if not necessary 
% timeVec2=1:length(recon_array);
% timeVec2=timeVec2';
% save timeVec2 timeVec2
recon_array=TFR_array;
nchan=size(recon_array,3);

save_name1 = filename(1:end-4); 
%% IN case of phase analysis recon_array=recon_array_ph;
%recon_array=recon_array_ph;
% %%%%%% LOOK HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% v=zeros(nchan, ??? to fix
%%
timeabove=find(timeVec==timeVec(100))
%clim=[0 5000];
for w = 1:nchan
    source = recon_array(:,:, w);
%     figure(w); imagesc(timeVec_msec, freqVec, 1e13^2*source);axis xy; colorbar; title([filename_all ':' s{w}])
    figure(w); imagesc(timeVec(timeabove:end-50), freqVec, source(:,timeabove:end-50)); axis xy; colorbar; 
    tlt = s{w}; tlt(strfind(tlt,'_'):end) = []; title(tlt);
    xlabel('Time (ms)');ylabel('Frequency (Hz)');
   set(gca, 'FontName', 'TimesNewRoman', 'FontSize', 36)  %% axis ticks
set(get(gca,'Title'), 'FontName', 'TimesNewRoman', 'FontSize', 36)
set(get(gca,'xlabel'), 'FontName', 'TimesNewRoman', 'FontSize', 36)
set(get(gca,'ylabel'), 'FontName', 'TimesNewRoman', 'FontSize', 36)

    v(w, :, :) = caxis;
   save_name = [save_name1 s{w}];
  saveas(gcf, save_name, 'fig')
end

if nchan<12
    figure;
    for j=1:nchan
        source = recon_array(:,:, j);
        subplot(5,2,j); imagesc(timeVec(timeabove:end-50), freqVec, source(:,timeabove:end-50)); axis xy; colorbar; 
    tlt = s{j}; tlt(strfind(tlt,'_'):end) = []; title(tlt);
       end
end
save_name='Plots_all'
saveas(gcf,save_name, 'fig');
close all
%%
close all
  caxis_min = min(v(:,:,1)); 
  caxis_max = max(v(:,:,2));
  c_axis_mean=mean(v(:,:,2));
  clim = [caxis_min caxis_max];
 % for max and maria 0.00006 worked well

for w = 1:nchan
    source = recon_array(:,:, w);
%     figure(w); imagesc(timeVec_msec, freqVec, 1e13^2*source);axis xy; colorbar; title([filename_all ':' s{w}])
    figure(w); imagesc(timeVec(timeabove:end-50), freqVec, source(:,timeabove:end-50), clim); axis xy; colorbar; 
    tlt = s{w}; tlt(strfind(tlt,'_'):end) = []; title(tlt);
    xlabel('Time (ms)');ylabel('Frequency (Hz)');
    v(w, :, :) = caxis;
    set(gca, 'FontName', 'TimesNewRoman', 'FontSize', 36)  %% axis ticks
set(get(gca,'Title'), 'FontName', 'TimesNewRoman', 'FontSize', 36)
set(get(gca,'xlabel'), 'FontName', 'TimesNewRoman', 'FontSize', 36)
set(get(gca,'ylabel'), 'FontName', 'TimesNewRoman', 'FontSize', 36)

   save_name = [save_name1 '_norm_' s{w}];
  saveas(gcf, save_name, 'fig')
end 
close all

% Make a big figure to put inside all the normalized plots - make it
% interactive
if nchan<12
    figure;
    for j=1:nchan
        source = recon_array(:,:, j);
        subplot(5,2,j); imagesc(timeVec(timeabove:end-50), freqVec, source(:,timeabove:end-50), clim); axis xy; colorbar; 
    tlt = s{j}; tlt(strfind(tlt,'_'):end) = []; title(tlt);
    end
end
save_name='Plots_all_norm'
saveas(gcf,save_name, 'fig');
close all

% %% Modified plot
% mp = 5;
% np = 2;
% left = [0:1/(np):1] +0.02;
% bottom = [0:1/(mp):1] +0.02;
% width = 1/np -0.04;
% height = 1/mp -0.05;
% 
% for it1=1:mp,
%     for it2=1:np,
%         ind = sub2ind([np,mp],it2,it1);
%         h{ind} = subplot(mp,np,ind);
%         set(h{ind},'pos',[left(it2) bottom(end-it1) width height]);
%         source = recon_array(:, :, ind);
%     imagesc(timeVec(timeabove:end-50), freqVec, source(:,timeabove:end-50), clim); axis xy; colorbar; 
%     tlt = s{ind}; tlt(strfind(tlt,'_'):end) = []; title(tlt);
% %         imagesc(timeVec, freqVec(f1:f2), source(f1:f2,:), clim);
% %         tlt = s{ind}(5:end); tlt(strfind(tlt,'_'):end) = []; title(tlt); 
%         axis xy; 
%         if ind~=1,
%             set(h{ind},'XTickLabel',''); set(h{ind},'YTickLabel','');
%         end
%     end
% end
% save_name='Plots_1_20_n'
% saveas(gcf,save_name, 'fig');
%         
%%

%  
% % for g=1:nchan
% %     source =[];
% %     source = recon_array(:, :, g);
% %     Nfigs = ndata*nchan+4;
% %     figure(w+g); imagesc(timeVec, freqVec, source(:,:), clim);axis xy; colorbar;title([save_name1 ':' s{g}])
% % %     save_name = ['Corr_LH_scaled_' s{g}];
% % %     saveas(gcf, save_name, 'fig');
% % end
% %%
% answer = input('Do you want to zoom? (y \ n)       ', 's');
% if (answer=='y')
%     disp('Current frequency Vector: ')
%     disp(freqVec)
%     freq_1=input('from Hz:      '); 
%     freq_2=input('up to Hz:     ');
%     f1=find(freqVec(1,:)==freq_1);
%     f2=find(freqVec(1,:)==freq_2);
%      figure;
%     numfigs=floor(nchan/10)
%     
%     cd(pathname)
% %%  
% 
% mp = 2;
% np = 5;
% left = [0:1/(np):1] +0.02;
% bottom = [0:1/(mp):1] +0.02;
% width = 1/np -0.04;
% height = 1/mp -0.05;
% 
% for it1=1:mp,
%     for it2=1:np,
%         ind = sub2ind([np,mp],it2,it1);
%         h{ind} = subplot(mp,np,ind);
%         set(h{ind},'pos',[left(it2) bottom(end-it1) width height]);
%         source = recon_array(:, :, ind);
% 
%         imagesc(timeVec, freqVec(f1:f2), source(f1:f2,:), clim);
%         tlt = s{ind}(5:end); tlt(strfind(tlt,'_'):end) = []; title(tlt); 
%         axis xy; 
%         if ind~=1,
%             set(h{ind},'XTickLabel',''); set(h{ind},'YTickLabel','');
%         end
%     end
% end
% save_name='Plots_1_20_n'
% saveas(gcf,save_name, 'fig');
% %%
%      
%    
% %% j=21:40
%   figure;
% for it1=1:mp,
%     for it2=1:np,
%     ind = sub2ind([np,mp],it2,it1);
%     h{ind} = subplot(mp,np,ind);
%     set(h{ind},'pos',[left(it2) bottom(end-it1) width height]);
%     source = recon_array(:, :, ind+20);
% 
%     imagesc(timeVec, freqVec(f1:f2), source(f1:f2,:),clim);
%     tlt = s{ind+20}(5:end); tlt(strfind(tlt,'_'):end) = []; title(tlt); 
%     axis xy; 
%         if ind~=1,
%             set(h{ind},'XTickLabel',''); set(h{ind},'YTickLabel','');
%         end
%     end
% end
%    save_name='Plots_21_40_n'
% saveas(gcf,save_name, 'fig');%%
%    
% %% j=41:60;
%     figure;
% for it1=1:mp,
%     for it2=1:np,
%     ind = sub2ind([np,mp],it2,it1);
%     h{ind} = subplot(mp,np,ind);
%     set(h{ind},'pos',[left(it2) bottom(end-it1) width height]);
%     source = recon_array(:, :, ind+40);
% 
%     imagesc(timeVec, freqVec(f1:f2), source(f1:f2,:),clim);
%     tlt = s{ind+40}(5:end); tlt(strfind(tlt,'_'):end) = []; title(tlt); 
%     axis xy; 
%         if ind~=1,
%             set(h{ind},'XTickLabel',''); set(h{ind},'YTickLabel','');
%         end
%     end
% end
% save_name='Plots_41_60_n'
% saveas(gcf,save_name, 'fig');
% %% 
% %% j=61:80;
% figure;
% for it1=1:mp,
%     for it2=1:np,
%     ind = sub2ind([np,mp],it2,it1);
%     h{ind} = subplot(mp,np,ind);
%     set(h{ind},'pos',[left(it2) bottom(end-it1) width height]);
%     source = recon_array(:, :, ind+60);
% 
%     imagesc(timeVec, freqVec(f1:f2), source(f1:f2,:),clim);
%     tlt = s{ind+60}(5:end); tlt(strfind(tlt,'_'):end) = []; title(tlt); 
%     axis xy; 
%         if ind~=1,
%             set(h{ind},'XTickLabel',''); set(h{ind},'YTickLabel','');
%         end
%     end
% end
% save_name='Plots_61_80_n'
% saveas(gcf,save_name, 'fig');
% %%
% end
% cd ..
