
function SM_main(init_SM_Day,SM_Time_resolution, Path_HydroGNSS_Data,Path_Auxiliary,...
     Path_HydroGNSS_ProcessedData,Resolution, metadata_name, DDMs_name,...
     readDDM, Frequency, Polarization, plotTag)
tic
%
% ***** read algorithms coefficients
load('./conf/Coefficients.mat')
% ***** read algorithms coefficients
%
% ***** Initialize variables
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

ReflectionHeight=[] ; 
SPIncidenceAngle=[] ; 
Map_Reflectivity_dB=[] ; 
Map_Reflectivity_linear=[] ; 
DDM=[] ; 
% ***** Initialize variables
%
% ***********  read L1B data
 [ReflectionCoefficientAtSP, Sigma0, DataTag]=read_L1Bproduct(init_SM_Day,...
     SM_Time_resolution, Path_HydroGNSS_Data, metadata_name, readDDM, DDMs_name) ; 
% ***********  read L1B data
%
% **********  Selecte only one signal for L2PP (placeholder)
%
[a Num_records]=size(ReflectionCoefficientAtSP) ; 
Signal= [Frequency '_' Polarization 'HCP'] ; 
ReflCoeff_dB=[] ;  
ReflCoeff_linear=[] ;  
SpecularPointLat=[] ; 
SpecularPointLon=[] ;
%
switch Signal 
   case 'L1_LHCP' 
for ii=1:Num_records ; 
    [Num_SP b]=size(ReflectionCoefficientAtSP(ii).L1_LHCP) ; 
if Num_SP >0
    ReflCoeff_dB=[ReflCoeff_dB;   ReflectionCoefficientAtSP(ii).L1_LHCP] ; 
    SpecularPointLat =[SpecularPointLat;   ReflectionCoefficientAtSP(ii).SpecularPointLat] ; 
    SpecularPointLon =[SpecularPointLon;   ReflectionCoefficientAtSP(ii).SpecularPointLon] ; 
    IntegrationMidPointTime=[IntegrationMidPointTime;   ReflectionCoefficientAtSP(ii).time] ; 
    ReflectionHeight=[ReflectionHeight; ReflectionCoefficientAtSP(ii).ReflectionHeight] ; 
    SPIncidenceAngle=[SPIncidenceAngle; ReflectionCoefficientAtSP(ii).SPIncidenceAngle] ; 

end
end
   case 'L1_RHCP'
for ii=1:Num_records ; 
    [Num_SP b]=size(ReflectionCoefficientAtSP(ii).L1_RHCP) ; 
if Num_SP >0
    ReflCoeff_dB =[ReflCoeff_dB;   ReflectionCoefficientAtSP(ii).L1_LHCP] ; 
    SpecularPointLat =[SpecularPointLat;   ReflectionCoefficientAtSP(ii).SpecularPointLat] ; 
    SpecularPointLon =[SpecularPointLon;   ReflectionCoefficientAtSP(ii).SpecularPointLon] ; 
    IntegrationMidPointTime=[IntegrationMidPointTime;   ReflectionCoefficientAtSP(ii).time] ; 
    ReflectionHeight=[ReflectionHeight; ReflectionCoefficientAtSP(ii).ReflectionHeight] ; 
    SPIncidenceAngle=[SPIncidenceAngle; ReflectionCoefficientAtSP(ii).SPIncidenceAngle] ; 
end
end

   case 'E1_LHCP'
for ii=1:Num_records ; 
    [Num_SP b]=size(ReflectionCoefficientAtSP(ii).E1_LHCP) ; 
if Num_SP >0
    ReflCoeff_dB =[ReflCoeff_dB;   ReflectionCoefficientAtSP(ii).L1_LHCP] ; 
    SpecularPointLat =[SpecularPointLat;   ReflectionCoefficientAtSP(ii).SpecularPointLat] ; 
    SpecularPointLon =[SpecularPointLon;   ReflectionCoefficientAtSP(ii).SpecularPointLon] ; 
    IntegrationMidPointTime=[IntegrationMidPointTime;   ReflectionCoefficientAtSP(ii).time] ; 
    ReflectionHeight=[ReflectionHeight; ReflectionCoefficientAtSP(ii).ReflectionHeight] ; 
    SPIncidenceAngle=[SPIncidenceAngle; ReflectionCoefficientAtSP(ii).SPIncidenceAngle] ; 

