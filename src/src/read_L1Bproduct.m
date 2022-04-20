
function [ReflectionCoefficientAtSP, Sigma0, DataTag]=read_L1Bproduct(init_SM_Day,...
    SM_Time_resolution, Path_HydroGNSS_Data, metadata_name, readDDM, DDMs_name) ; 

% ***********  loop on number of days to process for a single map
formatSpec='%02u' ; 
for j=1: SM_Time_resolution ; 
    SM_Day=init_SM_Day+1-j  ; 
Month=month(SM_Day)  ; Day=day(SM_Day)   ; Year=year(SM_Day)   ; 
Path_L1B_day=[Path_HydroGNSS_Data,'\', num2str(Year),'-', num2str(Month, formatSpec),'\',num2str(Day,formatSpec)] ;
D=dir(Path_L1B_day) ; 
Num_sixhours=0 ; 
if length(D)==0 , disp('No L1B data found'), quit , end; 
for jj=3:length(D)  ; % 
if D(jj).isdir==1 , Num_sixhours=Num_sixhours+1 ;  end  ;  ; 
end    
% Num_sixhours=length(D)-2 ; 
disp(['Reading Year=', num2str(Year), ' Month=', num2str(Month), ' Day=', num2str(Day), ' Num_sixhours=', num2str(Num_sixhours)]) ; 

% create string array with all 6-hours segments within one day 
Dir_Day=[] ; 
% DataTag=[] ; 
for jj=3:Num_sixhours+2 ; 
        Dir_Day= [Dir_Day ; D(jj).name];
end
Dir_Day=string(Dir_Day) ; 

toc
disp('Initiate reading loop of 6-hours') ; 
% ***************  loop on 6-hours segments within one day 
for jj=1:Num_sixhours  ; 
infometa=ncinfo([Path_L1B_day,'\',char(Dir_Day(jj)),'\',metadata_name]) ; 
[a, Num_Groups]=size(infometa.Groups) ; 
DataTag(jj)=convertCharsToStrings(infometa.Attributes(5).Value) ; 
ncid = netcdf.open(fullfile([Path_L1B_day,'\',char(Dir_Day(jj))],metadata_name), 'NC_NOWRITE');
trackNcids = netcdf.inqGrps(ncid);
 for track = 1:length(trackNcids)
    channelNcids(track,:) = netcdf.inqGrps(trackNcids(track));
    for chan = 1:length(channelNcids(track,:))
        coinNcids{track}(chan,:) = netcdf.inqGrps(channelNcids(track,chan));
    end
 end

ncid2 = netcdf.open(fullfile([Path_L1B_day,'\',char(Dir_Day(jj))],DDMs_name), 'NC_NOWRITE');
trackNcids2 = netcdf.inqGrps(ncid2); 
for track = 1:length(trackNcids2)
    channelNcids2(track,:) = netcdf.inqGrps(trackNcids2(track));
    for chan = 1:length(channelNcids2)
        coinNcids2{track}(chan,:) = netcdf.inqGrps(channelNcids2(chan));
    end
 end
toc
disp('Initiate reading loop over groups') ; 
% loop on Groups (i.e., tracks) within each 6-hours segment 
Num_Groups=2 ; % WARNTING: this is to read only one group and speed up
for kk=1:Num_Groups ; 
toc
disp(['Reading Six-hour ', num2str(jj), ' of ', num2str(Num_sixhours), ' - Group/Track ', num2str(kk), ' of ', num2str(Num_Groups)]) ; 
[a NumberOfChannels]=size(infometa.Groups(kk).Groups) ; 

if NumberOfChannels > 0   
% Case of HydroGNSS with several channels. Read specular point data    
ReflectionCoefficientAtSP(kk).Name=['Track n. ', num2str(kk)] ; 
ReflectionCoefficientAtSP(kk).PRN=infometa.Groups(kk).Attributes(8).Value  ; 

varIdTime = netcdf.inqVarID(trackNcids(kk), 'IntegrationMidPointTime');
read=netcdf.getVar(trackNcids(kk), varIdTime);

% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name, '/IntegrationMidPointTime']) ; 
ReflectionCoefficientAtSP(kk).time=read ; 

varId = netcdf.inqVarID(trackNcids(kk), 'SpecularPointLat');
read=netcdf.getVar(trackNcids(kk), varId);

% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name, '/SpecularPointLat']) ; 
ReflectionCoefficientAtSP(kk).SpecularPointLat=read ; 

varId = netcdf.inqVarID(trackNcids(kk), 'SpecularPointLon');
read=netcdf.getVar(trackNcids(kk), varId);
% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name, '/SpecularPointLon']) ;
ReflectionCoefficientAtSP(kk).SpecularPointLon=read ; 


varId = netcdf.inqVarID(trackNcids(kk), 'SPIncidenceAngle');
read=netcdf.getVar(trackNcids(kk), varId);
% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name,'/SPIncidenceAngle']) ;
ReflectionCoefficientAtSP(kk).SPIncidenceAngle= read ; 

varId = netcdf.inqVarID(trackNcids(kk), 'SPAzimuthARF');
read=netcdf.getVar(trackNcids(kk), varId);
% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name,'/SPAzimuthARF']) ;
ReflectionCoefficientAtSP(kk).PAzimuthARF=read ; 

