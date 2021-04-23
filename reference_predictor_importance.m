%
% Purpose:
%           Find predictor importance for reference set
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
load('data/all_bruna_features_scaled_zero_crossing','all_bruna_features');

% load labels
fid = fopen('./data/labels.txt');
data=textscan(fid,'%s');
labels = data{1};
fclose(fid);

% set random number seed
rng(1);

a = (randperm(20)-1)';

% select train and test sets
idx_train = [];
idx_test = [];
for j=1:20:840
    idx_train = [idx_train; j+a(1:16)]; %#ok<*AGROW>
    idx_test = [idx_test; j+a(17:20)];
end

% normalise to column mean of 0, sd of 1
all_bruna_features = normalize(all_bruna_features);

Xtrain = all_bruna_features(idx_train,:);
ytrain = labels(idx_train);
Xtest = all_bruna_features(idx_test,:);
ytest = labels(idx_test);
tblTrn = array2table(Xtrain);
tblTrn.Y = ytrain;

% find predictor importance

% keep these as XtrainN for compatibility with the Classification Learner App
predictorNames = {'Xtrain1', 'Xtrain2', 'Xtrain3', 'Xtrain4', 'Xtrain5', 'Xtrain6', 'Xtrain7', 'Xtrain8', 'Xtrain9', 'Xtrain10', 'Xtrain11', 'Xtrain12'};
predictors = tblTrn(:, predictorNames);
response = tblTrn.Y;

% train a classifier (hyperparameters taken from trainEnsemble.m)
template = templateTree('MaxNumSplits', 97, 'NumVariablesToSample', 6);
classificationEnsemble = fitcensemble(predictors,response,'Method', 'Bag','NumLearningCycles', 497,'Learners', template, ...
    'ClassNames', {'Drill'; 'Fan'; 'Grinder'; 'Hair_dryer'; 'Hedge_trimmer'; 'Lamp'; 'Paint_stripper'; 'Planer'; 'Router'; 'Sander'; 'Saw'; 'Vacuum_cleaner'});

% predict test set
ypred = predict(classificationEnsemble,Xtest);

% find predictor importance and scale to a convenient magnitude
imp = 1000*predictorImportance(classificationEnsemble);

feature_names = {'dpb','angp','len','md','vss','asl','dc','angc','dbc','dbd','dbang','ov'};

% display importance
figure;
bar(imp);
ylabel('Relative predictor importance');
xlabel('Reference features');
h = gca;
h.XTickLabel = feature_names;
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';        

% find accuracy
c = 0;
for i=1:168
    c = c +strcmp(ytest{i},ypred{i});
end
disp(['Accuracy is ' num2str(100*c/168)]);

fn = '/home/paul/Desktop/cache/dale/docs/Paper/PES/figures/reference_predictor_importance';
%saveas(gcf,fn,'epsc');



