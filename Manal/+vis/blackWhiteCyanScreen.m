function screen = blackWhiteCyanScreen(t)
%VIS.BLACKWHITECYANSCREEN Full-field colour screen stimulus.
%   Creates a Signals rectangle patch intended to cover the full stimulus
%   display. The experiment definition should set dims, colour, and show.

screen = vis.patch(t, 'rectangle');
screen.azimuth = 0;
screen.altitude = 0;
screen.orientation = 0;
screen.dims = [270; 90];
screen.colour = [0; 0; 0];
screen.show = true;

end
