function elem = rdk(t)
%VIS.RDK Returns a full-field Signals random dot kinematogram element.
%   The element renders normalized floating-point dot positions into a
%   dynamic full-field texture.  Experimental timing and dot-state
%   evolution should live in the exp def.
%
%   Fields:
%     dotPositions     N-by-2 normalized coordinates in [0, 1].
%     dims             Full-field extent [width height] in visual degrees.
%     dotSize          Dot diameter in texture pixels. Default 3.
%     dotColor         RGB column vector in [0, 1]. Default cyan.
%     backgroundColor  RGB column vector in [0, 1]. Default mid-grey.
%     show             Logical visibility signal. Default false.

elem = t.Node.Net.subscriptableOrigin('rdk');
elem.dotPositions = zeros(0, 2);
elem.dims = [270 90]';
elem.dotSize = 3;
elem.dotColor = [0 1 1]';
elem.backgroundColor = [0.5 0.5 0.5]';
elem.show = false;

% Keep elem.layers as a Signals layer signal whose current value is always
% a standard vis.emptyLayer struct.  exp.SignalsExp/loadVisual immediately
% reads layers.Node.CurrValue during init and expects [val.show] to work.
elem.layers = elem.map(@makeLayer).flattenStruct();
end

function layer = makeLayer(newelem)
layer = vis.emptyLayer();

% One full-field dynamic texture centred on the observer.
layer.texOffset = [0 0]';
layer.texAngle = 0;
layer.size = sanitizeDims(newelem.dims, [270 90], 'dims');
layer.isPeriodic = false;
layer.interpolation = 'linear';
layer.blending = 'source';
layer.show = newelem.show;

persistent rdkNum
rdkNum = iff(isempty(rdkNum), 1, rdkNum + 1);
layer.textureId = sprintf('~rdk%i', rdkNum);

if hasSignals(newelem.dotPositions, newelem.dotSize, ...
    newelem.dotColor, newelem.backgroundColor)
  [layer.rgba, layer.rgbaSize] = mapn( ...
    newelem.dotPositions, newelem.dotSize, ...
    newelem.dotColor, newelem.backgroundColor, ...
    @renderRdk);
else
  [layer.rgba, layer.rgbaSize] = renderRdk( ...
    newelem.dotPositions, newelem.dotSize, ...
    newelem.dotColor, newelem.backgroundColor);
end
end

function tf = hasSignals(varargin)
tf = false;
for i = 1:nargin
  if isa(varargin{i}, 'sig.Signal') || isa(varargin{i}, 'sig.node.Signal')
    tf = true;
    return
  end
end
end

function [rgba, rgbaSize] = renderRdk(dotPositions, dotSize, ...
    dotColor, backgroundColor)

textureWidth = 720;
textureHeight = 360;
dotSize = max(sanitizeScalar(dotSize, 3, 'dotSize'), 1);
dotColor = sanitizeColor(dotColor, [0 1 1], 'dotColor');
backgroundColor = sanitizeColor(backgroundColor, [0.5 0.5 0.5], ...
  'backgroundColor');

rgb = zeros(textureHeight, textureWidth, 3);
rgb(:, :, 1) = backgroundColor(1);
rgb(:, :, 2) = backgroundColor(2);
rgb(:, :, 3) = backgroundColor(3);

if ~isempty(dotPositions)
  dotPositions = double(dotPositions);
  dotPositions = mod(dotPositions(:, 1:2), 1);
  dotPositions = dotPositions(all(isfinite(dotPositions), 2), :);

  x = 1 + dotPositions(:, 1)*(textureWidth - 1);
  y = 1 + dotPositions(:, 2)*(textureHeight - 1);
  radius = max(dotSize/2, 0.5);

  for i = 1:size(dotPositions, 1)
    rgb = drawDot(rgb, x(i), y(i), radius, dotColor, ...
      textureWidth, textureHeight);
  end
end