end
end

   case 'E1_RHCP'
for ii=1:Num_records ; 
    [Num_SP b]=size(ReflectionCoefficientAtSP(ii).E1_LHCP) ; 
if Num_SP >0
    ReflCoeff_dB =[ReflCoeff_dB;   ReflectionCoefficientAtSP(ii).L1_LHCP] ; 
    SpecularPointLat =[SpecularPointLat;   ReflectionCoefficientAtSP(ii).SpecularPointLat] ; 
    SpecularPointLon =[SpecularPointLon;   ReflectionCoefficientAtSP(ii).SpecularPointLon] ; 
    IntegrationMidPointTime=[IntegrationMidPointTime;   ReflectionCoefficientAtSP(ii).time] ; 
    ReflectionHeight=[ReflectionHeight; ReflectionCoefficientAtSP(ii).ReflectionHeight] ; 
    SPIncidenceAngle=[SPIncidenceAngle; ReflectionCoefficientAtSP(ii).SPIncidenceAngle] ; 

end
end
    otherwise
        disp('Required signal not available') ;
end
%
% ****************  Start retrieval algorithm
%
% *********   Create map of mean observables in an EASE grid reference 
if Resolution==25, ngrid_x=1388; ngrid_y=584; else disp('Wrong resolution'), end
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
% *********   Read Auxiliary files
%
load([Path_Auxiliary,'/Landuse/lccs_EASE25km_no190-210-220.mat']) ; 
load([Path_Auxiliary,'/CCIbiomass/biomass_EASEv2-25km.mat']) ; 
load([Path_Auxiliary,'/DEM/elevation_EASEv2-25km.mat']) ; 
%
% *********   Read Auxiliary files
%
% *********   Compute soil moisture
indmodel=1 ; 
goodreflections=find(Map_Reflectivity_linear >0 & isnan(Map_Reflectivity_linear) ==0) ; 
SM = SMretrieval(Map_Reflectivity_dB(goodreflections),agb_class_EASE25(goodreflections),...
    DEM_elevation_EASE25(goodreflections), indmodel) ; 
% *********   Compute soil moisture
%
[colmax, c]=find(SPlat==min(SPlat(:))) ;
[colmin, c]=find(SPlat==max(SPlat(:))) ;
[c, rowmax]=find(SPlon==max(SPlon(:))) ;
[c, rowmin]=find(SPlon==min(SPlon(:))) ;
Grid_Reflectivity_dB=Map_Reflectivity_dB(colmin-1: colmax+1, rowmin-1:rowmax+1) ; 
Grid_SPlat=SPlat(colmin-1: colmax+1, rowmin-1:rowmax+1) ; 
Grid_SPlon=SPlon(colmin-1: colmax+1, rowmin-1:rowmax+1) ;
Grid_SM=NaN(1388,584) ;
Grid_SM(goodreflections) =SM ; 
Grid_SM=Grid_SM(colmin-1: colmax+1, rowmin-1:rowmax+1) ;

