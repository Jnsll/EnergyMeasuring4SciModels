%% clearExcept

function clearExcept(varargin)
vars = evalin('caller','who');
vars = setdiff(vars,varargin);
for idx = 1:numel(vars)
    evalin('caller',['clear(''',vars{idx},''')'])
end
end
