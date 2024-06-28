function [C_map, C_pop, C_hh] = map_Get_Cstock(map_tab, hh_list, hh_pop, pl_pop, lc_codes, n_LuOpts, C_lu) 
% ========================================================================
% ** IndoMod function **
% Returns map with biomass carbon stock changed based on optimal solution 
%   (os).
%
% C_map: vector of biomass carbon on map (tonnes/pixel)
% C_hh: vector of biomass carbon per hh (tonnes/hh)
%
% ========================================================================
% optimal land use:
lu_mat = table2array(pl_pop(:,(end-n_LuOpts):end));

% insert C stock in map
C_map = map_tab.lu*0;
for i = 1 : height(lc_codes)
    idx = find(map_tab.lcover == lc_codes.id(i));
    C_map(idx) = lc_codes.C_stock(i);
end

Cstock = lu_mat * C_lu'; % weighed C stock for plot
Cstock = Cstock .* pl_pop.prop; % Cstock weighed by proportion of map cell in plot
[umi,im,iu] = unique(pl_pop.map_idx);
C_w = accumarray(iu,Cstock); % in C stock/ha for each pixel
C_map(umi) = C_w; % change C for relevant cells on map 

% Retrieve carbon stock for plots managed by households. 
C_pop = C_map(pl_pop.map_idx);

%Carbon per household. 
C_hh = zeros(size(hh_list,1),1);
unique_hhs = unique(hh_list(:,1));
for i = 1:size(unique_hhs,1)
    hhidx = unique_hhs(i);
    hhs = find(hh_list(:,1) == hhidx);
    hhs_0 = find(hh_list(:,1) == hhidx & hh_list(:,3) == 0); % Do not participate
    hhs_1 = find(hh_list(:,1) == hhidx & hh_list(:,3) == 1); % Participate
    if ~isempty(hhs_0)
        hh_instance_0 = find(hhs == hhs_0(1));
        pl_rowidx = find(pl_pop.hhid == hhidx & pl_pop.hh_idn == hh_instance_0);
        C_hh(hhs_0) = sum(C_pop(pl_rowidx)) *0.09 ; % Also adjusts for hectares here.
    end
    
    if ~isempty(hhs_1)
        hh_instance_1 = find(hhs == hhs_1(1));
        pl_rowidx = find(pl_pop.hhid == hhidx & pl_pop.hh_idn == hh_instance_1);
        C_hh(hhs_1) = sum(C_pop(pl_rowidx)) *0.09 ; % Also adjusts for hectares here.
    end
   
end

% End of function. 

