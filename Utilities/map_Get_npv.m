function [V_map, V_pop, V_hh] = map_Get_npv(pl_pop, hh_list, hh_pop, V, V_base, n_LuOpts) 
% ========================================================================
% ** IndoMod function **
% Returns map with NPV calculated based on optimal solution (os).
%
% V_map: vector of NPV on entire map 
% V_pop: Vector of npv for household plots
% V_hh: vector of NPV by hh from farm production. (all in millions/rupiah)
% ========================================================================

% optimal land use:
lu_mat = table2array(pl_pop(:,(end-n_LuOpts):end));
lu_val = lu_mat * 0;
% get values for each pixel based on lu and slope
for i = 1 : n_LuOpts
    for j = 1 : 3
        idx = find(pl_pop.lu == i & pl_pop.slope == j);
        lu_val(idx,1: n_LuOpts) = repmat(V(i,:,j), length(idx),1);
    end
end

V_map = V_base; 
pix_val = sum(lu_mat .* lu_val, 2) .* pl_pop.prop; % npv per ha 
[umi,im,iu] = unique(pl_pop.map_idx);
V_w = accumarray(iu,pix_val); % NPV/ha for each pixel
V_map(umi) = V_w; % change NPV for relevant cells on map 

% Retrieve the npv per plot in pl_pop. 
V_pop = V_map(pl_pop.map_idx) .* pl_pop.prop;

% NPV per household (for farm plots only). 
V_hh = zeros(size(hh_list,1),1);
unique_hhs = unique(hh_list(:,1));
for i = 1:size(unique_hhs,1)
    hhidx = unique_hhs(i);
    hhs = find(hh_list(:,1) == hhidx);
    hhs_0 = find(hh_list(:,1) == hhidx & hh_list(:,3) == 0); % Do not participate
    hhs_1 = find(hh_list(:,1) == hhidx & hh_list(:,3) == 1); % Participate
    if ~isempty(hhs_0)
        hh_instance_0 = find(hhs == hhs_0(1));
        pl_rowidx = find(pl_pop.hhid == hhidx & pl_pop.hh_idn == hh_instance_0);
        V_hh(hhs_0) = sum(V_pop(pl_rowidx)) *0.09 ; % Also adjusts for hectares here.
    end
    
    if ~isempty(hhs_1)
        hh_instance_1 = find(hhs == hhs_1(1));
        pl_rowidx = find(pl_pop.hhid == hhidx & pl_pop.hh_idn == hh_instance_1);
        V_hh(hhs_1) = sum(V_pop(pl_rowidx)) *0.09 ; % Also adjusts for hectares here.
    end
   
end

% End of function. 





