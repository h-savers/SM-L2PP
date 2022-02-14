
clear all

% [dayinit, timeresolution, spaceresolution]=GUI
% get defaults and directories of input L1B products and L2 output
load('./conf/Configuration.mat') ;
% Path_HydroGNSS_Data = uigetdir(Path_HydroGNSS_Data, 'Select input L1B data folder') ; 
% Path_HydroGNSS_ProcessedData=uigetdir(Path_HydroGNSS_ProcessedData, 'Select output data folder') ;
% Path_Auxiliary=uigetdir(Path_Auxiliary, 'Select Auxiliary files folder') ;
metadata_name='metadata_L1_merged.nc' ; 
Path_HydroGNSS_Data = uigetdir('./', 'Select input L1B data folder') ; 
Path_HydroGNSS_ProcessedData=uigetdir('./', 'Select output data folder') ;
Path_Auxiliary=uigetdir('./', 'Select Auxiliary files folder') ;

save('./conf/Configuration.mat', 'Path_HydroGNSS_Data', 'Path_HydroGNSS_ProcessedData',...
    'Path_Auxiliary', 'metadata_name', '-append') ;

% Day = uidatepicker ; 
% get day of product and number of day to process
Year=2010;
Month=9 ; 
Day=9 ; 
init_SM_Day=datetime(2010, 9, 9) ; 
SM_Time_resolution= 1 ;
% DOY_Num=[213:1:365];
% DOY_Num=DOY_Num.' ; 
% 

% [j jj]=size(DOY_Num); 
% clear jj
% for i=1:j
%     if length(num2str(DOY_Num(i,:)))==1
%         dir=strcat('00',num2str(DOY_Num(i,:)));
%         DirectoryIndices(i,:)=dir;
%         clear dir
%     elseif length(num2str(DOY_Num(i,:)))==2
%         dir=strcat('0',num2str(DOY_Num(i,:)));
%         DirectoryIndices(i,:)=dir;
%         clear dir
%      elseif length(num2str(DOY_Num(i,:)))==3
%         dir=num2str(DOY_Num(i,:));
%         DirectoryIndices(i,:)=dir;
%         clear dir
%      end
% end
% clear j
% [NumIndices k]=size(DirectoryIndices);
% clear k

% Reading auxiliary data 
% Reading landuse in EASE grid 25 km
load([Path_Auxiliary,'/Landuse/lccs_EASE25km_no190-210-220.mat']) ; 
% Reading DEM in EASE grid 25 km
% load([Path_Auxiliary,'/DEM/lccs_EASE25km_no190-210-220.mat']) ; 


IntegrationMidPointTime=[] ; 
SpecularPointLat=[] ; 
SpecularPointLon=[] ; 
SPIncidenceAngle=[] ; 
DDMSNRAtPeakSingleDDM=[] ; 
PAzimuthARF=[] ; 
ReflectionHeight=[] ; 
ReflectionCoefficientAtSP.Name='ReflectionCoefficient' ; 
ReflectionCoefficientAtSP.L1_LHCP=[] ; 
ReflectionCoefficientAtSP.L1_RHCP=[] ; 
ReflectionCoefficientAtSP.L5_LHCP=[] ; 
ReflectionCoefficientAtSP.L5_RHCP=[] ; 
ReflectionCoefficientAtSP.E1_LHCP=[] ; 
ReflectionCoefficientAtSP.E1_RHCP=[] ; 
ReflectionCoefficientAtSP.E5_LHCP=[] ; 
ReflectionCoefficientAtSP.E5_RHCP=[] ; 

Sigma0.Name='Sigma0' ; 
Sigma0.L1_LHCP=[] ; 
Sigma0.L1_RHCP=[] ; 
Sigma0.L5_LHCP=[] ; 
Sigma0.L5_RHCP=[] ; 
Sigma0.E1_LHCP=[] ; 
Sigma0.E1_RHCP=[] ; 
Sigma0.E5_LHCP=[] ; 
Sigma0.E5_RHCP=[] ; 

Map_Reflectivity_dB=[] ; 
DDM=[] ; 

% loop on number of days to process for a single map
formatSpec='%02u' ; 
for j=1: SM_Time_resolution ; 
    SM_Day=init_SM_Day+1-j  ; 
