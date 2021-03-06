function [dec_mat, y_pred_whole, auc_whole] = ...
    f_pred_each_cluster_using_whole(X, y, clus, dec_mat, n_clusters,...
    useParfor)
% Predict each cluster using the whole data.

if nargin < 6
    useParfor = 0;
end

try
% [y_pred_whole, auc_whole] = f_weka_RF_arff_10_fo_3(X, y);
if useParfor == 1
    [y_pred_whole, auc_whole] = f_weka_RF_arff_k_fo_3_parfor(X, y, 10);
else
    [y_pred_whole, auc_whole] = f_weka_RF_arff_k_fo_3(X, y, 10);
end

for j=1:n_clusters        
    auc = f_SampleError(y_pred_whole(clus{j}), y(clus{j}), 'AUC');
    kap = f_my_01_kappa(y_pred_whole(clus{j}), y(clus{j}) );
    
    dec_mat(n_clusters+1, j) = auc;
end

fprintf('done using whole data to predict each clusters\n');
catch exception   
end



end

