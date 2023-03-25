function ParallelProcessing
%% 1: Load Data
clear all
close all

FileName = 'C:\Users\Vanshul Kumar\Downloads\Model\o3_surface_20180701000000.nc';

Contents = ncinfo(FileName);

Lat = ncread(FileName, 'lat');
Lon = ncread(FileName, 'lon');
NumHours = 1;

%% 2: Processing parameters
% ##  provided by customer  ##
RadLat = 30.2016;
RadLon = 24.8032;
RadO3 = 4.2653986e-08;

NaNErrors = 0;

StartLat = 1;
NumLat = 400;
StartLon = 1;
NumLon = 700;

%% 3: Pre-allocate output array memory
% the '-4' value is due to the analysis method resulting in fewer output
% values than the input array.
NumLocations = (NumLon - 4) * (NumLat - 4);
EnsembleVectorPar = zeros(NumLocations, NumHours); % pre-allocate memory

%% 4: Cycle through the hours and load all the models for each hour and record memory use

Num2Process = 1000;
Steps = 100;
tic
for idxTime = 1:NumHours

    %% 5: Load the data for each hour
    DataLayer = 1;
    for idx = [1, 2, 4, 5, 6, 7, 8]
        HourlyData(DataLayer,:,:) = ncread(FileName, Contents.Variables(idx).Name,...
            [StartLon, StartLat, idxTime], [NumLon, NumLat, 1]);
        DataLayer = DataLayer + 1;
    end
    
    %% 6: Pre-process the data for parallel processing
    [Data2Process, LatLon] = PrepareData(HourlyData, Lat, Lon);
   
    
%% Parallel Analysis
    %% 7: Create the parallel pool and attach files for use
    PoolSize = 4 ; % define the number of processors to use in parallel
    if isempty(gcp('nocreate'))
        parpool('local',PoolSize);
    end
    poolobj = gcp;
    addAttachedFiles(poolobj,{'EnsembleValue'});
    
    % Define data options for automated testing
    DataOptions = {Data2Process};
    % Define worker options for automated testing
    WorkerOptions = {LatLon, RadLat, RadLon, RadO3};
    % Define expected output for automated testing
    ExpectedOutput = [];
    
    % Run automated testing
    TestResults = AutomatedTesting(@EnsembleValue, DataOptions, WorkerOptions, ExpectedOutput);
    
    % Check if any tests failed
    if any(~[TestResults.Passed])
        warning('One or more tests failed!');
    end

    DataQ = parallel.pool.DataQueue; % Create a variable in the parallel pool
    N = Num2Process/Steps; % the total number of data to process
    p = 1; % offset so the waitbar shows some colour quickly.
    
    %% 9: The actual parallel processing!
    T4 = toc;
    parfor idx = 1: Num2Process
        [EnsembleVectorPar(idx, idxTime)] = EnsembleValue(Data2Process(idx,:,:,:), LatLon, RadLat, RadLon, RadO3);
        if idx/Steps == ceil(idx/Steps)
            send(DataQ, idx/Steps);
        end
    end    
    T3(idxTime) = toc - T4; 
    fprintf('Parallel processing time for hour %i : %.1f s\n', idxTime, T3(idxTime))
end
