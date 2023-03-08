%final code base
%% This script allows you to open and explore the data in a *.nc file
clear all % clear all variables
close all % close all windows

FileName = 'C:\Users\Vanshul Kumar\Downloads\Model\o3_surface_20180701000000.nc'; % define the name of the file to be used, the path is included
Contents = ncinfo(FileName);

Lat = ncread(FileName, 'lat'); % load the latitude locations
Lon = ncread(FileName, 'lon'); % loadthe longitude locations

%% Processing parameters provided by customer
RadLat = 30.2016; % cluster radius value for latitude
RadLon = 24.8032; % cluster radius value for longitude
RadO3 = 4.2653986e-08; % cluster radius value for the ozone data

%% Cycle through the hours and load all the models for each hour and record memory use
% We use an index named 'NumHour' in our loop
% The section 'sequential processing' will process the data location one
% after the other, reporting on the time involved.

StartLat = 1; % latitude location to start laoding
NumLat = 400; % number of latitude locations to load
StartLon = 1; % longitude location to start loading
NumLon = 700; % number of longitude locations to load
tic
for NumHour = 1:25 % loop through each hour
    fprintf('Processing hour %i\n', NumHour)
    DataLayer = 1; % which 'layer' of the array to load the model data into
    for idx = [1, 2, 4, 5, 6, 7, 8] % model data to load
        % load the model data for one hour only
        HourlyData(DataLayer,:,:) = ncread(FileName, Contents.Variables(idx).Name,...
            [StartLon, StartLat, 1], [NumLon, NumLat, 1]);
        DataLayer = DataLayer + 1; % step to the next 'layer'
    end
    
    % prepare the data for processing
    [Data2Process, LatLon] = PrepareData(HourlyData, Lat, Lon);
    
    % process the data sequentially for one hour
    %size(Data2Process,1)
    t1 = tic;
    for idx = 1: 5000 % step through each data location to process the data
        [EnsembleVector(idx)] = EnsembleValue(Data2Process(idx,:,:,:), LatLon, RadLat, RadLon, RadO3);
    end
    tSeq = toc(t1);
    fprintf('Processing hour %i took %.2f seconds\n', NumHour, tSeq)
    
     % record memory use
    memoryUsage(NumHour) = memory;
    %memoryUsageMb = whos('memoryUsage.MaxPossibleArrayBytes').bytes/1000000;
    fprintf('Memory usage after hour in bytes %i\n', memoryUsage.MaxPossibleArrayBytes )
    %fprintf('Memory used for hourly data: %.2f MB\n', memoryUsageMb)

    %% Parallel Analysis
    %Create the parallel pool and attache files for use
    PoolSize = 4 ; % define the number of processors to use in parallel
    if isempty(gcp('nocreate'))
        parpool('local',PoolSize);
    end
    poolobj = gcp;
    % attaching a file allows it to be available at each processor without
    % passing the file each time. This speeds up the process. For more
    % information, ask your tutor.
    addAttachedFiles(poolobj,{'EnsembleValue'});
    
%     %% 8: Parallel processing is difficult to monitor progress so we define a
%     % special function to create a wait bar which is updated after each
%     % process completes an analysis. The update function is defined at the
%     % end of this script. Each time a parallel process competes it runs the
%     % function to update the waitbar.
    DataQ = parallel.pool.DataQueue; % Create a variable in the parallel pool
    %% 9: The actual parallel processing!
    % Ensemble value is a function defined by the customer to calculate the
    % ensemble value at each location. Understanding this function is not
    % required for the module or the assessment, but it is the reason for
    % this being a 'big data' project due to the processing time (not the
    % pure volume of raw data alone).
    T4 = toc;
    parfor idx = 1: Num2Process % size(Data2Process,1)
        [EnsembleVectorPar(idx, idxTime)] = EnsembleValue(Data2Process(idx,:,:,:), LatLon, RadLat, RadLon, RadO3);
        if idx/Steps == ceil(idx/Steps)
            send(DataQ, idx/Steps);
        [EnsembleVectorPar(idx, idxTime)] = EnsembleValue(Data2Process(idx,:,:,:), LatLon, RadLat, RadLon, RadO3);
        m = memory;
        send(DataQ, [idx/Steps, m.MemUsedMATLAB]);
        end
    end
    
    %close(hWaitBar); % close the wait bar
    
    %T3(idxTime) = toc - T4; % record the parallel processing time for this hour of data
    %fprintf('Parallel processing time for hour %i : %.1f s\n', idxTime, T3(idxTime))
%% printing memory as well. 
    T3(idxTime) = toc - T4; % record the parallel processing time for this hour of data
    m = memory;
    fprintf('Parallel processing time for hour %i : %.1f s   Max Memory Usage: %d MB\n', idxTime, T3(idxTime), int32(m.MemUsedMATLAB/1e6));

    
 % end time loop
T2 = toc;
delete(gcp);

%% 10: Reshape ensemble values to Lat, lon, hour format
EnsembleVectorPar = reshape(EnsembleVectorPar, 696, 396, []);
fprintf('Total processing time for %i workers = %.2f s\n', PoolSize, sum(T3));

end