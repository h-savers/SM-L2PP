latitude = h5read('SMAP_L3_SM_P_E_20191028_R17000_002.h5',...
    '/Soil_Moisture_Retrieval_Data_AM/latitude') ;
longitude = h5read('SMAP_L3_SM_P_E_20191028_R17000_002.h5',...
    '/Soil_Moisture_Retrieval_Data_AM/longitude') ;
soil_moisture = h5read('SMAP_L3_SM_P_E_20191028_R17000_002.h5',...
    '/Soil_Moisture_Retrieval_Data_AM/soil_moisture') ;

[column,row] = easeconv(latitude(:),longitude(:), "low");
column(find(column <=0))=1 ; % problem with easeconv
row(find(row <= 0))=1 ; % problem with easeconv
soil_moisture(find(soil_moisture <0))=NaN ;
map_soil_moisture=accumarray([column row],soil_moisture(:), [], @mean) ; 
figure, imagesc(map_soil_moisture) ; 