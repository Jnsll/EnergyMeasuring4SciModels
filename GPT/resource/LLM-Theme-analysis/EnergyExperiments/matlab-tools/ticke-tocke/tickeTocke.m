%% tickeTocke

function varargout = tickeTocke(type,varargin)
% tickeTocke is used by both ticke and tocke functions

persistent lastEnergyCounterStamp energyUnits baseline lastTimeStamp

switch type
    case "initialize"
        if isempty(energyUnits)
            energyUnits = MsrRegisters.energyUnits;
        end

        % set last time stamp
        lastTimeStamp = datetime("now");

        % set last energy stamp
        lastEnergyCounterStamp = measure;
    case "measure"
        % set time stamp
        currentTimeStamp = datetime("now");

        % measure energy
        currentEnergyCounterStamp = measure;
        energyCounterDelta = currentEnergyCounterStamp - lastEnergyCounterStamp;

        % estimate baseline
        % pause(0.5)
        % baseline = estimateBaseLine;
        % baseline = 0;

        % calculate consumed energy
        % energyDeltaNet = (energyCounterDelta - baseline * (seconds(currentTimeStamp - lastTimeStamp))) * energyUnits;
        energyDeltaNet = 0;
        energyDelta = energyCounterDelta * energyUnits;

        % print to command window
        fprintf('Consumed energy (total CPUs) is %.2f Joules\n',energyDelta)
        if energyDeltaNet < 0 % print a warning if value is negative
            disp(['[',8,'Warning: Energy measurement can be inaccurate for small energy amounts.]',8])
        end
        % fprintf('Consumed energy (excl. estimated background consumption) is %.5f Joules\n',energyDeltaNet)
        if nargout
            varargout = {energyDelta,energyDeltaNet};
        end
end
end

function baseline = estimateBaseLine
deltaT = 5;
E1 = measure;
pause(deltaT)
E2 = measure;
% delta energy per second (estimated)
baseline = (E2 - E1) / deltaT;
end

function res = measure
% measure current energy counter stamp

numCpus = 1;
% persistent numCpus
% 
% if isempty(numCpus)
%     numCpus = MsrRegisters.numCpus;
% end

msrReg = MsrRegisters.MSR_PKG_ENERGY_STATUS;
for idx = numCpus:-1:1
    counter(idx) = readMsrByIdMex_noErrorHandling(msrReg,idx - 1);
end
res = sum(counter);
end