%
% ****************   Create structure to write output L2 product
%
% Check id DataTag is uique, otherwise exit with error message 
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
NumRetrievals=size(goodreflections) ; 
% Global 
OutputProduct.Name='HydroGNSS Soil Moisture' ; 
% Global attribute 
OutputProduct.DataID=['SM-L2_' date] ; % Data Tag
OutputProduct.Software='Soil Moil Algorithm from Reflectometry (SMART)' ;
OutputProduct.Version='v0' ; 
OutputProduct.Licence='Accredited Sapienza University of Rome' ;
OutputProduct.Creation=datetime ; % date_created 
OutputProduct.Projection='EASE grid v2'  ; % reference coordinate grid 
OutputProduct.Processinglevel='2'  ; % processing_level 
OutputProduct.InitTimeOfData=char(init_SM_Day) ; % time_coverage_start 
OutputProduct.FinalTimeOfData=char(char(init_SM_Day+SM_Time_resolution-1)) ; % time_coverage_end 
% Global Dimensions
OutputProduct.SM_Time_resolution=SM_Time_resolution ; % NumberOfDays
OutputProduct.NumRetrievals=NumRetrievals ; % NumberOfPoint
OutputProduct.GridColumns=colmax-colmin+3  ; 
OutputProduct.Gridrows=rowmax-rowmin+3 ; 
% Global variables 
OutputProduct.Resolution=Resolution ; % Attribute: unit: 'km' description: 'Size of observables aggregation area 
OutputProduct.PointTime=PointTime(goodreflections) ; % Attribute: unit: 'days since 0000-01-01 00:00:00 time of observation'
OutputProduct.UTCTime=UTCPointTime(goodreflections) ; % Attribute: unit: 'UTC' description: 'time of observation'
OutputProduct.SPlatitude=SPlat(goodreflections) ; % Attribute: unit: 'deg' description: 'mean longitude of observables'
OutputProduct.SPlongitude=SPlon(goodreflections) ; % Attribute: unit: 'deg' description: 'mean latitude of observables'
OutputProduct.SM=SM ; % Attribute: unit: '100*m^3/m^3 or %' description: 'surface volumetric soil moisture'
OutputProduct.NumIntegratedSP=NumIntegratedSP(goodreflections)  ; % Attribute: integer description: 'number of aggregates observation in the ares'
OutputProduct.Uncertainty=RadiometricResolution(goodreflections)  ; 
OutputProduct.Quality=zeros(NumRetrievals) ; % Attribute: unit '8 bits' description '8 Quality flags' 
OutputProduct.Map_Reflectivity=Map_Reflectivity_dB(goodreflections) ;  % Attribute: unit: 'dB' description 'mean L1B reflectivity in the aggregation area'
OutputProduct.agb_class_EASE25=agb_class_EASE25(goodreflections) ;  % Attribute: unit: 'ton' description 'mean CCI agb in the aggregation area'
OutputProduct.DEM_elevation_EASE25=DEM_elevation_EASE25(goodreflections) ; % Attribute: unit: 'meters' description 'mean GMTED 1km DEM elevation in the aggregation area'
OutputProduct.Signal= Signal ; % Attribute: unit: 'text' description 'GNSS signal processed'
% Gridded quantities 
OutputProduct.Grid_Reflectivity_dB=Grid_Reflectivity_dB ; 
OutputProduct.Grid_SM=Grid_SM  ; 
OutputProduct.Grid_SPlat=Grid_SPlat ;
OutputProduct.Grid_SPlon=Grid_SPlon ; 
%
Outfilename=['HydroGNSS_SM_' char(init_SM_Day) '_' char(init_SM_Day+SM_Time_resolution-1) '_' OutputProduct.Version '.nc'] ; 
OutputProduct.Filename=Outfilename ; 
%
Outdirectory=[Path_HydroGNSS_ProcessedData '\' OutputProduct.DataID] ; 
%
% ***************  Plot output map
if plotTag=='Yes'
    figure, imagesc(Grid_SM')
end
title(['Soil moisture map [%]'] );
c=colorbar ; 
c.Label.String = 'Soil Moisture [%]'; 
cmin=min(Grid_SM(:)) ; cmax=max(Grid_SM(:)) ; 
cmin=round(cmin-1) ; cmax=round(cmax+1) ; 
c.Limits=[cmin cmax] ; 
%
% ****************   Create structure to write output L2 product
%
;% ****************   Write output L2 product
%
warning('off') ; 
status= mkdir(Outdirectory) ; 
save([Outdirectory '\' Outfilename], 'OutputProduct')
%
% ****************   Write output L2 product
% 
end % end the main function



