function soil = WritingNetcdf(OutputProduct, Outdirectory)
Name="HydroGNSS Soil Moisture";
% date_created
License=OutputProduct.Licence;
FileName=OutputProduct.Filename;
DataTag=OutputProduct.DataID;
SourceConstellation="HYDROGNSS";
Program="European Space Agency Scout Program";
ProcessingLevel=OutputProduct.Processinglevel;
L2_ProcessorName=OutputProduct.Software;
L2_ProcessorVersion=OutputProduct.Version;
L2_ProcessorCreator="Sapienza University of Rome";
FirstTimeStamp=OutputProduct.InitTimeOfData;
LastTimeStamp=OutputProduct.FinalTimeOfData;
ProjectionType=OutputProduct.Projection;

NumberOfDays=OutputProduct.SM_Time_resolution;
NumberOfPoint=OutputProduct.NumRetrievals;
NumberOfColumns=OutputProduct.GridColumns;
NumberOfRows=OutputProduct.Gridrows;

MeanObservationTime=OutputProduct.PointTime;
MeanObservationUTCTime=string(OutputProduct.UTCTime);
GridResolution=repmat(OutputProduct.Resolution,size(MeanObservationTime));
DataMeanLatitude=OutputProduct.SPlatitude;
DataMeanLongitude=OutputProduct.SPlongitude;
SoilMoisture=OutputProduct.SM;
SoilMoistureMap=OutputProduct.Grid_SM;
NumIntegratedSP=OutputProduct.NumIntegratedSP;
Uncertainty=OutputProduct.Uncertainty;
QualityFlag=OutputProduct.Quality;
MAP_Reflectivity=OutputProduct.Map_Reflectivity;
AboveGroundBiomass=OutputProduct.agb_class_EASE25;
DEM_elevation=OutputProduct.DEM_elevation_EASE25;
Signal=repmat(string(OutputProduct.Signal),size(MeanObservationTime));


% ncid = netcdf.create(FileName,'NETCDF4');
ncid = netcdf.create([Outdirectory '\' FileName],'NETCDF4');



%% attributes
netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),'Name',Name);
netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),'date_created','');
netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),'License',License);
netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),'FileName',FileName);
netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),'DataTag',DataTag);
netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),'SourceConstellation',SourceConstellation);
netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),'Program',Program);
netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),'ProcessingLevel',ProcessingLevel);
netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),'L2_ProcessorName',L2_ProcessorName);
netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),'L2_ProcessorVersion',L2_ProcessorVersion);
netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),'L2_ProcessorCreator',L2_ProcessorCreator);
netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),'FirstTimeStamp',FirstTimeStamp);
netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),'LastTimeStamp',LastTimeStamp);
netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),'ProjectionType',ProjectionType);

%%dimensions

dimid1 = netcdf.defDim(ncid,'NumberOfDays',NumberOfDays);%20
dimid2 = netcdf.defDim(ncid,'NumberOfPoint',NumberOfPoint(1));%21
dimid3 = netcdf.defDim(ncid,'NumberOfColumns',NumberOfColumns);%columns 6/1
dimid4 = netcdf.defDim(ncid,'NumberOfRows',NumberOfRows); %rows 25
dimid5=[dimid3 dimid4];
%%variables


var1=netcdf.defVar(ncid,'MeanObservationTime','NC_DOUBLE',dimid2);
netcdf.putVar(ncid,var1,MeanObservationTime);
netcdf.putAtt(ncid,var1,'Description',"The mean timestamp (integrationMidPointTime) of the reflections averaged over the grid cell. Number of days from January 0, 0000");
var2=netcdf.defVar(ncid,'MeanObservationUTCTime','NC_STRING',dimid2);
netcdf.putVar(ncid,var2,MeanObservationUTCTime);
netcdf.putAtt(ncid,var2,'Description','The mean UTC timestamp of the reflections averaged over the grid cell');
var3=netcdf.defVar(ncid,'GridResolution','NC_DOUBLE',dimid2);
netcdf.putVar(ncid,var3,GridResolution);
netcdf.putAtt(ncid,var3,'Description','The resolution of the grid cell where the reflections are averaged');
var4=netcdf.defVar(ncid,'DataMeanLatitude','NC_DOUBLE',dimid2);
netcdf.putVar(ncid,var4,DataMeanLatitude);
netcdf.putAtt(ncid,var4,'Description','Mean latitude of the reflection specular points aggregated within the grid cell');
var5=netcdf.defVar(ncid,'DataMeanLongitude','NC_DOUBLE',dimid2);
netcdf.putVar(ncid,var5,DataMeanLongitude);
netcdf.putAtt(ncid,var5,'Description','Mean longitude of the reflection specular points aggregated within the grid cell');
var6=netcdf.defVar(ncid,'SoilMoisture','NC_DOUBLE',dimid2);
netcdf.putVar(ncid,var6,SoilMoisture);
netcdf.putAtt(ncid,var6,'Description','Soil moisture estimate');
netcdf.putAtt(ncid,var6,'Units','100*m^3/m^3');
var7=netcdf.defVar(ncid,'SoilMoistureMap','NC_DOUBLE',dimid5);
netcdf.putVar(ncid,var7,SoilMoistureMap);
netcdf.putAtt(ncid,var7, 'Description','Soil moisture estimate over a grid according to the ProjectionType and GridResolution. The map is limited to the geographical area covered by the product');
var8=netcdf.defVar(ncid,'NumIntegratedSP','NC_DOUBLE',dimid2);
netcdf.putVar(ncid,var8,NumIntegratedSP);
netcdf.putAtt(ncid,var8,'Description','Number of aggregated observations in the grid cell');
netcdf.putAtt(ncid,var8,'Units','count');
var9=netcdf.defVar(ncid,'Uncertainty','NC_DOUBLE',dimid2);
netcdf.putVar(ncid,var9,Uncertainty);
netcdf.putAtt(ncid,var9, 'Description','Uncertainty of the product');
netcdf.putAtt(ncid,var9,'Units','db');
var10=netcdf.defVar(ncid,'QualityFlag','NC_DOUBLE',dimid2);
netcdf.putVar(ncid,var10,QualityFlag);
netcdf.putAtt(ncid,var10,'Description','Quality Flags');
var11=netcdf.defVar(ncid,'MAP_Reflectivity','NC_DOUBLE',dimid2);
netcdf.putVar(ncid,var11,MAP_Reflectivity);
netcdf.putAtt(ncid,var11,'Description','Mean L1B reflectivity of the reflection specular points aggregated within the grid cell');
var12=netcdf.defVar(ncid,'AboveGroundBiomass','NC_DOUBLE',dimid2);
netcdf.putVar(ncid,var12,AboveGroundBiomass);
netcdf.putAtt(ncid,var12,'Description','Above ground biomass from the CCI product averaged within the grid cell');
netcdf.putAtt(ncid,var12,'Units','ton/ha');
var13=netcdf.defVar(ncid,'DEM_elevation','NC_DOUBLE',dimid2);
netcdf.putVar(ncid,var13,DEM_elevation);
netcdf.putAtt(ncid,var13,'Description','Mean surface elevation within the grid cell');
netcdf.putAtt(ncid,var13,'Units','meters');
var14=netcdf.defVar(ncid,'Signal','NC_STRING',dimid2);
netcdf.putVar(ncid,var14,Signal);
netcdf.putAtt(ncid,var14,'Description','GNSS signal and polarization used in the retrieval algorithm');

netcdf.close(ncid);
soil=ncinfo('HydroGNSS_SoilMoisture.nc');
% end