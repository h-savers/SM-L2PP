
function SM_main(init_SM_Day,final_SM_Day, SM_Time_resolution, Path_HydroGNSS_Data,Path_Auxiliary,...
     Path_HydroGNSS_ProcessedData,Resolution, metadata_name, DDMs_name,...
     readDDM, Frequency, Polarization, plotTag)
tic
%
if Resolution==25, ngrid_x=1388; ngrid_y=584; else disp('Wrong resolution'), end
%
global model ; 
global ReflectionCoefficientAtSP Sigma0 ; 
%
% *********   Read Auxiliary files
%
load([Path_Auxiliary,'/Landuse/lccs_EASE25km_no190-210-220.mat']) ; 
load([Path_Auxiliary,'/CCIbiomass/agb_EASE25_mean.mat']) ; 
load([Path_Auxiliary,'/DEM/elevation_EASEv2-25km.mat']) ;
Biomass=agb_class_EASE25_mean ;
Elevation= DEM_elevation_EASE25 ;
Slope=DEM_slope_EASE25 ;
Rmsheight=DEM_rmsheight_EASE25 ;
Rmsslope=DEM_rmsslope_EASE25 ; 
%
% *********   Read Auxiliary files
%
% ***** read algorithms model and/or coefficients
%
load('../conf/Coefficients.mat')
% global model ; 
% ***** read algorithms model and/or coefficients
%
% ***** Initialize variables
%
ReflectionCoefficientAtSP={}  ;
Sigma0={}  ; 
IntegrationMidPointTime=[] ; 
% SpecularPointLat=[] ; 
% SpecularPointLon=[] ; 
% SPIncidenceAngle=[] ; 
DDMSNRAtPeakSingleDDM=[] ; 
PAzimuthARF=[] ; 
ReflectionHeight=[] ; 
% ReflectionCoefficientAtSP.Name='ReflectionCoefficient' ; 
ReflectionCoefficientAtSP.Name=[]; 
ReflectionCoefficientAtSP.PRN=[] ; 
ReflectionCoefficientAtSP.TrackIDOrbit=[]  ; 
ReflectionCoefficientAtSP.time=[]  ; 
ReflectionCoefficientAtSP.SpecularPointLat=[]  ; 
ReflectionCoefficientAtSP.SpecularPointLon=[]  ; 
ReflectionCoefficientAtSP.SPIncidenceAngle=[]  ; 
ReflectionCoefficientAtSP.PAzimuthARF=[]  ; 
ReflectionCoefficientAtSP.ReflectionHeight=[]  ; 
ReflectionCoefficientAtSP.L1_LHCP=[] ; 
ReflectionCoefficientAtSP.L1_RHCP=[] ; 
ReflectionCoefficientAtSP.L5_LHCP=[] ; 
ReflectionCoefficientAtSP.L5_RHCP=[] ; 
ReflectionCoefficientAtSP.E1_LHCP=[] ; 
ReflectionCoefficientAtSP.E1_RHCP=[] ; 
ReflectionCoefficientAtSP.E5_LHCP=[] ; 
ReflectionCoefficientAtSP.E5_RHCP=[] ; 

% Sigma0.Name='Sigma0' ; 
Sigma0.L1_LHCP=[] ; 
Sigma0.L1_RHCP=[] ; 
Sigma0.L5_LHCP=[] ; 
Sigma0.L5_RHCP=[] ; 
Sigma0.E1_LHCP=[] ; 
Sigma0.E1_RHCP=[] ; 
Sigma0.E5_LHCP=[] ; 
Sigma0.E5_RHCP=[] ; 

ReflectionHeight=[] ; 
SPIncidenceAngle=[] ; 
Map_Reflectivity_dB=[] ; 
Map_Reflectivity_linear=[] ; 
DDM=[] ; 
Track_ID=0 ; 
IND_sixhours=0 ; 
DataTag="" ; 
%
% ***** Initialize variables
%
% ***** for on the day to be processed
%
num_of_days=datenum(final_SM_Day)-datenum(init_SM_Day)+1 ; 
for ind_day=1: num_of_days ; 
Day_to_process= init_SM_Day+ind_day-1 ;    
%