Month=month(SM_Day)  ; Day=day(SM_Day)   ; Year=year(SM_Day)   ; 
Path_L1B_day=[Path_HydroGNSS_Data,'\', num2str(Year),'-', num2str(Month, formatSpec),'\',num2str(Day,formatSpec)] ;
D=dir(Path_L1B_day) ; 
Num_sixhours=0 ; 
for jj=3:length(D)  ; % 
if D(jj).isdir==1 , Num_sixhours=Num_sixhours+1 ;  end  ;  ; 
end    
% Num_sixhours=length(D)-2 ; 
disp(['Year=', num2str(Year), ' Month=', num2str(Month), ' Day=', num2str(Day), ' Num_sixhours=', num2str(Num_sixhours)]) ; 

% create string array with all 6-hours segments within one day 
Dir_Day=[] ; 
for jj=3:Num_sixhours+2 ; 
        Dir_Day= [Dir_Day ; D(jj).name];
end
Dir_Day=string(Dir_Day) ; 

% loop on 6-hours segments within one day 
for jj=1:Num_sixhours  ; 
infometa=ncinfo([Path_L1B_day,'\',char(Dir_Day(jj)),'\',metadata_name]) ; 
[a, Num_Groups]=size(infometa.Groups) ; 

% These are in the new file only 
% NumberOfTracks=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\',metadata_name], 'NumberOfTracks') ; 
% NumberOfPolarisations=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\',metadata_name], 'NumberOfPolarisations') ; 
% NumberOfFrequencies=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\',metadata_name], 'NumberOfFrequencies') ; 

% loop on Groups (i.e., tracks) within each 6-hours segment 
%  Num_Groups=5 ; 
for kk=1:Num_Groups ; 
% IntegrationMidPointTime=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name'], ['/',...
%     infometa.Groups(1).Name,'/IntegrationMidPointTime']) ; 
% SpecularPointLat=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name'], ['/',...
%     infometa.Groups(1).Name,'/SpecularPointLat']) ; 
% SpecularPointLon=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name'], ['/',...
%     infometa.Groups(1).Name,'/SpecularPointLon']) ; 
% DDMSNRAtPeakSingleDDM=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name'], ['/',...
%     infometa.Groups(1).Name,'/DDMSNRAtPeakSingleDDM']) ; 
disp(['Six-hour ', num2str(jj), ' of ', num2str(Num_sixhours), ' - Group/Track ', num2str(kk), ' of ', num2str(Num_Groups)]) ; 
[a NumberOfChannels]=size(infometa.Groups(kk).Groups) ; 

if NumberOfChannels > 0   
% Case of HydroGNSS with several channels. Read specular point data    
ReflectionCoefficientAtSP(kk).Name=['Track n. ', num2str(kk)] ; 
ReflectionCoefficientAtSP(kk).PRN=infometa.Groups(kk).Attributes(8).Value  ; 

read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
    [infometa.Groups(kk).Name, '/IntegrationMidPointTime']) ; 
% IntegrationMidPointTime=[IntegrationMidPointTime, read'] ;  
ReflectionCoefficientAtSP(kk).time=read ; 

read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
    [infometa.Groups(kk).Name, '/SpecularPointLat']) ; 
% SpecularPointLat=[SpecularPointLat, read'] ; 
ReflectionCoefficientAtSP(kk).SpecularPointLat=read ; 

read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
    [infometa.Groups(kk).Name, '/SpecularPointLon']) ;
% SpecularPointLat=[SpecularPointLon, read'] ; 
ReflectionCoefficientAtSP(kk).SpecularPointLat=read ; 

read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
    [infometa.Groups(kk).Name,'/SPIncidenceAngle']) ;
% SPIncidenceAngle=[SPIncidenceAngle read'] ; 
ReflectionCoefficientAtSP(kk).SPIncidenceAngle= read ; 

read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
    [infometa.Groups(kk).Name,'/SPAzimuthARF']) ;
% PAzimuthARF=[PAzimuthARF read'] ; 
ReflectionCoefficientAtSP(kk).PAzimuthARF=read ; 

read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
    [infometa.Groups(kk).Name,'/ReflectionHeight']) ;