[rgba, rgbaSize] = vis.rgba(rgb, 1);
end

function rgb = drawDot(rgb, x, y, radius, dotColor, textureWidth, ...
    textureHeight)

xOffsets = 0;
yOffsets = 0;
edgePad = radius + 1;
if x - edgePad < 1
  xOffsets = [xOffsets textureWidth];
elseif x + edgePad > textureWidth
  xOffsets = [xOffsets -textureWidth];
end
if y - edgePad < 1
  yOffsets = [yOffsets textureHeight];
elseif y + edgePad > textureHeight
  yOffsets = [yOffsets -textureHeight];
end

for xOffset = xOffsets
  for yOffset = yOffsets
    rgb = drawDotCopy(rgb, x + xOffset, y + yOffset, radius, dotColor, ...
      textureWidth, textureHeight);
  end
end
end

function rgb = drawDotCopy(rgb, x, y, radius, dotColor, textureWidth, ...
    textureHeight)

pad = ceil(radius + 1);
xRange = max(1, floor(x) - pad):min(textureWidth, ceil(x) + pad);
yRange = max(1, floor(y) - pad):min(textureHeight, ceil(y) + pad);
if isempty(xRange) || isempty(yRange)
  return
end

[xx, yy] = meshgrid(xRange, yRange);
distanceFromCentre = hypot(xx - x, yy - y);

% Feathering preserves subpixel motion instead of snapping the visible dot
% footprint to integer texture coordinates.
coverage = min(max(radius + 0.5 - distanceFromCentre, 0), 1);
if ~any(coverage(:))
  return
end

for channel = 1:3
  current = rgb(yRange, xRange, channel);
  rgb(yRange, xRange, channel) = current.*(1 - coverage) + ...
    dotColor(channel).*coverage;
end
end

function value = sanitizeScalar(value, defaultValue, name)
if isempty(value)
  value = defaultValue;
elseif isnumeric(value) || islogical(value)
  value = double(value);
elseif ischar(value) || isstring(value)
  value = str2double(value);
  if isnan(value)
    error('rdk:InvalidParameter', ...
      'Parameter %s must be numeric or convertible to double.', name);
  end
else
  error('rdk:InvalidParameter', ...
    'Parameter %s must be numeric or convertible to double.', name);
end
value = value(1);
validateattributes(value, {'double'}, {'real', 'finite', 'scalar'}, ...
  mfilename, name);
end

function dims = sanitizeDims(dims, defaultValue, name)
if isempty(dims)
  dims = defaultValue;
elseif isnumeric(dims) || islogical(dims)
  dims = double(dims);
elseif ischar(dims) || isstring(dims)
  dims = sscanf(char(dims), '%f').';
  if isempty(dims)
    error('rdk:InvalidParameter', ...
      'Parameter %s must be numeric or convertible to double.', name);
  end
else
  error('rdk:InvalidParameter', ...
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
dims = dims(1:2);
dims = max(dims, eps);
end

function color = sanitizeColor(color, defaultValue, ~)
if isempty(color)
  color = defaultValue;
elseif isnumeric(color) || islogical(color)
  color = double(color);
elseif ischar(color) || isstring(color)
  color = parseColorString(color);
  if isempty(color)
    color = defaultValue;
  end
else
  color = defaultValue;
end
color = color(:);
color = color(isfinite(color));
if isempty(color)
  color = defaultValue(:);
elseif isscalar(color)
  color = repmat(color, 3, 1);
elseif numel(color) < 3
  color = defaultValue(:);
end
color = color(1:3);
if any(color > 1)
  color = color/255;
end
color = min(max(color, 0), 1);
end

function color = parseColorString(color)
color = char(strjoin(cellstr(string(color))));
color = strrep(color, ',', ' ');
color = strrep(color, ';', ' ');
color = strrep(color, '[', ' ');
color = strrep(color, ']', ' ');
color = sscanf(color, '%f').';
end
