function [E_map, E_pop, E_hh] = map_Get_Erosion(map_tab, hh_list, hh_pop, pl_pop, n_LuOpts,  Cfac) 
% ========================================================================
% ** IndoMod function **
% Returns map with erosion calculated based on optimal solution (os).
%
% E_map: vector of erosion rates on map (tonnes/pixel/yr)
% C_hh: vector of erosion rates by hh (tonnes/hh/yr)
%
% ========================================================================
% optimal land use:
lu_mat = table2array(pl_pop(:,(end-n_LuOpts):end));

Pf = ones(length(map_tab.lu),1); %* practice factor

C = lu_mat * Cfac'; % weighed C factor for plot
C = C .* pl_pop.prop; % C weighted by proportion of map cell in plot
%
[umi,im,iu] = unique(pl_pop.map_idx);
C_w = accumarray(iu,C);
map_tab.C1 = map_tab.C;
map_tab.C1(umi) = C_w; % change C for relevant cells on map

% Erosion for all map pixels on the landscape
E_map = map_tab.R .* map_tab.K .* map_tab.LS .* map_tab.C1 .* Pf;

% Erosion for plots managed by household on the landscape. 
E_pop = E_map(pl_pop.map_idx) .* pl_pop.prop;

% Erosion per household. 
% Here we allocate erosion per household instance - given they either
% participate or do not participate. 
E_hh = zeros(size(hh_list,1),1);
unique_hhs = unique(hh_list(:,1));
for i = 1:size(unique_hhs,1)
    hhidx = unique_hhs(i);
    hhs = find(hh_list(:,1) == hhidx);
    hhs_0 = find(hh_list(:,1) == hhidx & hh_list(:,3) == 0); % Do not participate
    hhs_1 = find(hh_list(:,1) == hhidx & hh_list(:,3) == 1); % Participate
    if ~isempty(hhs_0)
        hh_instance_0 = find(hhs == hhs_0(1));
        pl_rowidx = find(pl_pop.hhid == hhidx & pl_pop.hh_idn == hh_instance_0);
        E_hh(hhs_0) = sum(E_pop(pl_rowidx)) *0.09 ; % Also adjusts for hectares here.
    end
    
    if ~isempty(hhs_1)
        hh_instance_1 = find(hhs == hhs_1(1));
        pl_rowidx = find(pl_pop.hhid == hhidx & pl_pop.hh_idn == hh_instance_1);
        E_hh(hhs_1) = sum(E_pop(pl_rowidx)) *0.09 ; % Also adjusts for hectares here.
    end
   
end

% End of function. 



