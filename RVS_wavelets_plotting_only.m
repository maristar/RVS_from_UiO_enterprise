% 31 JAN 2016 MLS
clear all 
close all

Analyzed_path='/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/Analyzed_datasets/';
cd(Analyzed_path)
cd figures

[file1 path1]=uigetfile('*.mat', 'Select the BASE recon results');
cd(path1)
load(file1)
%load('BaseGA_ANALYSIS__1_13_step0.5_recon_array_width6.mat')
base_recon_array=recon_array;
clear names_chan
[nfreqs ntime nchan]=size(base_recon_array);


[file2 path2]=uigetfile('*.mat', 'Select the TEST recon results');
cd(path2)
load(file2)
test_recon_array=recon_array;
clear names_chan
[nfreqs ntime nchan]=size(test_recon_array);

% Keep this name channels labels please
names_chan={'Iz', 'Oz', 'POz', 'Pz', 'CPz', 'Fpz', 'AFz', 'Fz', 'FCz', 'Cz'};

sessions={'Base', 'Test'};
paths={path1, path2};
%good to test here
for jjk=1:length(sessions)
    session=sessions{jjk}
    switch session
        case 'Base'
            recon_array=base_recon_array;
            disp(session)
        case 'Test'
            recon_array=test_recon_array;
            disp(session)
    end
     for kk=1:nchan,
        H=figure;
        set(gca,'FontSize',24)
        Btemp=recon_array(:,:,kk);
        imagesc(timeVec(82:end), freqVec, Btemp(:,82:end,:));colorbar;
        disp('Working on channel number')
        disp(names_chan{kk})
        disp('PLOT NAME:')
        names_to_plot=[session names_chan{kk}]
        title(names_to_plot, 'FontSize', 24);
        xlabel('time (msec)', 'FontSize', 24);
        ylabel('frequency (Hz)', 'FontSize', 24);
        v(kk, :, :) = caxis;
        cd(Analyzed_path)
        cd figures
        cd(paths{jjk})
        %names_wave=[sessions{jjk} '_' names_chan{kk} '_wavelet']
        saveas(H, names_to_plot, 'png')
        saveas(H, names_to_plot, 'fig')
        clear Btemp names_to_plot H
     end
    min1=min(v(:,:,1));
    max1=max(v(:,:,2));
    clim(jjk,:,:)=[min1, max1];
      mkdir('PNGs');
      movefile('*.png', 'PNGs');
     cd(Analyzed_path)

end
  %% SOS TO CHOOSE THE RIGHT LIMITS FOR NORMALIZED PLOTS
  clim_min=min(clim(:,:,1));
  clim_max=max(clim(:,:,2));
  clim1=[clim_min clim_max];
% clim1 for gamma 0.1 - 1.5
  %clim= [0.3773 14.6386]; % % Base 3: as POZ (3o channel) [0.3773 14.6386]. Base and test [0.55 25] 
   %   clim1=[0.1 1.5]
 for jjk=1:length(sessions)
    session=sessions{jjk}
    switch session
        case 'Base'
            recon_array=base_recon_array;
            disp(session)
        case 'Test'
            recon_array=test_recon_array;
            disp(session)
    end
    
    disp(jjk)
     for kk=1:nchan,
        H=figure;
        set(gca,'FontSize',24)
        Btemp=recon_array(:,:,kk);
        imagesc(timeVec(82:end), freqVec, Btemp(:,82:end,:), clim1);colorbar;
        names_to_plot=[sessions{jjk} '-' names_chan{kk}];
        title(names_to_plot, 'FontSize', 24);
        xlabel('time (msec)', 'FontSize', 24);
        ylabel('frequency (Hz)', 'FontSize', 24);
        cd(Analyzed_path)
        cd figures
        cd(paths{jjk})
        names_wave=[sessions{jjk} '_' names_chan{kk} '_wavelet_norm_3'];
        saveas(H, names_wave, 'png')
        saveas(H, names_wave, 'fig')
         clear Btemp
     end % chan
       mkdir('PNGs')
      movefile('*.png', 'PNGs');
end