
clear all
close all

NumSP=100 ;
NumSoilMoist=21 ; 
NumRuns=9 ; 
NumRecords=NumSoilMoist*NumRuns ; 

dem=load('..\Auxiliary_Data\DEM\elevation_EASEv2-25kmrev.mat');
landcover=load('..\Auxiliary_Data\Landuse\lccs_EASE2-25km.mat');
lccs_class=landcover.lccs_class_EASE25;
%lccs_class((lccs_class(:)==216))=NaN; % removing the ocean pixels
ccibiomass=load('..\Auxiliary_Data\CCIbiomass\agb_EASE25_mean.mat','agb_class_EASE25_mean');
ccibiomass=ccibiomass.agb_class_EASE25_mean;

dem_elevation=dem.DEM_elevation_EASE25;
dem_rmsheight=dem.DEM_rmsheight_EASE25;
dem_rmsslope=dem.DEM_rmsslope_EASE25;
dem_slope=dem.DEM_slope_EASE25;


InputValues=load('..\Auxiliary_Data\Anshatrailsan_inOutReferenceFile.mat','inOutReferenceFile');
InputValues=InputValues.inOutReferenceFile ;
%% analysis for class-2 
for i=1:NumRecords

    Reflectivity(i,:)=InputValues(i).max_reflectivity_noNoise_LR_dB;
    soilmoisture(i)=mean(InputValues(i).terrainParameters(2:end,5));%class2
    soilroughness(i)=mean(InputValues(i).terrainParameters(:,2));% class2
    splat(:,i)=InputValues(i).geoSYSp.SPlat_series;
    splon(:,i)=InputValues(i).geoSYSp.SPlon_series;
end
%%'1 water bodies','2 broadleaved forest','2 needleleaved forest','3 cropland/grassland/shrubland','4 bare areas','5 flooded forest',
Reflectivity=Reflectivity';
soilroughness=soilroughness';
Resolution=25;
if Resolution==25, ngrid_x=1388; ngrid_y=584; else disp('Wrong resolution'), end

Reflect=[] ; 
Moisture=[] ; 
Elevation=[] ; 
Slope=[] ; 
Rmsheight=[] ;
Biomass=[] ; 
Roughness=[];
Rmsslope=[];

for j=1:NumRecords 

Map_Reflectivity_dB=nan(ngrid_x, ngrid_y) ;
Map_Reflectivity_linear=Map_Reflectivity_dB  ;
MAP_Soil=Map_Reflectivity_dB;

[column,row] = easeconv_grid2(splat(:,j),splon(:,j),Resolution);
soilmoisture=soilmoisture';
ReflCoeff_linear=10.^(Reflectivity/10) ;
SM=repmat(soilmoisture(j),size(column));

map_r =accumarray([column row],ReflCoeff_linear(:,j), [], @computemean,NaN) ;
map_soil=accumarray([column row],SM, [], @computemean,NaN) ;
% map_soil=accumarray([column row],soilmoisture,[],@computemean);
[a b ]=size(map_r) ;
% map2=map_r ;
% map2(find(map_r<=0))=NaN ;


Map_Reflectivity_linear(1: a, 1:b)=map_r ;
MAP_Soil(1:a,1:b)=map_soil;
Map_ReflectivitydB= 10*log10(Map_Reflectivity_linear);
goodrefl=find((Map_ReflectivitydB>=-25)  & (dem_slope <12) & (dem_elevation<2800));
%  goodrefl=find((Map_Reflectivity_linear >=0.01));% & (dem_slope <12) & (dem_elevation<2800));
 
