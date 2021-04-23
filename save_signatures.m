%
% Purpose:
%           Save path signatures of trajectories.
% Input     
%           Depth (degree) of signature to compute.
% Effects:
%
%
% (c) 2021 Paul Moore - moorep@maths.ox.ac.uk 
%
% This software is provided 'as is' with no warranty or other guarantee of
% fitness for the user's purpose.  Please let the author know of any bugs
% or potential improvements.


function save_signatures(depth)

    tic;

    % the length of the tag is used as the dimension
    % tag = 'vq';
    tag = 'tvi';
    
    cooll_path = '/home/paul/Desktop/cache/dale/cooll/';
    flac_path = [cooll_path 'flac/'];
   
    % apply scaling
    apply_scaling = 1;

    % Reading of the detected detection moments 
    load('data/cooll_on_off_times.mat','cooll_on_off_times')
    inst = cooll_on_off_times;

    % read scale factors
    load([cooll_path 'scaleFactors.txt'],'scaleFactors');

    % Information about COOLL Dataset
    Ta = 100000;                                % Sample rate
    f1 = 50;                                    % Signal Frequency
    cycle = Ta/f1;                              % Samples numbers per cycle

    % define path_width and find the sig and logsig lengths    
    path_width = length(tag);
    test_path = zeros(10, path_width);
    sig_length = numel(matlab_esig_shell(test_path, depth, 0));
    logsig_length = numel(matlab_esig_shell(test_path, depth, 1));

    % initialise signature matrices
    sig = zeros(840,sig_length);
    logsig = zeros(840,logsig_length);
    sig_trans = zeros(840,sig_length);
    logsig_trans = zeros(840,logsig_length);


    % find the features for each appliance
    for cnt = 1:840

        fprintf('%d ',cnt); 
        
        % File name
        date_current = strcat([flac_path 'scenarioC1_'], num2str(cnt),'.flac');
        date_voltage = strcat([flac_path 'scenarioV1_'], num2str(cnt),'.flac');

        % Read file
        current = audioread(date_current);          
        voltage = audioread(date_voltage);       

        % To steady state 
        inst_start = inst(cnt,1) + 60*cycle;
        inst_end = inst_start + cycle;

        % shift to start at zero crossing
        deltat = next_upward_zero_crossing(voltage(inst_start:inst_end));      
        inst_start = inst_start+deltat;
        inst_end = inst_end+deltat;
        Vs = voltage(inst_start:inst_end);    
        Is = current(inst_start:inst_end);

        % To transient state 	
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

        tic;
                
        % create signature of steady-state path
        if 1
            if isequal(tag,'tvi')
                t = (1:numel(Vs))';
                t =  t/numel(t);        
                A = [t Vs Is];
            elseif isequal(tag,'vq')
                A = [Vs cumsum(Is)];
            end
            
            sig(cnt,:) = matlab_esig_shell(A, depth, 0);       
            logsig(cnt,:) = matlab_esig_shell(A, depth, 1);
        end

        % create signature of transient path
        if 1
            if isequal(tag,'tvi')
                t = (1:numel(Vt))';
                t =  t/numel(t);        
                A = [t Vt It];
            elseif isequal(tag,'vq')
                A = [Vt cumsum(It)];
            end

            sig_trans(cnt,:) = matlab_esig_shell(A, depth, 0);       
            logsig_trans(cnt,:) = matlab_esig_shell(A, depth, 1);
        end
        toc;

    end

    if 1
        save(['./data/trajectory_signature_' tag '_' num2str(depth)],'sig','logsig','sig_trans','logsig_trans');
        disp(['Saved signature of depth ' num2str(depth)]);
    end

    toc;
    
end

