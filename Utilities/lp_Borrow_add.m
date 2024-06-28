function [lp] = lp_Borrow_add(lp, r, cred)
% ========================================================================
% ** IndoMod function **
% Used to expand an existing LP model.
% Takes lp model struct and expands matrices to allow borrowing
%  (at rate r per year). Returns expanded model.
%  
%    lp: LP struct for an individual household containing the matrices and
%        vectors required by linprog function.
%    r: the discount rate
%    cred: (1x2) are rhs constraints that limit the amount of credit 
%          available for establishment and operation phases
%  Calls embedded function ExpandLP
%
%  Note: ** This function is specific to a 20-year planning horizon (Tmax) 
%        it needs to be more general by passing Tmax as an argument.
% ========================================================================
% 
[lp] = ExpandLP(lp, r, cred(1), 1); % establishment phase
%
[lp] = ExpandLP(lp, r, cred(2), 0); % establishment phase
%
end 
%====================================================================
function [lp] = ExpandLP(lp, r, cred, est)
    if est == 1
        names{1,1} = 'borrow_e';
        names{2,1} = 'credit_e';
        lp.npv = [lp.npv, -r]; % objective coeff
    else
        names{1,1} = 'borrow_o';
        names{2,1} = 'credit_o';
        % include present value of capital
        % ** this is the code that needs attention:
        df = (1+r) .^ (-[1:19]);  
        % expand objective function vector:
        lp.npv = [lp.npv, -sum(df)]; 
        % old version
        % lp.npv = [lp.npv, -r * (1+r)^-1]; % objective coeff
    end
    id = lp_Get_id(lp);
    % new objective coefficient  
    nvar = length(lp.npv);
    % add new column and row of zeros
    lp.A = [lp.A, lp.A(:,1) * 0];
    lp.A = [lp.A; lp.A(1,:) * 0];
    %
    ncon = size(lp.A,1);
    lp.A(ncon,nvar) = 1;
    if est
        lp.A(id.y.Ke, nvar) = -1; % feed borrowed K into Ke row
    else
        lp.A(id.y.Ko, nvar) = -1; % feed borrowed K into Ko row
    end
    %
    lp.b = [lp.b; cred];
    %
    lp.lb(nvar) = 0;
    lp.ub(nvar) = inf;
    %
    lp.vnames{nvar} = names{1};
    lp.cnames{ncon} = names{2};
end    
