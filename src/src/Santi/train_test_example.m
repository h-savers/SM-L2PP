% training.m
% Example of code based on Matlab Neural Network toolbox for training
% and testing a neural network  for estimating Soil Moisture (SMC in %)
% from backscattering data at C band in 
% two polarizations (VV e VH) + Local Incidence Angle + NDVI. 
% Code developed at IFAC CNR by Emanuele Santi, based on ANN Matlab
% toolbox. for properly referring please contact e.santi@ifac.cnr.it

clear all
close all
uplim=50;
lowlim=0;
fontsiz=14;
xlabl='Target SMC (%)';
ylabl='Estimated SMC (%)';
plottitle='ANN test';
ANNdir='ANN\';
isthere=dir(ANNdir);  % check if the ANN dir already exists
if isempty(isthere)
    mkdir(ANNdir)
end
namenet='ANN_example.net';
[file,path]=uigetfile('VVHHVH*.csv','please select input file...');
infile=[path '\' file];
disp('**** loading input data ***')
[VV,HH,HV,THETA,PWC,SMC]= ...
    textread(infile, '%f %f %f %f %f %f  ', 'delimiter',',','headerlines',0); % reads input data from the sample file (generated by WCM)
disp('**** data loaded ****')
%%%%%%% GUI for setting the rate for random division training/test %%%%%%%%
prompt={'resampling factor? 0=no'; ...
    'number of layers '; ...
    'number of neurons'; ...
    'transfer function (purelin, logsig, tansig)'};
   name='configuration parameters';
   numlines=1;
   defaultanswer={'1'; ...           % it means half data set for training and half for testing.....
       '2'; ...                      % 2 hidden layers 
       '8'; ...                      % 8 neurons each
       'tansig'};                    % transfer function of type logistic sigmoid 
   answer=inputdlg(prompt,name,numlines,defaultanswer);
   if isempty(answer) 
     f = errordlg('input parameters not selected, exiting', 'error');
    waitfor(f)
    return
   end 
resampling=str2num(char(answer(1)));     % for splitting in train and test sets the input data 
nlay=str2num(char(answer(2)));           % number of hidden layers
nneu=str2num(char(answer(3)));           % number of neurons
trfun=char(answer(4));                   %transfer function: you can select between: 'logsig', 'tansig' e 'purelin'

if resampling; rate=resampling;else rate=1;end
filt=find(~isnan(HH) & ~isnan(HV) & ~isnan(PWC)); %filtering of NaN (if needed) you can adapt the string to your problem

%%%%%%%%%%%%%%%%%%%%%%%% filtering input data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HH=HH(filt);
HV=HV(filt);
THETA=THETA(filt);
PWC=PWC(filt);
SMC=SMC(filt);
disp(['max SMC is ' num2str(max(SMC)) ' %']) % just to write something on screen :-) 

%%%%%%%%% dividing training and test sets by random sampling %%%%%%%%%%%%%%

position=1:length(SMC);
trainindex=1:rate:length(position);
position(trainindex)=0;
testindex=find(position);
if rate==1
   testindex=trainindex;
end

HH_train=HH(trainindex);
HV_train=HV(trainindex);
THETA_train=THETA(trainindex);
PWC_train=PWC(trainindex);
SMC_train=SMC(trainindex);

%%%%%%%%%%%%%%%%% defining NN inputs and outputs %%%%%%%%%%%%%%%%%%%%%%%%%%

in=[HH_train HV_train THETA_train PWC_train]';
out=SMC_train';

%%%%%%%%%%%%%%%%%%% Defining ANN architecture %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the string below defined a NN with "nlay" hidden layers of "nneu" neurons each: 
% you can adapt this depending on the complexity of your problem to avoid
% overfitting and underfitting (see Santi et al. 2016). Transfer function
% of each layer is the one defined in "trfun",
% (from n-1 layer to output there is linear function by default).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nlay==1
    net=newff(in,out,[nneu],{trfun}); 
elseif nlay==2
    net=newff(in,out,[nneu,nneu],{trfun trfun }); 
end
%%%%%%%%%%%%%%%%%% Defining some NN parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here some examples of training parameters that you can adapt to your
% needs. For detailed description, please refer to the Matlab documentation
% (or ask...)

