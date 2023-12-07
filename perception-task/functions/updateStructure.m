function th_updated = updateStructure(th, contrast_lvls)
    % Find the closest value and index for th.single
    [minDiffSingle, singleIndex] = min(abs(contrast_lvls - th.single));
    th_updated = th;
    th_updated.single_real = contrast_lvls(singleIndex);
    th_updated.single_index = singleIndex;

    % Initialize arrays for multi_real and multi_index
    th_updated.multi_real = zeros(size(th.multi));
    th_updated.multi_index = zeros(size(th.multi));

    % Find the closest values and indices for each element in th.multi
    for i = 1:length(th.multi)
        [minDiff, idx] = min(abs(contrast_lvls - th.multi(i)));
        th_updated.multi_real(i) = contrast_lvls(idx);
        th_updated.multi_index(i) = idx;
    end
    
    th.contrast_lvls = contrast_lvls;
end