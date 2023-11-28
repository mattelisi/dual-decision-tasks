function th_updated = updateStructureUniqueIndices(th, contrast_lvls)

    % Function to calculate mean squared distance
    function dist = meanSquaredDistance(indices)
        roundedIndices = round(indices); % Ensure indices are integers
        dist = sum((contrast_lvls(roundedIndices) - th.multi).^2);
    end

    % Initialize the structure
    th_updated = th;

    % Find the closest value and index for th.single
    [~, singleIndex] = min(abs(contrast_lvls - th.single));
    th_updated.single_real = contrast_lvls(singleIndex);
    th_updated.single_index = singleIndex;

    % Find initial indices for th.multi
    initialIndices = arrayfun(@(x) find(min(abs(contrast_lvls - x)) == abs(contrast_lvls - x), 1), th.multi);

    % Optimization to find unique indices with minimum mean squared distance
    options = optimoptions('fmincon', 'Display', 'none');
    uniqueIndices = fmincon(@meanSquaredDistance, initialIndices, [], [], [], [], ones(size(initialIndices)), numel(contrast_lvls)*ones(size(initialIndices)), @ineqConstraint, options);

    % Update the structure with unique indices and corresponding values
    th_updated.multi_index = round(uniqueIndices); % Round indices to nearest integer
    th_updated.multi_real = contrast_lvls(th_updated.multi_index);

    % Inequality constraint function
    function [c, ceq] = ineqConstraint(x)
        c = zeros(length(x)-1, 1);
        for i = 1:length(x)-1
            c(i) = x(i) - x(i+1) + 1; % Ensure each index is smaller than the next
        end
        ceq = []; % No equality constraints
    end
end
