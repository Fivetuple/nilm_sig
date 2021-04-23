%
% Purpose:
%           Train model on a training set and predict COOLL labels
%           using path signatures
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

% clear variables and screen
clear;

% choose degree
degree = 3;   
fprintf('Degree %d \n',degree);

% load signatures - TVI path 
fn_sigs = ['data/trajectory_signature_tvi_' num2str(degree)];
load(fn_sigs,'sig','logsig','sig_trans','logsig_trans');

% create feature vector
features = [logsig logsig_trans]; 

% load labels
fid = fopen('./data/labels.txt');
data = textscan(fid,'%s');
labels = data{1};
fclose(fid);

% set random seed
rng(1);

% select train and test sets
a = (randperm(20)-1)';
idx_train = [];
idx_test = [];
for j=1:20:840
    idx_train = [idx_train; j+a(1:16)]; %#ok<*AGROW>
    idx_test = [idx_test; j+a(17:20)];
end

Xtrain = features(idx_train,:);
ytrain = labels(idx_train);
Xtest = features(idx_test,:);
ytest = labels(idx_test);

% save in a table for using the classfication app 
tblTrn = array2table(Xtrain);
tblTrn.Y = ytrain;

% predictorNames = {'Xtrain1', 'Xtrain2', ...}    
predictorNames = cell(1,size(Xtrain,2));
for k=1:size(Xtrain,2)
    predictorNames{k} = ['Xtrain' num2str(k)];
end

tblTest = array2table(Xtest,'VariableNames',predictorNames);

% use model parameters trained using Classification App
[trainedClassifier, validationAccuracy] = trainEnsemble(tblTrn);

% predict test set  
ypred = trainedClassifier.predictFcn(tblTest);

% find accuracy
c = 0;
for i=1:168
    c = c +strcmp(ytest{i},ypred{i});
end

cvacc = 100*mean(validationAccuracy);
cvstd= 100*std(validationAccuracy);

fprintf('Cross-validation results: %.4f %.4f %.4f %.4f %.4f \n',validationAccuracy);

fprintf('Cross-validation accuracy is %.2f (%.2f) \n',cvacc, cvstd);
fprintf('Test set accuracy is  is %.2f \n',100*c/168);

fprintf('Four digit precision:\n');
fprintf('Cross-validation accuracy is %.4f (%.4f) \n',cvacc, cvstd);
fprintf('Test set accuracy is  is %.4f \n',100*c/168);




