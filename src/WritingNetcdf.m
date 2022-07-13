function soil = WritingNetcdf(Num_records, OutputProduct, AttributeProduct, Outdirectory)
Name="HydroGNSS Soil Moisture" ;
Datacreated=AttributeProduct.Creation ;
License=AttributeProduct.Licence;
FileName=AttributeProduct.Filename;
DataTag=AttributeProduct.DataTagUnique;
SourceConstellation="HYDROGNSS";
Program="European Space Agency Scout Program";
ProcessingLevel=AttributeProduct.Processinglevel;
L2_ProcessorName=AttributeProduct.Software;
L2_ProcessorVersion=AttributeProduct.Version;
L2_ProcessorCreator="Sapienza University of Rome";
FirstTimeStamp=AttributeProduct.InitTimeOfData;
LastTimeStamp=AttributeProduct.FinalTimeOfData;
ProjectionType=AttributeProduct.Projection;
SM_Time_resolution=AttributeProduct.SM_Time_resolution;
NumberOfDays=AttributeProduct.num_of_days ; % total number of days processed
NumberOfTrack=Num_records ;
GridResolution=AttributeProduct.Resolution ;

%
% Loop over groups corresponding to different tracks
% For Aneesha: from now on you have to complete to write each track vector
% in a group





cmode = netcdf.getConstant('NETCDF4');
%  cmode = bitor(cmode,netcdf.getConstant('CLOBBER')); % WARNING
%  combination of CLOBBER and NETCDF4 does not succeed
ncid = netcdf.create([Outdirectory '\' FileName],cmode);
% ncid = netcdf.create([Outdirectory '\' FileName],'NETCDF4');



%% attributes
netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),'Name',Name);
netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),'Product creation time',Datacreated);
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
netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),'GridResolution',GridResolution);
netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),'TimeResolution',SM_Time_resolution);
dimid1 = netcdf.defDim(ncid,'NumberOfDays',NumberOfDays);%20
dimid6 = netcdf.defDim(ncid,'NumberOfTracks',Num_records);%20

% netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),'NumberOfDays',NumberOfDays);

%     TrackID=size(OutputProduct.NameTrack);
for  n=1:NumberOfTrack % no of trackgroups
    NameTrack=OutputProduct(n).NameTrack ;
    if n<=NumberOfTrack
        trackid(n) = netcdf.defGrp(ncid,NameTrack);
    end
    
    NumberOfPoint=OutputProduct(n).NumRetrievals ; % Number of points in a track
    NumberOfColumns=OutputProduct(n).GridColumns;
    NumberOfRows=OutputProduct(n).GridRows;

    MeanObservationTime=OutputProduct(n).PointTime;
    MeanObservationUTCTime=OutputProduct(n).UTCTime;
    MeanObservationUTCTime=string(MeanObservationUTCTime);
    % GridResolution=repmat(AttributeProduct.Resolution,size(MeanObservationTime));
    DataMeanLatitude=OutputProduct(n).SPlatitude;
    DataMeanLongitude=OutputProduct(n).SPlongitude;
    SoilMoisture=OutputProduct(n).SM;
    SoilMoistureMap=OutputProduct(n).Grid_SM;
    NumIntegratedSP=OutputProduct(n).NumIntegratedSP;
    Uncertainty=OutputProduct(n).Uncertainty;
    QualityFlag=OutputProduct(n).Quality;
    MAP_Reflectivity=OutputProduct(n).Map_Reflectivity;
    AboveGroundBiomass=OutputProduct(n).agb_class_EASE25;
    DEM_elevation=OutputProduct(n).DEM_elevation_EASE25;
    Signal=OutputProduct(n).Signal;
    TrackIDOrbit=OutputProduct(n).TrackIDOrbit;
    %%dimensions

    dimid2 = netcdf.defDim(trackid(n),'NumberOfPoint',NumberOfPoint);%21
    dimid3 = netcdf.defDim(trackid(n),'NumberOfColumns',NumberOfColumns);%columns 6/1
    dimid4 = netcdf.defDim(trackid(n),'NumberOfRows',NumberOfRows); %rows 25
    dimid5=([dimid3 dimid4]);
    %%variables




    netcdf.putAtt(trackid(n), netcdf.getConstant("NC_GLOBAL"),'TrackName',NameTrack);
