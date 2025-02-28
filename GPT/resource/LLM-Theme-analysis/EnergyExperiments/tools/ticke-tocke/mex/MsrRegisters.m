%% MsrRegisters

classdef MsrRegisters
    properties (Constant,Access = public)
        MSR_RAPL_POWER_UNIT = 0x606; % MSR register for power units
        MSR_PKG_ENERGY_STATUS = 0x611; % MSR register for engergy status
        % MAX_ENERGY_RANGE_UJ % TODO: maximum energy range before counter overflows
        fileName_readMsr = fullfile(gitLabPath,'matlab-tools','ticke-tocke','mex','readMsrById_noErrorHandling')

        % getNumCpusMex counts the directories inside directory /dev/cpu
        % (not counting . and ..)
        numCpus = getNumCpus
    end

    % methods
    %     function obj = MsrRegisters
    %         obj.exponentPowerUnits = hex2dec(unitsStr(end-1:end));
    %         obj.exponentTimeUnits = hex2dec(unitsStr(1:end-4));
    %     end
    % end

    methods (Static,Access = public)
        function res = energyUnits
            % energy units

            obj = MsrRegisters;
            cpuId = 0;
            units = obj.readUnits(obj.MSR_RAPL_POWER_UNIT,cpuId);
            % units = readMsrByIdMex_noErrorHandling(obj.MSR_RAPL_POWER_UNIT,cpuId);
            unitsStr = dec2hex(units);
            exponentEnergyUnits = hex2dec(unitsStr(end-3:end-2));
            res = 0.5^exponentEnergyUnits;
        end
    end

    methods (Static,Access = private)
        function units = readUnits(registerId,cpuId)
            units = readMsrByIdMex_noErrorHandling(registerId,cpuId);
        end
    end
end
