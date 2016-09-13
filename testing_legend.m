

t=1:1:2000;
s1=5*t;
s2=1*t;

figure;set(gca,'colororder',[0 0 1;0 1 0],'nextplot','add')
plot(s1); hold on; plot(s2);
x={'test', 'test2'};
legend(x)


%%%%%%%%%%
I can't reproduce this problem either (using 2006a).
But you can force legend to work properly by giving each plot a
handle:
h1=plot(x,cos(x),'-ro');
hold on
h2=plot(x,sin(x),'-.b');
hold off
then tell legend exactly which ones to plot:
hleg1 = legend([h1 h2],'cos_x','sin_x'); 


%% cell to string

s = sprintf('%s\n', x{:})
s
