function [lp] = lp_Lhire_add(lp, r, w, lc)
% ========================================================================
% ** IndoMod function **
% Takes an lp model struct for a farm houshold and expands matrices to 
%   allow labour hiring (at wage w(1) per day) 
%   and selling (at wage w(2) per day).
% Returns updated lp model.
%  INPUTS
%    lp: LP struct for an individual household containing the matrices and
%        vectors required by linprog function.
%    r: the discount rate
%    w: the 
%    lc: (1x2) vector of rhs constraints that limit the amount of labour 
%        that can be hired or sold, expressed as a proportion of the 
%        household labour available.
%  Calls embedded function ExpandLP
%
%  Note: ** This function is specific to a 20-year planning horizon (Tmax) 
%        it needs to be more general by passing Tmax as an argument.
% ========================================================================
[lp] = ExpandLP(lp, w, lc, r, 1); % establishment phase
%
[lp] = ExpandLP(lp, w, lc, r, 0); % operation phase
%
end 
%====================================================================
function [lp] = ExpandLP(lp, w, lc, r, est)
 Tmax = 20;
    if est == 1
        names{1,1} = 'le_hire';
        names{1,2} = 'le_sell';
        names{2,1} = 'le_hire_max';
        names{2,2} = 'le_sell_max';
    else
        names{1,1} = 'lo_hire';
        names{1,2} = 'lo_sell';
        names{2,1} = 'lo_hire_max';
        names{2,2} = 'lo_sell_max';
    end

    id = lp_Get_id(lp);
    % expand objective function vector for establishment phase
    if est
        lp.npv = [lp.npv, -w(1), w(2)];
    else
        % ** this is the code that needs attention:
        df = (1+r) .^ (-[1:(Tmax-1)]);  
        wr = repmat([-w(1),w(2)], (Tmax-1),1);
        w_disc =  df * wr; % discounted labour
        % expand objective function vector:
        lp.npv = [lp.npv, w_disc]; 
        % old version:
        % lp.npv = [lp.npv,[-w(1), w(2)]*(1+r)^-1];
    end
    nvar = length(lp.npv);
    % add new column and row of zeros
    [nc,nv] = size(lp.A); % n constraints, variables
    a_col = zeros(nc, 2);
    lp.A = [lp.A, a_col];
    nv = nv + 2;
    a_row = zeros(2,nv);
    lp.A = [lp.A; a_row];
    nc = nc + 2;
    % insert coefficients:
    if est == 1
        lp.A(id.y.Le, nv-1) = -1; % feed into labour row
        lp.A(id.y.Le, nv) = 1; % take from labour row to sell
        lp.A(id.y.Ke, nv-1) = w(1); % cost of labour hire in K row
        lp.A(id.y.Ke, nv) = -w(2); % supply K from labour sold
        lc = lc .* lp.b(id.y.Le); % hh labour available
    else
        lp.A(id.y.Lo, nv-1) = -1; % feed into labour row
        lp.A(id.y.Lo, nv) = 1; % take from labour row to sell
        lp.A(id.y.Ko, nv-1) = -w_disc(1)/(Tmax-1); % annual cost of labour hire in K row
        lp.A(id.y.Ko, nv) = -w_disc(2)/(Tmax-1); % supply K from labour sold
        lc = lc .* lp.b(id.y.Lo); % hh labour available
    end
    %
    lp.A(nc-1,nv-1) = 1;
    lp.A(nc,nv) = 1;
    % lc has been converted to person days
    lp.b = [lp.b; lc(1); lc(2)]; %  add new constraints to rhs
    %
    lp.lb = [lp.lb; 0; 0];
    lp.ub = [lp.ub; inf; inf];
    %
    lp.vnames{nvar-1} = names{1,1};
    lp.vnames{nvar} = names{1,2};
    %
    lp.cnames{nc-1} = names{2,1};
    lp.cnames{nc} = names{2,2};

end