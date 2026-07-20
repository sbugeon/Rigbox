function elem = greyScreen(t)
%VIS.GREYSCREEN Returns a full-field uniform colour screen element.
%   This visual element renders a rectangle centred on the display.  It is
%   intended for simple full-field backgrounds or timed grey/cyan screens.
%
%   Fields:
%     dims    Full-field extent [width height] in visual degrees.
%     colour  Scalar luminance or RGB colour in [0, 1] or [0, 255].
%     show    Logical visibility signal. Default false.
%
%   See also VIS.PATCH, VIS.RDK, VIS.PLAID

elem = t.Node.Net.subscriptableOrigin('greyScreen');
elem.dims = [270 90]';
elem.colour = [0 127 127]';
elem.show = false;

flatten = @(A)A(:);
isInitialized = @(l)~any(flatten(cellfun('isempty', struct2cell(l))));
layers = elem.map(@makeLayer).flattenStruct();
elem.layers = layers.keepWhen(layers.map(isInitialized));
end


function layer = makeLayer(newelem)
[layer, img] = vis.rectLayer([0; 0], [270 90]', 0);
layer.textureId = 'greyScreen';
layer.blending = 'source';

if isSignal(newelem.dims)
  layer.size = newelem.dims.map(@(d)3*sanitizeDims(d, [270 90], 'dims'));
else
  layer.size = 3*sanitizeDims(newelem.dims, [270 90], 'dims');
end

if isSignal(newelem.colour)
  layer.maxColour = newelem.colour.map( ...
    @(c)[sanitizeColour(c, [0 127 127], 'colour'); 1]);
else
  layer.maxColour = [sanitizeColour(newelem.colour, [0 127 127], ...
    'colour'); 1];
end

[layer.rgba, layer.rgbaSize] = vis.rgba(1, img);
layer.show = newelem.show;
end


function tf = isSignal(value)
tf = isa(value, 'sig.Signal') || isa(value, 'sig.node.Signal');
end


function colour = sanitizeColour(colour, defaultValue, name)
if isempty(colour)
  colour = defaultValue;
elseif isnumeric(colour) || islogical(colour)
  colour = double(colour);
elseif ischar(colour) || isstring(colour)
  colour = parseNumericVectorText(char(colour));
elseif iscell(colour)
  colour = cellfun(@double, colour);
else
  error('vis:greyScreen:InvalidParameter', ...
    'Parameter %s must be numeric or convertible to RGB values.', name);
end

colour = colour(:);
colour = colour(isfinite(colour));
if isempty(colour)
  colour = defaultValue(:);
elseif isscalar(colour)
  colour = repmat(colour, 3, 1);
elseif numel(colour) < 3
  colour = defaultValue(:);
end

colour = colour(1:3);
if any(colour > 1)
  colour = colour/255;
end
colour = min(max(colour, 0), 1);
end


function dims = sanitizeDims(dims, defaultValue, name)
if isempty(dims)
  dims = defaultValue;
elseif isnumeric(dims) || islogical(dims)
  dims = double(dims);
elseif ischar(dims) || isstring(dims)
  dims = parseNumericVectorText(char(dims));
elseif iscell(dims)
  dims = cellfun(@double, dims);
else
  error('vis:greyScreen:InvalidParameter', ...
    'Parameter %s must be numeric or convertible to double.', name);
end

dims = dims(:);
dims = dims(isfinite(dims));
if isempty(dims)
  dims = defaultValue(:);
elseif isscalar(dims)
  dims = repmat(dims, 2, 1);
elseif numel(dims) < 2
  dims = defaultValue(:);
end
dims = max(dims(1:2), eps);
end


function values = parseNumericVectorText(text)
tokens = regexp(text, '[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?', 'match');
values = str2double(tokens);
end
