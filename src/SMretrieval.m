
function SM = SMretrieval(Reflectivity,X1, X2, indmodel)
global coe ; 
SM=coe(indmodel, 1)+Reflectivity.*coe(indmodel, 2)+X1.*coe(indmodel, 3)+X2.*coe(indmodel, 4) ; 
end