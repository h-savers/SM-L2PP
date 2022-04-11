function  [column,row] = easeconv_grid2(latitude,longitude,resolution)

% RE_km = 6378.137  ; % WGS 84 EASE grid 2.0
Req=6378137 ; 
ecc= 0.0818191908426  ; 
COS_PHI1 = cosd(30)   ; %+-30 N/S
SIN_PHI1= sind(30)    ;

% CELL_km = 25.0252600081 ; % EASE grid 2.0 
CELL_m =36032.22 ; % Ref.: Correction: Brodzik, M.J., et al. EASE-Grid 2.0

if resolution == 9
    scale = 4;
    CELL_m =36032.22 ;
    cols=964;
    rows=406;
elseif resolution == 12.5
    scale =2;
    CELL_m = 25025.2600081;
    cols=1388;
    rows=584;
elseif resolution == 25
    scale = 1;
    CELL_m = 25025.2600081;
    cols=1388;
    rows=584;
elseif resolution ==36
    scale=1;
    CELL_m =36032.22 ;
    cols=964;
    rows=406;
end
r0=((scale*cols-1)/2) ;  
s0=((scale*rows-1)/2) ; 

while (longitude) < -180
    longitude=longitude+360;
end
while (longitude) > 180 
    longitude=longitude-360;
end
lam = pi*longitude/180 ; %degree to rad
phi = pi*latitude/180 ;  %degree to rad

% Ref.: Mary J. Brodzik et al., EASE-Grid 2.0: Incremental but Significant 
% Improvements for Earth-Gridded Data Sets, 2021

k0=COS_PHI1/sqrt(1-ecc*ecc*SIN_PHI1^2) ; 
quPHI=(1-ecc*ecc).*((sin(phi)./(1-ecc*ecc.*sin(phi).^2)-...
    ((1/2/ecc).*log((1-ecc.*sin(phi))./(1+ecc.*sin(phi))))))  ; 
ics=Req.*k0.*lam ; 
ips=Req*quPHI/2/k0  ; 
column=round(r0+scale*ics./CELL_m)+1 ; 
row=round(s0-scale*ips./CELL_m)+1 ; 
end
 