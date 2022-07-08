function SML2PP_start(mode, Path_PDGS_NAS_folder, ...
    startdate,enddate,SM_Time_resolution, Resolution, Frequency, Polarization)
% whos Resolution
% whos Frequency
% whos Polarization

% 
% clear all
% close all
%
% Abilitate final plot of the map (to be eventually transferred to the GUI 
plotTag='Yes' ; 
% a=1 ; 
if exist('mode')==0  | exist('mode')==2
    disp('ERROR: INPUT ARGUMENTS MISSING. Program exiting') ; 
    return ;
end
if mode=="-input"
    disp('Command input mode') 
%
if exist('startdate')==0 & exist('enddate')==0 & exist('Path_PDGS_NAS_folder')==0  &...
            exist('SM_Time_resolution')==0 & exist('Resolution')==0 &...
            exist('Frequency')==0 & exist('Polarization')==0
        disp('MISSING INPUTS. Program exiting') ;
        return ;
    end
%
if isequal(Frequency,'L1')==0 & isequal(Frequency,'L5')==0 & isequal(Frequency,'E1')==0 & isequal(Frequency,'E5')==0 ; 
        disp('ERROR: WRONG FREQUENCY CHANNEL. Program exiting') ; 
    return
end
%
if isequal(Polarization,'L')==0 & isequal(Polarization,'R')==0 & isequal(Polarization,'dual')==0 ;
        disp('ERROR: WRONG POLARIZATION CHANNEL. Program exiting') ; 
    return
end
if isfolder(Path_PDGS_NAS_folder) ==0  
    disp('ERROR: FOLDER DOES NOT EXIST. Program exiting') ; 
    return
end

load('../conf/Configuration2.mat') ;
  init_SM_Day=datetime((startdate));
  SM_Time_resolution=str2num(SM_Time_resolution) ; 
  %% ????  SM_Time_resolution=days(enddate-startdate)+1 ;
  Resolution=str2num(Resolution) ; 
%
% *************  Run the main program
%
Path_HydroGNSS_Data=[Path_PDGS_NAS_folder '\' 'DataRelease\L1A_L1B'];
Path_HydroGNSS_ProcessedData=[Path_PDGS_NAS_folder '\' 'DataRelease\L2OP-SSM'];
Path_Auxiliary=[Path_PDGS_NAS_folder '\' 'Auxiliar_Data\L2OP-SSM'];
%
SM_main(init_SM_Day,SM_Time_resolution, Path_HydroGNSS_Data,Path_Auxiliary,...
     Path_HydroGNSS_ProcessedData,Resolution, metadata_name, DDMs_name, ...
     readDDM, Frequency, Polarization, plotTag)
%
% *************  Run the main program
%
elseif mode=="-GUI" 
    disp('GUI mode')
% *************  Start GUI 
load('../conf/Configuration.mat') ;
% global model ; 
% ****** get inputs from GUI
prompt={'Metadata file name: ',...
         'DDM file name: ',...
         'Read DDM [Yes/No  Y/N]: ',...
         'Horizonbtal resolution [km]: ',...
         'Starting time year: ', ...
         'Starting time month: ', ...
         'Starting time day: ', ...
         'Final time year: ', ...
         'Final time month: ', ...
         'Final time day: ', ...
         'SM Time Resolution: ', 'Constellation-frequency [L1/L5/E1/E5]: ', 'Polarization [L/R/dual]'}  ; 
opts.Resize='on';
opts.WindowStyle='normal';
opts.Interpreter='tex';
name='Soil moisture L2 processor by Sapienza-CRAS';
numlines=[1 30; 1 30; 1 30; 1 30; 1 30; 1 30 ; 1 30; 1 30; 1 30; 1 30; 1 30; 1 30; 1 30] ; 
defaultanswer={Answer{1},Answer{2},...
                 Answer{3},Answer{4},Answer{5},Answer{6},Answer{7},...
                 Answer{8},Answer{9},Answer{10},...
                 Answer{11},Answer{12},Answer{13}};
Answer=inputdlg(prompt,name,numlines,defaultanswer,opts);
metadata_name= Answer{1};
DDMs_name= Answer{2};
readDDM= Answer{3};
Resolution= str2num(Answer{4});
init_SM_Day=datetime(str2num(Answer{5}), str2num(Answer{6}), str2num(Answer{7})) ;
final_SM_Day=datetime(str2num(Answer{8}), str2num(Answer{9}), str2num(Answer{10})) ;
SM_Time_resolution=str2num(Answer{11}) ;
Frequency=Answer{12} ;
Polarization=Answer{13} ;
% ****** get inputs from GUI
%
% ****** Save GUI input into Input Configuration File 
save('../conf/Configuration.mat', 'Answer', '-append') ;
% ****** Save GUI input into Input Configration File 
%
% readDDM='Yes' ;  
% metadata_name='metadata_L1_merged.nc' ; 
% DDMs_name='DDMs.nc' ; 
% Resolution=25 ; % resolution of the final map in km
% % get day of product and number of day to process from GUI
% % [dayinit, timeresolution, spaceresolution]=GUI
% init_SM_Day=datetime(2010, 9, 9) ; 
% SM_Time_resolution= 1 ;

% ***** get defaults and directories of input L1B products and L2 output
if Path_HydroGNSS_Data==0 ; 
    Path_HydroGNSS_Data = uigetdir('./', 'Select input L1B data folder') ; 
else
    Path_HydroGNSS_Data = uigetdir(Path_HydroGNSS_Data, 'Select input L1B data folder') ; 
end
%
if Path_HydroGNSS_ProcessedData==0 ; 
    Path_HydroGNSS_ProcessedData=uigetdir('./', 'Select output L2 data folder') ;
else
Path_HydroGNSS_ProcessedData=uigetdir(Path_HydroGNSS_ProcessedData, 'Select output L2 data folder') ;
end
%
if Path_Auxiliary==0 ; 
Path_Auxiliary=uigetdir('./', 'Select Auxiliary files folder') ;
else
Path_Auxiliary=uigetdir(Path_Auxiliary, 'Select Auxiliary files folder') ;
end
%
% ***** get defaults and directories of input L1B products and L2 output
%
% Path_HydroGNSS_Data = uigetdir('./', 'Select input L1B data folder') ; 
% Path_HydroGNSS_ProcessedData=uigetdir('./', 'Select output data folder') ;
% Path_Auxiliary=uigetdir('./', 'Select Auxiliary files folder') ;

% save defaults and directories  
save('../conf/Configuration.mat', 'Path_HydroGNSS_Data', 'Path_HydroGNSS_ProcessedData',...
    'Path_Auxiliary', 'metadata_name', 'readDDM', '-append') ;
% save defaults and directories  
%
% *************  Run the main program
%
SM_main(init_SM_Day,final_SM_Day, SM_Time_resolution, Path_HydroGNSS_Data,Path_Auxiliary,...
     Path_HydroGNSS_ProcessedData,Resolution, metadata_name, DDMs_name, ...
     readDDM, Frequency, Polarization, plotTag) ; 
%
% *************  Run the main program
else
    disp('WRONG INPUT. Program exiting ')
    return 
end % end if on input mode
end % end of the start function
