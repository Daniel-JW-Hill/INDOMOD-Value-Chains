function [OS, LP] = lp_Solve(lu_trans_cf_new, hh, lpp,  n_LuOpts,farmer_transaction_costs, LP)
% ========================================================================
% ** IndoMod function **
% Creates LP models for a set of households 
% Solves the models using linprog (MATLAB function in Optimization Toolbox)
%
% Returns the optimal solution array of struct (OS) and the linear 
%  programming array of struct (LP)
%
% INPUTS:
%   dcf_file: name of file containing the discounted cash flow (DCF) data 
%             for all land-use transitions.
%   hh: array of household struct (hh_state).
%   lpp: LP parameters struct.
%   adjust: struct containing parameters used to adjust components of the 
%           DCF before running the LP. 
% ========================================================================

% If a LP structure is passed into the LP solve already, run the solver, 
 if nargin>5
    nhh = length(hh);
    for i = 1 : nhh
        lp = LP(i);
        [xopt,fval,exitflag,output,lambda]  = linprog(-lp.npv, lp.A, lp.b, lp.Aeq, lp.beq, lp.lb, lp.ub, lpp.options);
        OS(i,1) = lp_OS_pack(lp, xopt,fval,lambda);
        LP(i,1) = lp;
    end 
    %Exit function 
    return
 end

% Get data for state transitions by slope / land use 
[V,L,K,Le,Ke,Lo,Ko,t_est] = lp_Get_npv_mat(lu_trans_cf_new, lpp.r, lpp.w(3), n_LuOpts, farmer_transaction_costs); 
% 
% Solve LP model for all households in the sample
%
% Solves LP model for a set of households and returns the optimal solution
nhh = length(hh);
for i = 1 : nhh
    lp = lp_Get_hhmod(hh(i), V, Le, Ke, Lo, Ko,n_LuOpts);
    lp = lp_Lhire_add(lp, lpp.r, lpp.w, lpp.lc);
    lp = lp_Borrow_add(lp, lpp.r, lpp.credit); % allow borrow up to cred M IDR
    [xopt,fval,exitflag,output,lambda]  = linprog(-lp.npv, lp.A, lp.b, lp.Aeq, lp.beq, lp.lb, lp.ub, lpp.options);
    OS(i,1) = lp_OS_pack(lp, xopt,fval,lambda);
    LP(i,1) = lp;
end
%%