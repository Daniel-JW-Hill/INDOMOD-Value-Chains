function [pl_pop] = Get_map2pl(pl_pop, hh_state)
% ========================================================================
% ** IndoMod function **
% Creates new variables in pl_plots table to give more information about
% plot level information consistent across all instances of a given
% household - tenure and soil conservation. This helps determine plot
% eligibility for the policy. 
% Note we can already retrieve slope and lu characterstics from pl_pop. 
% ========================================================================
%Add variable indicating plots that are owned 
%and variable indicating plots with soil conservation
tenure_idx = array2table(zeros(size(pl_pop,1), 1));
pl_pop = [pl_pop tenure_idx];
pl_pop.Properties.VariableNames("Var1") = "Tenure_idx";
soilcons_idx = array2table(zeros(size(pl_pop,1), 1));
pl_pop = [pl_pop soilcons_idx];
pl_pop.Properties.VariableNames("Var1") = "SoilCons_idx";

for  h =1:height(hh_state) 
        hidx = hh_state(h).id;
        np = hh_state(h).nplots;
        for j = 1 : np
            pl_tenure = hh_state(h).plots.tenure(j);
            pl_soilcons = hh_state(h).plots.cons_prac(j);
            pl_pop.Tenure_idx(find(pl_pop.hhid == hidx & pl_pop.plid == j)) = pl_tenure;
            pl_pop.SoilCons_idx(find(pl_pop.hhid == hidx & pl_pop.plid == j)) = pl_soilcons;
        end
end 

%Create scenario vector which will be used to indicate whether the plot is
%eligible for the experiment or not. 
scenario_idx = array2table(zeros(size(pl_pop,1), 1));
pl_pop = [pl_pop scenario_idx];
pl_pop.Properties.VariableNames("Var1") = "scenario_idx";

end