varId = netcdf.inqVarID(trackNcids(kk), 'ReflectionHeight');
read=netcdf.getVar(trackNcids(kk), varId);
% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name,'/ReflectionHeight']) ;
ReflectionCoefficientAtSP(kk).ReflectionHeight= read ; 

% ii count the channels in each track 
for ii=1:NumberOfChannels ; 
    
% Find polarization and channel (Galileo E1, E5 or GPS L1, L5)
Polarization=infometa.Groups(kk).Groups(ii).Attributes(4).Value ; % polarization LHCP or RHCP
Signal=split(infometa.Groups(kk).Groups(ii).Attributes(3).Value, '_') ; 
Signal_Pol=[Signal{2}, '_', Polarization] ; 
switch Signal{1} 
    case 'GPS'
        switch Signal_Pol 
            case 'L1_LHCP' 
%                 ['ReflectionCoefficientAtSP', '.', Signal{2}, '_', Polarization] 

varId = netcdf.inqVarID(coinNcids{kk}(ii,1), 'ReflectionCoefficientAtSP');
read=netcdf.getVar(coinNcids{kk}(ii,1), varId, 'double');

%  read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%      [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%      '/Incoherent/ReflectionCoefficientAtSP']) ;
ReflectionCoefficientAtSP(kk).L1_LHCP=read ; 

varId = netcdf.inqVarID(coinNcids{kk}(ii,1), 'Sigma0');
read=netcdf.getVar(coinNcids{kk}(ii,1), varId, 'double');
% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/Sigma0']) ; 
Sigma0(kk).L1_LHCP=read ; 

if readDDM=="Yes" | readDDM=="Y"
    
varId = netcdf.inqVarID(coinNcids2{kk}(ii,1), 'DDM');  
read=netcdf.getVar(coinNcids2{kk}(ii,1), varId, 'uint16');

% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', DDMs_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/DDM']) ;
Sigma0(kk).DDMs=read ; 
end

            case 'L1_RHCP'
varId = netcdf.inqVarID(coinNcids{kk}(ii,1), 'ReflectionCoefficientAtSP');
read=netcdf.getVar(coinNcids{kk}(ii,1), varId, 'double');
                
% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/ReflectionCoefficientAtSP']) ;                
ReflectionCoefficientAtSP(kk).L1_RHCP=read ; 

varId = netcdf.inqVarID(coinNcids{kk}(ii,1), 'Sigma0');
read=netcdf.getVar(coinNcids{kk}(ii,1), varId, 'double');

% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/Sigma0']) ;
Sigma0(kk).L1_RHCP=read ;   

if readDDM=="Yes" | readDDM=="Y"

varId = netcdf.inqVarID(coinNcids2{kk}(ii,1), 'DDM');  
read=netcdf.getVar(coinNcids2{kk}(ii,1), varId, 'uint16');

% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', DDMs_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/DDM']) ;

Sigma0(kk).DDMs=read ; 
end
            case 'L5_LHCP' 

