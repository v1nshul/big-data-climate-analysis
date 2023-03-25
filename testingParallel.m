DataOptions = [1000, 5000, 10000];
WorkerOptions = [2, 4, 6];
Results = [];

for idx1 = 1:size(DataOptions,1)
    DataParameter = DataOptions(idx1);
    for idx2 = 1:size(WorkerOptions,1)

        WorkerParameter = WorkerOptions(idx2);

        FileName = 'C:\Users\Vanshul Kumar\Downloads\Model\o3_surface_20180701000000.nc';
        Contents = ncinfo(FileName);
        Lat = ncread(FileName, 'lat');
        Lon = ncread(FileName, 'lon');
        NaNErrors = 0;
        NumHours = 1;
        RadLat = 30.2016;
        RadLon = 24.8032;
        RadO3 = 4.2653986e-08;
        StartLat = 1;
        NumLat = 400;
        StartLon = 1;
        NumLon = 700;
        NumLocations = (NumLon - 4) * (NumLat - 4);
        EnsembleVectorPar = zeros(NumLocations, NumHours); % pre-allocate memory
        Num2Process = DataParameter;
        Steps = 100;
        tic
        
        for idxTime = 1:NumHours
            DataLayer = 1;
            for idx = [1, 2, 4, 5, 6, 7, 8]
                HourlyData(DataLayer,:,:) = ncread(FileName, Contents.Variables(idx).Name,...
                    [StartLon, StartLat, idxTime], [NumLon, NumLat, 1]);
                DataLayer = DataLayer + 1;
            end
            [Data2Process, LatLon] = PrepareData(HourlyData, Lat, Lon);
            %checking for NaN errors. 
            if any(isnan(Data2Process), 'All')
                fprintf('NaNs present\n')
                NaNErrors = 1;
            end
            
            
            PoolSize = WorkerParameter; % define the number of processors to use in parallel
            if isempty(gcp('nocreate'))
                % If not, create a new pool with a specified number of workers
                poolobj = parpool('local', PoolSize);
            else
                % If yes, retrieve the current pool object
                poolobj = gcp;
                % Check if this is the last iteration for DataOptions or WorkerOptions
                if (idx1 == size(DataOptions, 1)) || (idx2 == size(WorkerOptions, 1))
                    % If yes, delete the current pool object and create a new one with the desired number of workers
                    delete(poolobj);
                    poolobj = parpool('local', PoolSize);
                end
            end
        
            % Attach a file to the current pool
            addAttachedFiles(poolobj, {'EnsembleValue'});
            Num2Process = DataParameter;
            DataQ = parallel.pool.DataQueue; % Create a variable in the parallel pool
            N = Num2Process / Steps; % the total number of data to process
            
            
            %% 9: The actual parallel processing!
            T4 = toc;
            parfor idx = 1:Num2Process
                [EnsembleVectorPar(idx, idxTime)] = EnsembleValue(Data2Process(idx,:,:,:), LatLon, RadLat, RadLon, RadO3);
                if idx/Steps == ceil(idx/Steps)
                    send(DataQ, idx/Steps);
                end
            end
            
            T3(idxTime) = toc - T4;
            fprintf('Parallel processing time for hour %i: %.1f s\n', idxTime, T3(idxTime))
                 
            T2 = toc;
            RunTime = sum(T3);
            fprintf('Total processing time for %i workers and %i data: %.2f s\n', WorkerParameter, DataParameter, RunTime);
            
            Results = [Results; WorkerParameter, DataParameter, T3(idxTime)];
        end  
    end        
end
%printing NaN errors if any 
fprintf('Testing files: %s\n', FileName)
if NaNErrors
    fprintf('NaN errors present!\n')
else
    fprintf('No NaN errors!\n')
end
figure
hold on
for i = 1:length(DataOptions)
    Data = DataOptions(i);
    idx = Results(:,2) == Data;
    plot(Results(idx,1), Results(idx,3), '-o', 'LineWidth', 1.5)
end
xlabel('Number of Workers')
ylabel('Total Processing Time (s)')
title('Impact of Parallel Workers on Processing Time')
legend(string(DataOptions), 'Location', 'northwest')
grid on

  

