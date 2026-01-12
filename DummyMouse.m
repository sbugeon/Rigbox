% In DummyMouse.m
classdef DummyMouse
    % A comprehensive dummy mouse/wheel input class.
    % It contains properties and methods that hw.devices and experiment
    % files commonly try to access during setup and runtime.
    
    properties
        % To accept assignment from rig.clock during configuration.
        Clock = []; 
        
        % To accept the DAQ session object created in hw.devices.
        DaqSession = [];
        
        % To accept sample rate configurations.
        SampleRate = [];

        % To accept input channel configurations.
        Inputs = [];

        MillimetresFactor = 0;
        ZeroOffset=0;

        EncoderResolution = 1024

WheelDiameter = 62
    end
    
    methods
        function position = read(~)
            % Called by the experiment to get the current wheel position.
           q % Always returns 0 for our dummy device.
            position = 0;
        end
        
        function reset(~)
            % Often called at the start of a trial to reset the position.
            % Does nothing for our dummy device.
        end

        function initialize(~)
            % May be called by some configuration scripts.
            % Does nothing for our dummy device.
        end

        function createDaqChannel(~)
            % Called by hw.devices during setup. Does nothing.
        end
        function zero(~)
            % Called by hw.devices during setup. Does nothing.
        end
        function w = readAbsolutePosition(~)
            % Called by hw.devices during setup. Does nothing.
            w=0;
        end
        
    end
end