varId = netcdf.inqVarID(coinNcids{kk}(ii,1), 'ReflectionCoefficientAtSP');
read=netcdf.getVar(coinNcids{kk}(ii,1), varId, 'double');

% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/ReflectionCoefficientAtSP']) ;
ReflectionCoefficientAtSP(kk).L5_LHCP=read ; 

varId = netcdf.inqVarID(coinNcids{kk}(ii,1), 'Sigma0');
read=netcdf.getVar(coinNcids{kk}(ii,1), varId, 'double');
% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/Sigma0']) ;
Sigma0(kk).L5_LHCP= read ; 

if readDDM=="Yes" | readDDM=="Y"

varId = netcdf.inqVarID(coinNcids2{kk}(ii,1), 'DDM');  
read=netcdf.getVar(coinNcids2{kk}(ii,1), varId, 'uint16');

% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', DDMs_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/DDM']) ;
Sigma0(kk).DDMs=read ; 
end

            case 'L5_RHCP' 
   
varId = netcdf.inqVarID(coinNcids{kk}(ii,1), 'ReflectionCoefficientAtSP');
read=netcdf.getVar(coinNcids{kk}(ii,1), varId, 'double');

% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/ReflectionCoefficientAtSP']) ;
ReflectionCoefficientAtSP(kk).L5_RHCP=read ; 

varId = netcdf.inqVarID(coinNcids{kk}(ii,1), 'Sigma0');
read=netcdf.getVar(coinNcids{kk}(ii,1), varId, 'double');
% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/Sigma0']) ;
Sigma0(kk).R5_LHCP=read ; 

if readDDM=="Yes" | readDDM=="Y"

varId = netcdf.inqVarID(coinNcids2{kk}(ii,1), 'DDM');  
read=netcdf.getVar(coinNcids2{kk}(ii,1), varId, 'uint16');

% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', DDMs_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/DDM']) ;
Sigma0(kk).DDMs=read ; 
end

      otherwise
        disp('NO GPS signal') 

      end  % end switch case GPS 
    
case 'Galileo'
    
    switch Signal_Pol 
      case 'E1_LHCP' 
%                 ['ReflectionCoefficientAtSP', '.', Signal{2}, '_', Polarization] 

varId = netcdf.inqVarID(coinNcids{kk}(ii,1), 'ReflectionCoefficientAtSP');
read=netcdf.getVar(coinNcids{kk}(ii,1), varId, 'double');

% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/ReflectionCoefficientAtSP']) ;
ReflectionCoefficientAtSP(kk).E1_LHCP=read ; 

varId = netcdf.inqVarID(coinNcids{kk}(ii,1), 'Sigma0');
read=netcdf.getVar(coinNcids{kk}(ii,1), varId, 'double');
% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/Sigma0']) ;
Sigma0(kk).E1_LHCP=read ; 

if readDDM=="Yes" | readDDM=="Y"

varId = netcdf.inqVarID(coinNcids2{kk}(ii,1), 'DDM');  
read=netcdf.getVar(coinNcids2{kk}(ii,1), varId, 'uint16');

% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', DDMs_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/DDM']) ;
Sigma0(kk).DDMs=read ; 
end

      case 'E1_RHCP'

varId = netcdf.inqVarID(coinNcids{kk}(ii,1), 'ReflectionCoefficientAtSP');
read=netcdf.getVar(coinNcids{kk}(ii,1), varId, 'double');          
% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/ReflectionCoefficientAtSP']) ;                
ReflectionCoefficientAtSP(kk).E1_RHCP=read ; 

varId = netcdf.inqVarID(coinNcids{kk}(ii,1), 'Sigma0');
read=netcdf.getVar(coinNcids{kk}(ii,1), varId, 'double');
% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/Sigma0']) ;
Sigma0(kk).E1_RHCP=read ;       

if readDDM=="Yes" | readDDM=="Y"

varId = netcdf.inqVarID(coinNcids2{kk}(ii,1), 'DDM');  
read=netcdf.getVar(coinNcids2{kk}(ii,1), varId, 'uint16');

% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', DDMs_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/DDM']) ;
Sigma0(kk).DDMs=read ; 
end

        case 'E5_LHCP' 
            
