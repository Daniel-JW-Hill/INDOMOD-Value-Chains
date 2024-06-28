function [buyer_parameters] = get_buyer_parameters(transaction_costs_scenarios_vec, discountrate)
% ========================================================================
% ** IndoMod script **
% This script retrieves and packages the buyer parameters for their
% decision function. 
% This includes transaction costs c_by, plot level transaction costs c_bn,
% farmer level transaction costs c_bf, and village level investment costs
% I_b
% We also specify the price they receive in downstream markets for red
% coffee cherries net variable costs P_b (gross margin). And their discount rate (in which we use to get the
% npv for their transaction costs.)
% ========================================================================

buyer_parameters.discount_rate_buyer = discountrate;
buyer_parameters.years = 20; 
year_vec = 0:buyer_parameters.years-1; 

discount_factor = 1 ./ (1 + buyer_parameters.discount_rate_buyer ).^year_vec;

% Allocate transaction costs to dataframe. 
column_name_to_find = 'I_b';
column_index = strcmp(transaction_costs_scenarios_vec.Properties.VariableNames, column_name_to_find);
buyer_parameters.I_b = transaction_costs_scenarios_vec{1,column_index};

column_name_to_find = 'C_bf';
column_index = strcmp(transaction_costs_scenarios_vec.Properties.VariableNames, column_name_to_find);
buyer_parameters.C_bf = repelem(transaction_costs_scenarios_vec{1,column_index},buyer_parameters.years );
buyer_parameters.C_bf = buyer_parameters.C_bf * discount_factor';

column_name_to_find = 'C_bn';
column_index = strcmp(transaction_costs_scenarios_vec.Properties.VariableNames, column_name_to_find);
buyer_parameters.C_bn = repelem(transaction_costs_scenarios_vec{1,column_index},buyer_parameters.years );
buyer_parameters.C_bn = buyer_parameters.C_bn * discount_factor';

column_name_to_find = 'C_by';
column_index = strcmp(transaction_costs_scenarios_vec.Properties.VariableNames, column_name_to_find);
buyer_parameters.C_by = transaction_costs_scenarios_vec{1,column_index};

column_name_to_find = 'P_b';
column_index = strcmp(transaction_costs_scenarios_vec.Properties.VariableNames, column_name_to_find);
buyer_parameters.P_b = transaction_costs_scenarios_vec{1,column_index};

%End of function. 




