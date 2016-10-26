
Analyzed_path='/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/Analyzed_datasets/';
cd(Analyzed_path)
cd figures

[file1 path1]=uigetfile('*.mat', 'Select the TEST recon results');
cd(path1)
load(file1)
test_recon_array=recon_array;

[file2 path2]=uigetfile('*.mat', 'Select the BASE recon results');
cd(path2)
load(file2)
%load('BaseGA_ANALYSIS__1_13_step0.5_recon_array_width6.mat')
base_recon_array=recon_array;

[nfreqs ntime nchan]=size(test_recon_array);

% 101 x 2304 x 10
for kk=1:nchan
    for jj=1:nfreqs
        difference(jj,:, kk)=base_recon_array(jj,:,kk)-test_recon_array(jj,:,kk);
    end
end

session={'Base-Test'};
paths={path1, path2};
      % to test if good to test here
     for kk=1:nchan,
        H=figure;
        set(gca,'FontSize',24)
        Btemp=difference(:,:,kk);
        imagesc(timeVec, freqVec, Btemp);colorbar;
        title(names_chan{kk}, 'FontSize', 24);
        xlabel('time (sec)', 'FontSize', 24);
        ylabel('frequency (Hz)', 'FontSize', 24);
        v(kk, :, :) = caxis;
        cd(Analyzed_path)
        cd figures
        mkdir(session{:})
        cd(session{:})  
        names_wave=[session{:} '_' names_chan{kk} '30_43wavelet']
        saveas(H, names_wave, 'png')
        saveas(H, names_wave, 'fig')
        clear Btemp H names_wave
     end
     
     
     
     close all
  caxis_min = min(v(:,:,1)); 
  caxis_max = max(v(:,:,2));
  c_axis_mean=mean(v(:,:,2));
  clim = [caxis_min caxis_max];
  %clim= [-12 31];
          for kk=1:nchan,
        H=figure;
        set(gca,'FontSize',24)
        Btemp=difference(:,:,kk);
        imagesc(timeVec, freqVec, Btemp, clim); colorbar;
        title(names_chan{kk}, 'FontSize', 24);
        xlabel('time (sec)', 'FontSize', 24);
        ylabel('frequency (Hz)', 'FontSize', 24);
        set(gca, 'FontName', 'TimesNewRoman', 'FontSize', 18); % axis ticks
        cd(Analyzed_path)
        cd figures
        mkdir(session{:})
        cd(session{:})  
        names_wave=[session{:} '_' names_chan{kk} '_wavelet_norm']
        saveas(H, names_wave, 'png')
        saveas(H, names_wave, 'fig')
        clear Btemp H names_wave
          end
          mkdir('PNGs')
           movefile('*.png', 'PNGs');