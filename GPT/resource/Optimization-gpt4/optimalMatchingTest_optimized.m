% Consider matching sources to detections

%  s1 d2  
%         s2 d3
%  d1

% Define sources and detections with coordinates
sources = [0.1 0.7; 0.6 0.4]';
detections = [0.2 0.2; 0.2 0.8; 0.7 0.1]';

% Calculate the squared distances between sources and detections
dst = sqdist(sources, detections);

% Find the optimal matching for the given distances
matching1 = optimalMatching([52; 0.01]);
matching2 = optimalMatching(dst);  % a = [2 3] which means s1-d2, s2-d3
matching3 = optimalMatching(dst'); % a = [0 1 2] which means d1-0, d2-s1, d3-s2

% Display results
disp('Matching for [52; 0.01]:');
disp(matching1);
disp('Matching for dst:');
disp(matching2);
disp('Matching for dst transposed:');
disp(matching3);

% Function to calculate squared distances between points
function d = sqdist(A, B)
    % Calculate pairwise squared distances between columns of A and B
    d = bsxfun(@plus, dot(A, A, 1)', dot(B, B, 1)) - 2 * (A' * B);
end

% Placeholder for the optimalMatching function
function a = optimalMatching(dst)
    % This is a placeholder function. The actual implementation will depend
    % on the specific algorithm used for optimal matching.
    % For demonstration purposes, we'll use a simple greedy algorithm.
    
    % Initialize matching array
    [numSources, numDetections] = size(dst);
    a = zeros(1, numSources);
    
    % Simple greedy matching (for demonstration only)
    for i = 1:numSources
        [~, minIdx] = min(dst(i, :));
        a(i) = minIdx;
        dst(:, minIdx) = inf; % Mark this detection as used
    end
end