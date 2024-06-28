function [lpp, lu_trans_cf_new] = lp_Parm_default(r, credit, w1, w2, lu_trans_cf_new)
% ========================================================================
% ** IndoMod function **
% Returns default parameters for an LP problem (lpp) and an adjustment
%  parameter(adjust) to modify the discounted cash flow model values 
%  contained in file dcf_file.
%
%  r is the discount rate
% ========================================================================
    lpp.r = r; % discount rate (MIDR)
    lpp.credit = credit;  % credit limit establishment, operation
    lpp.w(1) = w1; % labour hire wage (MIDR)
    lpp.w(2) = w2; % labour sell wage
    lpp.w(3) = 0; % hh labour wage for K constraint
    % labour constraints as proportion of hh L
    lpp.lc(1) = 0.5; 
    lpp.lc(2) = 0.5; 
    lpp.options = optimoptions('linprog','Algorithm','dual-simplex');

    % Adjust the 'adjust' structure to create a preference weight for land
    % uses on different slopes. 
    % This is used to calibrate the model to match observed landscape
    % outcomes.
    % Preferences are attached to prices to facilitate calculation -
    % meaning weights are held consistent against certain crop ouputs
    % rather than landuse combinations.
    lu_trans_cf_new.adjust.Pref_weights = [1.8 1.8 1;
                           0.9 0.9 0.9;
                           1 1 1;
                           1 1 1;
                           1.5 1.5 1.5;
                           1.8 1.8 1];
 
end % function
