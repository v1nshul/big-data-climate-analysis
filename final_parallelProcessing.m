function ParallelProcessing(FileName)
    Contents = ncinfo(FileName);
    Lat = ncread(FileName, 'lat');
    Lon = ncread(FileName, 'lon');
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
        
        PoolSize = WorkerParameter; % define the number of processors to use in parallel
        if isempty(gcp('nocreate'))
            parpool('local', PoolSize);                
        end
        poolobj = gcp;
        addAttachedFiles(poolobj, {'EnsembleValue'});
        
        DataQ = parallel.pool.DataQueue; % Create a variable in the parallel pool
        N = Num2Process / Steps; % the total number of data to process
        p = 1; % offset so the waitbar shows some colour quickly.
        
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
        
        
    end
    
    T2 = toc;
    RunTime = sum(T3);
    fprintf('Total processing time for %i workers and %i data: %.2f s\n', WorkerParameter, DataParameter, RunTime);
    
end % end function