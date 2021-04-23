function [trainedClassifier, validationAccuracy] = trainEnsembleSignatureSelected(trainingData)

% Auto-generated by MATLAB on 09-Mar-2021 15:42:41
%
% Choice in classificationApp - Bag of Trees, 100 learners.
%
% Amended to include Reprodicible flag in templateTree, and 
% for kFoldLoss to return accuracy for each fold.

% Extract predictors and response
% This code processes the data into the right shape for training the
% model.
inputTable = trainingData;
predictorNames = {'Xtrain1', 'Xtrain2', 'Xtrain3', 'Xtrain4', 'Xtrain5', 'Xtrain6', 'Xtrain7'};
predictors = inputTable(:, predictorNames);
response = inputTable.Y;
isCategoricalPredictor = [false, false, false, false, false, false, false];

% Train a classifier
% This code specifies all the classifier options and trains the classifier.
template = templateTree(...
    'MaxNumSplits', 671,... 
    'Reproducible',true);
classificationEnsemble = fitcensemble(...
    predictors, ...
    response, ...
    'Method', 'Bag', ...
    'NumLearningCycles', 100, ...
    'Learners', template, ...
    'ClassNames', {'Drill'; 'Fan'; 'Grinder'; 'Hair_dryer'; 'Hedge_trimmer'; 'Lamp'; 'Paint_stripper'; 'Planer'; 'Router'; 'Sander'; 'Saw'; 'Vacuum_cleaner'});

% Create the result struct with predict function
predictorExtractionFcn = @(t) t(:, predictorNames);
ensemblePredictFcn = @(x) predict(classificationEnsemble, x);
trainedClassifier.predictFcn = @(x) ensemblePredictFcn(predictorExtractionFcn(x));

% Add additional fields to the result struct
trainedClassifier.RequiredVariables = {'Xtrain1', 'Xtrain2', 'Xtrain3', 'Xtrain4', 'Xtrain5', 'Xtrain6', 'Xtrain7'};
trainedClassifier.ClassificationEnsemble = classificationEnsemble;
trainedClassifier.About = 'This struct is a trained model exported from Classification Learner R2019b.';
trainedClassifier.HowToPredict = sprintf('To make predictions on a new table, T, use: \n  yfit = c.predictFcn(T) \nreplacing ''c'' with the name of the variable that is this struct, e.g. ''trainedModel''. \n \nThe table, T, must contain the variables returned by: \n  c.RequiredVariables \nVariable formats (e.g. matrix/vector, datatype) must match the original training data. \nAdditional variables are ignored. \n \nFor more information, see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ''appclassification_exportmodeltoworkspace'')">How to predict using an exported model</a>.');

% Extract predictors and response
% This code processes the data into the right shape for training the
% model.
inputTable = trainingData;
predictorNames = {'Xtrain1', 'Xtrain2', 'Xtrain3', 'Xtrain4', 'Xtrain5', 'Xtrain6', 'Xtrain7'};
predictors = inputTable(:, predictorNames);
response = inputTable.Y;
isCategoricalPredictor = [false, false, false, false, false, false, false];

% Perform cross-validation
partitionedModel = crossval(trainedClassifier.ClassificationEnsemble, 'KFold', 5);

% Compute validation predictions
[validationPredictions, validationScores] = kfoldPredict(partitionedModel);

% Compute validation accuracy - now returns accuracy for each fold
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError','Mode','individual');