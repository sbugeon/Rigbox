function hosts = mpepUDPDataHosts()
% Returns a cell array of {IP, Port}
ip = '10.51.107.30';
hosts = { ...
    [ ip,':1001'],; ... % Port 1 on the remote PC (neural imaging listener)
    [ip,':1002']; ... % Port 2 on the same PC (eye tracking)
    [ip,':1011'];     % Port 3 on the same PC (timeline)
    };
end