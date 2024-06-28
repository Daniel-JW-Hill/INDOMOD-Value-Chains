% This function returns the full factorial of transaction cost parameters
% for testing in the model. 
function [transaction_costs_scenarios] = get_trans_cost_scenarios(P_b, I_b, C_bf, C_bn, C_by, I_f, C_ff, C_fy)

% Use ndgrid to generate permutations
[grid1, grid2, grid3, grid4, grid5, grid6, grid7, grid8] = ndgrid(P_b, I_b, C_bf, C_bn, C_by, I_f, C_ff, C_fy);

% Reshape the grids into column vectors
transaction_costs_scenarios = [grid1(:),... 
                    grid2(:),...
                    grid3(:),... 
                    grid4(:),... 
                    grid5(:),... 
                    grid6(:),... 
                    grid7(:),... 
                    grid8(:)];

column_names = {'P_b', 'I_b', 'C_bf', 'C_bn', 'C_by', 'I_f', 'C_ff', 'C_fy'};
transaction_costs_scenarios = array2table(transaction_costs_scenarios, 'VariableNames', column_names);

% Now multiply out transaction costs relative to the buyer's price. 
P_b_relative = table2array((transaction_costs_scenarios(:,1) - min(P_b))  ./ min(P_b));
transaction_costs_scenarios = [transaction_costs_scenarios  array2table(P_b_relative)];

% End of function


