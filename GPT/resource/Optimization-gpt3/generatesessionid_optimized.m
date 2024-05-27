function id = generatesessionid()

% GENERATESESSIONID
%
% See also GENERATEJOBID, GENERATEBATCHID

% Copyright (C) 2011-2012, Robert Oostenveld
%
% This file is part of FieldTrip, see http://www.fieldtriptoolbox.org
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id$

if nargin ~= 0
    error('Incorrect number of input arguments');
end

% Get the username and hostname only once to avoid repeated function calls
username = getusername();
hostname = gethostname();

% Generate the process ID once to avoid repeated function calls
pid = getpid();

% Combine the strings directly instead of using sprintf
id = [username, '_', hostname, '_p', num2str(pid)];