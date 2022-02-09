%% Preparing CYGNSS Dataset

clear all
close all
clc
%% Setting Study Area / Time Period (DOY_Num)
%Esempio di study area Global e dati anni intero
StudyArea='00_Global_2018'; 
Year=2018;
DOY_Num=[213:1:365];
DOY_Num=DOY_Num.' ; 
% DOY_Num=[1] ; 
% DOY_Num=DOY_Num.' ; 
LatMin=-90;
LatMax=90;
LonMin=-180;
LonMax=180;

% StudyArea='00_smalltest_2019'; 
% Year=2019;
% DOY_Num=[1:1:2];
% DOY_Num=DOY_Num.' ; 
% LatMin=0;
% LatMax=1;
% LonMin=0;
% LonMax=1;

% StudyArea='00_Argentina'; 
% Year=2019;
% DOY_Num=[1:1:5];
% DOY_Num=DOY_Num.' ; 
% LatMin=-31.37;
% LatMax=-21.77;
% LonMin=-66.4;
% LonMax=-54.73;

% StudyArea='03_Sud_America'; 
% Year=2017;
% DOY_Num=[86;95;128;137;170;179;198];
% LatMin=-60;
% LatMax=15;
% LonMin=-90;
% LonMax=-30;

% StudyArea='00_Angola';
% Year=2019;
% DOY_Num=[1:1:5];
% DOY_Num=DOY_Num.' ; 
% LatMin=-20;
% LatMax=-5;
% LonMin=+10;
% LonMax=+25;

% StudyArea='00_SanLuisValley_prova'; 
% Year=2019;
% DOY_Num=[1:1:3];
% DOY_Num=DOY_Num.' ; 
% LatMin=+37;
% LatMax=+39.0;
% LonMin=-107.0;
% LonMax=-105.0;

% StudyArea='00_Congo19'; 
% Year=2019;
% DOY_Num=[1:1:31];
% DOY_Num=DOY_Num.' ; 
% LatMin=-4;
% LatMax=+4;
% LonMin=+9;
% LonMax=+28;

%%% Fine definizione di study area

%% End Setting Study Area / Time Period (DOY_Num)
%DDMs_Flag=0; % DDMs are NOT saved
%DDMs_Flag=1; % DDMs are saved
DDMs_Flag=2; % minor volume di dati

