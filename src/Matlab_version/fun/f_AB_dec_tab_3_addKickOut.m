function [dec_mat, y_pred_tactic, auc_tactic,tactic_pick, tactic_pick_code] = ...
    f_AB_dec_tab_3_addKickOut(X, y, clus, clus_1extra, ...
    dec_mat, y_pred_whole, y_pred_self, y_pred_other,  adv_whole, adv_self)
% clus_extra is the addtional kick-out cluster of the origianl cluster
% It works as the whole data in the algorithm.

% This version 3 adds the support for fuzzy clustering - one instance may
%  belongs to more than one cluster. 
% This updated version also outputs the predicted values of y.
% support more than 3 clusters
% normalization take place in y_pred_self and y_pred_other, thus do not
%  need normalization when predict y_pred_tactic.
% ixsp is another cluster form.
if nargin < 9
    %adv_whole = 0.05;
    %adv_self = 0.03;
    adv_whole = 0.02;
    adv_self = 0.01;
end

n_clusters = length(clus);
% dec_mat = nan(n_clusters + 1, n_clusters);

% ixsp(ixsp == 0) = nan;
%% --------------------------- WHOLE -------------------------------------
% Predict each cluster using the whole data. 
% [dec_mat, y_pred_whole, auc_whole] = ...
%     f_pred_each_cluster_using_whole(X, y, clus, dec_mat, n_clusters);

%% ------------------------ SELF --------------------------------
% Self prediction using 10-fold CV
% [dec_mat, y_pred_self, auc_self, y_pred_self_multi] = ...
%     f_pred_each_cluster_using_self_forWhole(X, y, clus, dec_mat, n_clusters, y_pred_whole);

%% ---------------------- Find best 'other' ------------------------------
% fill dec_mat for 'others'
% [dec_mat ] = f_fill_dec_mat_for_others(X, y, clus, dec_mat, ...
%     n_clusters, y_pred_whole, y_pred_self_multi);

%% use the best 'other' to predict current cluster for the whole data
% [dec_mat, y_pred_other, auc_other] = ...
%   f_useBestOther_toPredClus_forWholeData(X, y, clus, dec_mat, n_clusters, ...
%   y_pred_whole, y_pred_self_multi);

%% use kicked out whole data to predict each cluster. 
[dec_mat, y_pred_kickOut_whole] = ...
    f_pred_each_cluster_using_kickOut(X, y, clus, clus_1extra, dec_mat, n_clusters);
dec_mat,
%% tactically use the best for each cluster
y_pred_tactic = y_pred_whole;
tactic_pick = cell(1, n_clusters); % whole / self / other_x
tactic_pick_code = zeros(1, n_clusters); % 1 for whole; 2 for self; 3 for other


for c = 1:n_clusters
    tmp = dec_mat(:, c);
    % ------------- convert nan to 1 --------------
    % Because usually result is nan, it is because y is all 1 or all 0, and
    %  the predictions are all correct. Thus we put all nan to 1. 
    % In addition, we should choose 'whole' when there is a 'draw'.
    % 
    % tmp(isnan(tmp)) = 1;
    % revised from the above line of code. If the cluster's result is nan (
    %  y is all 1 or all 0 and the prediction might be all correct), and 
    %  there is enough instances, we convert the nan to 1 to show it is a
    %  good prediction.
    for q = 1:n_clusters
        if isnan(tmp(q))
            if length(clus{q} ) > 15
                tmp(q) = 1;
            end
        end
    end
    
    % give whole data some AUC benefit
    % also give self data some AUC benefit
    tmp(n_clusters+1) = tmp(n_clusters+1) + adv_whole;
    tmp(c) = tmp(c) + adv_self;
    if max(tmp) == tmp(n_clusters+1)
        % when whole is best
        y_pred_tactic(clus{c}) = y_pred_whole(clus{c});
        %y_pred_tactic_pcc(clus{c}) = y_pred_whole(clus{c});
        
        tactic_pick{c} = 'whole';
        tactic_pick_code(c) = 1;
    elseif max(tmp) == tmp(n_clusters+2)
        % when kicke-out-whole is best
        y_pred_tactic(clus{c}) = y_pred_kickOut_whole(clus{c});
        
        tactic_pick{c} = 'whole-kick-out';
        tactic_pick_code(c) = 4;
    elseif max(tmp) == tmp(c)
        % when self is best 
        y_pred_tactic(clus{c}) = y_pred_self(clus{c});
        %y_pred_tactic_pcc(clus{c}) = y_pred_pcc(clus{c});
        
        tactic_pick{c} = 'self';
        tactic_pick_code(c) = 2;
    else
        % when other is the best
        y_pred_tactic(clus{c}) = y_pred_other(clus{c});
        %y_pred_tactic_pcc(clus{c}) = y_pred_other(clus{c});
        
        % tactic_pick{c} = ['other_', int2str(find(tmp == max(tmp) ))];
        tmp_ixs = find(tmp == max(tmp));
        first_ixs = tmp_ixs(1);
        tactic_pick{c} = ['other_', int2str(first_ixs )];
        tactic_pick_code(c) = 3;
    end
    
end


y_tmp = y(~isnan(y_pred_tactic)); 
y_pred_tactic_p = y_pred_tactic(~isnan(y_pred_tactic));
auc_tactic = f_SampleError(y_pred_tactic_p, y_tmp, 'AUC');

% y_tmp = y(~isnan(y_pred_tactic_pcc)); 
% y_pred_tactic_pcc = y_pred_tactic_pcc(~isnan(y_pred_tactic_pcc));
% auc_tactic_pcc = f_SampleError(y_pred_tactic_pcc, y_tmp, 'AUC');

fprintf('done tactically use the best for each cluster\n');


end










