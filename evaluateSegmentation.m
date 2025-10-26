% evaluateSegmentation.m
function [accuracy, sensitivity, specificity] = evaluateSegmentation(segmentedBW, groundTruthBW)
    % Evaluates the performance of a binary segmentation against a ground truth.
    % Inputs:
    %   segmentedBW   - The binary image output from your segmentation algorithm (logical).
    %   groundTruthBW - The ground truth binary mask (logical).
    % Outputs:
    %   accuracy      - (TP + TN) / (TP + TN + FP + FN)
    %   sensitivity   - TP / (TP + FN) (True Positive Rate, Recall)
    %   specificity   - TN / (TN + FP) (True Negative Rate)

    if ~isequal(size(segmentedBW), size(groundTruthBW))
        error('Input images (segmentedBW and groundTruthBW) must have the same dimensions.');
    end

    % Convert to logical if they aren't already
    segmentedBW = logical(segmentedBW);
    groundTruthBW = logical(groundTruthBW);

    % Calculate True Positives (TP), True Negatives (TN), False Positives (FP), False Negatives (FN)
    TP = sum(segmentedBW(:) & groundTruthBW(:));    % Pixels correctly identified as vessels
    TN = sum(~segmentedBW(:) & ~groundTruthBW(:));  % Pixels correctly identified as non-vessels
    FP = sum(segmentedBW(:) & ~groundTruthBW(:));   % Pixels incorrectly identified as vessels
    FN = sum(~segmentedBW(:) & groundTruthBW(:));   % Pixels incorrectly identified as non-vessels

    % Calculate metrics
    totalPixels = numel(segmentedBW);

    accuracy = (TP + TN) / totalPixels;

    if (TP + FN) > 0
        sensitivity = TP / (TP + FN); % Also known as Recall or True Positive Rate
    else
        sensitivity = 0; % Avoid division by zero if no actual positive pixels in GT
    end

    if (TN + FP) > 0
        specificity = TN / (TN + FP); % Also known as True Negative Rate
    else
        specificity = 0; % Avoid division by zero if no actual negative pixels in GT
    end

end