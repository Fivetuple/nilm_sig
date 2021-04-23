%
% Purpose:
%           Returns the index of the next upward zero crossing in the
%           vector.
%           Returns 0 if none is found.
% Input     
%           
% Effects:
%
%
% (c) 2021 Paul Moore - moorep@maths.ox.ac.uk 
%
% This software is provided 'as is' with no warranty or other guarantee of
% fitness for the user's purpose.  Please let the author know of any bugs
% or potential improvements.

function out = next_upward_zero_crossing(x)
    
    out = 0;
    for j=1:numel(x)-1
       
        crossed = (x(j)<=0 && x(j+1) >= 0);
        if crossed
            out = j;
            break
        end
    end
    
end
