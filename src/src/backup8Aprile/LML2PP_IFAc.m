
clear all
close all
% [dayinit, timeresolution, spaceresolution]=GUI
% get defaults and directories of input L1B products and L2 output
%load('./conf/Configuration.mat') ;
%Path_HydroGNSS_Data = uigetdir(Path_HydroGNSS_Data, 'Select input L1B data folder') ; 
%Path_HydroGNSS_ProcessedData=uigetdir(Path_HydroGNSS_ProcessedData, 'Select output data folder') ;
%Path_Auxiliary=uigetdir(Path_Auxiliary, 'Select Auxiliary files folder') ;
metadata_name='metadata_L1_merged.nc' ; 
Path_HydroGNSS_Data = uigetdir('./', 'Select input L1B data folder') ; 
Path_HydroGNSS_ProcessedData=uigetdir('./', 'Select output data folder') ;
Path_Auxiliary=uigetdir('./', 'Select Auxiliary files folder') ;

%save('./conf/Configuration.mat', 'Path_HydroGNSS_Data', 'Path_HydroGNSS_ProcessedData',...
    'Path_Auxiliary', 'metadata_name', '-append') ;

% get day of product and number of day to process
init_SM_Day=datetime(2010, 9, 9) ; 
SM_Time_resolution= 1 ;

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

% loop on Groups (i.e., tracks) within each 6-hours segment 
Num_Groups=3 ; % WARNING!!!!  THIS IS NEEDED TO READ ONLY A PORTION OF THE SSTL SAMPLE FILE
for kk=1:Num_Groups ; 

disp(['Six-hour ', num2str(jj), ' of ', num2str(Num_sixhours), ' - Group/Track ', num2str(kk), ' of ', num2str(Num_Groups)]) ; 
[a NumberOfChannels]=size(infometa.Groups(kk).Groups) ; 

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
ReflectionCoefficientAtSP(kk).SpecularPointLon=read ; 

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
      
end % end loop on channels 
        


end % end loop on number of groups/tracks
end % end loop on number of six-hour blocks 
end % end loop on number of days

% Selecte only GPS L1 signal for L2PP (placeholder)

[a Num_records]=size(ReflectionCoefficientAtSP) ; 
ReflCoeff_L1_LHCP=[] ;  
for ii=1:Num_records ; 
    [Num_L1_LHCP b]=size(ReflectionCoefficientAtSP(ii).L1_LHCP) ; 
if Num_L1_LHCP >0
    ReflCoeff_L1_LHCP =[ReflCoeff_L1_LHCP;   ReflectionCoefficientAtSP(ii).L1_LHCP] ; 
    SpecularPointLat =[SpecularPointLat;   ReflectionCoefficientAtSP(ii).SpecularPointLat] ; 
    SpecularPointLon =[SpecularPointLon;   ReflectionCoefficientAtSP(ii).SpecularPointLon] ; 
end
end

% create map of mean observables in an EASE grid reference
[column,row] = easeconv(SpecularPointLat,SpecularPointLon, "low");
column(find(column <=0))=1 ; % problem with easeconv
row(find(row <= 0))=1 ; % problem with easeconv

Map_Reflectivity =accumarray([column row],ReflCoeff_L1_LHCP, [], @mean) ;
figure, imagesc(10*log10(Map_Reflectivity)')
save('workspace.mat') ; 
