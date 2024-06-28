function [lu_trans_cf_new, lu_codes, lc_codes, n_LuOpts] = Create_policy_lu(dcf_file, lu_codes, lc_codes, name, cfactor, c_stock, lut_param, Y_row_param, carbon)

% Create_policy_lu.m
% ========================================================================
% ** IndoMod script **
% This script is used to parameterise a policy land use for IndoMod, for
% households to choose from relative to other land uses. 

% This script is called to change the parameters in
% certain input files of which are already defined. 
% This script has flexibility to add more than one policy land use, which
% will dynamically update the scripts called by LP_run_script.m through the
% parameter n_LUOpts. n_LuOpts = 4 + n_policy_LuOpts where 4 = initial land
% uses pre-defined in the model.  

% Note - these land uses are only relevant after the optimal solution. This
% script does not alter any initial conditions or land uses. 

% OUTPUTS:
% 1. lu_codes - updated to introduce new LU codes for the policy LU options
% 2. lc_codes - updated to introduce new landcover paramters for policy Lu
% options. 
% 3. n_LUOpts - n_LuOpts = 4 + n_policy_LuOpts where 4 = initial land
% uses pre-defined in the model. This parameter is called in multiple loops
% to dynamically update the set up of the LP model, OS_results, and other
% utilities. 
% 4. A new dcf file is also saved with est_tab, p_vec, adjust, and lut_cf.
% The output is the new dcf_file which is the name of the file to call.

%% == Number of new land uses %%
n_policy_LuOpts  = 1;
n_LuOpts = 4 + n_policy_LuOpts;

%% == Update lu_codes
% Specify the new ID and luse value
newID = max(lu_codes.id) + 1;
newLuse = name;
newRow = table(newID, newLuse, 'VariableNames', lu_codes.Properties.VariableNames);
lu_codes = [lu_codes; newRow];

%% == Update lc_codes
% This file will update the map data, including erosion and carbon
% parameters. 
newID = max(lc_codes.id) + 1;
newLuse = name;
lu_code = max(lu_codes.id) + 1 - n_policy_LuOpts;
lu_type = lu_codes.luse(lu_codes.id == lu_code);
c_fac = cfactor;
lc_short = name;
lcs_code = max(lc_codes.lcs_code)+1;
C_stock = c_stock;
newRow = table(newID, newLuse,0,0,0,0,lu_code,lu_type,c_fac,lc_short,lcs_code,C_stock,'VariableNames',lc_codes.Properties.VariableNames);
lc_codes = [lc_codes; newRow]; 

%% == Update dcf_file
% This file will update the returns and costs associated with the land use.
% The DCF file has:
% est_tab - how long it takes for land use to establish
% p_tab - vector of initial output prices. 
% v - for indexing the rows when calculating NPVs later. 
% lut.cf = a 4x4x4 cell where dim1 = current lu, dim2 = new land use and
% dim3 = slope. 
% For each combination, inputs are profiled over 20 years. 

% In the DCF structure, we have yields for coffee, rice, hort, fruit
% and timber. A new output needs to be created within the structure for
% each new output where prices or yields want to be adjusted in the model
% calcs. 

% Note - LP_PARM_DEFAULT.m is used to adjust the prices and other parameters dynamically.  

% The lut_cf file can have new lu types added in two ways:
% 1. By using the existing .m structure, copy the profiles of an existing
% land use and edit directly. This can be done if the profile matches an
% existing lu well (e.g. relationship coffee vs commodity coffee). 
% 2. Profile all inputs in a separate file (e.g. a .csv file) with the same
% structure and read this in. This is preferred when the new lu has
% completely different costs and yields to existing lu options. 

load(['Data\',dcf_file]);
lut_cf(:,5,:) = lut_cf(:,lut_param,:);
lut_cf(5,:,:) = lut_cf(lut_param,:,:);

%Now we need to shift the outputs from the relevant rows
newRowReference = size(lut_cf{1,1,1}, 1)+1;
for i = 1:5
   for j = 1:5
        for s = 1:3
            if j == 5 
            lut_cf{i,5,s}(newRowReference,:) = lut_cf{i,lut_param,s}(Y_row_param,:);
            lut_cf{i,5,s}(Y_row_param,:) = zeros(1,size(lut_cf{i,lut_param,s}, 2));
            else 
            lut_cf{i,j,s}(newRowReference,:) = zeros(1,size(lut_cf{i,lut_param,s}, 2)); 
            end
        end
   end 
end

%% == Update adjust, p_tab, est_tab, V
%Make new price equal to 1 for easy adjustment later. 
new_p_tab = table(newLuse, 1, 'VariableNames', p_tab.Properties.VariableNames);
p_tab = [p_tab; new_p_tab];

% Update est_tab with new indexes.  
ids = table2array(est_tab(:, 1));
initial_lu_est = ids >= lut_param*100 & ids < (lut_param+1)*100;
new_lu_est = mod(ids, 100) >= lut_param*10 & mod(ids, 100) < (lut_param+1)*10;
initial_lu_est = est_tab(initial_lu_est , :);
new_lu_est = est_tab(new_lu_est, :);
new_initial_ids = table2array(initial_lu_est(:, 1)) + (5-lut_param)*100;
new_new_ids = table2array(new_lu_est(:, 1)) + (5-lut_param)*10;
initial_lu_est(:,1) = array2table(new_initial_ids);
new_lu_est(:, 1) = array2table(new_new_ids);
est_tab = [est_tab; initial_lu_est ; new_lu_est];
%We also need to add the final combinations manually
est_tab_new = array2table([551 0; 552 0; 553 0], 'VariableNames', est_tab.Properties.VariableNames);
est_tab = [est_tab; est_tab_new];

%Update adjust 
adjust.names = [adjust.names(:)' {newLuse}]'; % Adjusts the names
adjust.type = [adjust.type(:)' {'Y'}]'; % Adjusts the types for referencing 
adjust.L  = [adjust.L, ones(size(adjust.L, 1),1)];
adjust.K  = [adjust.K, ones(size(adjust.K, 1),1)];
adjust.Y =  [adjust.Y ; 1];
adjust.P =  [adjust.P ; 1];

%Update V 
v.names = [v.names(:)' {'Y_valuechain'}]'; % Adjusts the names of rows for new yield
if Y_row_param < 24
    v.Y_rows = [v.Y_rows(:); size(v.names,1)]'; %references new yield added to dcf mats. 
else 
    v.V_rows = [v.V_rows(:); size(v.names,1)]'; %references new timber volume added to dcf mats. 
end

% Update Y if carbon market - set yields to 1 per ha so payments are on a
% per ha basis and not yield based
if carbon == 1
    for i  = 1:5
        for s = 1:3
            lut_cf{i,5,s}(end,:) = ones(1,size(lut_cf{i,5,s},2));
        end
    end
end

%Save the new DCF package and parameterise file name for . 
lu_trans_cf_new.adjust = adjust;
lu_trans_cf_new.est_tab = est_tab;
lu_trans_cf_new.lut_cf = lut_cf;
lu_trans_cf_new.p_tab = p_tab;
lu_trans_cf_new.v = v;


% End of Function.
