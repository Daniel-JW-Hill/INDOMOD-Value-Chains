function [map_lu, lu_map_mat] = map_LU_opt(map, pl_pop)
% ========================================================================
% ** IndoMod function **
% Returns land-use map map_lu as a vector of land-use codes for each 
%  pixel on the map. 
%
% The results are based on the land use transitions in the optimal 
%  solution (OS).
%
% Note that the mode is used to assign land use to a pixel. This is needed 
%  because of fractional pixel assignment to plots. So each pixel is 
%  assigned its most common land use 
% ========================================================================

plp = pl_pop;

% retrieve optimal land uses from agricutlural plots. 
lu_mat = [plp.lu_cof, plp.lu_veg, plp.lu_ric, plp.lu_mix, plp.policyop1, plp.lu_nu];

% Assign maximum LU proportion to plot
[m,mi] = max(lu_mat,[],2);
lu_opt = mi; 

[umi,im,iu] = unique(pl_pop.map_idx);
LU_w = accumarray(iu,lu_opt,[],@mode); %finds the mode land use for each map pixel in pl_pop

% create pl_pop x and y dataframe with associated land use
map_idx = umi;
x = map.x(umi);
y = map.y(umi);
lu = LU_w;
lu_map_mat = table(map_idx, x, y, lu);

% Update map tab 
LU_map = map.lu;
LU_map(umi) = LU_w; % change lu for relevant cells on map 
map_lu = LU_map;

% end of function






