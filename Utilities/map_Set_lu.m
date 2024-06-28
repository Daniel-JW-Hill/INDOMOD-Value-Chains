function [map] = map_Set_lu(map, pl_pop, lc_codes)
% ========================================================================
% ** IndoMod function **
% Returns map table as the original map  adjusted based on land uses for 
%  map pixels according to the land uses in plot population pl_pop. 
% The erosion C factor and biomass carbon stocks are also updated in map. 
%
% Note: because LU is a discrete variable and hh plots are spread over 
% portions of pixels, lu is updated based on the mode rather than the sum
% so each pixel is assigned its most common land use 
% ========================================================================
[umi,im,iu] = unique(pl_pop.map_idx);
LU_w = accumarray(iu,pl_pop.lu,[],@mode); 
%
LU_map = map.lu;
LU_map(umi) = LU_w; % change lu for relevant cells on map 
map.lu = LU_map; % new land use becomes mode for plots related to pixels
%
% ---------  get codes from land cover table
lcc = zeros(1,4); % land cover code
cfac = zeros(1,4); % erosion C factor
cstock = zeros(1,4); % carbon stock
for i = 1:4 % land uses
    idx = find(lc_codes.lu_code == i);
    lcc(i) = idx;
    cfac(i) = lc_codes.c_fac(idx);
    cstock(i) = lc_codes.C_stock(idx);
end
% ---------------------- update land cover 
for i = 1:4
    idx = find(map.lu == i);
    map.lcover(idx) = lcc(i);
end
% ---------------------- update weighed factors 
Cfac = zeros(height(pl_pop),1);
Cstock = zeros(height(pl_pop),1);
for i = 1:4
    idx = find(pl_pop.lu == i);
    Cfac(idx) = cfac(i);
    Cstock(idx) = cstock(i);
end
% weighed variables by proportion of map cell in plot
Cfac = Cfac .* pl_pop.prop; 
Cstock = Cstock .* pl_pop.prop; 
% accumulate by map_idx
Cfac_w = accumarray(iu,Cfac);
Cstock_w = accumarray(iu,Cstock);
map.C(umi) = Cfac_w; % change C for relevant cells on map
map.C_stock(umi) = Cstock_w; % change Cstock for relevant cells on map