%% Setting Path
%Path_CYGNSS_Data=['Z:\allData\cygnss\L1\v2.1\']; % Input CYGNSS Data
%Path_CYGNSS_Data=['E:\CyGNSS\L1\v2.1\']; % Input CYGNSS Data
%Path_CYGNSS_Data=['C:\Users\donys\Desktop\materiale borsa Sapienza\v2.1\']; % Input CYGNSS Data
Path_CYGNSS_Data=['W:\CYGNSS\v3.0\']; % Input CYGNSS Data v3.0
Path_CYGNSS_Data_Year=[Path_CYGNSS_Data,num2str(Year),'\']; % Input CYGNSS Data by year (contained folders are divided by DOY)

% Path_CYGNSS_ProcessedData=['Z:\CYGNSS\Test\'];mkdir(Path_CYGNSS_ProcessedData);
% Path_CYGNSS_ProcessedData=['G:\Il mio Drive\Work\ESA-Ecology\CYGNSSdata\'];mkdir(Path_CYGNSS_ProcessedData);
Path_CYGNSS_ProcessedData=['E:\Users\MauroPierdicca\CYGNSSdata\'];mkdir(Path_CYGNSS_ProcessedData);

% Path_CYGNSS_ProcessedData=['C:\Users\donys\Desktop\materiale borsa Sapienza\'];mkdir(Path_CYGNSS_ProcessedData);
Path_CYGNSS_ProcessedData_StudyArea=[Path_CYGNSS_ProcessedData,StudyArea,'\'];mkdir(Path_CYGNSS_ProcessedData_StudyArea);
Path_CYGNSS_ProcessedData_StudyArea_Year=[Path_CYGNSS_ProcessedData_StudyArea,num2str(Year),'\'];mkdir(Path_CYGNSS_ProcessedData_StudyArea_Year);
%% initialise variables

% CYGNSS sat ID
SCID=[];

% second of the day
SoD=[];

% day of the year
DoY=[];

%DDM source ---> 0: E2ES, 1: ZENITH ANTENNA (never used), 2: STARBOARD ANTENNA , 3: PORT ANTENNA
DDM_SOURCE=[];

% Receiver position coordinates in ECEF [m]
RX_POS_X=[];
RX_POS_Y=[];
RX_POS_Z=[];
% Receiver velocity coordinates in ECEF [m/s] MP Jan2020
RX_VEL_X=[];
RX_VEL_Y=[];
RX_VEL_Z=[];
%
% Nano star tracker attitude status (0 is OK, 1 or more is erroneous condition)
NST=[];

% pitch/roll/yaw
PITCH=[];
ROLL=[];
YAW=[];

% PRN --> Prn code = prn -->trasmettitore (1 10 22 etc..)
PRN=[];

% lat/long of specular point on ground
SPLAT=[];
SPLON=[];

% incidence angle
THETA=[];

% azimuth angle in specular point orbit frame
PHI_Initial_sp_az_orbit=[];
PHI_sp_az_body=[];
THE_sp_theta_body=[] ; 

% gain of receiver antenna [dBi]
GAIN=[];

% EIRP [W]
EIRP=[];

% % SNR of direct signal [dB]
% SNR_DIR=[];

% SNR of reflected signal - NOTE: calculated from the uncalibrated DDM in
% counts [dB]
SNR=[];

% peak power
PA=[];
PA2=[];

% noise floor
NF=[];
NF2=[];
NFRAW=[];

% Tx/Rx ranges [m]
RXRANGE=[];
TXRANGE=[];

% Transmitter position coordinates in ECEF [m]
TX_POS_X=[];
TX_POS_Y=[];
TX_POS_Z=[];

% Transmitter velocity coordinates in ECEF [m/sec] MP Jan2020
TX_VEL_X=[];
TX_VEL_Y=[];
TX_VEL_Z=[];
%
% quality flags
% overall quality
OQF=[];
% land flag
LF=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % % AGGIUNTA LUCA
QC=[]; 
DDM_NBRCS=[];
PA_DOPPLER=[]; 
PA_DELAY=[]; 
PA2_DOPPLER=[]; 
PA2_DELAY=[]; 
TRACK_ID=[];
% Number of bins >= Threshold (computed in the area where the noise is estimated)
BINS_HT_THRESHOLD_NF=[];
BINS_HT_THRESHOLD_NF2=[];
% Number of bins >= Threshold (computed in the whole DDM)
BINS_HT_THRESHOLD_DDM=[];
BINS_HT_THRESHOLD_DDM2=[];
% Number of bins with maximum/peak value in the whole DDM --> serve per vedere quanti picchi (valori massimi) ci sono in ogni DDM
BINS_WITH_PEAK=[];
BINS_WITH_PEAK2=[];
SPLON_EW=[];
% DDM GeoSubset
if DDMs_Flag==1
    DDM_GEOSUBSET=[];
    else
end
% Kurtosis
KURTOSIS=[];
KURTOSIS_UNBIASED=[];
KURTOSIS_DOPP_0=[];
TE_WIDTH = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Directory indices

[j jj]=size(DOY_Num);
clear jj
for i=1:j
    if length(num2str(DOY_Num(i,:)))==1
        dir=strcat('00',num2str(DOY_Num(i,:)));
        DirectoryIndices(i,:)=dir;
        clear dir
    elseif length(num2str(DOY_Num(i,:)))==2
        dir=strcat('0',num2str(DOY_Num(i,:)));
        DirectoryIndices(i,:)=dir;
        clear dir
     elseif length(num2str(DOY_Num(i,:)))==3
        dir=num2str(DOY_Num(i,:));
        DirectoryIndices(i,:)=dir;
        clear dir
     end
end
clear j
[NumIndices k]=size(DirectoryIndices);
clear k

tic
%tstart=tic;
%for ii=ind1:ind2
 for ii=1:NumIndices
    disp(['day '+string(ii)]) 
    foldername=DirectoryIndices(ii,:);
    
    % path on local machine of CYGNSS files
    Path_CYGNSS_Data_StudyArea_Year_DOY=[Path_CYGNSS_Data_Year,foldername];
    cd(Path_CYGNSS_Data_StudyArea_Year_DOY);
    D=dir;
    %n=length(D); 
    
    %for jj=3:n
    for jj=3:length(D)
        filename=D(jj).name;
        
        if endsWith(filename,'nc')
            
            % specular point latitude/longitude
            sp_lat_full=ncread(filename,'sp_lat');
            
            sp_lon_full=ncread(filename,'sp_lon');
            
              
            % Longitude converted from 0-360 to -180 / 180
            sp_lon_ew_full=rem((sp_lon_full+180),360)-180;
              
            % spacecraft id
            scid_Initial=ncread(filename,'spacecraft_num'); % --> aggiungi nella matrice
            
            % track id
            track_id_full=ncread(filename,'track_id');
            
            %ddm source starboard/port antenna
            ddm_source_in = ncread(filename,'ddm_source');
              
            % time stamp
            ts_full=ncread(filename,'ddm_timestamp_utc'); % seconds since 2017-03-27 00:00:00.999261529
            
            % rx position (ECEF)
            rx_pos_x_full=ncread(filename,'sc_pos_x');
            rx_pos_y_full=ncread(filename,'sc_pos_y');
            rx_pos_z_full=ncread(filename,'sc_pos_z');
            
            % rx velocity [ECEF]  MP Jan 2020
            rx_vel_x_full=ncread(filename,'sc_vel_x');   
            rx_vel_y_full=ncread(filename,'sc_vel_y');
            rx_vel_z_full=ncread(filename,'sc_vel_z');

            % attitude flag (I don't use it over land)
            nst_full=ncread(filename,'nst_att_status');
            
            % spacecraft pitch/roll/yaw
            pitch_full=ncread(filename,'sc_pitch');
            roll_full=ncread(filename,'sc_roll');
            yaw_full=ncread(filename,'sc_yaw');
            
            % prn
            prn_full=ncread(filename,'prn_code');

            % incidence/azimuth angle
            theta_full=ncread(filename,'sp_inc_angle');
            phi_full_Initial_sp_az_orbit=ncread(filename,'sp_az_orbit');
            
            % specular point direction wrt body
            the_full_sp_theta_body=ncread(filename,'sp_theta_body') ;
            phi_full_sp_az_body=ncread(filename,'sp_az_body');
            
            % gain [dB]
            gain_full=ncread(filename,'sp_rx_gain');
            
            % gps eirp
            eirp_full=ncread(filename,'gps_eirp');

%!!!!!!!!!!!!!!! not present in v3
%             % snr of direct signal [dB]
%             snr_dir_full=ncread(filename,'direct_signal_snr');
            
            % snr of reflected signal [dB]
            snr_full=ncread(filename,'ddm_snr');
            
            % noise floor from uncalibrated DDM of counts
            nf_full=ncread(filename,'ddm_noise_floor');
            
            % tx/rx ranges
            rxrange_full=ncread(filename,'rx_to_sp_range');
            txrange_full=ncread(filename,'tx_to_sp_range');
                        
            % tx position [ECEF]
            tx_pos_x_full=ncread(filename,'tx_pos_x');
            tx_pos_y_full=ncread(filename,'tx_pos_y');
            tx_pos_z_full=ncread(filename,'tx_pos_z');
            
            % tx velocity [ECEF] MP Jan2020
            tx_vel_x_full=ncread(filename,'tx_vel_x');
            tx_vel_y_full=ncread(filename,'tx_vel_y');
            tx_vel_z_full=ncread(filename,'tx_vel_z');
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % AGGIUNTA LUCA
            % Normalized BRCS
            ddm_nbrcs_full=ncread(filename,'ddm_nbrcs');
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % quality flag bits
            qc_full=ncread(filename,'quality_flags');
           
            peak_delay_full_CYGNSS=ncread(filename,'brcs_ddm_peak_bin_delay_row'); % asse Y nella DDM, in matlab sono le righe 
            peak_doppler_full_CYGNSS=ncread(filename,'brcs_ddm_peak_bin_dopp_col'); % asse X nella DDM, in matlab sono le colonne 
            
            peak_delay_full=peak_delay_full_CYGNSS+1; % In order to be correctly used in Matlab these two indexes must be inverted and it must be added 1 (matlab starts from  1, CYGNSS data from 0)
            peak_doppler_full=peak_doppler_full_CYGNSS+1; % In order to be correctly used in Matlab these two indexes must be inverted and it must be added 1 (matlab starts from  1, CYGNSS data from 0)
            
            PA2_delay_full_CYGNSS=ncread(filename,'brcs_ddm_peak_bin_delay_row'); % asse Y nella DDM, in matlab sono le righe 
            PA2_doppler_full_CYGNSS=ncread(filename,'brcs_ddm_peak_bin_dopp_col'); % asse X nella DDM, in matlab sono le colonne 
            
            PA2_delay_full=PA2_delay_full_CYGNSS+1; % In order to be correctly used in Matlab these two indexes must be inverted and it must be added 1 (matlab starts from  1, CYGNSS data from 0)
            PA2_doppler_full=PA2_doppler_full_CYGNSS+1; % In order to be correctly used in Matlab these two indexes must be inverted and it must be added 1 (matlab starts from  1, CYGNSS data from 0)
            
            % FILTER FOR GEOGRAPHICAL SUBSET (Specular Point)
            % sp_lat_full sp_lon_ew_full sono organizzati in matrici con 4 righe che rappresentano i 4 ricevitori presenti su ogni spacecraft,
            % con il ciclo for qui sotto assegno il valore 1 ai punti speculari presenti nell'area di studio e NaN agli altri
            [Receivers, Observations]=size(sp_lat_full);
            for i=1:Receivers % loop over the 4 channels of one .nc file to filter geo window
                for iobs=1:Observations  % loop over the samples of one .nc file to filter geo window
                    if ((sp_lat_full(i,iobs)>=LatMin) && (sp_lat_full(i,iobs)<=LatMax) && (sp_lon_ew_full(i,iobs)>=LonMin) && (sp_lon_ew_full(i,iobs)<=LonMax))
                        Matrix_GeoSubset(i,iobs)=1;
                    else
                        Matrix_GeoSubset(i,iobs)=NaN;
                    end
                end
            end
            % Visto che in uno stesso istante temporale (ovvero sulla stessa colonna) ci puo essere un diverso numero di ricevitori presenti nell'area di studio (o non esserci)
            % trovo i valori delle colonne (istanti temporali) che hanno almeno un ricevitore nell'area di studio e gli assegno il valore 1 e assegno NaN agli altri 
            Matrix_GeoSubset_Mean=nanmean(Matrix_GeoSubset); % it contains 1 if at least one PRN is in the geo window
            % creo un indice per trovare gli elementi con valore 1
            Matrix_GeoSubset_Index_OK=find(~isnan(Matrix_GeoSubset_Mean));
            % successivamente creo un indice per trovare gli elementi (istanti temporali) con valore NaN
            Matrix_GeoSubset_Index_NaN=find(isnan(Matrix_GeoSubset_Mean));
            % Uso l'indice Matrix_GeoSubset_Index_NaN per rimuovere le colonne della tabella che rappresentano gli istanti temporali in cui non c'è almeno un ricevitore che acquisice dati nell'area di studio
            % Le variabili che hanno solo una riga vengono modificate in
            % maniera tale da essere formate da 4 righe identiche, 1 per
            % ogni ricevitore
            ts_full4=repmat(ts_full',4,1);
            nst_full4=repmat(nst_full',4,1);
            rx_pos_x_full4=repmat(rx_pos_x_full',4,1);
            rx_pos_y_full4=repmat(rx_pos_y_full',4,1);
            rx_pos_z_full4=repmat(rx_pos_z_full',4,1);
            % MP Jan2020 to include RX velocity that is signel column
            rx_vel_x_full4=repmat(rx_vel_x_full',4,1);
            rx_vel_y_full4=repmat(rx_vel_y_full',4,1);
            rx_vel_z_full4=repmat(rx_vel_z_full',4,1);
            %
            nst_full4=repmat(nst_full',4,1);
            pitch_full4=repmat(pitch_full',4,1);
            roll_full4=repmat(roll_full',4,1);
            yaw_full4=repmat(yaw_full',4,1);
                  
            clear ts_full rx_pos_x_full rx_pos_y_full rx_pos_z_full nst_full pitch_full pitch_full roll_full yaw_full...
            rx_vel_x_full rx_vel_y_full rx_vel_z_full % MP Jan2020
            for i=1:Receivers
                sp_lat_full_single_row=sp_lat_full(i,:);
                sp_lat_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
                sp_lat(i,:)=sp_lat_full_single_row;
                
                sp_lon_full_single_row=sp_lon_full(i,:);
                sp_lon_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
                sp_lon(i,:)=sp_lon_full_single_row;
                
                sp_lon_ew_full_single_row=sp_lon_ew_full(i,:);
                sp_lon_ew_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
                sp_lon_ew(i,:)=sp_lon_ew_full_single_row;                
                
                track_id_full_single_row=track_id_full(i,:);
                track_id_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
                track_id(i,:)=track_id_full_single_row;  
                
                ts_full4_single_row=ts_full4(i,:);
                ts_full4_single_row(Matrix_GeoSubset_Index_NaN)=[];
                ts(i,:)=ts_full4_single_row;

                nst_full4_single_row=nst_full4(i,:);
                nst_full4_single_row(Matrix_GeoSubset_Index_NaN)=[];
                nst(i,:)=nst_full4_single_row;
                
                rx_pos_x_full4_single_row=rx_pos_x_full4(i,:);
                rx_pos_x_full4_single_row(Matrix_GeoSubset_Index_NaN)=[];
                rx_pos_x(i,:)=rx_pos_x_full4_single_row;
                
                rx_pos_y_full4_single_row=rx_pos_y_full4(i,:);
                rx_pos_y_full4_single_row(Matrix_GeoSubset_Index_NaN)=[];
                rx_pos_y(i,:)=rx_pos_y_full4_single_row;
                
                rx_pos_z_full4_single_row=rx_pos_z_full4(i,:);
                rx_pos_z_full4_single_row(Matrix_GeoSubset_Index_NaN)=[];
                rx_pos_z(i,:)=rx_pos_z_full4_single_row;
                
                % MP Jan2020 to add TX velocity out
                rx_vel_x_full4_single_row=rx_vel_x_full4(i,:);
                rx_vel_x_full4_single_row(Matrix_GeoSubset_Index_NaN)=[];
                rx_vel_x(i,:)=rx_vel_x_full4_single_row;
                
                rx_vel_y_full4_single_row=rx_vel_y_full4(i,:);
                rx_vel_y_full4_single_row(Matrix_GeoSubset_Index_NaN)=[];
                rx_vel_y(i,:)=rx_vel_y_full4_single_row;
                
                rx_vel_z_full4_single_row=rx_vel_z_full4(i,:);
                rx_vel_z_full4_single_row(Matrix_GeoSubset_Index_NaN)=[];
                rx_vel_z(i,:)=rx_vel_z_full4_single_row;               
                % end
                
                pitch_full4_single_row=pitch_full4(i,:);
                pitch_full4_single_row(Matrix_GeoSubset_Index_NaN)=[];
                pitch(i,:)=pitch_full4_single_row;
                               
                roll_full4_single_row=roll_full4(i,:);
                roll_full4_single_row(Matrix_GeoSubset_Index_NaN)=[];
                roll(i,:)=roll_full4_single_row;
                
                yaw_full4_single_row=yaw_full4(i,:);
                yaw_full4_single_row(Matrix_GeoSubset_Index_NaN)=[];
                yaw(i,:)=yaw_full4_single_row;
                
                prn_full_single_row=prn_full(i,:);
                prn_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
                prn(i,:)=prn_full_single_row;
                
                theta_full_single_row=theta_full(i,:);
                theta_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
                theta(i,:)=theta_full_single_row;
                
                phi_full_Initial_sp_az_orbit_single_row=phi_full_Initial_sp_az_orbit(i,:);
                phi_full_Initial_sp_az_orbit_single_row(Matrix_GeoSubset_Index_NaN)=[];
                phi_Initial_sp_az_orbit(i,:)=phi_full_Initial_sp_az_orbit_single_row;
                              
                
                phi_full_sp_az_body_single_row=phi_full_sp_az_body(i,:);
                phi_full_sp_az_body_single_row(Matrix_GeoSubset_Index_NaN)=[];
                phi_sp_az_body(i,:)=phi_full_sp_az_body_single_row;
                
                the_full_sp_theta_body_single_row=the_full_sp_theta_body(i,:) ; % MP
                the_full_sp_theta_body_single_row(Matrix_GeoSubset_Index_NaN)=[] ; % MP
                the_sp_theta_body(i,:)=the_full_sp_theta_body_single_row ;  % MP
                
                gain_full_single_row=gain_full(i,:);
                gain_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
                gain(i,:)=gain_full_single_row;
                                
                eirp_full_single_row=eirp_full(i,:);
                eirp_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
                eirp(i,:)=eirp_full_single_row;
                
                
%                 snr_dir_full_single_row=snr_dir_full(i,:);
%                 snr_dir_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
%                 snr_dir(i,:)=snr_dir_full_single_row;
                
                snr_full_single_row=snr_full(i,:);
                snr_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
                snr(i,:)=snr_full_single_row;
                
                nf_full_single_row=nf_full(i,:);
                nf_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
                nf(i,:)=nf_full_single_row;
                
                rxrange_full_single_row=rxrange_full(i,:);
                rxrange_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
                rxrange(i,:)=rxrange_full_single_row;                
 
                txrange_full_single_row=txrange_full(i,:);
                txrange_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
                txrange(i,:)=txrange_full_single_row;
                
                tx_pos_x_full_single_row=tx_pos_x_full(i,:);
                tx_pos_x_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
                tx_pos_x(i,:)=tx_pos_x_full_single_row;
                
                tx_pos_y_full_single_row=tx_pos_y_full(i,:);
                tx_pos_y_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
                tx_pos_y(i,:)=tx_pos_y_full_single_row;
                
                tx_pos_z_full_single_row=tx_pos_z_full(i,:);
                tx_pos_z_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
                tx_pos_z(i,:)=tx_pos_z_full_single_row;
                
                % MP Jan2020 to add TX velocity out
                tx_vel_x_full_single_row=tx_vel_x_full(i,:);
                tx_vel_x_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
                tx_vel_x(i,:)=tx_vel_x_full_single_row;
                
                tx_vel_y_full_single_row=tx_vel_y_full(i,:);
                tx_vel_y_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
                tx_vel_y(i,:)=tx_vel_y_full_single_row;
                
                tx_vel_z_full_single_row=tx_vel_z_full(i,:);
                tx_vel_z_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
                tx_vel_z(i,:)=tx_vel_z_full_single_row;               
                % end
                
                ddm_nbrcs_full_single_row=ddm_nbrcs_full(i,:);
                ddm_nbrcs_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
                ddm_nbrcs(i,:)=ddm_nbrcs_full_single_row;                
                
                qc_full_single_row=qc_full(i,:);
                qc_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
                qc(i,:)=qc_full_single_row;
                
                peak_delay_full_single_row=peak_delay_full(i,:);
                peak_delay_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
                peak_delay(i,:)=peak_delay_full_single_row;
               
                peak_doppler_full_single_row=peak_doppler_full(i,:);
                peak_doppler_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
                peak_doppler(i,:)=peak_doppler_full_single_row;
                             
                PA2_delay_full_single_row=PA2_delay_full(i,:);
                PA2_delay_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
                PA2_delay(i,:)=PA2_delay_full_single_row;
                
                PA2_doppler_full_single_row=PA2_doppler_full(i,:);
                PA2_doppler_full_single_row(Matrix_GeoSubset_Index_NaN)=[];
                PA2_doppler(i,:)=PA2_doppler_full_single_row;
  %%%%%%%%%%%%%%%%%%%%  ORUNT INDEX              
  %              i
                
            end
            
           clear  sp_lat_full sp_lat_full_single_row sp_lon_full sp_lon_full_single_row sp_lon_ew_full sp_lon_ew_full_single_row ... 
            track_id_full track_id_full_single_row ts_full4 ts_full4_single_row nst_full4 nst_full4_single_row rx_pos_x_full4 rx_pos_x_full4_single_row...
            rx_pos_y_full4 rx_pos_y_full4_single_row rx_pos_z_full4 rx_pos_z_full4_single_row pitch_full4 pitch_full4_single_row roll_full4 roll_full4_single_row...
            yaw_full4 yaw_full4_single_row prn_full prn_full_single_row theta_full theta_full_single_row phi_full_Initial_sp_az_orbit phi_full_Initial_sp_az_orbit_single_row phi_full_sp_az_body phi_full_sp_az_body_single_row gain_full gain_full_single_row...
            eirp_full eirp_full_single_row snr_full snr_full_single_row nf_full nf_full_single_row rxrange_full rxrange_full_single_row...
            tx_pos_x_full tx_pos_x_full_single_row tx_pos_y_full tx_pos_y_full_single_row tx_pos_z_full tx_pos_z_full_single_row ddm_nbrcs_full ddm_nbrcs_full_single_row...
            qc_full qc_full_single_row peak_delay_full peak_delay_full_single_row peak_doppler_full peak_doppler_full_single_row PA2_doppler_full PA2_doppler_full_single_row PA2_delay_full PA2_delay_full_single_row peak_delay_full_CYGNSS peak_doppler_full_CYGNSS PA2_doppler_full_CYGNSS PA2_delay_full_CYGNSS...
            tx_vel_x_full tx_vel_x_full_single_row tx_vel_y_full tx_vel_y_full_single_row tx_vel_z_full tx_vel_z_full_single_row...      % MO Jan 2020
            rx_vel_x_full rx_vel_x_full_single_row rx_vel_y_full rx_vel_y_full_single_row rx_vel_z_full rx_vel_z_full_single_row         % MP Jan 2020
%      
            % Loading power_analog / DDM
            pa=ncread(filename,'power_analog');
            
            % trovo il numero di elementi presenti (i.e., colonne) nell'area di studio selezionata
             bb=size(qc,2);
             
            % Creo questi tre campi per la matrice finale
            scid=double(scid_Initial).*ones(size(qc));
            ddm_source=double(ddm_source_in).*ones(size(qc));
            dayofyear=str2num(DirectoryIndices(ii,:)).*ones(size(qc));
                        
            % DDM peak: calculated as the maximum value in DDM
            peak=NaN(4,bb);
            
            % DDM peak: calculated as the value in the DDM row and column given by (brcs_ddm_peak_bin_delay_row,brcs_ddm_peak_bin_dopp_col);
            peak2=NaN(4,bb);
            
            % noise floor for the first peak calculation
            nftemp=NaN(4,bb);
            
            % noise floor for the second peak calculation
            nftemp2=NaN(4,bb);
            
            % AGGIUNTA LUCA
            PA_doppler=NaN(4,bb);
            PA_delay=NaN(4,bb);
            % Number of bins >= Threshold (computed in the area where the noise is estimated)
            Bins_With_Value_HT_Threshold_NF=NaN(4,bb);
            Bins_With_Value_HT_Threshold_DDM=NaN(4,bb);
            % Number of bins >= Threshold (computed in the whole DDM)
            Bins_With_Value_HT_Threshold_NF2=NaN(4,bb);
            Bins_With_Value_HT_Threshold_DDM2=NaN(4,bb);
            % Number of bins with maximum/peak value in the whole DDM --> serve per vedere quanti picchi (valori massimi) ci sono in ogni DDM
            Bins_With_Peak=NaN(4,bb);
            Bins_With_Peak2=NaN(4,bb);
            % DDM
            if DDMs_Flag==1
                DDM_GeoSubset=cell(4,bb);
                else
            end
            % Kurtosis
            Kurtosis=NaN(4,bb);
            Kurtosis_Unbiased=NaN(4,bb);
            Kurtosis_dopp0=NaN(4,bb);
            TE_width=NaN(4,bb);
            
            WF_threshold_value = NaN(4,bb);
            peak_WF = NaN(4,bb); ind_peak = NaN(4,bb);
            peak_delay_WF = NaN(4,bb); WF_threshold_input = NaN(4,bb);
            diff_peak_threshold = NaN(4,bb); min_diff_threshold = NaN(4,bb);
            closestIndex = NaN(4,bb); ind_thr_value = NaN(4,bb);
            
            for uu=1:Receivers
                for vv=1:bb
                    
                    % read DDM of analog scattered power
                    DDMtemp=pa(:,:,uu,Matrix_GeoSubset_Index_OK(vv));
                    
                    % Save the DDM of the GeoSubset as a column vector
                    if DDMs_Flag==1
                        DDM_GeoSubset{uu,vv}=DDMtemp(:)'; 
                        else
                    end
                                            
                    % first version of DDM peak: maximum of DDM
                    [i1, i2]=find(DDMtemp==max(DDMtemp(:)));
                    peak(uu,vv)=max(DDMtemp(:));
                    Bins_With_Peak(uu,vv)=sum(DDMtemp(:)==max(DDMtemp(:))); % Number of bins with peak value in the whole DDM --> serve per vedere quanti picchi (valori massimi) ci sono in ogni DDM
                    
                    % Computin Kurtosis
                    Kurtosis(uu,vv)=kurtosis(DDMtemp(:));
                    Kurtosis_Unbiased(uu,vv)=kurtosis(DDMtemp(:),0);
                    
                    %Kurtosis with normalization 
                    Doppler_bins=[1:1:17] ; 
                    DDMsize=size(DDMtemp) ; 
                    %SELEZIONARE LA RIGA CENTRALE A DOPP 0 
                    Dopp_nulla = DDMtemp(6,:);
                    % MO 11/11/2020 mette a zero campioni negativi (rumore)
                    Dopp_nulla(find(Dopp_nulla <0))=0 ; 
                    Dopp_norm = Dopp_nulla/sum(Dopp_nulla);
                    N=size(Dopp_nulla) ;
%                     ind=[1: 1: N(1)] ; 
%                     ind=ind' ; 
                    c(uu,vv) = sum(Doppler_bins.*Dopp_norm) ; 
                    var(uu,vv) = sum(Dopp_norm.*((Doppler_bins-c(uu,vv)).^2)) ;
                    Kurtosis_dopp0(uu,vv) = sum(Dopp_norm.*((Doppler_bins-c(uu,vv)).^4))./var(uu,vv)^2;
                   

                    %Trailing Edge width
                    
                    waveform_peak(uu,vv) = max(Dopp_nulla);
                    CA_chip_delay = 0.2552; %around 1/4 of CA code chip
                    delay_vector = 0:CA_chip_delay:16*CA_chip_delay;
                    if (sum(isnan(Dopp_nulla))~=0) %check if DDM zero doppler in the region has an empty value
                        TE_width(uu,vv) = NaN;
                    else
                        cs = spline(delay_vector, Dopp_nulla);
                        nn = size(Dopp_nulla,2)*100 + 1; %index 1:1701
                        resampled_delay = linspace(delay_vector(1),delay_vector(end), nn);

                        resampled_WF = ppval(cs,resampled_delay);

                        [peak_WF(uu,vv),ind_peak(uu,vv)] = max(resampled_WF);
                        peak_delay_WF(uu,vv) = resampled_delay(ind_peak(uu,vv));

                        WF_threshold_input(uu,vv) = peak_WF(uu,vv)*0.7; %power threshold 70% 
                        trail_ones = ones(1, length(resampled_WF(ind_peak(uu,vv):end)));
                        trail_peak_WF_ones = ones*peak_WF(uu,vv); %vector of the WF_peak value
                        WF_trail = resampled_WF(ind_peak(uu,vv):end); %vector representing values over the peak till the end
                        check_greater_than_threshold = WF_trail >= WF_threshold_input(uu,vv);
                        
                        if (all(check_greater_than_threshold) == 1) %condition if threshold is over the 1700 lag samples
                            TE_width(uu,vv) = NaN;
                        elseif (ind_peak(uu,vv) >= 1690) %check if peak is too shifted to the end of lags
                            TE_width(uu,vv) = NaN;
                        else
                            
                            flip_WF_trail = flip(WF_trail);
                            flip_threshold = flip_WF_trail(flip_WF_trail <= WF_threshold_input(uu,vv)); 
                            WF_trail_second = flip(flip_threshold); %Selected value from the tail of resampled WF to select the nearest value of threshold that is farther from peak 
                            
                            %diff_peak_trail = trail_peak_WF_ones - WF_trail; %difference between peak power and all following values to see the minimum difference.
                            diff_peak_trail = trail_peak_WF_ones - WF_trail_second;
                            diff_peak_threshold(uu,vv) = peak_WF(uu,vv) - WF_threshold_input(uu,vv); %power loss at 70% power reduction

                            min_diff_threshold(uu,vv) = min(abs(diff_peak_trail-diff_peak_threshold(uu,vv)));
                            closestIndex(uu,vv) = find(min_diff_threshold(uu,vv)) + (length(WF_trail) - length(WF_trail_second));
                            WF_threshold_value(uu,vv) = WF_trail(closestIndex(uu,vv)); %closest value to the power threshold 70%, that means "WF_threshold_input" 
                             
                            eligible_values_for_threshold = find(resampled_WF == WF_threshold_value(uu,vv));
                            ind_thr_value(uu,vv) = eligible_values_for_threshold(end); %select the farthest value from peak

                            TE_width(uu,vv) = (resampled_delay(ind_thr_value(uu,vv)) - peak_delay_WF(uu,vv))* 1.5* 10^8 *10^-6; %trailing edge width in metres
                             
                         end
                    end
                                      

                    
                    % AGGIUNTA LUCA per trovare coordinate massimo DDM               
                    [max_num, max_idx]=max(DDMtemp(:));
                    [PA_doppler_FULL,PA_delay_FULL]=ind2sub(size(DDMtemp),find(DDMtemp==max_num));
                    %(Asse Y, Asse X) --> ATTENZIONE POSSIBILE ERRORE: in
                    %realtà sembra che queste dimensioni siano corrette
                    %(e.g., coerenti con il PA2_DOPPLER, PA2_DELAY) se considerate al contrario (i.e., invertite) --> da capire meglio..)
                    if isnan(PA_doppler_FULL)==0
                        PA_doppler(uu,vv)=PA_doppler_FULL(1); % prendo un valore univoco perchè il valore massimo nella ddm potrebbe non essere univoco                        
                    else
                        PA_doppler(uu,vv)=NaN; % se il valore massimo non c'è imposto il valore su NaN
                    end
                    if isnan(PA_delay_FULL)==0
                        PA_delay(uu,vv)=PA_delay_FULL(1);  % prendo un valore univoco perchè il valore massimo nella ddm potrebbe non essere univoco                      
                    else
                        PA_delay(uu,vv)=NaN; % se il valore massimo non c'è imposto il valore su NaN
                    end
                    
                    % compute noise floor as the mean of the DDM subset
                    % taken as all the Dopplers, and the delays from the
                    % first until the one separated from the peak by 0.75
                    % chips
                    
                    % if the peak is located at a delay column of 4 or
                    % less, then there are not enough delay columns to
                    % calculate the noise floor
                    if i2<5
                        nftemp(uu,vv)=NaN;
                        Bins_HT_NF(uu,vv)=NaN;
                    else
                        nfddmtemp=DDMtemp(:,1:i2-4);
                        nftemp(uu,vv)=nanmean(nfddmtemp(:));
                        Threshold_NF=2*nftemp; % Questo serve per trovare il threshold da utilizzare per il calcolo degli outlier nell'area dove si calcola il rumore
                        Threshold_DDM=2*nftemp; % Questo serve per trovare il threshold da utilizzare per il calcolo degli outlier nell'area dell'intera DDM
                        Bins_With_Value_HT_Threshold_NF(uu,vv)=sum(nfddmtemp(:)>= Threshold_NF(uu,vv)); % Questo serve per trovare il numero di bin nell'area IN CUI SI CALCOLA IL RUMORE che hanno un valore oltre il Threshold_NF
                        Bins_With_Value_HT_Threshold_DDM(uu,vv)=sum(DDMtemp(:)>= Threshold_DDM(uu,vv)); % Questo serve per trovare il numero di bin nell'area DI TUTTA LA DDM che hanno un valore oltre il Threshold_DDM
                    end
                    
                    % land overall quality flag: its' the AND of a number
                    % of bits - please type ncdisp(netCDF FILENAME) FOR
                    % DETAILS OF EACH FLAG
                    oqf(uu,vv)=(bitget(qc(uu,vv),4) | bitget(qc(uu,vv),5) | bitget(qc(uu,vv),6) | bitget(qc(uu,vv),7) | bitget(qc(uu,vv),8) | bitget(qc(uu,vv),9) | bitget(qc(uu,vv),10) | bitget(qc(uu,vv),14) | bitget(qc(uu,vv),15) | bitget(qc(uu,vv),16) | bitget(qc(uu,vv),18) | bitget(qc(uu,vv),22) | bitget(qc(uu,vv),23) | bitget(qc(uu,vv),26));
                    
                    % SP over land flag
                    lf(uu,vv)=bitget(qc(uu,vv),11);
%                     
%                   % second version of peak % brcs
                    peak_delaytemp=peak_delay(uu,vv);
                    peak_dopplertemp=peak_doppler(uu,vv);
                     if peak_delaytemp>0 & peak_dopplertemp>0
                         peak2(uu,vv)=DDMtemp(peak_dopplertemp,peak_delaytemp); % IN MATLAB, LE RIGHE E COLONNE SONO INVERTITE RISPETTO ALLE DDM CYGNSS 
                         Bins_With_Peak2(uu,vv)=sum(DDMtemp(:)==DDMtemp(peak_dopplertemp,peak_delaytemp)); % Number of bins with peak2 value in the whole DDM --> serve per vedere quanti picchi (valori massimi) ci sono in ogni DDM
                     if peak_delaytemp<5
                         nftemp2(uu,vv)=NaN;
                         Bins_HT_NF2(uu,vv)=NaN;
                     else
                         nfddmtemp=DDMtemp(:,1:peak_delaytemp-4);
                         nftemp2(uu,vv)=nanmean(nftemp(:));
                         Threshold_NF2=2*nftemp2; % Questo serve per trovare il threshold da utilizzare per il calcolo degli outlier nell'area dove si calcola il rumore (VERSIONE 2)
                         Threshold_DDM2=2*nftemp2; % Questo serve per trovare il threshold da utilizzare per il calcolo degli outlier nell'area dell'intera DDM (VERSIONE 2)
                         Bins_With_Value_HT_Threshold_NF2(uu,vv)=sum(nfddmtemp(:)>= Threshold_NF2(uu,vv)); % Questo serve per trovare il numero di bin nell'area IN CUI SI CALCOLA IL RUMORE che hanno un valore oltre il Threshold_NF2
                         Bins_With_Value_HT_Threshold_DDM2(uu,vv)=sum(DDMtemp(:)>= Threshold_DDM2(uu,vv)); % Questo serve per trovare il numero di bin nell'area DI TUTTA LA DDM che hanno un valore oltre il Threshold_DDM2
                     end
                     end
                 end
             end
             
            % combine all into one
            SCID=[SCID; scid(:)];
            SoD=[SoD; ts(:)];
            DDM_SOURCE = [DDM_SOURCE; ddm_source(:)];
            DoY=[DoY; dayofyear(:)];
            RX_POS_X=[RX_POS_X; rx_pos_x(:)];
            RX_POS_Y=[RX_POS_Y; rx_pos_y(:)];
            RX_POS_Z=[RX_POS_Z; rx_pos_z(:)];
            % MP Jan 2020 to include RX velocity output
            RX_VEL_X=[RX_VEL_X; rx_vel_x(:)];
            RX_VEL_Y=[RX_VEL_Y; rx_vel_y(:)];
            RX_VEL_Z=[RX_VEL_Z; rx_vel_z(:)];
            %           
            NST=[NST; nst(:)];
            PITCH=[PITCH; pitch(:)];
            ROLL=[ROLL(:); roll(:)];
            YAW=[YAW; yaw(:)];
            PRN=[PRN; prn(:)];
            SPLAT=[SPLAT; sp_lat(:)];
            SPLON=[SPLON; sp_lon(:)];
            THETA=[THETA; theta(:)];
            PHI_Initial_sp_az_orbit=[PHI_Initial_sp_az_orbit; phi_Initial_sp_az_orbit(:)];
            PHI_sp_az_body=[PHI_sp_az_body; phi_sp_az_body(:)];
            THE_sp_theta_body=[THE_sp_theta_body; the_sp_theta_body(:)] ; % MP
            GAIN=[GAIN; gain(:)];
            EIRP=[EIRP; eirp(:)];
%             SNR_DIR=[SNR_DIR; snr_dir(:)];
            SNR=[SNR; snr(:)];
            NFRAW=[NFRAW; nf(:)];
            RXRANGE=[RXRANGE; rxrange(:)];
            TXRANGE=[TXRANGE; txrange(:)];
            TX_POS_X=[TX_POS_X; tx_pos_x(:)];
            TX_POS_Y=[TX_POS_Y; tx_pos_y(:)];
            TX_POS_Z=[TX_POS_Z; tx_pos_z(:)];
            % MP Jan 2020 to include RX velocity output
            TX_VEL_X=[TX_VEL_X; tx_vel_x(:)];
            TX_VEL_Y=[TX_VEL_Y; tx_vel_y(:)];
            TX_VEL_Z=[TX_VEL_Z; tx_vel_z(:)];
            % 
%           OQF=[OQF; oqf(:)];
            QC=[QC; qc(:)]; % AGGIUNTA LUCA
%            LF=[LF; lf(:)];
            PA=[PA; peak(:)];
            NF=[NF; nftemp(:)];
            PA2=[PA2; peak2(:)];
            NF2=[NF2; nftemp2(:)];
            PA_DOPPLER=[PA_DOPPLER; PA_doppler(:)]; % AGGIUNTA LUCA
            PA_DELAY=[PA_DELAY; PA_delay(:)]; % AGGIUNTA LUCA
            PA2_DOPPLER=[PA2_DOPPLER; PA2_doppler(:)]; % AGGIUNTA LUCA
            PA2_DELAY=[PA2_DELAY; PA2_delay(:)]; % AGGIUNTA LUCA
            BINS_HT_THRESHOLD_NF=[BINS_HT_THRESHOLD_NF; Bins_With_Value_HT_Threshold_NF(:)]; % AGGIUNTA LUCA
            BINS_HT_THRESHOLD_DDM=[BINS_HT_THRESHOLD_DDM; Bins_With_Value_HT_Threshold_DDM(:)]; % AGGIUNTA LUCA
            BINS_HT_THRESHOLD_NF2=[BINS_HT_THRESHOLD_NF2; Bins_With_Value_HT_Threshold_NF2(:)]; % AGGIUNTA LUCA
            BINS_HT_THRESHOLD_DDM2=[BINS_HT_THRESHOLD_DDM2; Bins_With_Value_HT_Threshold_DDM2(:)]; % AGGIUNTA LUCA
            BINS_WITH_PEAK=[BINS_WITH_PEAK; Bins_With_Peak(:)]; % AGGIUNTA LUCA
            BINS_WITH_PEAK2=[BINS_WITH_PEAK2; Bins_With_Peak2(:)]; % AGGIUNTA LUCA
            TRACK_ID=[TRACK_ID; track_id(:)]; % AGGIUNTA LUCA
            DDM_NBRCS=[DDM_NBRCS; ddm_nbrcs(:)]; % AGGIUNTA LUCA
            SPLON_EW=[SPLON_EW; sp_lon_ew(:)];
            if DDMs_Flag==1
                DDM_GEOSUBSET=[DDM_GEOSUBSET; DDM_GeoSubset(:)];
                else
            end           
            KURTOSIS=[KURTOSIS; Kurtosis(:)];
            KURTOSIS_UNBIASED=[KURTOSIS_UNBIASED; Kurtosis_Unbiased(:)];   
            KURTOSIS_DOPP_0=[KURTOSIS_DOPP_0; Kurtosis_dopp0(:)]; 
            TE_WIDTH = [TE_WIDTH; TE_width(:)];
        end
        
    clear Matrix_GeoSubset Matrix_GeoSubset_Mean Matrix_GeoSubset_Index_OK Matrix_GeoSubset_Index_NaN

    clear  scid ts dayofyear ddm_source rx_pos_x rx_pos_y rx_pos_z nst pitch roll yaw prn sp_lat sp_lon theta phi_Initial_sp_az_orbit phi_sp_az_body gain the_sp_theta_body eirp...
    snr nf rxrange txrange tx_pos_x tx_pos_y tx_pos_z oqf qc lf peak nftemp peak2 nftemp2 PA_doppler PA_delay...
    PA2_doppler PA2_delay Bins_With_Value_HT_Threshold_NF Bins_With_Value_HT_Threshold_DDM Bins_With_Value_HT_Threshold_NF2 Bins_With_Value_HT_Threshold_DDM2...
    Bins_With_Peak Bins_With_Peak2 track_id ddm_nbrcs sp_lon_ew peak_delay peak_doppler Kurtosis Kurtosis_Unbiased Kurtosis_dopp0...
    rx_vel_x rx_vel_y rx_vel_z tx_vel_x tx_vel_y tx_vel_z 

    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %             % AGGIUNTA LUCA
    % Compute Reflectivity by using EIRP provided by Metadata
    
    % Linear 2 dB conversion
    %  A = 10*log10(P2/P1)     (Linear to dB)
    %  P2/P1 = 10^(A/10)       (dB to Linear)
    GAIN_LINEAR=10.^(GAIN/10);
    lambda=0.1903; % 0.19 m --> 19 cm  MP: aggiornata rispetto a 0.19
    
    % MP 11/11/2020 rimossa sottrazione del rumore
    % REFLECTIVITY_LINEAR_PA=(((4.*pi).^2).*(PA-NF).*((RXRANGE+TXRANGE).^2))./(EIRP.*GAIN_LINEAR.*lambda.^2);
    REFLECTIVITY_LINEAR_PA=(((4.*pi).^2).*PA.*((RXRANGE+TXRANGE).^2))./(EIRP.*GAIN_LINEAR.*lambda.^2);
    
    %REFLECTIVITY_dB_PA=10*log10(REFLECTIVITY_LINEAR_PA);
   
    Num_CalFactDDMs=(((4.*pi).^2).*((RXRANGE+TXRANGE).^2));
    Den_CalFactDDMs=(EIRP.*GAIN_LINEAR.*lambda.^2);
   
    % MP 11/11/2020 rimossa sottrazione del rumore
    % REFLECTIVITY_LINEAR_PA2=(((4.*pi).^2).*(PA2-NF2).*((RXRANGE+TXRANGE).^2))./(EIRP.*GAIN_LINEAR.*lambda.^2);
    REFLECTIVITY_LINEAR_PA2=(((4.*pi).^2).*PA2.*((RXRANGE+TXRANGE).^2))./(EIRP.*GAIN_LINEAR.*lambda.^2);
    %REFLECTIVITY_dB_PA2=10*log10(REFLECTIVITY_LINEAR_PA2);
      
   
    % Compute Reflectivity by using SNR_DIR to calculate EIRP

%     ReceiverTransmitterDistance=(TX_POS_X-RX_POS_X).^2+(TX_POS_Y-RX_POS_Y).^2+(TX_POS_Z-RX_POS_Z).^2;
%     SNR_DIR_LINEAR=10.^(SNR_DIR/10);
%     CalDirect=(SNR_DIR_LINEAR-1).*ReceiverTransmitterDistance;
% 
%     Cal=((RXRANGE+TXRANGE).^2)./GAIN_LINEAR;
% 
%     REFLECTIVITY_LINEAR_PA_vNewEIRP=(PA-NF).*Cal./CalDirect; 
%     %REFLECTIVITY_dB_PA_NewEIRP=10*log10(REFLECTIVITY_LINEAR_PA_NewEIRP);
% 
%     REFLECTIVITY_LINEAR_PA2_vNewEIRP=(PA2-NF2).*Cal./CalDirect;
%     %REFLECTIVITY_dB_PA2_NewEIRP=10*log10(REFLECTIVITY_LINEAR_PA2_NewEIRP);
    
    REFLECTIVITY_LINEAR_PA(REFLECTIVITY_LINEAR_PA<=0)=NaN;
    REFLECTIVITY_LINEAR_PA2(REFLECTIVITY_LINEAR_PA2<=0)=NaN;
%     REFLECTIVITY_LINEAR_PA_vNewEIRP(REFLECTIVITY_LINEAR_PA_vNewEIRP<=0)=NaN;
%     REFLECTIVITY_LINEAR_PA2_vNewEIRP(REFLECTIVITY_LINEAR_PA2_vNewEIRP<=0)=NaN;  
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Saving Data

%MATRICE GENERALE
%     CYGNSS_Data=NaN([numel(SCID),52]); % Inizializzo la matrice
% 
%     CYGNSS_Data(:,1)=Year;
%     CYGNSS_Data(:,2)=DoY; % DOY
%     CYGNSS_Data(:,3)=SoD;  % second of the day / time stamp ddm_timestamp_utc The number of seconds since time_coverage_start with nanosecond resolution.
%     CYGNSS_Data(:,4)=SCID; % CYGNSS sat ID spacecraft_num
%     CYGNSS_Data(:,5)=RX_POS_X; % rx position (ECEF) sc_pos_x
%     CYGNSS_Data(:,6)=RX_POS_Y; % rx position (ECEF) sc_pos_y
%     CYGNSS_Data(:,7)=RX_POS_Z; % rx position (ECEF) sc_pos_z
%     CYGNSS_Data(:,8)=NST; % Nano Star Tracker attitude status nst_att_status
%     CYGNSS_Data(:,9)=PITCH; % pitch sc_pitch
%     CYGNSS_Data(:,10)=ROLL; % roll sc_roll
%     CYGNSS_Data(:,11)=YAW; % yaw sc_yaw
%     CYGNSS_Data(:,12)=PRN; % prn_code
%     CYGNSS_Data(:,13)=SPLAT; % specular point latitude sp_lat
%     CYGNSS_Data(:,14)=SPLON; % specular point longitude sp_lon (0-360)
%     CYGNSS_Data(:,15)=SPLON_EW; % specular point longitude sp_lon (-180 +180)
%     CYGNSS_Data(:,16)=THETA; % Specular point incidence angle sp_inc_angle
%     CYGNSS_Data(:,17)=PHI_Initial_sp_az_orbit; % Specular point orbit frame azimuth angle - sp_az_orbit
%     CYGNSS_Data(:,18)=TX_POS_X; % tx position [ECEF] tx_pos_x
%     CYGNSS_Data(:,19)=TX_POS_Y; % tx position [ECEF] tx_pos_y
%     CYGNSS_Data(:,20)=TX_POS_Z; % tx position [ECEF] tx_pos_z
%     CYGNSS_Data(:,21)=GAIN; % Specular point Rx antenna gain [dB]
%     CYGNSS_Data(:,22)=GAIN_LINEAR; % Specular point Rx antenna gain [Linear]
%     CYGNSS_Data(:,23)=EIRP; % gps_eirp in watt
%     CYGNSS_Data(:,24)=SNR_DIR; % snr of direct signal direct_signal_snr [dB]
%     CYGNSS_Data(:,25)=SNR; % snr of reflected signal ddm_snr [dB]
%     CYGNSS_Data(:,26)=NFRAW; % noise floor from uncalibrated DDM of counts ddm_noise_floor
%     CYGNSS_Data(:,27)=RXRANGE; % Rx to specular point range rx_to_sp_range
%     CYGNSS_Data(:,28)=TXRANGE; % Tx to specular point range tx_to_sp_range
%     CYGNSS_Data(:,29)=REFLECTIVITY_LINEAR_PA; % Reflectivity Computed with method 1 (Linear)
%     CYGNSS_Data(:,30)=REFLECTIVITY_LINEAR_PA2; % Reflectivity Computed with method 2 (Linear)
%     CYGNSS_Data(:,31)=DDM_NBRCS; % Normalized BRCS of a 3 delay x 5 Doppler bin box that includes the specular point bin ddm_nbrcs
%     CYGNSS_Data(:,32)=QC; % quality_flags   
%     CYGNSS_Data(:,33)=PA; % Peak method 1
%     CYGNSS_Data(:,34)=PA2; % Peak method 2
%     CYGNSS_Data(:,35)=NF; % Noise method 1
%     CYGNSS_Data(:,36)=NF2; % noise method 2
%     CYGNSS_Data(:,37)=TRACK_ID; % DDM Track ID track_id
%     CYGNSS_Data(:,38)=BINS_HT_THRESHOLD_NF; % 
%     CYGNSS_Data(:,39)=BINS_HT_THRESHOLD_DDM; % 
%     CYGNSS_Data(:,40)=BINS_HT_THRESHOLD_NF2; % 
%     CYGNSS_Data(:,41)=BINS_HT_THRESHOLD_DDM2; % 
%     CYGNSS_Data(:,42)=BINS_WITH_PEAK; %
%     CYGNSS_Data(:,43)=BINS_WITH_PEAK2; %
%     CYGNSS_Data(:,44)=PA_DOPPLER; %
%     CYGNSS_Data(:,45)=PA_DELAY; %
%     CYGNSS_Data(:,46)=PA2_DOPPLER; %
%     CYGNSS_Data(:,47)=PA2_DELAY; %
%     CYGNSS_Data(:,48)=PHI_sp_az_body; % Specular point orbit frame azimuth angle - sp_az_orbit
%     CYGNSS_Data(:,49)=REFLECTIVITY_LINEAR_PA_vNewEIRP; % Reflectivity Computed with method 1 (Linear) and EIRP derived from SNR_DIR
%     CYGNSS_Data(:,50)=REFLECTIVITY_LINEAR_PA2_vNewEIRP; % Reflectivity Computed with method 2 (Linear) and EIRP derived from SNR_DIR
%     CYGNSS_Data(:,51)=KURTOSIS; 
%     CYGNSS_Data(:,52)=KURTOSIS_UNBIASED;
    
 
if DDMs_Flag==1
    DDMs_Uncalibrated=cell2mat(DDM_GEOSUBSET);
    [aaa bbb]=size(DDMs_Uncalibrated)
    for ijij=1:aaa
        DDMs_Calibrated(ijij,:)=((DDMs_Uncalibrated(ijij,:)-NF(ijij,1)).*Num_CalFactDDMs(ijij,1))./Den_CalFactDDMs(ijij,1);
    end
else    
    end

 end
toc
%tend=toc(tstart);

%%%%%%FILTERING OUT DATA IN THE REGION OF INTEREST (Donato)
    X1=[LonMin,LatMin]; X2=[LonMax,LatMin]; X3=[LonMax,LatMax]; X4=[LonMin,LatMax];
    X=[X1(1),X2(1),X3(1),X4(1)];
    Y=[X1(2),X2(2),X3(2),X4(2)];
    in = inpolygon(SPLON_EW,SPLAT, X,Y);
    
   
    idx_true = find(in == 1);
    REFLECTIVITY_LINEAR_PA = REFLECTIVITY_LINEAR_PA(idx_true);
    SPLAT = SPLAT(idx_true);
    SPLON = SPLON(idx_true);
    DoY = DoY(idx_true);
    SoD = SoD(idx_true);
    SCID = SCID(idx_true);
    DDM_SOURCE = DDM_SOURCE(idx_true);
    PITCH = PITCH(idx_true);
    ROLL = ROLL(idx_true);
    YAW = YAW(idx_true);
    PRN = PRN(idx_true);
    THETA = THETA(idx_true);
    GAIN = GAIN(idx_true);
    EIRP = EIRP(idx_true);
    SNR = SNR(idx_true);
    PHI_Initial_sp_az_orbit = PHI_Initial_sp_az_orbit(idx_true);
    TX_POS_X = TX_POS_X(idx_true);
    TX_POS_Y = TX_POS_Y(idx_true);
    TX_POS_Z = TX_POS_Z(idx_true);
    TX_VEL_X = TX_VEL_X(idx_true);
    TX_VEL_Y = TX_VEL_Y(idx_true);
    TX_VEL_Z = TX_VEL_Z(idx_true);
    RX_POS_X = RX_POS_X(idx_true);
    RX_POS_Y = RX_POS_Y(idx_true);
    RX_POS_Z = RX_POS_Z(idx_true);
    RX_VEL_X = RX_VEL_X(idx_true);
    RX_VEL_Y = RX_VEL_Y(idx_true);
    RX_VEL_Z = RX_VEL_Z(idx_true);
    KURTOSIS = KURTOSIS(idx_true);
    KURTOSIS_DOPP_0 = KURTOSIS_DOPP_0(idx_true);
    TE_WIDTH = TE_WIDTH(idx_true);
    
    
    DDM_NBRCS = DDM_NBRCS(idx_true);
    QC = QC(idx_true);
    PA = PA(idx_true);
    NF = NF(idx_true);
    TRACK_ID = TRACK_ID(idx_true);
    PHI_sp_az_body = PHI_sp_az_body(idx_true);
    THE_sp_theta_body = THE_sp_theta_body(idx_true);  
    
%% Saving Data  
if DDMs_Flag == 0 % DDMs are NOT saved
     cd(Path_CYGNSS_ProcessedData_StudyArea_Year)
     save(strcat('CYGNSS_Reflectivity_',StudyArea,'_DATA_MATRIX.mat'),'Year', 'DoY', 'SoD', 'SCID', 'PITCH', ...
         'ROLL', 'YAW', 'PRN', 'SPLAT', 'SPLON', 'THETA', 'GAIN', 'EIRP', 'SNR', 'PHI_Initial_sp_az_orbit', ...
         'TX_POS_X', 'TX_POS_Y', 'TX_POS_Z','TX_VEL_X', 'TX_VEL_Y', 'TX_VEL_Z', ...
         'RX_POS_X', 'RX_POS_Y', 'RX_POS_Z','RX_VEL_X', 'RX_VEL_Y', 'RX_VEL_Z', ...
         'REFLECTIVITY_LINEAR_PA', 'KURTOSIS', 'KURTOSIS_DOPP_0', 'TE_WIDTH', 'DDM_NBRCS', 'QC', 'PA', 'NF', 'TRACK_ID','PHI_sp_az_body', 'THE_sp_theta_body', '-v7.3'); 

elseif DDMs_Flag == 1 % DDMs are saved

    cd(Path_CYGNSS_ProcessedData_StudyArea_Year)

     save(strcat('CYGNSS_Reflectivity_',StudyArea,'_DATA_MATRIX.mat'), 'Year', 'DoY', 'SoD', 'SCID', 'PITCH', ...
         'ROLL', 'YAW', 'PRN', 'SPLAT', 'SPLON', 'THETA', 'GAIN', 'EIRP', 'SNR', 'PHI_Initial_sp_az_orbit', ...
         'TX_POS_X', 'TX_POS_Y', 'TX_POS_Z','TX_VEL_X', 'TX_VEL_Y', 'TX_VEL_Z', ...
         'RX_POS_X', 'RX_POS_Y', 'RX_POS_Z','RX_VEL_X', 'RX_VEL_Y', 'RX_VEL_Z', ...
         'REFLECTIVITY_LINEAR_PA', 'KURTOSIS', 'KURTOSIS_DOPP_0', 'TE_WIDTH', 'DDM_NBRCS', 'QC', 'PA', 'NF', 'TRACK_ID','DDMs_Uncalibrated','DDMs_Calibrated','PHI_sp_az_body', 'THE_sp_theta_body', '-v7.3'); 

elseif DDMs_Flag == 2 %Caso di minor volume dati
    cd(Path_CYGNSS_ProcessedData_StudyArea_Year)
    
     save(strcat('CYGNSS_Reflectivity_',StudyArea,'_DATA_MATRIX.mat'), 'Year', 'DoY', 'SoD', 'SCID', ...
         'PRN', 'SPLAT', 'SPLON', 'THETA', 'EIRP', 'SNR', 'PHI_Initial_sp_az_orbit', ...
         'REFLECTIVITY_LINEAR_PA', 'KURTOSIS', 'KURTOSIS_DOPP_0', 'TE_WIDTH', 'DDM_NBRCS', 'QC', 'PA', 'NF', '-v7.3') 
     
else
    disp('There is something wrong in your processing')
    
end








