function [lp] = lp_Get_hhmod(hh, V, Le, Ke, Lo, Ko, n_LuOpts)
% ========================================================================
% ** IndoMod function **
% Returns the basic LP model for a single household based on the number 
%    and types of plots it manages.
% The lp struct contains all the components of the LP model 
% it includes L and K constraints for establishment and operation phases.
% ========================================================================
%
nplots = height(hh.plots);
V_plot = zeros(1,nplots * n_LuOpts); 
A_plot = zeros(nplots,nplots * n_LuOpts);
Le_plot = zeros(1,nplots * n_LuOpts); % establishment
Ke_plot = zeros(1,nplots * n_LuOpts); 
Lo_plot = zeros(1,nplots * n_LuOpts); % operation
Ko_plot = zeros(1,nplots * n_LuOpts); 
b = zeros(nplots + 4,1); % constraint rhs
c1 = 1; % column to enter data
vcount = 1;
for i = 1 : nplots
    c2 = c1 + n_LuOpts-1;
    slope = hh.plots.slope(i);
    lu = hh.plots.lu_type(i);
    V_plot(c1:c2) = V(lu,:,slope);
    % labour and capital constraint rows
    Le_plot(c1:c2) = Le(lu,:,slope);
    Lo_plot(c1:c2) = Lo(lu,:,slope);
    Ke_plot(c1:c2) = Ke(lu,:,slope);
    Ko_plot(c1:c2) = Ko(lu,:,slope);
    % coeffs for area constraint
    A_plot(i,c1:c2) = 1;
    c1 = c2+1;
    b(i) = hh.plots.ha(i); 
    for x = 1:n_LuOpts
    x_name{vcount + (x-1)} = sprintf('p%1.0f_%1.0f_%d',i, hh.plots.lu_type(i),x);
    end 
    vcount = vcount + n_LuOpts;
    y_name{i} = sprintf('p%1.0f',i);
end
y_name{i+1} = 'Le';
y_name{i+2} = 'Lo';
y_name{i+3} = 'Ke';
y_name{i+4} = 'Ko';
% constraint vector
b(nplots+1) = hh.L; % labour constraint in est.
b(nplots+2) = hh.L; % labour constraint in op
b(nplots+3) = max(hh.K - hh.D, 0); % capital constraint
b(nplots+4) = max(hh.K - hh.D, 0); % capital constraint
% package lp model
lp.hhid = hh.id;
lp.vnames = x_name';
lp.cnames = y_name';
lp.npv = V_plot;
lp.A = [A_plot; Le_plot; Lo_plot; Ke_plot; Ko_plot]; % matrix of tech coeff 
lp.b = b; % rhs 
lp.Aeq = []; 
lp.beq = [];
[nc,nv] = size(lp.A); % n constraints, variables
lp.lb = zeros(nv,1);
lp.ub = ones(nv,1) .* inf;
lp.nplots = nplots;
%

