 %
% Purpose:  Predict reference features from signature
%
% Input     
%           
% Effects: 
%
% Usage examples
%
%
% (c) 2021 Paul Moore - moorep@maths.ox.ac.uk 
%
% This software is provided 'as is' with no warranty or other guarantee of
% fitness for the user's purpose.  Please let the author know of any bugs
% or potential improvements.

% clear variables, screen and close figures
clear;
clc;
close all;

% load reference features and set names variable
load('data/all_bruna_features_scaled_zero_crossing','all_bruna_features');
feature_names = {'dpb','angp','len','md','vss','asl','dc','angc','dbc','dbd','dbang','ov'};

% load signatures
% VQ path
%load('data/signature_vq_5.mat','sig','logsig','sig_trans','logsig_trans');
%load('data/signature_vq_8.mat','sig','logsig','sig_trans','logsig_trans');

% TVI path 
load('data/trajectory_signature_tvi_5','sig','logsig','sig_trans','logsig_trans');


% set islog to 0 for signature features or 1 for log signature features
islog = 1;

% file stem location for figure output
fnstem = '/home/paul/Desktop/cache/dale/docs/Paper/PES/figures';
if islog
    features = [logsig]; 
    features_trans = [logsig logsig_trans]; 
    fn = [fnstem '/bruna_features_prediction_logsig'];
else
    features = [sig]; 
    features_trans = [sig sig_trans]; 
    fn = [fnstem '/bruna_features_prediction_sig'];
end
    
% set random number seed
rng(1); 
 
% select the same train and test sets as for predicting labels
a = (randperm(20)-1)';
idx_train = [];
idx_test = [];
for j=1:20:840
    idx_train = [idx_train; j+a(1:16)]; %#ok<*AGROW>
    idx_test = [idx_test; j+a(17:20)];
end

% reference features - the last 4 use the transient trajectory
% 1:dpb 2:angp 3:len 4:md 5:vss 6:asl 7:dc 8:angc 9:dbc 10:dbd 11:dbang 12:ov

% create figure
figure;

% loop over features
for ftid = 1:12           

    if ftid < 9
        Xtrain = features(idx_train,:);
        Xtest= features(idx_test,:);
    else
        Xtrain = features_trans(idx_train,:);
        Xtest= features_trans(idx_test,:);
    end
        
    ytrain = all_bruna_features(idx_train,ftid);
    ytest = all_bruna_features(idx_test,ftid);

    % save in a table for using the classfication app 
    tblTrn = array2table(Xtrain);
    tblTrn.Y = ytrain;
% predictor names need updating     
%    predictorNames = {'Xtrain1', 'Xtrain2', 'Xtrain3', 'Xtrain4', 'Xtrain5', 'Xtrain6', 'Xtrain7', 'Xtrain8', 'Xtrain9', 'Xtrain10', 'Xtrain11', 'Xtrain12'};
%    tblTest = array2table(Xtest,'VariableNames',predictorNames);
    
    % train a model 
    mdl = TreeBagger(50,Xtrain,ytrain,'OOBPrediction','Off','Method','regression','minleaf',5);
    
    % predict from test features
    [ypred, score] = mdl.predict(Xtest);
    
    % plot true and predicted
    subplot(4,3,ftid);
    hold on;
    
    title(feature_names(ftid));
    if any([1 4 7 10] == ftid)
        ylabel('Predicted');
    end    
    if any([10 11 12] == ftid)
        xlabel('Actual');
    end    
    
    scatter(ytest, ypred);
    
    lims = ones(12,2)*NaN;
    lims(1,:) = [620 660];
    lims(2,:) = [0 5];
    lims(3,:) = [1000 2000];
    lims(4,:) = [310 330];
    lims(5,:) = [0 200];
    lims(7,:) = [0 25];

    if ~isnan(lims(ftid,1))
        xlim(lims(ftid,:));
        ylim(lims(ftid,:));
    end
    
    % draw y=x
    xl = xlim;
    yl = ylim;        
    minlim = min([xl yl]);
    maxlim = max([xl yl]);
    
    x = [minlim; maxlim]; 
    y = [minlim; maxlim]; 
    plot(x,y,'g','Linewidth',2);    

    % no element of ytest may be zero because we divide by it to find MdARE
    ytest(ytest==0) = 1e-9;
    err = errperf(ytest,ypred,'mdare');
    
    % note that we report as a percentage error
    str_err = ['Feature ' num2str(ftid) ' MdAPE is ' num2str(round(100*err,2))];
    disp(str_err);
    
end


%saveas(gcf,fn,'epsc');