net.trainParam.lr=5e-5;
net.trainParam.epochs=50000;  % upper limit of training iterations
net.trainParam.goal=1e-6;     % target error (almost never met)
net.trainParam.mu_max=1e200;
net.trainParam.min_grad=0;
net.trainParam.max_fail=6;    % deals with the early stopping rule: it is the number of iterations after the training error stopped decreasing before ending the training 

net=init(net);                % optional: to reset initial values of ANN weights before repeating the training
%%%%%%%%%%%%%%%%%%%%% training %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the string below launch the training: the progress is displayed in four
% plots

net=train(net,in,out);
SMC_NN_train=sim(net,in)';
filterNaN=find(~isnan(SMC_NN_train));
estimated=SMC_NN_train(filterNaN);
target=SMC_train(filterNaN);
[m,b,r]=postreg(estimated',target','hide');
RMSE=sqrt(1/length(estimated)*sum((estimated-target).^2));
BIAS=1/length(estimated)*sum(estimated-target);
mean_test_NN=mean(estimated);
mean_test_ground=mean(target);
disp('**************** training results *******************')
 disp(['Estimated SMC average= ' num2str(mean_test_NN)])
 disp(['target SMC average= ' num2str(mean_test_ground)])
 disp(['RMSE= ' num2str(RMSE)])
 disp(['BIAS= ' num2str(BIAS)])
 disp(['correlation coefficient= ' num2str(r)])
 disp(['dataset size= ' num2str(length(estimated))])
disp('*****************************************************')


%%%%%%%%%%%%%%%%%%%%%%%%%% testing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These instruction display the scatterplot estimated vs. expected values
% after the ANN training is completed. 
disp('**************** testing the ANN *******************')

%%%%%%%%%%%%%% creating the test set %%%%%%%%%%%%%%%%%%%%%%%%%
HH_test=HH(testindex);
HV_test=HV(testindex);
THETA_test=THETA(testindex);
PWC_test=PWC(testindex);
SMC_test=SMC(testindex);
%%%%%%%%%%%%%% testing the ANN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
in=[HH_test HV_test THETA_test PWC_test]';
SMC_NN_test=sim(net,in)'; 
filterNaN=find(~isnan(SMC_NN_test));
estimated=SMC_NN_test(filterNaN);
target=SMC_test(filterNaN);
figure
[m,b,r]=postreg(estimated',target','hide');
axes('FontSize',fontsiz)
h=plot(target,estimated,'k*');
axis([lowlim uplim lowlim uplim])
title(plottitle)
xlabel(xlabl)
ylabel(ylabl)
hold on
grid on
vec=[lowlim, uplim];
plot(vec,vec,'r');
vecreg=[m*vec(1)+b, m*vec(2)+b];
plot(vec,vecreg,'g');
RMSE=sqrt(1/length(estimated)*sum((estimated-target).^2));
BIAS=1/length(estimated)*sum(estimated-target);
testo={['R= ' num2str((round(r*1000))/1000)], ...
    ['RMSE= ' num2str((round(RMSE*1000))/1000)],...
    ['BIAS= ' num2str((round(BIAS*10000))/10000)], ...  ['n = ' num2str(length(estimated))]
    };
text(lowlim,uplim,testo,'Fontsize',fontsiz,'VerticalAlignment','top')
disp('*****************************************************')
disp('*****************************************************')
disp('****************** test results *********************')
 disp(['Estimated SMC average= ' num2str(mean_test_NN)])
 disp(['target SMC average= ' num2str(mean_test_ground)])
 disp(['RMSE= ' num2str(RMSE)])
 disp(['BIAS= ' num2str(BIAS)])
 disp(['correlation coefficient= ' num2str(r)])
 disp(['dataset size= ' num2str(length(estimated))])
disp('*****************************************************')
%%%%%%%%%%%%%%%%%%%%% saving the net %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this part of the code allows to save the trained ANN as Matlab object
%(.net file) that can be re-loaded (with the simple instruction "load" ANN filename) 
% and applied to new data without repeating the training. The result plot
% is also saved as png figure.

pause(10)
ButtonName = questdlg('do you want to save the net? !EXISTING NET WILL BE OVERWRITTEN!', ...
                         'save', ...
                         'yes', 'no', 'yes');
switch ButtonName
  case 'yes'
    eval (['save ' [ANNdir namenet] ' net'])
    eval(['saveas(h,''' [ANNdir namenet(1:end-4)] '_training.png'',''png'')'])
  case 'no'
         return
 end


