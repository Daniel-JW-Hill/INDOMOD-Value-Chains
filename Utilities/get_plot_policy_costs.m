function [net_costs_contracting, Y_npv_buyer, Y_npv_farmer] = get_plot_policy_costs(lu, s, lu_trans_cf_new, w, r,  farmer_transaction_costs, r_buyer)
% ========================================================================
% ** IndoMod function **
% Returns npv of costs for a given plot that transitions to the policy
% option. 
% Also returns yields per plot for the policy option for the buyer to
% optimise. 
% ========================================================================

tmax = size(lu_trans_cf_new.lut_cf{1,1,1},2); % planning horizon
t = [0:tmax-1]';
df_farmer = (1+r).^-t; % discount factor starts at year 0
df_buyer = (1+r_buyer).^-t; % discount factor starts at year 0


%Prices for other outputs. 
p_vec = lu_trans_cf_new.p_tab.price;
p_vec = p_vec - farmer_transaction_costs.c_fy; %prices now net of unit level transaction costs. 

X = lu_trans_cf_new.lut_cf{lu,5,s}; % full DCF matrix (cols are years)

L = X(lu_trans_cf_new.v.L_rows,:); % labour
Lf = L(1:7,:); % family
Lh = L(8:14,:); % hired
L = Lf + Lh; % total labour per item 
K = X(lu_trans_cf_new.v.K_rows,:); % capital
Y = X(lu_trans_cf_new.v.Y_rows,:); % yields
V = X(lu_trans_cf_new.v.V_rows(end),:); % timber volumes. 
Ltot = sum(L);
Ktot = sum(K);

% apply adjustments
Ladj = sum(L .* lu_trans_cf_new.adjust.L(:,5)); % total L adjusted
Kadj = sum(K .* lu_trans_cf_new.adjust.K(:,5)); % total K adjusted

if size(lu_trans_cf_new.adjust.Y,1) == size(Y,1)
    
    Y = Y .* lu_trans_cf_new.adjust.Y; % adjustment per output
   
    % final vectors with adjustment for operation phase:
    idx = find(lu_trans_cf_new.est_tab.trans == lu*100 + 5*10 + s);
    y_est = lu_trans_cf_new.est_tab.yr_est(idx); % years of establishment
    
    KK = [Ktot(1:y_est),Kadj(y_est+1:tmax)];
    LL = [Ltot(1:y_est),Ladj(y_est+1:tmax)];
    t_cost = KK + LL * w; 

    % Because transitioning from agroforestry brings in timber revenues
    % upfront, we include this in a net cost for contracting. 
    % We make this general in case there are other revenues that can be
    % obtained from the policy option such as intercropping. 
    P = p_vec .* lu_trans_cf_new.adjust.P; % adjustment per output

    t_other_rev = Y((1:end-1),:) .* P(1:end-1); 
    t_other_rev = sum(t_other_rev, 1);
    net_t_cost = t_cost - t_other_rev; 
    
    %Add transaction costs associated with the yield for the farmer.
    transaction_costs  = Y(end,:) * farmer_transaction_costs.c_fy(end);
    
    % Save outputs
    net_costs_contracting = ((net_t_cost + transaction_costs) * df_farmer) / 1e+6; % in million rupiah
    Y_npv_buyer = (Y(end,:) * df_buyer)/1e+6; % Yields for buyer problem, in millions of kgs. Discounting at buyer rate
    Y_npv_farmer = (Y(end,:) * df_farmer) /1e+6; % Yields for buyer problem, in millions of kgs. Discounting at farmer rate

else 

    Y = Y .* lu_trans_cf_new.adjust.Y(1:size(Y,1)); % adjustment per output
    V = V .* lu_trans_cf_new.adjust.V(end); % adjust for timber revenues
    
    % final vectors with adjustment for operation phase:
    idx = find(lu_trans_cf_new.est_tab.trans == lu*100 + 5*10 + s);
    y_est = lu_trans_cf_new.est_tab.yr_est(idx); % years of establishment
    KK = [Ktot(1:y_est),Kadj(y_est+1:tmax)];
    LL = [Ltot(1:y_est),Ladj(y_est+1:tmax)];
    t_cost = KK + LL * w; 

    P = p_vec .* lu_trans_cf_new.adjust.P; 

    t_other_rev = Y((1:end),:) .* P(1:end-1); 
    t_other_rev = sum(t_other_rev, 1);
    net_t_cost = t_cost - t_other_rev;

    %Add transaction costs associated with the yield for the farmer.
    transaction_costs = V(end,tmax) * farmer_transaction_costs.c_fy(end);
    
    % Save outputs
    net_costs_contracting = ((net_t_cost + transaction_costs) * df_farmer) / 1e+6; % in million rupiah
    Y_npv_buyer = (V(end,tmax) * df_buyer(tmax))/1e+6; % Yields for buyer problem, in millions of kgs. Discounting at buyer rate
    Y_npv_farmer = (V(end,tmax) * df_farmer(tmax)) /1e+6; % Yields for buyer problem, in millions of kgs. Discounting at farmer rate

end



% End of function

