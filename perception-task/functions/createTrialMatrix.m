function matrix = createTrialMatrix(th, n_trials)
    % Number of indices
    numIndices = length(th.multi_index);

    % Check if n_trials is evenly divisible by 2 * numIndices
    if mod(n_trials, 2 * numIndices) ~= 0
        error('n_trials must be divisible by twice the number of indices.');
    end

    % Calculate repetitions per index
    repsPerIndex = n_trials / (numIndices);

    % Create columns
    V = repmat(th.multi_index', repsPerIndex, 1);
    % Combine columns
    matrix = [V(randperm(n_trials)), V(randperm(n_trials))];
end
