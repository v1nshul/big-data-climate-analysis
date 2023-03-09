function final_seq_proc_1(FileName)
Contents = ncinfo(FileName)
Lat = ncread(FileName, 'lat'); 
Lon = ncread(FileName, 'lon'); 

%% Processing parameters provided by customer
RadLat = 30.2016; 
RadLon = 24.8032; 
RadO3 = 4.2653986e-08; 
%% Cycle through the hours and load all the models for each hour and record memory use
StartLat = 1; 
NumLat = 400; 
StartLon = 1; 
NumLon = 700; 
tic
for NumHour = 1:25 % loop through each hour
    fprintf('Processing hour %i\n', NumHour)
    DataLayer = 1;
    for idx = [1, 2, 4, 5, 6, 7, 8] 
        HourlyData(DataLayer,:,:) = ncread(FileName, Contents.Variables(idx).Name,...
            [StartLon, StartLat, 1], [NumLon, NumLat, 1]);
        DataLayer = DataLayer + 1; % step to the next 'layer'
    end
    [Data2Process, LatLon] = PrepareData(HourlyData, Lat, Lon);
    %size(Data2Process,1)
    t1 = toc;
    t2 = t1;
    for idx = 1: size(Data2Process,1)  
        [EnsembleVector(idx, NumHour)] = EnsembleValue(Data2Process(idx,:,:,:), LatLon, RadLat, RadLon, RadO3);
        if idx/1000 == ceil( idx/1000)
            tt = toc-t2;
            fprintf('Total %i of %i, last 1000 in %.2f s  predicted time for all data %.1f s\n',...
                idx, size(Data2Process,1), tt, size(Data2Process,1)/1000*25*tt)
            t2 = toc;
        end
    end
    T2(NumHour) = toc - t1; % record the total processing time for this hour
    fprintf('Processing hour %i - %.2f s\n\n', NumHour, sum(T2));
    
        
end
tSeq = toc;

fprintf('Total time for sequential processing = %.2f s\n\n', tSeq)
end


