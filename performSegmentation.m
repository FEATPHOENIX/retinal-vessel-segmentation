    % performSegmentation.m
    function [preprocessedImg, vesselEnhancedImg, segmentedBW, thinnedVessels, overlayImg] = performSegmentation(originalImage)
    
        % --- 1. Preprocessing ---
        % Convert to grayscale
        if size(originalImage, 3) == 3
            grayImg = rgb2gray(originalImage);
        else
            grayImg = originalImage; % Already grayscale
        end
        preprocessedImg = grayImg;
    
        % Enhance contrast using CLAHE (Adaptive Histogram Equalization)
        % Often the green channel gives best contrast for vessels
        if size(originalImage, 3) == 3
            greenChannel = originalImage(:,:,2); 
            vesselEnhancedImg = adapthisteq(greenChannel, 'ClipLimit', 0.02, 'Distribution', 'rayleigh');
        else
            vesselEnhancedImg = adapthisteq(grayImg, 'ClipLimit', 0.02, 'Distribution', 'rayleigh');
        end
    
        % --- 2. Blood Vessel Segmentation (Classic DIP techniques) ---
        % Matched Filtering using a 2D Gaussian Kernel (common for vessels)
        % Create a series of line detectors at different orientations
        numOrientations = 12; % Number of orientations for line detection
        sigma = 2;           % Gaussian std deviation (related to vessel width)
        len = 9;             % Length of the line detector
        
        vesselMap = zeros(size(vesselEnhancedImg), 'single'); % Initialize as single precision
        
        for i = 0:numOrientations-1
            theta = i * (180/numOrientations);
            % Create a linear filter (ridge filter)
            % Using 'log' for Laplacian of Gaussian to find ridges/lines
            h = fspecial('log', [len len], sigma); 
            h = imrotate(h, theta, 'bilinear', 'crop');
            
            % Apply filter
            filteredImg = imfilter(single(vesselEnhancedImg), h, 'replicate');
            
            % Take the maximum response across all orientations to get the strongest vessel response
            vesselMap = max(vesselMap, filteredImg); 
        end
    
        % Normalize the vessel map to [0, 1] for consistent thresholding
        vesselMap = rescale(vesselMap); 
        
        % Global thresholding (Otsu's method)
        % You might need to experiment with thresholding techniques for better results
        level = graythresh(vesselMap);
        segmentedBW = imbinarize(vesselMap, level);
        
        % Morphological cleaning
        segmentedBW = bwareaopen(segmentedBW, 50); % Remove small objects (noise)
        se = strel('disk', 2);
        segmentedBW = imclose(segmentedBW, se); % Close small gaps in vessels
        
        % --- 3. Post-processing ---
        % Thinning (skeletonization)
        thinnedVessels = bwmorph(segmentedBW, 'skel', Inf);
        
        % Overlay segmentation on original image
        % Find boundaries of segmented vessels
        boundaries = bwperim(segmentedBW);
        
        % Convert original image to uint8 if it's not already
        originalForOverlay = originalImage;
        if ~isa(originalForOverlay, 'uint8')
            originalForOverlay = im2uint8(originalForOverlay);
        end
    
        overlayImg = originalForOverlay;
        % Set boundary pixels to white for overlay
        overlayImg(repmat(boundaries, [1 1 size(originalForOverlay,3)])) = 255; 
    
    end