%     netcdf.putAtt(trackid(n), netcdf.getConstant("NC_GLOBAL"),'NumberOfPoint',NumberOfPoint);
%     netcdf.putAtt(trackid(n), netcdf.getConstant("NC_GLOBAL"),'NumberOfColumns',NumberOfColumns);
%     netcdf.putAtt(trackid(n), netcdf.getConstant("NC_GLOBAL"),'NumberOfRow',NumberOfRows);
    netcdf.putAtt(trackid(n), netcdf.getConstant("NC_GLOBAL"),'Signal',Signal);
    netcdf.putAtt(trackid(n), netcdf.getConstant("NC_GLOBAL"),'TrackIDOrbit',TrackIDOrbit);

    var1=netcdf.defVar(trackid(n),'MeanObservationTime','NC_DOUBLE',dimid2);
    netcdf.putVar(trackid(n),var1,MeanObservationTime);
    netcdf.putAtt(trackid(n),var1,'Description',"The mean timestamp (integrationMidPointTime) of the reflections averaged over the grid cell. Number of days from January 0, 0000");
    var2=netcdf.defVar(trackid(n),'MeanObservationUTCTime','NC_STRING',dimid2);
    netcdf.putVar(trackid(n),var2,MeanObservationUTCTime);
    netcdf.putAtt(trackid(n),var2,'Description','The mean UTC timestamp of the reflections averaged over the grid cell');
    var4=netcdf.defVar(trackid(n),'DataMeanLatitude','NC_DOUBLE',dimid2);
    netcdf.putVar(trackid(n),var4,DataMeanLatitude);
    netcdf.putAtt(trackid(n),var4,'Description','Mean latitude of the reflection specular points aggregated within the grid cell');
    var5=netcdf.defVar(trackid(n),'DataMeanLongitude','NC_DOUBLE',dimid2);
    netcdf.putVar(trackid(n),var5,DataMeanLongitude);
    netcdf.putAtt(trackid(n),var5,'Description','Mean longitude of the reflection specular points aggregated within the grid cell');
    var6=netcdf.defVar(trackid(n),'SoilMoisture','NC_DOUBLE',dimid2);
    netcdf.putVar(trackid(n),var6,SoilMoisture);
    netcdf.putAtt(trackid(n),var6,'Description','Soil moisture estimate');
    netcdf.putAtt(trackid(n),var6,'Units','100*m^3/m^3');
    var7=netcdf.defVar(trackid(n),'SoilMoistureMap','NC_DOUBLE',dimid5);
    netcdf.putVar(trackid(n),var7,SoilMoistureMap);
    netcdf.putAtt(trackid(n),var7, 'Description','Soil moisture estimate over a grid according to the ProjectionType and GridResolution. The map is limited to the geographical area covered by the product');
    var8=netcdf.defVar(trackid(n),'NumIntegratedSP','NC_DOUBLE',dimid2);
    netcdf.putVar(trackid(n),var8,NumIntegratedSP);
    netcdf.putAtt(trackid(n),var8,'Description','Number of aggregated observations in the grid cell');
    netcdf.putAtt(trackid(n),var8,'Units','count');
    var9=netcdf.defVar(trackid(n),'Uncertainty','NC_DOUBLE',dimid2);
    netcdf.putVar(trackid(n),var9,Uncertainty);
    netcdf.putAtt(trackid(n),var9, 'Description','Uncertainty of the product');
    netcdf.putAtt(trackid(n),var9,'Units','db');
    var10=netcdf.defVar(trackid(n),'QualityFlag','NC_DOUBLE',dimid2);
    netcdf.putVar(trackid(n),var10,QualityFlag);
    netcdf.putAtt(trackid(n),var10,'Description','Quality Flags');
    var11=netcdf.defVar(trackid(n),'Reflectivity_dB','NC_DOUBLE',dimid2);
    netcdf.putVar(trackid(n),var11,MAP_Reflectivity);
    netcdf.putAtt(trackid(n),var11,'Description','Mean L1B reflectivity of the reflection specular points aggregated within the grid cell in dB');
    var12=netcdf.defVar(trackid(n),'AboveGroundBiomass','NC_DOUBLE',dimid2);
    netcdf.putVar(trackid(n),var12,AboveGroundBiomass);
    netcdf.putAtt(trackid(n),var12,'Description','Above ground biomass from the CCI product averaged within the grid cell');
    netcdf.putAtt(trackid(n),var12,'Units','ton/ha');
    var13=netcdf.defVar(trackid(n),'DEM_elevation','NC_DOUBLE',dimid2);
    netcdf.putVar(trackid(n),var13,DEM_elevation);
    netcdf.putAtt(trackid(n),var13,'Description','Mean surface elevation within the grid cell');
    netcdf.putAtt(trackid(n),var13,'Units','meters');


end         % ReflectionCoefficientAtSP(Track_ID).TrackIDOrbit

%
% end for over groups
%
netcdf.close(ncid);
soil=ncinfo([Outdirectory '\' FileName]);
% end