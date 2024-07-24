%script Test_BrikLoad
%
%
%
%Purpose:
%
%
%
%Input:
%
%
%
%Output:
%
%
%
%
%
%Key Terms:
%
%More Info :
%
%
%
%
%     Author : Ziad Saad
%     Date : Fri Dec 15 20:19:14 PST 2000
%     LBC/NIMH/ National Institutes of Health, Bethesda Maryland


BrikName = 'ARzs_CW_avvr.DEL+orig.BRIK';
[~, V, Info, ~] = BrikLoad (BrikName);
Opt.Format = 'vector';
[~, Vv, Infov, ~] = BrikLoad (BrikName, Opt);
Opt.Format = 'matrix';
[err, Vm, Infom, ErrMessage] = BrikLoad (BrikName, Opt);
