function [hh_outcomes] = map_Convert2_hh(E_map, C_map, V_map, pl_pop, hh_pop, hh_list)
% ========================================================================
% ** IndoMod function **
% Converts maps to hh dimension based on table pl_pop
% INPUTS:
%   E_map: erosion map vector, each row is a pixel.
%   C_map: biomass carbon map vector, each row is a pixel.
%   V_map: NPV map vector, each row is a pixel.
%   pl_pop: table to map plots managed by hh population to pixels 
%           on the map. 
%   hh_pop: Table listing the number of instances of each hh type in the 
%           full population.
% OUTPUTS:
%   E_hh: Erosion vector, each row is a hh.
%   C_hh: biomass carbon vector, each row is a hh.
%   V_hh: NPV vector, each row is a hh.
% ======================================================================== 
% Get indexes for accumulating by hh
[umi,im,iu] = unique(pl_pop.hhid);
% Erosion
E_pop = E_map(pl_pop.map_idx) .* pl_pop.prop;
E_hh = accumarray(iu,E_pop); % NPV per hh
E_hh = (E_hh * 0.09)./ hh_pop.hhn; % actual erosion per hh
% Carbon stock
C_pop = C_map(pl_pop.map_idx) .* pl_pop.prop;
C_hh = accumarray(iu,C_pop); % NPV per hh
C_hh = (C_hh * 0.09)./ hh_pop.hhn; % actual C stock per hh
% NPV
V_pop = V_map(pl_pop.map_idx) .* pl_pop.prop;
V_hh = accumarray(iu,V_pop); % NPV per hh
V_hh = (V_hh * 0.09)./ hh_pop.hhn; % actual NPV per hh

% Now for this to be comparable after the policy run we must repeat
% outcomes for all household instances
Ehh_0 = zeros(size(hh_list,1),1);
Chh_0 = Ehh_0;
Vhh_0 = Ehh_0;

for i = 1:size(hh_list,1)
    hhidx = hh_list(i,1);
    row_idx = find(hh_pop.hhid == hhidx);
    Ehh_0(i) = E_hh(row_idx);
    Chh_0(i) = C_hh(row_idx);
    Vhh_0(i) = V_hh(row_idx);
end
hh_outcomes = table(Ehh_0, Chh_0, Vhh_0, 'VariableNames', {'Ehh_0', 'Chh_0', 'Vhh_0'});

