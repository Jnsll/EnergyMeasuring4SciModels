function id = generatesessionid()
% GENERATESESSIONID
%
% See also GENERATEJOBID, GENERATEBATCHID
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

% Ensure no input arguments are provided
narginchk(0, 0);

% Generate the session ID
username = getusername();
hostname = gethostname();
pid = getpid();

id = sprintf('%s_%s_p%d', username, hostname, pid);
end