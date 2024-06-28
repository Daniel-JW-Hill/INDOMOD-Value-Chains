function [LP] = lp_SetConstraints_EligibleLand(LP, hh_state, pl_pop, lu_trans_cf_new, lp_parm,  n_LuOpts, farmer_transaction_costs)
% =======================================================================
   % This script changes the LP structure to run OS_1 - which gives the
   % optimal solution for all households if they are eligible for the
   % policy scenario. 
  
% =======================================================================
% First determine the eligible land uses
eligible_idx = find(pl_pop.scenario_idx == 1);
target_hhid = unique(pl_pop.hhid(eligible_idx));

%Retrieve npv mat for this scenario. This may be the same as before as only prices may change.  
[V,L,K,Le,Ke,Lo,Ko,t_est] = lp_Get_npv_mat(lu_trans_cf_new, lp_parm.r, lp_parm.w(3),  n_LuOpts, farmer_transaction_costs); 

% Now for each eligible household, reconstruct the LP matrix to match new
% scenario. 
% If a household is not part of the target population, the LP function
% remains the same between model runs. 

%First strip out any households not deemed to be eligible at a household
%level. 
target_hhid_new = [];
for i = 1:length(target_hhid)
    ihh = target_hhid(i);
    hh = hh_state(find(vertcat(hh_state.id) == ihh));
    if hh.eligible == 1
        target_hhid_new = [target_hhid_new, ihh];
    end
end

for i = 1:length(target_hhid_new)
    
    %Find relevant data structures and ids for the household
    ihh = target_hhid_new(i);
    ii = (find(vertcat(LP.hhid) == ihh));
    lp = LP(ii); 
    hh = hh_state(find(vertcat(hh_state.id) == ihh));
 
    %change credit for eligible plots, if credit scenario chosen. 
    LP(ii).b(end-1:end) = lp_parm.credit;

    % Find eligible plots for the household
    % Depending on the scenario this may be all plots
    % Subset plot population for the given household 
    % where the scenario index is equal to 1
    idy = unique(pl_pop.plid(find(pl_pop.hhid == ihh & pl_pop.scenario_idx == 1)));
   
    %Number of total plots (important for indexing in LP matrix. 
    np_total = lp.nplots;
    
    % Change LP technical coefficients for eligible plots.
    c1 = 1; % column to enter data
    for pp = 1 : np_total
        c2 = c1 + n_LuOpts-1;
        if ~ismember(pp, idy) 
            %if the plot is not an eligible plot, move indexes along and
            %maintain the original LP structure for the plot. 
            %Continue looping over all plots
            c1 = c2+1;
        continue  
        end
         %If an eligible plot:
         slope = hh.plots.slope(pp);
         lu = hh.plots.lu_type(pp);
         % Retrieve new NPVs for the plot
         LP(ii).npv(c1:c2) = V(lu,:,slope);
         % Retrieve new labour and capital constraint rows
         LP(ii).A(find(lp.cnames=="Le"),(c1:c2)) = Le(lu,:,slope);
         LP(ii).A(find(lp.cnames=="Lo"),(c1:c2)) = Lo(lu,:,slope);
         LP(ii).A(find(lp.cnames=="Ke"),(c1:c2)) = Ke(lu,:,slope);
         LP(ii).A(find(lp.cnames=="Ko"),(c1:c2)) = Ko(lu,:,slope);
         %keep counter moving for next plots
         c1 = c2+1;
    end
end