% ReflectionHeight=[ReflectionHeight read'] ; 
ReflectionCoefficientAtSP(kk).ReflectionHeight= read ; 
% ii count the channels in each track 
for ii=1:NumberOfChannels ; 
    
% Find polarization and channel (Galileo E1, E5 or GPS L1, L5)
Polarization=infometa.Groups(kk).Groups(ii).Attributes(4).Value ; % polarizaion LHCP or RHCP
% Signal=infometa.Groups(kk).Groups(ii).Attributes(3).Value ; % signal Galileo_E1, etc. 
Signal=split(infometa.Groups(kk).Groups(ii).Attributes(3).Value, '_') ; 
Signal_Pol=[Signal{2}, '_', Polarization] ; 
switch Signal{1} 
    case 'GPS'
        switch Signal_Pol 
            case 'L1_LHCP' 
%                 ['ReflectionCoefficientAtSP', '.', Signal{2}, '_', Polarization] 

read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
    [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
    '/Incoherent/ReflectionCoefficientAtSP']) ;
% ReflectionCoefficientAtSP(kk).L1_LHCP=[ReflectionCoefficientAtSP(kk).L1_LHCP read'] ; 
ReflectionCoefficientAtSP(kk).L1_LHCP=read ; 

read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
    [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
    '/Incoherent/Sigma0']) ;
% Sigma0(kk).E1_LHCP=[Sigma0(kk).E1_LHCP read'] ; 
Sigma0(kk).L1_LHCP=read ; 

            case 'L1_RHCP'
                
read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
    [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
    '/Incoherent/ReflectionCoefficientAtSP']) ;                
% ReflectionCoefficientAtSP(kk).L1_RHCP=[ReflectionCoefficientAtSP(kk).L1_RHCP read'] ; 
ReflectionCoefficientAtSP(kk).L1_RHCP=read

read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
    [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
    '/Incoherent/Sigma0']) ;
% Sigma0(kk).L1_RHCP=[Sigma0(kk).L1_RHCP read'] ; 
Sigma0(kk).L1_RHCP=read ;       

            case 'L5_LHCP' 
read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
    [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
    '/Incoherent/ReflectionCoefficientAtSP']) ;
ReflectionCoefficientAtSP(kk).L5_LHCP=[ReflectionCoefficientAtSP(kk).L5_LHCP read'] ; 

read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
    [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
    '/Incoherent/Sigma0']) ;
Sigma0(kk).L5_LHCP=[Sigma0(kk).L5_LHCP read'] ; 

            case 'L5_RHCP' 
    
read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
    [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
    '/Incoherent/ReflectionCoefficientAtSP']) ;
ReflectionCoefficientAtSP(kk).L5_RHCP=[ReflectionCoefficientAtSP(kk).L5_RHCP read'] ; 

read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
    [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
    '/Incoherent/Sigma0']) ;
Sigma0(kk).R5_LHCP=[Sigma0(kk).L5_RHCP read'] ; 

      otherwise
        disp('NO signal') 

      end  % end switch case GPS 
    
case 'Galileo'
    
    switch Signal_Pol 
      case 'E1_LHCP' 
%                 ['ReflectionCoefficientAtSP', '.', Signal{2}, '_', Polarization] 

read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
    [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
    '/Incoherent/ReflectionCoefficientAtSP']) ;
% ReflectionCoefficientAtSP(kk).L1_LHCP=[ReflectionCoefficientAtSP(kk).L1_LHCP read'] ; 
ReflectionCoefficientAtSP(kk).E1_LHCP=read ; 

read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
    [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
    '/Incoherent/Sigma0']) ;
% Sigma0(kk).E1_LHCP=[Sigma0(kk).E1_LHCP read'] ; 
Sigma0(kk).E1_LHCP=read ; 

      case 'E1_RHCP'
                
read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
    [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
    '/Incoherent/ReflectionCoefficientAtSP']) ;                
% ReflectionCoefficientAtSP(kk).L1_RHCP=[ReflectionCoefficientAtSP(kk).L1_RHCP read'] ; 
ReflectionCoefficientAtSP(kk).E1_RHCP=read

read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
    [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
    '/Incoherent/Sigma0']) ;
% Sigma0(kk).L1_RHCP=[Sigma0(kk).L1_RHCP read'] ; 
Sigma0(kk).E1_RHCP=read ;       

        case 'E5_LHCP' 
read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
    [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
    '/Incoherent/ReflectionCoefficientAtSP']) ;
ReflectionCoefficientAtSP(kk).E5_LHCP=[ReflectionCoefficientAtSP(kk).L5_LHCP read'] ; 

read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
    [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
    '/Incoherent/Sigma0']) ;
