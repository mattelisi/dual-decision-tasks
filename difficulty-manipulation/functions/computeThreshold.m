function [th] = computeThreshold(x,r)
% fit cumulative Gaussian and return threshold

% initial parameters
%par0 = log(1.5*mean(abs(x)));

% options
options = optimset('Display', 'off') ;

%
n = length(x);

% do optimization - no lapses
fun = @(par) -L_r(x, r, par);
par0 = mean(abs(x));
[par, L] = fminsearch(fun, par0, options);
AIC = 2 - 2*(-L);
AICc_0 = AIC + (2 + 2)/(n-1-1);
sigma_0 = exp(par);

% do optimization - with lapses
fun = @(par) -L_r_lambda(x, r, par(1), par(2));
par0 = [mean(abs(x)), norminv(0.01)+2];
[par, L] = fminsearch(fun, par0, options);
AIC = 2 - 2*(-L);
AICc_1 = AIC + (2 + 2)/(n-1-1);
sigma_1 = exp(par(1));

aic_w = calculate_akaike_weight([AICc_0 , AICc_1]);
sigma = aic_w(1)*sigma_0 + aic_w(2)*sigma_1;

% output parameters 
%al = [0.55, 0.65, 0.75, 0.85, 0.95];
al = [0.65, 0.7, 0.75, 0.8, 0.85]; % should we add 0.05 here?
th.single = quantile_fun(mean(al), sigma);
th.multi  = [quantile_fun(al(1), sigma), quantile_fun(al(2), sigma), quantile_fun(al(3), sigma), quantile_fun(al(4), sigma), quantile_fun(al(5), sigma)];
%th.multi  = [quantile_fun(al(1), sigma), quantile_fun(al(2), sigma), quantile_fun(al(3), sigma)];
th.sigma = sigma;

end

% --------------------------------

function x = quantile_fun(p, sigma)
    x = sigma * sqrt(2) * erfinv(2*p-1);
end

function L = L_r(x, r, logsigma)
    L = sum(log(p_r(x(r==1), exp(logsigma)))) + sum(log(1 - p_r(x(r==0), exp(logsigma))));
end

function p = p_r(x, sigma)
    p = 0.5 *(1 + erf(x/(sqrt(2)*sigma)));
end

function p = p_r_lambda(x, logsigma, lambda)
    lambda = normcdf(lambda-2);
    p = lambda + (1-2*lambda)* 0.5 *(1 + erf(x/(sqrt(2)* exp(logsigma))));
end

function L = L_r_lambda(x, r, logsigma, lambda)
    L = sum(log(p_r_lambda(x(r==1), exp(logsigma), lambda))) + sum(log(1 - p_r_lambda(x(r==0), exp(logsigma), lambda)));
end

function[aic_w] = calculate_akaike_weight(aic)
% calculate Akaike weight; aic and aic_w are vectors
aic_w = aic - min(aic);
aic_w = exp(-0.5 * aic_w);
aic_w = aic_w/sum(aic_w);
end