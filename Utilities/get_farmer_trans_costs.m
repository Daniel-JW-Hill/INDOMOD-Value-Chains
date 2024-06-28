function [farmer_transaction_costs] = get_farmer_trans_costs(lu_trans_cf_new, r, transaction_costs_scenarios_vec)

% ========================================================================
% ** IndoMod function **
% Returns farmer level transaction costs per land use
% Farmers face three types of transaction costs, of which are rationalised
% to two parameters.
% Upfront investment (I_f), and annual fixed costs (C_ff) for a land use 
% In this script we profile out as a single NPV epr farmer  given the
% discount rate. This enters directly into the LP objective function as a
% fixed cost when eligible. But when allocating the preferred optimal
% solution, farmers can opt out and avoid these fixed costs. 
%
% Unit level transaction costs (C_fy) are any transaction costs related per
% unit of output. This enters into the lp_get_NPV_mat function. 

% ========================================================================
tmax = size(lu_trans_cf_new.lut_cf{1,1,1},2); % planning horizon
years = 0:tmax-1; 

%% Fixed transaction costs

% annual transaction costs in rupiah.
column_name_to_find = 'C_ff';
column_index = strcmp(transaction_costs_scenarios_vec.Properties.VariableNames, column_name_to_find);
c_ff  = transaction_costs_scenarios_vec{1,column_index}; 

% upfront investment cost in rupiah.
column_name_to_find = 'I_f';
column_index = strcmp(transaction_costs_scenarios_vec.Properties.VariableNames, column_name_to_find);
I_f   = transaction_costs_scenarios_vec{1,column_index}; % annual transaction costs in rupiah.

c_ff = repmat(c_ff, tmax, 1);
c_ff(1) = c_ff(1) + I_f ;

discount_factor = 1 ./ (1 + r).^years;

c_ff_relationshipcoffee =  discount_factor * c_ff;

%Save as a single cost for now. 
c_ff = c_ff_relationshipcoffee;

%% Annual unit level transaction costs

 % unit level transaction cost in rupiah.
column_name_to_find = 'C_fy';
column_index = strcmp(transaction_costs_scenarios_vec.Properties.VariableNames, column_name_to_find);
c_fy_valuechain  = transaction_costs_scenarios_vec{1,column_index}; 

%Save in a vector with 0 assigned to other prices. 
n_prices = size(lu_trans_cf_new.p_tab,1);
c_fy = zeros(n_prices,1);
c_fy(6) = c_fy_valuechain ;

%Save in a structure as output for function
farmer_transaction_costs.c_ff = c_ff; 
farmer_transaction_costs.c_fy = c_fy; 

% End of function. 

