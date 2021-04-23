%
% Purpose:
%           Train model on a training set and predict on a test set
%           using a selected subset of the reference features.
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
clc;

% load features
load('data/all_bruna_features_scaled_zero_crossing','all_bruna_features','all_longjun_features');

% load labels
fid = fopen('./data/labels.txt');
data=textscan(fid,'%s');
labels = data{1};
fclose(fid);

acc = zeros(20,1);
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

% normalise to column mean of 0, sd of 1
% note that there remain some outliers - it might be worth removing later
if 1
    all_bruna_features = normalize(all_bruna_features);
    all_longjun_features = normalize(all_longjun_features);
end 

% select features ar, r, and angp, md, dbang
selected_features = [all_bruna_features(:,[2 4 11]) all_longjun_features(:,[2 5])];

Xtrain = selected_features(idx_train,:);
ytrain = labels(idx_train);
Xtest = selected_features(idx_test,:);
ytest = labels(idx_test);

% save in a table for using the classfication app 
tblTrn = array2table(Xtrain);
tblTrn.Y = ytrain;
predictorNames = {'Xtrain1', 'Xtrain2', 'Xtrain3', 'Xtrain4', 'Xtrain5'};
tblTest = array2table(Xtest,'VariableNames',predictorNames);

% trainEnsembleSelected uses the same model as trainEnsemble with different numbers of features.
[trainedClassifier, validationAccuracy] = trainEnsembleSelected(tblTrn);

ypred = trainedClassifier.predictFcn(tblTest);

% find test set accuracy
c = 0;
for i=1:168
    c = c +strcmp(ytest{i},ypred{i});
end

cvacc = 100*mean(validationAccuracy);
cvstd= 100*std(validationAccuracy);

fprintf('Cross-validation accuracy is %.2f (%.2f) \n',cvacc, cvstd);
fprintf('Test set accuracy is  is %.2f \n',100*c/168);




