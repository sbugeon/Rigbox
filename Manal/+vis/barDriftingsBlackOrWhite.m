function stimulus = barDriftingsBlackOrWhite(t)
%VIS.BARDRIFTINGSBLACKORWHITE Full-field cyan background with drifting bar.
%   Creates the visual elements used by barDriftingsBlackOrWhiteParadigm:
%   a full-screen background patch and a rectangular bar patch. The expDef
%   sets colour, position, orientation, dimensions, and visibility.

background = vis.patch(t, 'rectangle');
background.azimuth = 0;
background.altitude = 0;
background.orientation = 0;
background.dims = [270; 90];
background.colour = [0; 0.5; 0.5];
background.show = true;

bar = vis.patch(t, 'rectangle');
bar.azimuth = 0;
bar.altitude = 0;
bar.orientation = 0;
bar.dims = [8; 90];
bar.colour = [1; 1; 1];
bar.show = false;

stimulus = struct('background', background, 'bar', bar);

end
