function func_tst_seq()
Options = [1000, 5000, 10000];
for idx1 = 1:size(Options,1)
    LoopParameter = Options(idx1);

    FileName = 'C:\Users\Vanshul Kumar\Downloads\Model\o3_surface_20180701000000.nc';   
    Contents = ncinfo(FileName);   
    Lat = ncread(FileName, 'lat'); 
    Lon = ncread(FileName, 'lon');        
    RadLat = 30.2016; 
    RadLon = 24.8032; 
    RadO3 = 4.2653986e-08; 
    StartLat = 1; 
    NumLat = 400; 
    StartLon = 1; 
    NumLon = 700; 
    NaNErrors = 0;
    NumHours = 1;
    tic
    for NumHour = 1 : size(Options,1) % loop through each hour
        fprintf('Processing hour %i\n', NumHour)
        DataLayer = 1;
        for idx = [1, 2, 4, 5, 6, 7, 8] 
            HourlyData(DataLayer,:,:) = ncread(FileName, Contents.Variables(idx).Name,...
                [StartLon, StartLat, 1], [NumLon, NumLat, 1]);
            DataLayer = DataLayer + 1; % step to the next 'layer'
        end
        % check for NaNs
        if any(isnan(LoopParameter), 'All')
            fprintf('NaNs present\n')
            NaNErrors = 1;
        end

        [Data2Process, LatLon] = PrepareData(HourlyData, Lat, Lon);
        %size(Data2Process,1)
        t1 = toc;
        t2 = t1;
        for idx = 1: LoopParameter  
            [EnsembleVector(idx, NumHour)] = EnsembleValue(Data2Process(idx,:,:,:), LatLon, RadLat, RadLon, RadO3);
            if idx/1000 == ceil( idx/1000)
                tt = toc-t2;
                fprintf('Total %i of %i, last 1000 in %.2f s  predicted time for all data %.1f s\n',...
                    idx, 1000, tt, 1000/1000*25*tt)
                t2 = toc;
            end
        end
        T2(NumHour) = toc - t1; % record the total processing time for this hour
        fprintf('Processing hour %i - %.2f s\n\n', NumHour, sum(T2));
            
    end
    tSeq = toc;
    
    fprintf('Total time for sequential processing = %.2f s\n\n', tSeq)
    Results(idx1,:) = [Options(idx1), tSeq];
end
%printing NaN errors if any 
fprintf('Testing files: %s\n', FileName)
if NaNErrors
    fprintf('NaN errors present!\n')
else
    fprintf('No NaN errors!\n')
end

end