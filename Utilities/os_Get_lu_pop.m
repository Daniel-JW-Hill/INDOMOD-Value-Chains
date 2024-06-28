function [pl_pop] = os_Get_lu_pop(OS_0, OS_1, hh, pl_pop, n_LuOpts, hh_list)
% ========================================================================
% ** IndoMod function **
% Returns the original table containing the population of plots (pl_plots) 
%   expanded to contain additional variables for land uses:
%
% The pl_pop table returned contains:
%   lu_cof: proportion of the plot entry containing coffee 
%   lu_veg: proportion of the plot entry containing vegetables 
%   lu_ric: proportion of the plot entry containing rice 
%   lu_mix: proportion of the plot entry containing mixed agroforestry
%   lu_policy: proportion of hte plot entry containing the policy land use.
%   lu_nu: proportion of the plot entry not used. 
% ========================================================================
pl_lu = zeros(height(pl_pop),n_LuOpts); % land uses per plot entry
hhid_values = [OS_0.hhid]';

for i = 1:size(hh, 2)
   hhidx = hh(i).id;
   condition1 = pl_pop.hhid == hhidx;
   
   hhs = find(hh_list(:,1) == hhidx);
   hhs_0 = find(hh_list(hhs,3) == 0); % Do not participate
   hhs_1 = find(hh_list(hhs,3) ==  1); % Participate

   if ~isempty(hhs_0) % For all plots where household does not participate. 
       condition2 = ismember(pl_pop.hh_idn, hhs_0);
       OS = OS_0(find(hhid_values == hhidx));
       ptab = hh(find(hhid_values == hhidx)).plots; 
       np = OS.nplots;

       % extract optimal results for plots:
       lu_mat = reshape(OS.x_star.val(1:np*n_LuOpts),n_LuOpts,np)';
       lu_prop = lu_mat ./ ptab.ha; % proportion of plot per lu
       
       for p  = 1:np
           plot_number = ptab.plot_no(p);
           condition3 = pl_pop.plid == plot_number;
           final_condition = condition1 & condition2 & condition3;
           prow_idx = find(final_condition);
           pl_lu(prow_idx,:) = repmat(lu_prop(p,:),size(pl_lu(prow_idx,:),1),1);
       end
   end
   
   if ~isempty(hhs_1) %For all plots where household does participates. 
       condition2 = ismember(pl_pop.hh_idn, hhs_1);
       OS = OS_1(find(hhid_values == hhidx));
       ptab = hh(find(hhid_values == hhidx)).plots; 
       np = OS.nplots;

       % extract optimal results for plots:
       lu_mat = reshape(OS.x_star.val(1:np*n_LuOpts),n_LuOpts,np)';
       lu_prop = lu_mat ./ ptab.ha; % proportion of plot per lu
       
       for p  = 1:np
           plot_number = ptab.plot_no(p);
           condition3 = pl_pop.plid == plot_number;
           final_condition = condition1 & condition2 & condition3;
           prow_idx = find(final_condition);
           pl_lu(prow_idx,:) = repmat(lu_prop(p,:),size(pl_lu(prow_idx,:),1),1);
       end
   end
    
end

% add new variables to plot table
pl_pop.lu_cof = pl_lu(:,1);
pl_pop.lu_veg = pl_lu(:,2);
pl_pop.lu_ric = pl_lu(:,3);
pl_pop.lu_mix = pl_lu(:,4);
for lu = 1:(n_LuOpts - 4)
    field_name = sprintf('policyop%d', lu);
    pl_pop.(field_name) = pl_lu(:, lu + 4);
end
pl_pop.lu_nu = 1 - sum(pl_lu,2); % land not used
%