Sigma0(kk).E5_LHCP=[Sigma0(kk).E5_LHCP read'] ; 

        case 'E5_RHCP' 
    
read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
    [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
    '/Incoherent/ReflectionCoefficientAtSP']) ;
ReflectionCoefficientAtSP(kk).E5_RHCP=[ReflectionCoefficientAtSP(kk).L5_RHCP read'] ; 

read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
    [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
    '/Incoherent/Sigma0']) ;
Sigma0(kk).R5_LHCP=[Sigma0(kk).E5_RHCP read'] ; 

      otherwise
        disp('NO signal') 
       
    end  % end switch case Galileo
    otherwise
        disp('NO TX constellation') 
 end  % end switch between signals / pol 
      
% Read observables as structure and fill structure 
% channel(ii)=[Polarization, Signal] ; 
% switch channel ;
%     case 'LHCPGalileo_E1'
% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/ReflectionCoefficientAtSP']) ;
% ReflectionCoefficientAtSP.E1_LHCP=[ReflectionCoefficientAtSP.E1_LHCP read'] ; 
% 
% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/Sigma0']) ;
% Sigma0.E1_LHCP=[Sigma0.E1_LHCP read'] ; 
%     
%     case 'LHCPGPS_L1' 
% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/ReflectionCoefficientAtSP']) ;
% ReflectionCoefficientAtSP.L1_LHCP=[ReflectionCoefficientAtSP.L1_LHCP read'] ; 
% 
% read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\', metadata_name],...
%     [infometa.Groups(kk).Name,'/', infometa.Groups(kk).Groups(ii).Name,...
%     '/Incoherent/Sigma0']) ;
% Sigma0.L1_LHCP=[Sigma0.L1_LHCP read'] ; 
% 
%     otherwise
%         disp('NO signal') 
% end

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
end
end
end

% create map of mean observables in an EASE grid reference 
% [column,row] = geo2easeGrid(SpecularPointLat',180+SpecularPointLon');
[column,row] = easeconv(SpecularPointLat',SpecularPointLon', "low");
% AccuDDMSNR =accumarray([row column],10.^(DDMSNRAtPeakSingleDDM/10), [], @mean) ;
% AccuDDMSNR =accumarray([column+200 row+200],10.^(DDMSNRAtPeakSingleDDM/10), [], @mean) ;
column(find(column <=0))=1 ; % problem with easeconv
row(find(row <= 0))=1 ; % problem with easeconv
save('wotkspace.mat') ; 
% Map_Reflectivity =accumarray([column row],10.^(DDMSNRAtPeakSingleDDM/10), [], @mean) ;
% Map_Reflectivity(find(Map_Reflectivity ==0))=NaN ; 
% figure, imagesc(10*log10(Map_Reflectivity)')

% pippo=lccs_class(74000:76000, 40000:41000) ;
% pippo_lon=lon(74000:76000) ;
% pippo_lat=lat(40000:41000) ;
% 
% lonpippo=pippo ;
% latpippo=pippo ;
% for i=1:1001 , lonpippo(:, i)=pippo_lon;  end
% for i=1:2001 , latpippo(i ,:)=pippo_lat; , end
% 
% pippo=pippo(:) ; 
% lonpippo=lonpippo(:) ; 
% latpippo=latpippo(:) ; 
% [column,row] = easeconv(latpippo,lonpippo, "low") ;
% AccuDDMSNR =accumarray([column row],pippo, [], @mean) ;



% lon=ncread('ESACCI-LC-L4-LCCS-Map-300m-P1Y-2015-v2.0.7b.nc', 'lon') ;
% lat=ncread('ESACCI-LC-L4-LCCS-Map-300m-P1Y-2015-v2.0.7b.nc', 'lat') ;
% lccs_class=ncread('ESACCI-LC-L4-LCCS-Map-300m-P1Y-2015-v2.0.7b.nc', 'lccs_class') ;
% 
% lonpippo=lccs_class ;
% latpippo=lccs_class ;
% for i=1:129600 , lonpippo(:, i)=lon; , end
% for i=1:64800 , latpippo(i ,:)=lat; , end
% 
% pippo=lccs_class(:) ; 
% lonpippo=lonpippo(:) ; 
% latpippo=latpippo(:) ; 
% [column,row] = easeconv(latpippo,lonpippo, "low") ;
% AccuDDMSNR =accumarray([column row],pippo, [], @mode) ;




