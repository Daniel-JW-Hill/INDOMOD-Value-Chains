function [os] = lp_OS_pack(lp, xopt, fval, lambda)
% ========================================================================
% ** IndoMod function **
% Packs the LP optimal solution into a struct (os) for a household, where 
%  the fields of os are different components of the optimal solution.  
%
% INPUTS:
%  lp: the lp model (struct) for a farm household   
%  xopt: optimal decision vector*
%  fval: objective function result*
%  lambda: dual values (shadow prices)*
% * outputs from running linprog
% ========================================================================
%
    os.hhid = lp.hhid;
    os.nplots = lp.nplots;
    os.npv = -fval;
    os.x_star = table(lp.vnames, 'VariableNames',{'var'});
    os.x_star.val = xopt;
    os.x_star.rcost = lambda.lower;
    %
    os.y_star = table(lp.cnames, 'VariableNames',{'constraint'});
    os.y_star.val = lp.A * xopt; 
    os.y_star.rhs = lp.b; 
    os.y_star.shadp = lambda.ineqlin;
end
