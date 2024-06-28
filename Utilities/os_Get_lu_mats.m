function [lu_0, lu_1, lu_nu] = os_Get_lu_mats(pl_pop, n_LuOpts)
% ========================================================================
% ** IndoMod function **
% Returns Initial and Optimal land use matrices by slope / land use.
%
% The units of lu_i are ha under each land use (columns) for each slope
% type (rows).
%     slope (flat, moderate, steep).
%     land use (coffee, vegs, rice, mixed) 
% INPUTS:
%  OS : optimal solution struct
%  hh : household state struct 
%  pl_pop : table of all plots managed by the farmer population 
%
% OUTPUTS: 
%  lu_0 : Initial land use matrix (ha)
%  lu_1 : Optimal land use matrix (ha)
%  lu_nu : ha of land not used under optimal solution, vector 3x1 
% ========================================================================
% add optimal land use to pl_pop table
lu_opt = table2array(pl_pop(:,(end-n_LuOpts):end)) .* pl_pop.prop;
for i = 1:3
    idx = find(pl_pop.slope==i);
    for j = 1:n_LuOpts+1
        lu_1(i,j) = sum(lu_opt(idx,j));
    end
end
%
for i = 1:3
    for j = 1:n_LuOpts
        idx = find(pl_pop.slope==i & pl_pop.lu==j);
        lu_0(i,j) = sum(pl_pop.prop(idx));
    end
end
lu_1 = lu_1 * .09; % in ha
lu_0 = lu_0 * .09;
% 
lu_nu = lu_1(:,n_LuOpts+1); % not used
lu_1 = lu_1(:,1:n_LuOpts); 
%
%%