%final code base
%% This script allows you to open and explore the data in a *.nc file
clear all % clear all variables
close all % close all windows

FileName = 'C:\Users\Vanshul Kumar\Downloads\Model\o3_surface_20180701000000.nc'; % define the name of the file to be used, the path is included
Contents = ncinfo(FileName);


final_seq_proc_1(FileName)   
final_parallelProcessing(FileName)