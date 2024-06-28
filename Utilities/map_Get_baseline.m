function [map_outcomes] = map_Get_baseline(map_tab, V, lc_codes, n_LuOpts)
% ========================================================================
% ** IndoMod function **
% Returns maps of three key variables: erosion (E_map) , biomass 
%  carbon (C_map) and profit (V_map).
%
% These variables are calculated based on land use, land cover and slope of
%  map pixels. 
% INPUTS:
%   map_tab: table containing all the maps required by the model (each row
%            is one pixel).
%   V: NPV of land-use transitions of dimensions 4 x 4 x 3 representing
%      'from' land use, 'to' land use, slope. Originally obtained from
%      discounted cash flow data.
%   lc_codes: table of codes related to land cover, used to assign erosion
%             and carbon to each pixel. 
% ======================================================================== 
E_map = zeros(height(map_tab),1);
C_map = E_map;
V_map = E_map;
for i = 1 : n_LuOpts
    for j = 1 : 3
        idx = find(map_tab.lu == i & map_tab.slope == j);
        V_map(idx) = repmat(V(i,i,j), length(idx),1);
    end
end
Pf = ones(height(map_tab),1); %* practice factor
Cf = Pf * 0; %* cover factor
for i = 1 : height(lc_codes)
    Cf(map_tab.lcover==i) = lc_codes.c_fac(i);
    C_map(map_tab.lcover==i) = lc_codes.C_stock(i);
end
E_map = map_tab.R .* map_tab.K .* map_tab.LS .* Cf .* Pf;

map_outcomes = table(E_map, C_map, V_map, 'VariableNames', {'Emap_0', 'Cmap_0', 'Vmap_0'});


