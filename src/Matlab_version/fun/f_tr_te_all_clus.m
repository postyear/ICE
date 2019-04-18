function [ y_pred_all ] = f_tr_te_all_clus(X_tr, y_tr, X_te, y_te, clus, doNorm)
% Use the training data to predict the testing data. 
%  Use whole training data to predict
%  Use each cluster of training data to predict the testing data.

if nargin < 6
    doNorm = 1;
end

y_pred_all = zeros(size(X_te, 1), length(clus) + 1);

% the first col is for using the whole data
y_pred_all(:, 1) = f_weka_RF_tr_te(X_tr, y_tr, X_te, y_te);

% start from the second col, the result is for each cluster
for i=1:length(clus)
    y_pred_te = f_weka_RF_tr_te(X_tr(clus{i}, :), y_tr(clus{i}), X_te, y_te);
    
    % Normalization
    if doNorm == 1
        templete = y_pred_all(:, 1);
        target = y_pred_te;
        y_pred = f_my_quantileNorm(templete, target);
    else
        y_pred = y_pred_te;
    end
    
    y_pred_all(:, i+1) = y_pred;
    
end



end

