% displayImageOnAxes.m
function displayImageOnAxes(targetAxes, imageData)
    % Clears previous content, displays image, and sets axes properties.
    
    cla(targetAxes); % Clear the axes
    
    if ~isempty(imageData)
        imshow(imageData, 'Parent', targetAxes);
    else
        % Optionally display a placeholder or nothing if imageData is empty
    end
    
    set(targetAxes, 'XTick', [], 'YTick', [], 'Box', 'on', ...
                    'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');
end