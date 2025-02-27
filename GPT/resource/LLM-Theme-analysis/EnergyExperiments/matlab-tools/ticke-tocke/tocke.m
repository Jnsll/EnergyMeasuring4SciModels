%% tocke

function varargout = tocke(varargin)
% tocke is thought as an analogon to the matlab toc function. initializing
% an energy counter using ticke can be used by tocke to return the amount
% of energy consumed between the calls of ticke and tocke

[varargout{1:nargout}] = tickeTocke("measure",varargin{:});

end
