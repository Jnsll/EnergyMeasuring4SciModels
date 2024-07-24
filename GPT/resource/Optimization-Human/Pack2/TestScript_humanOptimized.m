%% TestScript.m

close all

axis = [1,2,3];
axis = axis / norm(axis);
angle = pi / 2;

num = ' % 1.5f';
str = ['\r', num, '\t', num, '\t', num];
str2 = ['\r', num, '\t', num, '\t', num, '\t', num];

%% Axis-angle to rotation matrix

helpFun3(@axisAngle2rotMat, '\rAxis-angle to rotation matrix:', str,axis, angle);

%% Axis-angle to quaternion

q = helpFun4(@axisAngle2quatern, '\rAxis-angle to quaternion:', str2,axis, angle);

%% Quaternion to rotation matrix

R = helpFun3(@quatern2rotMat, '\rQuaternion to rotation matrix:', str,q);

%% Rotation matrix to quaternion

q = helpFun4(@rotMat2quatern, '\rRotation matrix to quaternion:', str2,R);

%% Rotation matrix to ZYX Euler angles

helpFun4(@rotMat2euler, '\rRotation matrix to ZYX Euler angles:', str2,R);

%% Quaternion to ZYX Euler angles

euler = helpFun4(@quatern2euler, '\rQuaternion to ZYX Euler angles:', str2,q);

%% ZYX Euler angles to rotation matrix

R = helpFun3(@euler2rotMat, '\rZYX Euler angles to rotation matrix:', str,euler(1), euler(2), euler(3));

%% End of file

function b = helpFun(str, R, idx)
b = sprintf(str, R(idx,:));
end

function b = helpFun2(str2, q)
b = sprintf(str2, q);
end

function R = helpFun3(fun, titleStr, str,varargin)
R = fun(varargin{:});
a = sprintf(titleStr);
b = helpFun(str, R, 1);
c = helpFun(str, R, 2);
d = helpFun(str, R, 3);
disp([a,b,c,d]);
end

function q = helpFun4(fun, titleStr, str2,varargin)
q = fun(varargin{:});
a = sprintf(titleStr);
b = helpFun2(str2, q);
disp([a,b]);
end