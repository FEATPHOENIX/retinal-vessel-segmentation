% main_retinal_segmentation_gui.m
% Retinal Blood Vessel Segmentation for Diabetic Retinopathy Detection
% For Digital Image Processing Subject
% Submitted by: PRATEEK VASNIK, URK23EC4031

function main_retinal_segmentation_gui()

    % --- 1. GUI Initialization ---
    f = figure('Name', 'Retinal Blood Vessel Segmentation for Diabetic Retinopathy Detection - PRATEEK VASNIK (URK23EC4031)', ... % Updated Title
               'NumberTitle', 'off', ...
               'MenuBar', 'none', ...
               'ToolBar', 'none', ...
               'Position', [100 100 1400 750], ... % Adjusted size for more controls
               'Color', [0.15 0.15 0.2]); % Dark background

    % Store handles to GUI components in the figure's UserData
    handles = struct();
    handles.f = f;
    
    % --- Left Panel: Controls and Log Output ---
    leftPanel = uipanel(f, 'Title', 'Controls & Log', ...
                        'Units', 'pixels', ...
                        'Position', [10 10 300 730], ... % Adjusted width
                        'BackgroundColor', [0.2 0.2 0.25], ...
                        'ForegroundColor', [0.9 0.9 0.9], ...
                        'BorderType', 'none', ...
                        'FontSize', 12);

    % File Operations Panel within Left Panel
    fileOpsPanel = uipanel(leftPanel, 'Title', 'File Operations', ...
                           'Units', 'normalized', ...
                           'Position', [0.02 0.8 0.96 0.19], ... % [left bottom width height]
                           'BackgroundColor', [0.25 0.25 0.3], ...
                           'ForegroundColor', [0.9 0.9 0.9], ...
                           'BorderType', 'none', ...
                           'FontSize', 10);
    
    handles.LoadImageButton = uicontrol(fileOpsPanel, 'Style', 'pushbutton', ...
                                        'String', 'Load Retinal Image', ...
                                        'Units', 'normalized', ...
                                        'Position', [0.05 0.7 0.9 0.25], ...
                                        'BackgroundColor', [0.3 0.5 0.7], ...
                                        'ForegroundColor', [1 1 1], ...
                                        'Callback', @loadImageCallback);

    handles.LoadGTButton = uicontrol(fileOpsPanel, 'Style', 'pushbutton', ...
                                     'String', 'Load Ground Truth Mask', ...
                                     'Units', 'normalized', ...
                                     'Position', [0.05 0.4 0.9 0.25], ...
                                     'BackgroundColor', [0.3 0.6 0.5], ... % Different color for GT
                                     'ForegroundColor', [1 1 1], ...
                                     'Callback', @loadGTCallback);

    uicontrol(fileOpsPanel, 'Style', 'text', ...
              'String', 'Loaded Image:', ...
              'Units', 'normalized', ...
              'Position', [0.05 0.2 0.9 0.15], ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', [0.25 0.25 0.3], ...
              'ForegroundColor', [0.9 0.9 0.9]);

    handles.LoadedImagePathField = uicontrol(fileOpsPanel, 'Style', 'text', ...
                                          'String', 'No image loaded.', ...
                                          'Units', 'normalized', ...
                                          'Position', [0.05 0.05 0.9 0.15], ...
                                          'HorizontalAlignment', 'left', ...
                                          'BackgroundColor', [0.25 0.25 0.3], ...
                                          'ForegroundColor', [0.8 0.8 0.8], ...
                                          'TooltipString', 'Path of the currently loaded image');
                                      
    % Segmentation Controls Panel within Left Panel
    segControlsPanel = uipanel(leftPanel, 'Title', 'Segmentation & Analysis', ...
                               'Units', 'normalized', ...
                               'Position', [0.02 0.53 0.96 0.26], ... % Adjusted height
                               'BackgroundColor', [0.25 0.25 0.3], ...
                               'ForegroundColor', [0.9 0.9 0.9], ...
                               'BorderType', 'none', ...
                               'FontSize', 10);

    handles.PerformSegmentationButton = uicontrol(segControlsPanel, 'Style', 'pushbutton', ...
                                                  'String', 'Perform Segmentation', ...
                                                  'Units', 'normalized', ...
                                                  'Position', [0.05 0.8 0.9 0.18], ...
                                                  'BackgroundColor', [0.7 0.3 0.3], ...
                                                  'ForegroundColor', [1 1 1], ...
                                                  'Callback', @performSegmentationCallback, ...
                                                  'Enable', 'off'); % Disabled until image is loaded

    handles.EvaluateButton = uicontrol(segControlsPanel, 'Style', 'pushbutton', ...
                                       'String', 'Evaluate Segmentation', ...
                                       'Units', 'normalized', ...
                                       'Position', [0.05 0.58 0.9 0.18], ...
                                       'BackgroundColor', [0.7 0.5 0.3], ...
                                       'ForegroundColor', [1 1 1], ...
                                       'Callback', @evaluateSegmentationCallback, ...
                                       'Enable', 'off'); % Disabled until seg & GT available

    handles.ClassifyDRButton = uicontrol(segControlsPanel, 'Style', 'pushbutton', ...
                                        'String', 'Classify Diabetic Retinopathy', ...
                                        'Units', 'normalized', ...
                                        'Position', [0.05 0.36 0.9 0.18], ...
                                        'BackgroundColor', [0.7 0.7 0.3], ...
                                        'ForegroundColor', [1 1 1], ...
                                        'Callback', @classifyDRCallback, ...
                                        'Enable', 'off'); % Disabled until seg available

    handles.SaveOutputButton = uicontrol(segControlsPanel, 'Style', 'pushbutton', ...
                                         'String', 'Save Segmented Output', ...
                                         'Units', 'normalized', ...
                                         'Position', [0.05 0.05 0.9 0.18], ...
                                         'BackgroundColor', [0.3 0.7 0.7], ...
                                         'ForegroundColor', [1 1 1], ...
                                         'Callback', @saveOutputCallback, ...
                                         'Enable', 'off'); % Disabled until seg available

    % Evaluation Metrics Panel
    metricsPanel = uipanel(leftPanel, 'Title', 'Evaluation Metrics', ...
                           'Units', 'normalized', ...
                           'Position', [0.02 0.35 0.96 0.17], ...
                           'BackgroundColor', [0.25 0.25 0.3], ...
                           'ForegroundColor', [0.9 0.9 0.9], ...
                           'BorderType', 'none', ...
                           'FontSize', 10);

    uicontrol(metricsPanel, 'Style', 'text', 'String', 'Accuracy:', ...
              'Units', 'normalized', 'Position', [0.05 0.7 0.45 0.2], 'HorizontalAlignment', 'left', ...
              'BackgroundColor', [0.25 0.25 0.3], 'ForegroundColor', [0.9 0.9 0.9]);
    handles.AccuracyText = uicontrol(metricsPanel, 'Style', 'text', 'String', 'N/A', ...
                                     'Units', 'normalized', 'Position', [0.5 0.7 0.45 0.2], 'HorizontalAlignment', 'right', ...
                                     'BackgroundColor', [0.25 0.25 0.3], 'ForegroundColor', [0.8 0.8 0.8]);

    uicontrol(metricsPanel, 'Style', 'text', 'String', 'Sensitivity:', ...
              'Units', 'normalized', 'Position', [0.05 0.45 0.45 0.2], 'HorizontalAlignment', 'left', ...
              'BackgroundColor', [0.25 0.25 0.3], 'ForegroundColor', [0.9 0.9 0.9]);
    handles.SensitivityText = uicontrol(metricsPanel, 'Style', 'text', 'String', 'N/A', ...
                                        'Units', 'normalized', 'Position', [0.5 0.45 0.45 0.2], 'HorizontalAlignment', 'right', ...
                                        'BackgroundColor', [0.25 0.25 0.3], 'ForegroundColor', [0.8 0.8 0.8]);

    uicontrol(metricsPanel, 'Style', 'text', 'String', 'Specificity:', ...
              'Units', 'normalized', 'Position', [0.05 0.2 0.45 0.2], 'HorizontalAlignment', 'left', ...
              'BackgroundColor', [0.25 0.25 0.3], 'ForegroundColor', [0.9 0.9 0.9]);
    handles.SpecificityText = uicontrol(metricsPanel, 'Style', 'text', 'String', 'N/A', ...
                                        'Units', 'normalized', 'Position', [0.5 0.2 0.45 0.2], 'HorizontalAlignment', 'right', ...
                                        'BackgroundColor', [0.25 0.25 0.3], 'ForegroundColor', [0.8 0.8 0.8]);

    % DR Classification Panel
    drPanel = uipanel(leftPanel, 'Title', 'Diabetic Retinopathy Status', ...
                      'Units', 'normalized', ...
                      'Position', [0.02 0.25 0.96 0.09], ...
                      'BackgroundColor', [0.25 0.25 0.3], ...
                      'ForegroundColor', [0.9 0.9 0.9], ...
                      'BorderType', 'none', ...
                      'FontSize', 10);
    handles.DRStatusText = uicontrol(drPanel, 'Style', 'text', 'String', 'Not Classified', ...
                                      'Units', 'normalized', 'Position', [0.05 0.2 0.9 0.6], ...
                                      'HorizontalAlignment', 'center', ...
                                      'BackgroundColor', [0.25 0.25 0.3], 'ForegroundColor', [1 1 0], ... % Yellow for unclassified
                                      'FontSize', 12, 'FontWeight', 'bold');

    % Log Output Panel within Left Panel
    logPanel = uipanel(leftPanel, 'Title', 'Log Output', ...
                       'Units', 'normalized', ...
                       'Position', [0.02 0.02 0.96 0.22], ... % Adjusted height
                       'BackgroundColor', [0.25 0.25 0.3], ...
                       'ForegroundColor', [0.9 0.9 0.9], ...
                       'BorderType', 'none', ...
                       'FontSize', 10);
                   
    handles.LogTextArea = uicontrol(logPanel, 'Style', 'edit', ...
                                     'Max', 2, 'Min', 0, ... % Multiline text
                                     'String', 'Welcome to Retinal Blood Vessel Segmentation for DR Detection!', ...
                                     'Units', 'normalized', ...
                                     'Position', [0.02 0.02 0.96 0.96], ...
                                     'HorizontalAlignment', 'left', ...
                                     'BackgroundColor', [0.1 0.1 0.15], ...
                                     'ForegroundColor', [0 0.8 0], ...
                                     'Enable', 'inactive', ... % Not editable by user
                                     'FontSize', 10, ...
                                     'FontName', 'Consolas'); % Monospaced font for log

    % --- Right Panel: Image Displays ---
    % Create a grid of axes for image display
    axesPanel = uipanel(f, 'Title', '', ...
                       'Units', 'pixels', ...
                       'Position', [320 10 1060 730], ... % Adjust position and size
                       'BackgroundColor', [0.15 0.15 0.2], ...
                       'BorderType', 'none');

    % Define positions for 6 axes (3 rows, 2 columns)
    axesWidth = 0.45; % Relative width within axesPanel
    % Adjusted axesHeight to allow more vertical space
    axesHeight = 0.28; % Slightly smaller to ensure all rows fit
    labelHeight = 0.03; % Height for labels
    verticalGapBetweenAxesAndLabel = 0.01; % Small gap between axes and its label
    verticalGapBetweenRows = 0.03; % Gap between image rows

    % Row 1 positions
    % Calculate yPosLabel1 from the top of the panel, then place axes below it
    yPosLabel1 = 1 - labelHeight - 0.01; % Start from near the top of the axesPanel (1 is top)
    yPosAxes1 = yPosLabel1 - axesHeight - verticalGapBetweenAxesAndLabel; 
    xPos1 = 0.05;
    xPos2 = xPos1 + axesWidth + 0.05; % Add some horizontal spacing

    % Axes Labels and Handles (Row 1)
    uicontrol(axesPanel, 'Style', 'text', 'String', 'Original Image', ...
              'Units', 'normalized', 'Position', [xPos1 yPosLabel1 axesWidth labelHeight], ...
              'HorizontalAlignment', 'center', 'BackgroundColor', [0.15 0.15 0.2], 'ForegroundColor', [0.9 0.9 0.9]);
    handles.OriginalAxes = axes('Parent', axesPanel, 'Units', 'normalized', ...
                                'Position', [xPos1 yPosAxes1 axesWidth axesHeight], 'XTick', [], 'YTick', [], 'Box', 'on', ...
                                'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');

    uicontrol(axesPanel, 'Style', 'text', 'String', 'Preprocessed', ...
              'Units', 'normalized', 'Position', [xPos2 yPosLabel1 axesWidth labelHeight], ...
              'HorizontalAlignment', 'center', 'BackgroundColor', [0.15 0.15 0.2], 'ForegroundColor', [0.9 0.9 0.9]);
    handles.PreprocessedAxes = axes('Parent', axesPanel, 'Units', 'normalized', ...
                                  'Position', [xPos2 yPosAxes1 axesWidth axesHeight], 'XTick', [], 'YTick', [], 'Box', 'on', ...
                                  'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');

    % Row 2 positions
    yPosLabel2 = yPosAxes1 - verticalGapBetweenRows - labelHeight;
    yPosAxes2 = yPosLabel2 - axesHeight - verticalGapBetweenAxesAndLabel; 
    
    % Axes Labels and Handles (Row 2)
    uicontrol(axesPanel, 'Style', 'text', 'String', 'Vessel Enhanced (Green Channel)', ...
              'Units', 'normalized', 'Position', [xPos1 yPosLabel2 axesWidth labelHeight], ...
              'HorizontalAlignment', 'center', 'BackgroundColor', [0.15 0.15 0.2], 'ForegroundColor', [0.9 0.9 0.9]);
    handles.VesselEnhancedAxes = axes('Parent', axesPanel, 'Units', 'normalized', ...
                                    'Position', [xPos1 yPosAxes2 axesWidth axesHeight], 'XTick', [], 'YTick', [], 'Box', 'on', ...
                                    'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');

    uicontrol(axesPanel, 'Style', 'text', 'String', 'Segmented Vessels', ...
              'Units', 'normalized', 'Position', [xPos2 yPosLabel2 axesWidth labelHeight], ...
              'HorizontalAlignment', 'center', 'BackgroundColor', [0.15 0.15 0.2], 'ForegroundColor', [0.9 0.9 0.9]);
    handles.SegmentedVesselsAxes = axes('Parent', axesPanel, 'Units', 'normalized', ...
                                      'Position', [xPos2 yPosAxes2 axesWidth axesHeight], 'XTick', [], 'YTick', [], 'Box', 'on', ...
                                      'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');

    % Row 3 positions
    yPosLabel3 = yPosAxes2 - verticalGapBetweenRows - labelHeight;
    yPosAxes3 = yPosLabel3 - axesHeight - verticalGapBetweenAxesAndLabel;

    % Axes Labels and Handles (Row 3)
    uicontrol(axesPanel, 'Style', 'text', 'String', 'Overlay on Original', ...
              'Units', 'normalized', 'Position', [xPos1 yPosLabel3 axesWidth labelHeight], ...
              'HorizontalAlignment', 'center', 'BackgroundColor', [0.15 0.15 0.2], 'ForegroundColor', [0.9 0.9 0.9]);
    handles.OverlayAxes = axes('Parent', axesPanel, 'Units', 'normalized', ...
                             'Position', [xPos1 yPosAxes3 axesWidth axesHeight], 'XTick', [], 'YTick', [], 'Box', 'on', ...
                             'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');

    uicontrol(axesPanel, 'Style', 'text', 'String', 'Thinned Vessels', ...
              'Units', 'normalized', 'Position', [xPos2 yPosLabel3 axesWidth labelHeight], ...
              'HorizontalAlignment', 'center', 'BackgroundColor', [0.15 0.15 0.2], 'ForegroundColor', [0.9 0.9 0.9]);
    handles.ThinnedVesselsAxes = axes('Parent', axesPanel, 'Units', 'normalized', ...
                                    'Position', [xPos2 yPosAxes3 axesWidth axesHeight], 'XTick', [], 'YTick', [], 'Box', 'on', ...
                                    'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');

    % Set UserData for the figure to store handles
    set(f, 'UserData', handles);

    % --- 2. Callback Functions ---
    function logMessage(msg)
        % Append message to the log text area
        currentLog = get(handles.LogTextArea, 'String');
        if ischar(currentLog)
            set(handles.LogTextArea, 'String', {currentLog; msg});
        else
            set(handles.LogTextArea, 'String', [currentLog; {msg}]);
        end
        % Ensure the scrollbar goes to the bottom
        set(handles.LogTextArea, 'Value', numel(get(handles.LogTextArea, 'String')));
        drawnow; % Update GUI immediately
    end

    function loadImageCallback(~, ~)
        logMessage('Loading retinal image...');
        [filename, pathname] = uigetfile({'*.jpg;*.png;*.tif', 'Image Files (*.jpg, *.png, *.tif)'; '*.*', 'All Files (*.*)'}, ...
            'Select a Retinal Image');
        
        if isequal(filename, 0) || isequal(pathname, 0)
            logMessage('Image loading cancelled.');
            return;
        end
        
        fullImagePath = fullfile(pathname, filename);
        originalImage = imread(fullImagePath);
        
        % Store original image and path in handles
        handles.OriginalImage = originalImage;
        handles.CurrentImagePath = fullImagePath;
        handles.SegmentedBW = []; % Clear previous segmentation results
        handles.GroundTruthMask = []; % Clear previous ground truth
        set(handles.f, 'UserData', handles); % Update handles in figure UserData

        % Display original image
        displayImageOnAxes(handles.OriginalAxes, handles.OriginalImage);
        logMessage(['Image loaded: ' filename]);
        set(handles.LoadedImagePathField, 'String', fullImagePath);
        set(handles.PerformSegmentationButton, 'Enable', 'on'); % Enable segmentation button
        
        % Reset evaluation and classification
        resetEvaluationAndClassification();
        clearSegmentationResults();
    end

    function loadGTCallback(~, ~)
        handles = get(handles.f, 'UserData'); % Get latest handles
        if ~isfield(handles, 'OriginalImage') || isempty(handles.OriginalImage)
            logMessage('Error: Load an original image first before loading ground truth.');
            return;
        end

        logMessage('Loading ground truth mask...');
        [filename, pathname] = uigetfile({'*.png;*.tif', 'Binary Mask Files (*.png, *.tif)'; '*.*', 'All Files (*.*)'}, ...
            'Select Ground Truth Mask (Binary)');
        
        if isequal(filename, 0) || isequal(pathname, 0)
            logMessage('Ground truth loading cancelled.');
            return;
        end
        
        fullGTPath = fullfile(pathname, filename);
        gtMask = imread(fullGTPath);
        
        % Ensure GT is binary (0/1 or 0/255) and matches original image size
        if size(gtMask, 3) == 3
            gtMask = rgb2gray(gtMask); % Convert to grayscale if RGB
        end
        
        % Only binarize if it's not already logical, or if it's uint8/uint16/double where 0 is background and non-zero is foreground.
        % imbinarize expects numerical types, not logical. If gtMask is already logical (e.g., from a previous imbinarize call on an RGB image),
        % calling imbinarize again can cause an error.
        if ~islogical(gtMask)
             gtMask = imbinarize(gtMask); % Ensure it's a logical binary mask
        else
            gtMask = logical(gtMask); % Ensure it's logical (if it was already logical but maybe not 'logical' class)
        end
        
        % Resize GT mask if it doesn't match original image size
        if ~isequal(size(gtMask), size(rgb2gray(handles.OriginalImage)))
            logMessage('Warning: Ground truth mask size does not match original image. Resizing GT mask.');
            gtMask = imresize(gtMask, size(rgb2gray(handles.OriginalImage)), 'nearest');
        end

        handles.GroundTruthMask = gtMask;
        set(handles.f, 'UserData', handles); % Update handles in figure UserData

        logMessage(['Ground truth mask loaded: ' filename]);
        % Check if segmentation is already performed to enable evaluation
        if isfield(handles, 'SegmentedBW') && ~isempty(handles.SegmentedBW)
            set(handles.EvaluateButton, 'Enable', 'on');
        end
        resetEvaluationMetrics(); % Clear previous metrics
    end

    function performSegmentationCallback(~, ~)
        handles = get(handles.f, 'UserData'); % Get latest handles
        if ~isfield(handles, 'OriginalImage') || isempty(handles.OriginalImage)
            logMessage('Error: No image loaded. Please load an image first.');
            return;
        end
        
        logMessage('Segmentation started...');
        set(handles.PerformSegmentationButton, 'Enable', 'off'); % Disable during processing
        set(handles.EvaluateButton, 'Enable', 'off'); % Disable evaluation during re-segmentation
        set(handles.ClassifyDRButton, 'Enable', 'off'); % Disable classification
        set(handles.SaveOutputButton, 'Enable', 'off'); % Disable save
        resetEvaluationAndClassification();
        drawnow; % Update GUI immediately

        try
            % Call the external segmentation function
            [preprocessedImg, vesselEnhancedImg, segmentedBW, thinnedVessels, overlayImg] = ...
                performSegmentation(handles.OriginalImage);
            
            % Store results in handles
            handles.PreprocessedImg = preprocessedImg;
            handles.VesselEnhancedImg = vesselEnhancedImg;
            handles.SegmentedBW = segmentedBW;
            handles.ThinnedVessels = thinnedVessels;
            handles.OverlayImg = overlayImg;
            set(handles.f, 'UserData', handles); % Update handles in figure UserData

            % Display results
            displayImageOnAxes(handles.PreprocessedAxes, preprocessedImg);
            logMessage('Preprocessing: Grayscale conversion complete.');
            drawnow;
            
            displayImageOnAxes(handles.VesselEnhancedAxes, vesselEnhancedImg);
            logMessage('Preprocessing: Contrast enhancement (CLAHE) complete.');
            drawnow;

            displayImageOnAxes(handles.SegmentedVesselsAxes, segmentedBW);
            logMessage('Segmentation: Matched filtering and thresholding complete.');
            drawnow;

            displayImageOnAxes(handles.ThinnedVesselsAxes, thinnedVessels);
            logMessage('Post-processing: Vessel thinning complete.');
            drawnow;

            displayImageOnAxes(handles.OverlayAxes, overlayImg);
            logMessage('Post-processing: Overlay generated.');
            drawnow;

            logMessage('All segmentation steps completed successfully!');
            set(handles.SaveOutputButton, 'Enable', 'on'); % Enable save button
            set(handles.ClassifyDRButton, 'Enable', 'on'); % Enable classification button

            % Check if ground truth is loaded to enable evaluation
            if isfield(handles, 'GroundTruthMask') && ~isempty(handles.GroundTruthMask)
                set(handles.EvaluateButton, 'Enable', 'on');
            end

        catch ME
            logMessage(['Error during segmentation: ' ME.message]);
            logMessage('Segmentation failed.');
            % For debugging, display full report in command window
            disp(getReport(ME)); 
        end
        
        set(handles.PerformSegmentationButton, 'Enable', 'on'); % Re-enable button
    end

    function evaluateSegmentationCallback(~, ~)
        handles = get(handles.f, 'UserData'); % Get latest handles
        if ~isfield(handles, 'SegmentedBW') || isempty(handles.SegmentedBW)
            logMessage('Error: Perform segmentation first.');
            return;
        end
        if ~isfield(handles, 'GroundTruthMask') || isempty(handles.GroundTruthMask)
            logMessage('Error: Load ground truth mask first for evaluation.');
            return;
        end

        logMessage('Evaluating segmentation against ground truth...');
        set(handles.EvaluateButton, 'Enable', 'off');
        drawnow;

        try
            [accuracy, sensitivity, specificity] = evaluateSegmentation(handles.SegmentedBW, handles.GroundTruthMask);
            
            set(handles.AccuracyText, 'String', sprintf('%.4f', accuracy));
            set(handles.SensitivityText, 'String', sprintf('%.4f', sensitivity));
            set(handles.SpecificityText, 'String', sprintf('%.4f', specificity));
            logMessage(sprintf('Evaluation Complete: Acc=%.4f, Sen=%.4f, Spec=%.4f', accuracy, sensitivity, specificity));
        catch ME
            logMessage(['Error during evaluation: ' ME.message]);
            disp(getReport(ME));
        end
        set(handles.EvaluateButton, 'Enable', 'on');
    end

    function classifyDRCallback(~, ~)
        handles = get(handles.f, 'UserData'); % Get latest handles
        if ~isfield(handles, 'SegmentedBW') || isempty(handles.SegmentedBW)
            logMessage('Error: Perform segmentation first to classify DR.');
            return;
        end

        logMessage('Classifying Diabetic Retinopathy...');
        set(handles.ClassifyDRButton, 'Enable', 'off');
        drawnow;

        try
            % The classifyDiabeticRetinopathy function will be a placeholder
            % A real ML model would involve loading a pre-trained model and
            % extracting appropriate features from the segmentedBW image.
            [drStatus, vesselDensity] = classifyDiabeticRetinopathy(handles.SegmentedBW);
            
            set(handles.DRStatusText, 'String', drStatus);
            if strcmp(drStatus, 'Diabetic Retinopathy Detected')
                set(handles.DRStatusText, 'ForegroundColor', [1 0 0]); % Red for DR
            else
                set(handles.DRStatusText, 'ForegroundColor', [0 1 0]); % Green for Normal
            end
            logMessage(['DR Classification Complete: ' drStatus ' (Vessel Density: ' sprintf('%.4f', vesselDensity) ')']);
        catch ME
            logMessage(['Error during DR classification: ' ME.message]);
            disp(getReport(ME));
            set(handles.DRStatusText, 'String', 'Classification Failed');
            set(handles.DRStatusText, 'ForegroundColor', [1 1 0]); % Yellow for failed
        end
        set(handles.ClassifyDRButton, 'Enable', 'on');
    end

    function saveOutputCallback(~, ~)
        handles = get(handles.f, 'UserData');
        if ~isfield(handles, 'SegmentedBW') || isempty(handles.SegmentedBW)
            logMessage('Error: No segmented image to save.');
            return;
        end

        logMessage('Saving segmented output...');
        [filename, pathname] = uiputfile({'*.png', 'PNG Image (*.png)'; '*.tif', 'TIFF Image (*.tif)'}, ...
                                         'Save Segmented Blood Vessels As', ...
                                         'segmented_vessels.png');
        
        if isequal(filename, 0) || isequal(pathname, 0)
            logMessage('Saving cancelled.');
            return;
        end
        
        fullSavePath = fullfile(pathname, filename);
        try
            % You might want to save segmentedBW or overlayImg
            imwrite(handles.SegmentedBW, fullSavePath);
            logMessage(['Segmented image saved to: ' fullSavePath]);
        catch ME
            logMessage(['Error saving image: ' ME.message]);
        end
    end

    function clearSegmentationResults()
        % Clear all axes except the original
        cla(handles.PreprocessedAxes);
        cla(handles.VesselEnhancedAxes);
        cla(handles.SegmentedVesselsAxes);
        cla(handles.OverlayAxes);
        cla(handles.ThinnedVesselsAxes);
    end

    function resetEvaluationMetrics()
        set(handles.AccuracyText, 'String', 'N/A');
        set(handles.SensitivityText, 'String', 'N/A');
        set(handles.SpecificityText, 'String', 'N/A');
    end

    function resetDRClassification()
        set(handles.DRStatusText, 'String', 'Not Classified');
        set(handles.DRStatusText, 'ForegroundColor', [1 1 0]); % Yellow for unclassified
    end

    function resetEvaluationAndClassification()
        resetEvaluationMetrics();
        resetDRClassification();
        set(handles.EvaluateButton, 'Enable', 'off');
        set(handles.ClassifyDRButton, 'Enable', 'off');
        set(handles.SaveOutputButton, 'Enable', 'off');
    end

end