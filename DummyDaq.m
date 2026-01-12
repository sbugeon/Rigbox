classdef DummyDaq
    % A comprehensive dummy DAQ controller class.
    % It contains properties and methods that Rigbox's core scripts
    % call during initialization and runtime.
    
    properties
        % To allow indexing like 'SignalGenerators(1)'. Initialized as a 
        % struct to be a valid container.
        SignalGenerators = struct();
    end
    
    methods
        function createDaqChannels(~)
            % Called by hw.devices during setup. Does nothing.
        end
        
        function outputSingleScan(~, ~)
            % Called to output a value. Does nothing.
        end
        
        function inputSingleScan(~)
            % Called to read a value. Does nothing.
        end

        function startBackground(~)
            % Called to start continuous acquisition/generation. Does nothing.
        end

        function stop(~)
            % Called to stop continuous acquisition/generation. Does nothing.
        end
    end
end