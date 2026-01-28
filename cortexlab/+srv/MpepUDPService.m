classdef MpepUDPService < srv.Service
  % Fixed MpepUDPService that satisfies all Rigbox requirements
  
  properties
    RemoteIP = '10.51.107.30';
    RemotePort = 1001;
  end
  
  % Rigbox Service parent class requires these to be defined
  properties (Dependent, SetAccess = protected)
    Status
  end
  
  methods
    function obj = MpepUDPService(id, port)
      obj.Id = id;
      obj.Title = id;
      obj.RemotePort = port;
    end

    % Mandatory: Rigbox uses this to check if the service is ready
    function value = get.Status(obj)
      value = 'idle'; 
    end

    function start(obj, expRef, ~)
      % This runs when Rigbox starts the experiment
      try
        [subject, series, expNum] = dat.expRefToMpep(expRef);
        msg = sprintf('ExpStart %s %d %d', subject, series, expNum);
      catch
        msg = sprintf('ExpStart %s', expRef);
      end
      
      obj.sendUDP(msg);
    end
    
    function stop(obj)
      % This runs when Rigbox stops the experiment
      obj.sendUDP('ExpEnd');
    end

    function sendUDP(obj, msg)
      fprintf('>> [%s] Sending UDP to %s:%d -> %s\n', obj.Id, obj.RemoteIP, obj.RemotePort, msg);
      try
        % Modern MATLAB udpport
        u = udpport("datagram");
        write(u, uint8(msg), obj.RemoteIP, obj.RemotePort);
        clear u;
      catch
        % Fallback for older MATLAB
        try
            u = udp(obj.RemoteIP, obj.RemotePort);
            fopen(u); fwrite(u, uint8(msg)); fclose(u); delete(u);
        catch E
            fprintf('UDP Error: %s\n', E.message);
        end
      end
    end
  end
end