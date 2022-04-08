 function  [column,row] = easeconv_m(latitude,longitude, grid)
%
%	convert geographic coordinates (spherical earth) to 
%	equal area cylindrical grid coordinates EASE grid version 2.0
%
% By Nazzareno Pierdicca march 2022
%   Calling sequence:
%   [column,row] = easeconv_m(latitude,longitude, grid)
%
%	input : grid resolution 
%               where l = "low"  = 25km resolution
%                     h = "high" = 12.5km resolution
%		lat, lon - geo. coords. (decimal degrees)
%
%	output: r, s - column, row coordinates
%

 
% RE_km = 6378.137  ; % WGS 84 EASE grid 2.0
Req=6378137 ; 
% CELL_km = 25.0252600081 ; % EASE grid 2.0 
CELL_m =25025.2600000 ; % Ref.: Correction: Brodzik, M.J., et al. EASE-Grid 2.0
% 
ecc= 0.0818191908426  ; 
COS_PHI1 = cosd(30)   ; %+-30 N/S
SIN_PHI1= sind(30)    ; 
cols=1388;
rows=584;

ezlh_convert = -1 ; 

if grid =="low" 
    scale = 1   ;
elseif grid =="high" 
    scale = 2  ;
else
    ezlh_convert = -2 ; 
end  

r0 = ((cols-1)/2. * scale)  ; % to be verified if it should be r0=((scale*cols-1)/2) 
s0 = ((rows-1)/2. * scale)  ; % to be verified if it should be r0=((scale*rows-1)/2)
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
quPHI=(1-ecc*ecc).*(sind(latitude)./(1-ecc.*ecc.*sind(latitude).^2)-...
    (1/2/ecc).*log((1-ecc.*sind(latitude))./(1+ecc.*sind(latitude))))  ; 
ics=Req.*k0.*lam ; 
ips=Req*quPHI/2/k0  ; 
column=round(r0+scale*ics./CELL_m)+1 ; 
row=round(s0-scale*ips./CELL_m)+1 ; 

  end