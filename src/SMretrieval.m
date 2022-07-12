
function SM = SMretrieval(Reflect,Biomass,Elevation,Slope, Rmsheight,Rmsslope, idmodel)
global model ; 
% SM=coe(indmodel, 1)+Reflectivity.*coe(indmodel, 2)+X1.*coe(indmodel, 3)+X2.*coe(indmodel, 4) ; 
SM=predict(model,[Reflect,Biomass,Elevation,Slope, Rmsheight,Rmsslope]);
% SM=polyvaln(model,[Reflect,Biomass,Elevation,Slope, Rmsheight,Rmsslope]); % to get the predicted values from polyfit
end