% ***********  read L1B data
 [DataTag, noday,Track_ID, IND_sixhours]=read_L1Bproduct(DataTag, Day_to_process,...
     SM_Time_resolution, Path_HydroGNSS_Data, metadata_name, readDDM, ...
     DDMs_name,Track_ID, IND_sixhours) ; 
% ***********  read L1B data
if noday==1, continue, end  ;  
%
end 
% ***** end for on the day to be processed
%
% Check if DataTag is unique, otherwise exit with error message 
DataTagUnique   =unique(DataTag) ; 
[a b]=size(DataTagUnique) ; 
% DataTagUnique=replace(DataTagUnique, [':'], ['-']) ; 
% DataTagUnique=replace(DataTagUnique, [' '], ['_']) ;
% DataTagUnique=replace(DataTagUnique, ['/'], ['\']) ;
if b>1 
    disp('WARNING: data Tag is not unique and the data come from different esperiments. Program exiting'), 
    return
else disp(['Data Tag -- ' char(DataTagUnique) ' -- is unique']) ;
end
%
% **********  Selecte only one signal for L2PP (placeholder)
%
[a Num_records]=size(ReflectionCoefficientAtSP) ; 
Signal= [Frequency '_' Polarization 'HCP'] ; 
ReflCoeff_dB=[] ;  
ReflCoeff_linear=[] ;  
SpecularPointLat=[] ; 
SpecularPointLon=[] ;
SPIncidenceAngle=[] ;
IntegrationMidPointTime=[] ; 
ReflectionHeight=[] ;
NameTrack=[] ; 
TrackIDOrbit=[] ; 
%
% Loop on number of tracks of day interval%
%
for ii=1:Num_records ; 
    [Num_SP b]=size(ReflectionCoefficientAtSP(ii).time) ; 
    if Num_SP ==0, continue, end ; % No specular point in a track 
%
switch Signal 

   case 'L1_LHCP' 

%     ReflCoeff_dB=[ReflCoeff_dB;   ReflectionCoefficientAtSP(ii).L1_LHCP] ; 
%     SpecularPointLat =[SpecularPointLat;   ReflectionCoefficientAtSP(ii).SpecularPointLat] ; 
%     SpecularPointLon =[SpecularPointLon;   ReflectionCoefficientAtSP(ii).SpecularPointLon] ; 
%     IntegrationMidPointTime=[IntegrationMidPointTime;   ReflectionCoefficientAtSP(ii).time] ; 
%     ReflectionHeight=[ReflectionHeight; ReflectionCoefficientAtSP(ii).ReflectionHeight] ; 
%     SPIncidenceAngle=[SPIncidenceAngle; ReflectionCoefficientAtSP(ii).SPIncidenceAngle] ; 

    ReflCoeff_dB=ReflectionCoefficientAtSP(ii).L1_LHCP ; 
    SpecularPointLat =ReflectionCoefficientAtSP(ii).SpecularPointLat ; 
    SpecularPointLon =ReflectionCoefficientAtSP(ii).SpecularPointLon ; 
    IntegrationMidPointTime=ReflectionCoefficientAtSP(ii).time ; 
    ReflectionHeight=ReflectionCoefficientAtSP(ii).ReflectionHeight ; 
    SPIncidenceAngle=ReflectionCoefficientAtSP(ii).SPIncidenceAngle ; 
    NameTrack=ReflectionCoefficientAtSP(ii).Name ; 
    TrackIDOrbit=ReflectionCoefficientAtSP(ii).TrackIDOrbit ; 



   case 'L1_RHCP'
% to be edited
    ReflCoeff_dB =[ReflCoeff_dB;   ReflectionCoefficientAtSP(ii).L1_LHCP] ; 
    SpecularPointLat =[SpecularPointLat;   ReflectionCoefficientAtSP(ii).SpecularPointLat] ; 
    SpecularPointLon =[SpecularPointLon;   ReflectionCoefficientAtSP(ii).SpecularPointLon] ; 
    IntegrationMidPointTime=[IntegrationMidPointTime;   ReflectionCoefficientAtSP(ii).time] ; 
    ReflectionHeight=[ReflectionHeight; ReflectionCoefficientAtSP(ii).ReflectionHeight] ; 
    SPIncidenceAngle=[SPIncidenceAngle; ReflectionCoefficientAtSP(ii).SPIncidenceAngle] ; 

    case 'E1_LHCP'
% to be edited to accomodate time resolution > 1

    ReflCoeff_dB =[ReflCoeff_dB;   ReflectionCoefficientAtSP(ii).L1_LHCP] ; 
    SpecularPointLat =[SpecularPointLat;   ReflectionCoefficientAtSP(ii).SpecularPointLat] ; 
    SpecularPointLon =[SpecularPointLon;   ReflectionCoefficientAtSP(ii).SpecularPointLon] ; 
    IntegrationMidPointTime=[IntegrationMidPointTime;   ReflectionCoefficientAtSP(ii).time] ; 
    ReflectionHeight=[ReflectionHeight; ReflectionCoefficientAtSP(ii).ReflectionHeight] ; 
    SPIncidenceAngle=[SPIncidenceAngle; ReflectionCoefficientAtSP(ii).SPIncidenceAngle] ; 

   case 'E1_RHCP'
% to be edited

    ReflCoeff_dB =[ReflCoeff_dB;   ReflectionCoefficientAtSP(ii).L1_LHCP] ; 
    SpecularPointLat =[SpecularPointLat;   ReflectionCoefficientAtSP(ii).SpecularPointLat] ; 
    SpecularPointLon =[SpecularPointLon;   ReflectionCoefficientAtSP(ii).SpecularPointLon] ; 
    IntegrationMidPointTime=[IntegrationMidPointTime;   ReflectionCoefficientAtSP(ii).time] ; 
    ReflectionHeight=[ReflectionHeight; ReflectionCoefficientAtSP(ii).ReflectionHeight] ; 
    SPIncidenceAngle=[SPIncidenceAngle; ReflectionCoefficientAtSP(ii).SPIncidenceAngle] ; 

    otherwise
    disp('Required signal not available') ;
end
%
% ****************  Start retrieval algorithm
%
% *********   Create map of mean observables in an EASE grid reference 
%    
[a b]=size(IntegrationMidPointTime)  ; 
if b==0 disp('ERROR: DATA NOT FOUND IN THE AREA. Program exiting') ; 
    return ;
end
%
Map_Reflectivity_dB=nan(ngrid_x, ngrid_y) ;  
Map_Reflectivity_linear=Map_Reflectivity_dB  ;
PointTime=Map_Reflectivity_dB  ; 
NumIntegratedSP=Map_Reflectivity_dB ;
SPlat=Map_Reflectivity_dB  ; 
SPlon=Map_Reflectivity_dB  ; 
RadiometricResolution=Map_Reflectivity_dB ; 
[column,row] = easeconv_m(SpecularPointLat,SpecularPointLon, "low");
column(find(column <=0))=1 ; % problem with easeconv
row(find(row <= 0))=1 ; % problem with easeconv
ReflCoeff_linear=10.^(ReflCoeff_dB/10) ; 
map =accumarray([column row],ReflCoeff_linear, [], @computemean) ;
[a b ]=size(map) ; 
map2=map ; 
map2(find(map<=0))=NaN ;
% Map_Reflectivity_linear(ngrid_x-a+1:end, ngrid_y-b+1:end)=map ; 
Map_Reflectivity_linear(1: a, 1:b)=map2 ; 

map2=accumarray([column row],ReflCoeff_linear, [], @computestd) ;
map2(find(map<=0))=NaN ; 
RadiometricResolution(1: a, 1: b)=10.*log10(1+map2./Map_Reflectivity_linear(1: a, 1:b)) ; 

% [badrow, badcol]=find(Map_Reflectivity_linear<= 0 | isnan(Map_Reflectivity_linear)==1) ;
% Map_Reflectivity_linear(badrow, badcol)= NaN ; 
Map_Reflectivity_dB=10.*log10(Map_Reflectivity_linear) ; 
%
map2=accumarray([column row],ReflCoeff_linear, [], @computesize) ;
map2(find(map<=0))=NaN ; 
NumIntegratedSP(1: a, 1: b)=map2 ; 
%
map2 =accumarray([column row],IntegrationMidPointTime, [], @computemean) ;
map2(find(map<=0))=NaN ; 
PointTime(1: a, 1: b)=map2 ;

map2 =accumarray([column row],SpecularPointLat, [], @computemean) ;
map2(find(map<=0))=NaN ; 
SPlat(1: a, 1: b)=map2 ; 
map2=[] ; 
map2 =accumarray([column row],SpecularPointLon, [], @computemean) ;
map2(find(map<=0))=NaN ; 
SPlon(1: a, 1: b)=map2 ; 

UTCPointTime = datetime(PointTime,'ConvertFrom','datenum') ; 

%
% *********   Create map of mean observables in an EASE grid reference
%
% *********   Compute soil moisture
indmodel=1 ; 
% goodreflections=find(Map_Reflectivity_linear >0 & isnan(Map_Reflectivity_linear) ==0) ; 
% goodreflections=find((Map_Reflectivity_linear>=0.0) & (Slope<8) & ...
%     (Elevation<2500) & Rmsheight < 350) ; 
goodreflections=find(Map_Reflectivity_linear>=0 & Map_Reflectivity_dB >=-45);
SM=SMretrieval(Map_Reflectivity_dB(goodreflections),Biomass(goodreflections),...
    Elevation(goodreflections), Slope(goodreflections),...
    Rmsheight(goodreflections), Rmsslope(goodreflections), indmodel) ; 
% *********   Compute soil moisture
%
[colmax, c]=find(SPlat==min(SPlat(:))) ;
[colmin, c]=find(SPlat==max(SPlat(:))) ;
[c, rowmax]=find(SPlon==max(SPlon(:))) ;
[c, rowmin]=find(SPlon==min(SPlon(:))) ;
Grid_Reflectivity_dB=Map_Reflectivity_dB(colmin-1: colmax+1, rowmax-1:rowmin+1) ; 
Grid_SPlat=SPlat(colmin-1: colmax+1, rowmin-1:rowmax+1) ; 
Grid_SPlon=SPlon(colmin-1: colmax+1, rowmin-1:rowmax+1) ;
Grid_SM=NaN(1388,584) ;
Grid_SM(goodreflections) =SM ; 
Grid_SM=Grid_SM(colmin-1: colmax+1, rowmax-1:rowmin+1) ;
%
% ****************   Create structure to write output L2 product
%
[a b]=size(goodreflections) ;
NumRetrievals=b ; 

% Single track quantities
OutputProduct(ii).NameTrack=NameTrack ; % NumberOfPoint
OutputProduct(ii).NumRetrievals=NumRetrievals ; % NumberOfPoint
OutputProduct(ii).GridColumns=colmax-colmin+3  ; 
OutputProduct(ii).Gridrows=rowmax-rowmin+3 ; 
% Trackwise variables 
OutputProduct(ii).PointTime=PointTime(goodreflections) ; % Attribute: unit: 'days since 0000-01-01 00:00:00 time of observation'
OutputProduct(ii).UTCTime=UTCPointTime(goodreflections) ; % Attribute: unit: 'UTC' description: 'time of observation'
OutputProduct(ii).SPlatitude=SPlat(goodreflections) ; % Attribute: unit: 'deg' description: 'mean longitude of observables'
OutputProduct(ii).SPlongitude=SPlon(goodreflections) ; % Attribute: unit: 'deg' description: 'mean latitude of observables'
OutputProduct(ii).SM=SM ; % Attribute: unit: '100*m^3/m^3 or %' description: 'surface volumetric soil moisture'
OutputProduct(ii).NumIntegratedSP=NumIntegratedSP(goodreflections)  ; % Attribute: integer description: 'number of aggregates observation in the ares'
OutputProduct(ii).Uncertainty=RadiometricResolution(goodreflections)  ; 
OutputProduct(ii).Quality=zeros(NumRetrievals) ; % Attribute: unit '8 bits' description '8 Quality flags' 
OutputProduct(ii).Map_Reflectivity=Map_Reflectivity_dB(goodreflections) ;  % Attribute: unit: 'dB' description 'mean L1B reflectivity in the aggregation area'
OutputProduct(ii).agb_class_EASE25=Biomass(goodreflections) ;  % Attribute: unit: 'ton' description 'mean CCI agb in the aggregation area'
OutputProduct(ii).DEM_elevation_EASE25=Elevation(goodreflections) ; % Attribute: unit: 'meters' description 'mean GMTED 1km DEM elevation in the aggregation area'
OutputProduct(ii).Signal= Signal ; % Attribute: unit: 'text' description 'GNSS signal processed'
OutputProduct(ii).TrackIDOrbit= TrackIDOrbit ; % Attribute: unit: 'text' description 'Track ID from orbit file'
%
% Other parameters should be added
% Gridded quantities 
OutputProduct(ii).Grid_Reflectivity_dB=Grid_Reflectivity_dB ; 
OutputProduct(ii).Grid_SM=Grid_SM  ; 
OutputProduct(ii).Grid_SPlat=Grid_SPlat ;
OutputProduct(ii).Grid_SPlon=Grid_SPlon ; 
%
% Enf for on number of track over day interval
%
end
% end for over records
%
% File global attributes
AttributeProduct.Name='HydroGNSS Soil Moisture' ; 
AttributeProduct.Creation=char(datetime) ; % date_created 
AttributeProduct.Software='Soil Moil Algorithm from Reflectometry (SMART)' ;
AttributeProduct.Version='v0' ; 
AttributeProduct.Licence='Accredited Sapienza University of Rome' ;
AttributeProduct.Projection='EASE grid v2'  ; % reference coordinate grid 
AttributeProduct.Processinglevel='2'  ; % processing_level 
AttributeProduct.InitTimeOfData=char(init_SM_Day) ; % time_coverage_start 
AttributeProduct.FinalTimeOfData=char(final_SM_Day) ; % time_coverage_end 
AttributeProduct.DataTagUnique=char(DataTagUnique) ; % Unique tag to identify the experiment  
AttributeProduct.num_of_days=num_of_days ; % total number of days processed  



% Global Dimensions
AttributeProduct.SM_Time_resolution=SM_Time_resolution ; % Product time resolution, i.e., number of aggregates days
AttributeProduct.Resolution=Resolution ; % Attribute: unit: 'km' description: 'Size of observables aggregation area 
%
% File global attributes
%
% Outdirectory=[Path_HydroGNSS_ProcessedData '\' AttributeProduct.DataID] ;
Outdirectory=Path_HydroGNSS_ProcessedData ;
Outfilename=['HydroGNSS_SM_' char(init_SM_Day) '_' char(final_SM_Day) '_' AttributeProduct.Version '.nc'] ; 
%
AttributeProduct.Filename=Outfilename ; 
%
% ***************  Plot output map
if plotTag=='Yes'
figure, imagesc(Grid_SM')
title(['Soil moisture map [%]'] );
c=colorbar ; 
c.Label.String = 'Soil Moisture [%]'; 
cmin=min(Grid_SM(:),[],'omitnan') ; cmax=max(Grid_SM(:),[],'omitnan') ; 
cmin=round(cmin-1) ; cmax=round(cmax+1) ; 
% c.Limits=[cmin cmax] ; 
end
%
% ****************   Create structure to write output L2 product
%
% ****************   Write output L2 product
%
warning('off') ; 
TT=clock ; 
if exist([Outdirectory '\' Outfilename])==2, Outdirectory=[Outdirectory '\' 'SM' '_' num2str((TT(4))) '_' num2str((TT(5))) ] ; end; 
status= mkdir(Outdirectory) ; 
soil= WritingNetcdf(Num_records, OutputProduct,AttributeProduct, Outdirectory ) ; 
% save([Outdirectory '\' Outfilename], 'OutputProduct')
%
% ****************   Write output L2 product
% 
end % end the main function