Reflect=[Reflect ; 10*log10(Map_Reflectivity_linear(goodrefl))] ; 
Moisture=[Moisture ; MAP_Soil(goodrefl)]     ; 
Elevation=[Elevation ; dem_elevation(goodrefl) ] ;
Slope=[Slope ; dem_slope(goodrefl) ] ; 
Rmsheight=[Rmsheight ; dem_rmsheight(goodrefl) ] ;
Rmsslope=[Rmsslope ; dem_rmsslope(goodrefl)];
Biomass=[Biomass ; ccibiomass(goodrefl) ] ; 
% Reflect=[Reflect ; 10*log10(Map_Reflectivity_linear(:))] ; 
% TotalMoisture=[Moisture ; MAP_Soil(:)]     ; 
% Elevation=[Elevation ; dem_elevation(:) ] ;
% Slope=[Slope ; dem_slope(:) ] ; 
% Rmsheight=[Rmsheight ; dem_rmsheight(:) ] ;
% Rmsslope=[Rmsslope ; dem_rmsslope(:)];
% Biomass=[Biomass ; ccibiomass(:)] ; 


end

inputnames= {'Reflect','Biomass','Elevation','Slope','Rmsheight','Rmsslope'};
outputnames={'SoilMoisture'};

attributes=[inputnames,outputnames];
% desiging the matrix with all parameters
%a=find(Roughness<=1.5);%class2 forest
%X=[Reflect(a),Biomass(a),Elevation(a),Slope(a), Rmsheight(a),Rmsslope(a),Moisture(a)];%first 6 input Xa and last column 7 is the output Y
X=[Reflect,Biomass,Elevation,Slope, Rmsheight,Rmsslope,Moisture];%first 6 input Xa and last column 7 is the output Y

%% linear regression model
mdllinear=fitlm(X(:,1:6),Moisture);%fitlm
SM_pred=predict(mdllinear,X(:,1:6));% predicted soil moisture values from the trained model.
%% randomforest Regression
T = array2table(X);T.Properties.VariableNames(1:7) = {'Reflect','Biomass','Elevation','Slope','Rmsheight','Rmsslope','SoilMoisture'};
T.Properties.VariableNames=attributes;
Xa=T{:,inputnames};
Y=T{:,outputnames};
rng(6); % 6 values in random
cv=cvpartition(height(T),"HoldOut",0.2);% 80% train data 20% test data
t=RegressionTree.template('MinLeaf',6); % 6 regression random
mdl=fitensemble(Xa(cv.training,:),Y(cv.training,:),'LSBoost',600,t,'PredictorNames',inputnames, ...
    'ResponseName',outputnames{1},'LearnRate',0.02);  % 600 random trees regression 
L=loss(mdl,Xa(cv.test,:),Y(cv.test,:),'mode','ensemble'); % test loss returns MSE(mean square error)
RMSE=sqrt(L); % rmse for test loss
% mdl1=fitcensemble(Xa,Y);
% rsLoss1 = resubLoss(mdl1);
trainingLoss = resubLoss(mdl,'mode','cumulative');
figure,plot(Y(cv.training),'b','LineWidth',2)
hold on , plot(predict(mdl,Xa(cv.training,:)),'.','LineWidth',1,'MarkerSize',15)
testloss = loss(mdl,Xa(cv.test,:),Y(cv.test));%,'mode','cumulative');
figure,plot(trainingLoss),hold on
plot(testloss,'r')
legend({'Training Set Loss','Test Set Loss'})
xlabel('Number of Trees');
ylabel('Mean Sqaured Error');

%% polynomial analysis
mdlpoly1=polyfitn([Reflect,Biomass,Elevation,Slope, Rmsheight,Rmsslope],Y,1);%first  order polynomial
mdlpoly2=polyfitn([Reflect,Biomass,Elevation,Slope, Rmsheight,Rmsslope],Y,2);%second degree polynomial
mdlpoly3=polyfitn([Reflect,Biomass,Elevation,Slope, Rmsheight,Rmsslope],Y,3);%third degree polynomial
mdlpoly4=polyfitn([Reflect,Biomass,Elevation,Slope, Rmsheight,Rmsslope],Y,4);%fourth degree polynomial