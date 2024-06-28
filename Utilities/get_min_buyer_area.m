function [pl_pop, min_buyer_area] = get_min_buyer_area(lu_trans_cf_new, pl_pop, buyer_parameters, P_f, Y_npv_buyer)
% ========================================================================
% ** IndoMod function **
% Determines the minimum area that the buyer requires per contracted
% household, weighted by the slope to accoutn for differing expected yields.
% 
% Note, even if the LP runs prevent contracting on certain slopes, this
% script does not need to change as the weights will be multiplied by a
% zero later on. 
% ========================================================================

r = buyer_parameters.discount_rate_buyer;
tmax = size(lu_trans_cf_new.lut_cf{1,1,1},2); % planning horizon
t = [0:tmax-1]';
df = (1+r).^-t; % discount factor starts at year 0

%Solve for minimum area the buyer is wlling to engage with for lu_0 = 5,     
% lu_1 = 5 and s = 3. This is our reference land size. 
yieldreference = lu_trans_cf_new.lut_cf{5,5,2}(end,:)/1e+6; % This represents the reference yield for the weights. 
yieldreference = yieldreference * df;

P_b = buyer_parameters.P_b;
C_bn = buyer_parameters.C_bn/1e+6;
C_by = buyer_parameters.C_by;

a_min = C_bn/((P_b - P_f - C_by)*yieldreference);

% Retrieve weights and reference yields for flat and moderate sloped land, depending on lu transition. 
weights = zeros(4,3); %4 initial lus, 3 slopes
for lu = 1:4
    for s = 1:3
    weights(lu,s) = Y_npv_buyer(lu,s) / yieldreference;
    end
end

% Set all plots in pl_pop that are below this threshold to ineligible
% Households can still choose to allocate only a proportion of their plot
% to contracting and this may fall below the minimum plot thresholds. 
% But including this constraint is not possible under a linear programming
% framework as the infeasible set is no longer convex. Intlinprog would
% work in this scenario but we lose some important results such as the
% current shadow price structure. 
% As plots may be spread over multiple pixels, we need to account for
% multple entries in the pl_pop structure. 
unique_hhs = unique(pl_pop.hhid);
for i = 1:size(unique_hhs,1)
    hh_idx = unique_hhs(i);
    unique_plots = unique(pl_pop(find(pl_pop.hhid == hh_idx),:).plid);
    n_plots = size(unique_plots,1);
    hh_instance = pl_pop(find(pl_pop.hhid == hh_idx & pl_pop.hh_idn == 1),:);
    for p  = 1:n_plots % calculate area for each plot based on the first hh instance and apply across all instances
        p_idx = unique_plots(p);
        hh_plot = hh_instance(find(hh_instance.plid == p_idx),:);
        lu = hh_plot.lu(1);
        slope = hh_plot.slope(1);
        min_area = 1/weights(lu,slope) * a_min;
        plot_area = sum(hh_plot.prop) * 0.09;
        if (plot_area < min_area)
           pl_pop.scenario_idx(find(pl_pop.hhid == hh_idx & pl_pop.plid == p_idx)) = 0;
        end    
    end
end

%Save in a structure as output for function
min_buyer_area.min_area = a_min; 
min_buyer_area.weights = weights; 

end


