function SML2PP_start(mode, Path_PDGS_NAS_folder, ...
    startdate,enddate,Resolution, Frequency, Polarization)

%clear all
plotTag='Yes'
% a=1 ;
if mode=="-input"
    disp('Command input mode')
    if exist('startdate')==0 & exist('enddate')==0 & exist('Path_PDGS_NAS_folder')==0  &...
            exist('SM_Time_resolution')==0 & exist('Resolution')==0 &...
            exist('Frequency')==0 & exist('Polarization')==0
        disp('MISSING INPUTS. Program exiting') ;
        return ;
    end
    load('../conf/Configuration2.mat') ;
    init_SM_Day=datetime((startdate));
    SM_Time_resolution=days(enddate-startdate)+1 ;
    Resolution=str2num(Resolution) ;
    %
    % *************  Run the main program
    %
    abspath=pwd;
    Path_HydroGNSS_Data=[abspath '\' 'input\'];
    Path_HydroGNSS_ProcessedData=[abspath '\' 'output\'];
    Path_Auxiliary=[abspath '\' 'Auxiliaryfiles' '\'];
    Path_PDGS_NAS_folder=[abspath];
    SM_main(init_SM_Day,SM_Time_resolution,Path_PDGS_NAS_folder, Path_HydroGNSS_Data,Path_Auxiliary,...
        Path_HydroGNSS_ProcessedData,Resolution, metadata_name, DDMs_name, ...
        readDDM, Frequency, Polarization, plotTag)
    %
    % *************  Run the main program
    %
elseif mode=="-GUI"
    disp('GUI mode')
    % *************  Start GUI
    load('../conf/Configuration.mat') ;
    global coe ;
    % ****** get inputs from GUI
    prompt={'Metadata file name: ',...
        'DDM file name: ',...
        'Read DDM [Yes/No  Y/N]: ',...
        'Horizonbtal resolution [km]: ',...
        'Startdate: ', ...
        'Enddate', ...
        'Constellation-frequency [L1/L5/E1/E5]: ', 'Polarization [L/R/dual]'}  ;
    opts.Resize='on';
    opts.WindowStyle='normal';
    opts.Interpreter='tex';
    name='Soil moisture L2 processor by Sapienza-CRAS';
    numlines=[1 30; 1 30; 1 30; 1 30; 1 30; 1 30 ; 1 30; 1 30] ;
    defaultanswer={ Answer{1}, Answer{2},...
        Answer{3},Answer{4},Answer{5},Answer{6},Answer{7},...
        Answer{8}};
    Answer=inputdlg(prompt,name,numlines,defaultanswer,opts);
    metadata_name= Answer{1};
    DDMs_name= Answer{2};
    readDDM= Answer{3};
    Resolution= str2double(Answer{4});
    init_SM_Day=datetime((Answer{5})) ;
    enddate=datetime((Answer{6}));
    Frequency=Answer{7} ;
    Polarization=Answer{8} ;
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
    Path_HydroGNSS_Data = uigetdir(Path_HydroGNSS_Data, 'Select input L1B data folder') ;
    Path_HydroGNSS_ProcessedData=uigetdir(Path_HydroGNSS_ProcessedData, 'Select output data folder') ;
    Path_Auxiliary=uigetdir(Path_Auxiliary, 'Select Auxiliary files folder') ;
    Path_PDGS_NAS_folder=uigetdir(Path_PDGS_NAS_folder,'Select PGDS NAS Folder');
    SM_Time_resolution=days(enddate-init_SM_Day)+1;
    % ***** get defaults and directories of input L1B products and L2 output
    %
    % Path_HydroGNSS_Data = uigetdir('./', 'Select input L1B data folder') ;
    % Path_HydroGNSS_ProcessedData=uigetdir('./', 'Select output data folder') ;
    % Path_Auxiliary=uigetdir('./', 'Select Auxiliary files folder') ;

    % save defaults and directories
    save('../conf/Configuration.mat','Path_PDGS_NAS_folder', 'Path_HydroGNSS_Data', 'Path_HydroGNSS_ProcessedData',...
        'Path_Auxiliary', 'metadata_name', 'readDDM', '-append') ;
    % save defaults and directories
    %
    % *************  Run the main program
    %
    SM_main(init_SM_Day,SM_Time_resolution, Path_HydroGNSS_Data,Path_Auxiliary,...
        Path_HydroGNSS_ProcessedData,Resolution, metadata_name, DDMs_name, ...
        readDDM, Frequency, Polarization, plotTag)
    %
    % *************  Run the main program
else
    disp('WRONG INPUT. Program exiting ')
    return
end % end if on input mode
end % end of the start function