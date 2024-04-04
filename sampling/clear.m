%fake clear, shadowing the builtin clear function
%used to prevent "clear 'all'" calls
%that destroy the wrapping work space
function clear(varargin)
    if nargin == 1 && strcmp(varargin{1}, 'all')
        %a "clear 'all'" call is detected
        %do nothing
    else
        builtin('clear', varargin{:});
        %individual variables are allowed to be cleared
    end
end