co = get(gca,'ColorOrder') % Initial
% Change to new colors.
set(gca, 'ColorOrder', [0.5 0.5 0.5; 1 0 0], 'NextPlot', 'replacechildren');
co = get(gca,'ColorOrder') % Verify it changed

% Now plot with changed colors.
x = 1:3;
y = [1 2 3; 42 40 34];
figure; plot(x,y, 'LineWidth', 3);



colorstring = 'kbgry';
figure(1); cla;
hold on
for i = 1:5
  plot(x,y(:, i), 'Color', colorstring(i))
end

h1=plot(x,cos(x),'-ro');
hold on
h2=plot(x,sin(x),'-.b');
hold off
then tell legend exactly which ones to plot:
hleg1 = legend([h1 h2],'cos_x','sin_x'); 