varId = netcdf.inqVarID(coinNcids{kk}(ii,1), 'ReflectionCoefficientAtSP');
read=netcdf.getVar(coinNcids{kk}(ii,1), varId, 'double');               
% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/ReflectionCoefficientAtSP']) ;
ReflectionCoefficientAtSP(kk).E5_LHCP= read ; 

varId = netcdf.inqVarID(coinNcids{kk}(ii,1), 'Sigma0');
read=netcdf.getVar(coinNcids{kk}(ii,1), varId, 'double');
% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/Sigma0']) ;
Sigma0(kk).E5_LHCP=read ; 

if readDDM=="Yes" | readDDM=="Y"

varId = netcdf.inqVarID(coinNcids2{kk}(ii,1), 'DDM');  
read=netcdf.getVar(coinNcids2{kk}(ii,1), varId, 'uint16');

% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', DDMs_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/DDM']) ;
Sigma0(kk).DDMs=read ; 
end
        case 'E5_RHCP' 
    
varId = netcdf.inqVarID(coinNcids{kk}(ii,1), 'ReflectionCoefficientAtSP');
read=netcdf.getVar(coinNcids{kk}(ii,1), varId, 'double');
% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/ReflectionCoefficientAtSP']) ;
ReflectionCoefficientAtSP(kk).E5_RHCP=read ; 

varId = netcdf.inqVarID(coinNcids{kk}(ii,1), 'Sigma0');
read=netcdf.getVar(coinNcids{kk}(ii,1), varId, 'double');
% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/Sigma0']) ;
Sigma0(kk).R5_LHCP=read ; 

if readDDM=="Yes" | readDDM=="Y"
    
varId = netcdf.inqVarID(coinNcids2{kk}(ii,1), 'DDM');  
read=netcdf.getVar(coinNcids2{kk}(ii,1), varId, 'uint16');

% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', DDMs_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/DDM']) ;
Sigma0(kk).DDMs=read ; 
end

      otherwise
        disp('NO Galileo signal') 
       
    end  % end switch case Galileo
    otherwise
        disp('NO TX constellation') 
 end  % end switch between signals / pol 

end       % end loop on channels 
        

elseif NumberOfChannels== 0  ; 
read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name], ['/',...
    infometa.Groups(kk).Name,'/IntegrationMidPointTime']) ; 
IntegrationMidPointTime=[IntegrationMidPointTime, read'] ;  
read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name], ['/',...
    infometa.Groups(kk).Name,'/SpecularPointLat']) ; 
SpecularPointLat=[SpecularPointLat, read'] ; 

read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name], ['/',...
    infometa.Groups(kk).Name,'/SpecularPointLon']) ;
SpecularPointLon=[SpecularPointLon, read'] ; 

read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name], ['/',...
    infometa.Groups(kk).Name,'/SPIncidenceAngle']) ;
SPIncidenceAngle=[SPIncidenceAngle read'] ; 

read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name], ['/',...
    infometa.Groups(kk).Name,'/PAzimuthARF']) ;
PAzimuthARF=[PAzimuthARF read'] ; 

read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name], ['/',...
    infometa.Groups(kk).Name,'/ReflectionHeight']) ;
ReflectionHeight=[ReflectionHeight read'] ; 

read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name], ['/',...
    infometa.Groups(kk).Name,'/DDMSNRAtPeakSingleDDM']) ; 
DDMSNRAtPeakSingleDDM=[DDMSNRAtPeakSingleDDM, read'] ; 

read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\DDMs.nc'], ['/',...
    infometa.Groups(kk).Name,'/DDM']) ; 
DDM=cat(3, DDM, read) ; 
% Reading DDMs

% [column,row] = geo2easeGrid(SpecularPointLat,SpecularPointLon);
% AccuDDMSNR =accumarray([row column],10.^(DDMSNRAtPeakSingleDDM/10), [], @mean) ;
    end
end % end loop on number of groups/tracks
netcdf.close(ncid) ; 
netcdf.close(ncid2) ; 
end % end loop on number of six-hour blocks 
end % end loop on number of days

end