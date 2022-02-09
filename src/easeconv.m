function  [column,row] = easeconv(latitude,longitude, grid);
%
%	convert geographic coordinates (spherical earth) to 
%	azimuthal equal area or equal area cylindrical grid coordinates
%
%   status = ezlh_convert (grid, lat, lon, r, s)
%
%	input : grid - projection name '[NSM][lh]'
%               where l = "low"  = 25km resolution
%                     h = "high" = 12.5km resolution
%		lat, lon - geo. coords. (decimal degrees)
%
%	output: r, s - column, row coordinates
%
%
RE_km = 6371.228   ;
CELL_km = 25.067525   ;
COS_PHI1 = .866025403   ;
%PI = 3.141592653589793 ; 
% rad(t) = t*PI/180.  ;
% deg(t) = t*180./PI  ;

ezlh_convert = -1 ; 
% case of global 
cols = 1383  ;
rows = 586  ;
      
if grid=="low" 
    scale = 1   ;
elseif grid=="high" ; 
    scale = 2  ;
else
    ezlh_convert = -2 ; 
end  
    
Rg = scale * RE_km/CELL_km   ;
r0 = (cols-1)/2. * scale  ;
s0 = (rows-1)/2. * scale  ;
phi = pi*latitude/180 ; 
lam = pi*longitude/180 ; 

% caso Global. Added one to account for Matlab index starting from 1 (to be
% cheched)
column=round(r0 + Rg.* lam.* COS_PHI1)+1 ;
row = round(s0 - Rg.* sin(phi)./ COS_PHI1)+1  ;
% Origin 1,1 seems to be around +70 lat, -180 lon to be verified
          

          