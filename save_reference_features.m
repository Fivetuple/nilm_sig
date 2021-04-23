%
% Purpose:
%           Compute and save reference features from COOLL data.
%           Implemented zero-crossing to detect start of cycles.
%           Sampling steady state trajectory after 60 cycles.
% Input     
%           
% Effects:
%
%
% Adapted from read_COOLL_and_VI_analysis.m by Bruna Mulinari.
%           
% This software is provided 'as is' with no warranty or other guarantee of
% fitness for the user's purpose.  Please let the author know of any bugs
% or potential improvements.

% Clear the workspace and command window
close all;
clear
clc;

tic;

cooll_path = '/home/paul/Desktop/cache/dale/cooll/';
flac_path = [cooll_path 'flac/'];
addpath('./V-I_trajectory/current_features_2018');
addpath('./V-I_trajectory/proposed_features');

% apply scaling
apply_scaling = 1;

% Reading of the detected detection moments 
load('data/cooll_on_off_times.mat','cooll_on_off_times')
inst = cooll_on_off_times;

% Read scale factors
load([cooll_path 'scaleFactors.txt'])

% Informations about COOLL Dataset
Ta = 100000;                                % Sample rate
f1 = 50;                                    % Signal Frequency
cycle = Ta/f1;                              % Samples numbers per cycle

% Bruna Mulinari's features
all_bruna_features = zeros(840,12);

% Longjun Wang's features
all_longjun_features = zeros(840,10);

% keep track of errors from fe_viW/parts_division 
failed_ids = [];

% find the features for each appliance
for cnt = 1:840

    % File name
    date_current = strcat([flac_path 'scenarioC1_'], num2str(cnt),'.flac');
    date_voltage = strcat([flac_path 'scenarioV1_'], num2str(cnt),'.flac');

	% Read file
    current = audioread(date_current);          
    voltage = audioread(date_voltage);       

	% steady state 
	inst_start = inst(cnt,1) + 60*cycle;
    inst_end = inst_start + cycle;
    	
    % shift to start at zero crossing
    deltat = next_upward_zero_crossing(voltage(inst_start:inst_end));      
	inst_start = inst_start+deltat;
    inst_end = inst_end+deltat;
    Vs = voltage(inst_start:inst_end);    
    Is = current(inst_start:inst_end);
    
	% transient state 	
	inst_start = inst(cnt,1) + 2*cycle;
    inst_end = inst_start + cycle;
    
    % shift to start at zero crossing
    deltat = next_upward_zero_crossing(voltage(inst_start:inst_end));      
	inst_start = inst_start+deltat;
    inst_end = inst_end+deltat;
    Vt = voltage(inst_start:inst_end);
	It = current(inst_start:inst_end);
    
    % scale the values if apply_scaling is set
    if apply_scaling
        Vs = Vs*scaleFactors(cnt,2);
        Vt = Vt*scaleFactors(cnt,2);
        Is = Is*scaleFactors(cnt,1);
        It = It*scaleFactors(cnt,1);
    end
    
	vetor_features = fe_vi_STS(Vs,Is,Vt,It,cnt);        
    all_bruna_features (cnt,:) = vetor_features;

    % Longjun Wang's features
    % fe_viW/parts_division sometimes throws an error
    try
        vetor_featuresW = fe_viW(Vs,Is,cnt);
        all_longjun_features(cnt,:) = vetor_featuresW;
    catch
        failed_ids = [failed_ids; cnt]; %#ok<AGROW>
    end
    
end

save('./data/all_bruna_features_scaled_zero_crossing','all_bruna_features','all_longjun_features','failed_ids');

toc;
