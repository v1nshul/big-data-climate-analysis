%% Plotting graphs in Matlab
clear all
close all


%% Show two plots on different y-axes
%% 1000 data processed
x1Vals = [1000,5000];
y1Vals = [2.16,73.1];
figure(1)
yyaxis left
plot(x1Vals, y1Vals, '-bd')
xlabel('Number of Processors')
ylabel('Processing time (s)')
title('Processing time vs number of processors')


%% 1,000 data processed seq pro
x2Vals = [3.97,25.48];
y2Vals = [1000, 5000];
figure(1)
yyaxis right
plot(x2Vals, y2Vals, '-rx')
xlabel('Number of Processors')
ylabel('Processing time (s)')
title('Processing time vs number of processors')

legend('250 Data', '5,000 Data')


%% Show two plots on same y-axis
%% Mean processing time
y1MeanVals = y1Vals / 1000;
y2MeanVals = y2Vals / 1000;

figure(2)
plot(x1Vals, y1MeanVals, '-bd')
hold on
plot(x2Vals, y2MeanVals, '-rx')
xlabel('Number of Processors')
ylabel('Processing time (s)')
title('parallel Processing time vs sequential processing')
legend('1000 Data', '5,000 Data')