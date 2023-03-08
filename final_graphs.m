% Total data
total_data = 6945100;

% Processing time for 10,000 data points with 4 workers in my pc
data_points = 50000;
workers = 4;
processing_time = 69.9

% Processing speed and time for all data points
processing_speed = (data_points / processing_time) / workers;
total_processing_time = total_data / (processing_speed * workers);

% Range of workers to plot
num_workers = 1:20;

% Calculate processing time for each number of workers
processing_times = total_data ./ (processing_speed * num_workers) /3600;

% Plot the results
plot(num_workers, processing_times, 'b.-', 'LineWidth', 2, 'MarkerSize', 20);
xlabel('Number of Workers');
ylabel('Total Processing Time (hours)');
title('Relationship Between Number of Workers and Total Processing Time');
grid on;

figure(2)
% Constants
total_data = 277804 * 25;
subset_data = 10000;
subset_time = 29;
total_time = subset_time * (total_data / subset_data);

% Processing speed
processing_speed = (subset_data / subset_time);
 
% Time per datum as a function of the number of workers
num_workers = 1:20;
time_per_datum = (total_time ./ total_data) ./ num_workers;

% Plot the results
plot(num_workers, time_per_datum, 'b-o', 'LineWidth', 2)
xlabel('Number of Workers')
ylabel('Time per Datum (s)')
title('Time per Datum as a Function of the Number of Workers')
grid on