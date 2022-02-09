
% clear all

% [dayinit, timeresolution, spaceresolution]=GUI
% get defaults and directories of input L1B products and L2 output
load('./conf/Configuration.mat') ;
Path_HydroGNSS_Data = uigetdir(Path_HydroGNSS_Data, 'Select input L1B data folder') ; 
Path_HydroGNSS_ProcessedData=uigetdir(Path_HydroGNSS_ProcessedData, 'Select output data folder') ;
Path_Auxiliary=uigetdir(Path_Auxiliary, 'Select Auxiliary files folder') ;
save('./conf/Configuration.mat', 'Path_HydroGNSS_Data', 'Path_HydroGNSS_ProcessedData',...
    'Path_Auxiliary', '-append') ;
% Day = uidatepicker ; 
% get day of product and number of day to process
Year=2018;
Month=9 ; 
Day=9 ; 
init_SM_Day=datetime(2018, 9, 9) ; 
SM_Time_resolution= 2 ;
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
DDMSNRAtPeakSingleDDM=[] ; 
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
for jj=3:length(D)  ; 
if D(jj).isdir==1 , Num_sixhours=Num_sixhours+1 ;  end  ;  ; 
end    
% Num_sixhours=length(D)-2 ; 
disp(['Year=', num2str(Year), ' Month=', num2str(Month), ' Day=', num2str(Day), ' Num_sixhours=', num2str(Num_sixhours)]) ; 

% create string array with 6-hours segments within one day 
Dir_Day=[] ; 
for jj=3:Num_sixhours+2
        Dir_Day= [Dir_Day ; D(jj).name];
end
Dir_Day=string(Dir_Day) ; 

% loop on 6-hours segments within one day 
for jj=1:Num_sixhours  ; 
infometa=ncinfo([Path_L1B_day,'\',char(Dir_Day(jj)),'\metadata.nc']) ; 
[a, Num_Groups]=size(infometa.Groups) ; 

% loop on Groups (i.e., tracks) within each 6-hours segment 
for kk=1:Num_Groups ; 
% IntegrationMidPointTime=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\metadata.nc'], ['/',...
%     infometa.Groups(1).Name,'/IntegrationMidPointTime']) ; 
% SpecularPointLat=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\metadata.nc'], ['/',...
%     infometa.Groups(1).Name,'/SpecularPointLat']) ; 
% SpecularPointLon=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\metadata.nc'], ['/',...
%     infometa.Groups(1).Name,'/SpecularPointLon']) ; 
% DDMSNRAtPeakSingleDDM=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\metadata.nc'], ['/',...
%     infometa.Groups(1).Name,'/DDMSNRAtPeakSingleDDM']) ; 
disp(['Six-hour ', num2str(jj), ' of ', num2str(Num_sixhours), ' - Group ', num2str(kk), ' of ', num2str(Num_Groups)]) ; 
read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\metadata.nc'], ['/',...
    infometa.Groups(kk).Name,'/IntegrationMidPointTime']) ; 
IntegrationMidPointTime=[IntegrationMidPointTime, read'] ;  
read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\metadata.nc'], ['/',...
    infometa.Groups(kk).Name,'/SpecularPointLat']) ; 
SpecularPointLat=[SpecularPointLat, read'] ; 
read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\metadata.nc'], ['/',...
    infometa.Groups(kk).Name,'/SpecularPointLon']) ;
SpecularPointLon=[SpecularPointLon read'] ; 
read=ncread([Path_L1B_day,'\',char(Dir_Day(jj)),'\metadata.nc'], ['/',...
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

% create map of mean observables in an EASE grid reference 
% [column,row] = geo2easeGrid(SpecularPointLat',180+SpecularPointLon');
[column,row] = easeconv(SpecularPointLat',SpecularPointLon', "low");
% AccuDDMSNR =accumarray([row column],10.^(DDMSNRAtPeakSingleDDM/10), [], @mean) ;
% AccuDDMSNR =accumarray([column+200 row+200],10.^(DDMSNRAtPeakSingleDDM/10), [], @mean) ;
column(find(column <=0))=1 ; % problem with easeconv
row(find(row <= 0))=1 ; % problem with easeconv
Map_Reflectivity =accumarray([column row],10.^(DDMSNRAtPeakSingleDDM/10), [], @mean) ;
Map_Reflectivity(find(Map_Reflectivity ==0))=NaN ; 
figure, imagesc(10*log10(Map_Reflectivity)')
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



