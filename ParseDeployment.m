function data=ParseDeployment(rawfile,parse_nuc_timestamps,gps_timestamp)
% This function parses data from raw IMU, ADCP, and GPS files. 
% It is called by RHIBproc, but can also be used independently
% usage:
%   data = ParseDeployment(rawfile,parse_nuc_timestamps)


% find all files in deployment folder    
files.adcp = dir(fullfile(rawfile,'ADCP','*ADCP_timestamped*.bin'));
files.imu = dir(fullfile(rawfile,'IMU','IMU_timestamped*.bin'));
isNortek = all(startsWith({files.adcp.name},'Nortek'));

% working on option to include nuc timestamps for GPS (not yet functional)
if gps_timestamp
    files.gps = dir(fullfile(rawfile,'GPS','GPS_timestamped*.log'));
else
    files.gps = dir(fullfile(rawfile,'GPS','GPS_2*.log'));
end

% establish structure to load with parsed data
data=struct('adcp',[],'gps',[],'imu',[]);
fprintf('Parsing data...')

if ~isempty(files.imu)
    fprintf('IMU...')
    try
        data.imu=parse_imu(files.imu,parse_nuc_timestamps);
    catch imu_ME
        warning('\n%s:%s\nIMU will not be parsed.\n',imu_ME.identifier,imu_ME.message);
    end
end

if ~isempty(files.adcp)
    fprintf('ADCP...')
    %***********NORTEK PROCESSING NEEDS TO BE VERIFIED**********
    if isNortek
        error('Nortek processing is not yet functional')
        % data.adcp=parse_nortek_adcp(files.adcp,parse_nuc_timestamps);
    else
        data.adcp=parse_rdi_adcp(files.adcp,parse_nuc_timestamps);
    end
end

if ~isempty(files.gps)
    fprintf('GPS...')
    data.gps=parse_gps(files.gps);
end

fprintf('\nData parsing complete...\n')




