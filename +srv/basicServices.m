function services = basicServices()
    % This version should have no inputs for your Rigbox version
    fprintf('!!! INITIALIZING CONCRETE UDP SERVICES !!!\n');
    
    services = {};
    hostIDs = {'neural-imaging', 'eye-tracking', 'timeline'};
    ports = [1001, 1002, 1011];

    for i = 1:length(hostIDs)

        s = io.MpepUDPDataHosts({'BUGEON-BRUKER'});
      
        s.RemotePort = ports(i);
        s.Id = hostIDs{i};
        s.Title= hostIDs{i};
       s.open();
        s.broadcast('hello');
        services{i, 1} = s;
    end
    
end