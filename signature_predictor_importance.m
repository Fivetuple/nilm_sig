%
% Purpose:
%           Find predictor importance for signature features.
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

degree = 3;   
fprintf('Degree %d \n',degree);

% load signatures - TVI path 
fn_sigs = ['data/trajectory_signature_tvi_' num2str(degree)];
load(fn_sigs,'sig','logsig','sig_trans','logsig_trans');

% create feature vector
features = [logsig]; 
%features = [logsig_trans]; 
%features = [logsig logsig_trans]; 

% load labels
fid = fopen('./data/labels.txt');
data=textscan(fid,'%s');
labels = data{1};
fclose(fid);

% set random number seed
rng(1);

% select train and test set indices
a = (randperm(20)-1)';
idx_train = [];
idx_test = [];
for j=1:20:840
    idx_train = [idx_train; j+a(1:16)]; %#ok<*AGROW>
    idx_test = [idx_test; j+a(17:20)];
end

% define the training and test sets using the indices
Xtrain = features(idx_train,:);
ytrain = labels(idx_train);
Xtest = features(idx_test,:);
ytest = labels(idx_test);
tblTrn = array2table(Xtrain);
tblTrn.Y = ytrain;

% predictorNames = {'Xtrain1', 'Xtrain2', ...}   
predictorNames = cell(1,size(Xtrain,2));
for k=1:size(Xtrain,2)
    predictorNames{k} = ['Xtrain' num2str(k)];
end

predictors = tblTrn(:, predictorNames);
response = tblTrn.Y;

% Train a classifier - the values are from trainEnsemble.m
template = templateTree('MaxNumSplits', 671,'Reproducible',true);

classificationEnsemble = fitcensemble(predictors, response, 'Method', 'Bag', 'NumLearningCycles', 100,  'Learners', template, ...
    'ClassNames', {'Drill'; 'Fan'; 'Grinder'; 'Hair_dryer'; 'Hedge_trimmer'; 'Lamp'; 'Paint_stripper'; 'Planer'; 'Router'; 'Sander'; 'Saw'; 'Vacuum_cleaner'});

% predict test set
ypred = predict(classificationEnsemble,Xtest);

% find predictor importance and scale to a convenient magnitude
imp = 1000*predictorImportance(classificationEnsemble);

% x labels
feature_names = {'t', 'V', 'I', 't,V', 't,I', 'V,I', 't,[t,V]', 't,[t,I]', 'V,[t,V]', 'V,[t,I]', 'V,[V,I]', 'I,[t,V]', 'I,[t,I]', 'I,[V,I]'};

% display importance
figure;
bar(imp);
ylabel('Relative predictor importance');
xlabel('Signature terms');
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

fn = ['/home/paul/Desktop/cache/dale/docs/Paper/PES/figures/signature_predictor_importance_degree_' num2str(degree)];
%saveas(gcf,fn,'epsc');



