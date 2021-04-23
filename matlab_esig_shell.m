%
% Purpose:
%           Simple MATLAB wrapper for eSig using MATLAB py class
%
% Input   
%           A - input path with each dimension in a column
%           depth - signature degree
%           islog - 0: path signature, 1: log signature
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

% Make sure that matlab is called with access to the right env
% >source activate yourenv OR workon yourenv
% >matlab
% 
% Using an earlier version, matlab had to be called as follows
% > LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libstdc++.so.6" matlab


function sig = matlab_esig_shell(A, depth, islog)  

    % set the python executable 
    [~, ~, isloaded] = pyversion;
    if ~isloaded
        pyversion('/home/moorep/.virtualenvs/pes/bin/python');
    end
    
    % without this line, the boolean is converted to a float
    islog = int8(islog);
    
    % set to 1 if esig_shell.py is modified
    if 0
        clear classes;
        mod = py.importlib.import_module('esig_shell');
        py.importlib.reload(mod);
    end
    
    % test code
    if 0
        x = 0:5; %#ok<UNRCH>
        A = [x ;sin(x); sin(x-1)]';
        depth  = 2;
    end
        
    [n,m] = size(A);  % m is the dimension
    npA = py.numpy.array(A(:).');
    siglen = int64(py.esig_shell.siglen(m,depth,islog));
    out = py.esig_shell.run_esig(npA,n,m,depth,islog);
    data = double(py.array.array('d',py.numpy.nditer(out)));
    sig = reshape(data,[1,siglen]);
    
end




