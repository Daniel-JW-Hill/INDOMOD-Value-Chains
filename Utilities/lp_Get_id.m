function [lp_id] = lp_Get_id(lp)
% 
% ========================================================================
% ** IndoMod function **
% Creates an index struct to map the variables and constraints present in 
% the household LP model lp. It is used by other functions that manipulate 
% the LP model.
%
% lp_id.x: refers to decision variables in the LP model (the columns of the A matrix).
% •	plots: vector of indexes for the LP variables representing plots (land-use transition columns).
% •	le_hire: index for variable representing labour hire for establishment.
% •	le_sell: index for variable representing labour sold during establishment phase.
% •	lo_hire: index for variable representing labour hire for operation.
% •	lo_sell: index for variable representing labour sold during operation phase.
% •	borrow_e: index for variable representing the borrowing decision during the establishment phase.
% •	borrow_o: index for variable representing the borrowing decision during the operation phase.
%
% lp_id.y: refers to constraints in the LP model 
%          (the rows of the A matrix).
% •	plots: vector of indexes for the LP constraints for plot area. 
% •	Le: index for constraint representing labour requirements for establishment. 
% •	Lo: index for constraint representing labour requirements for operation.  
% •	Ke: index for constraint representing capital requirements for establishment. 
% •	Ko: index for constraint representing capital requirements for operation.   
% •	le_hire_max: index for constraint limiting how much labour can be hired during establishment.
% •	le_sell_max: index for constraint limiting how much labour can be sold during establishment.
% •	lo_hire_max: index for constraint limiting how much labour can be hired during operation.
% •	lo_sell_max: index for constraint limiting how much labour can be sold during operation.
% •	credit_e: index for constraint limiting the credit available for establishment.
% •	credit_o: index for constraint limiting the credit available for operation.
% ========================================================================
[nc,nv] = size(lp.A); % n constraints, variables
% variables (x)
idx = [1:lp.nplots * 4]';
lp_id.x.plots = idx;
idx = [max(idx) + 1 : nv]';
for i = 1 : length(idx)
   eval(['lp_id.x.',char(lp.vnames(idx(i))),'= idx(i);']);
end
% constraints (y)
idy = [1:lp.nplots]';
lp_id.y.plots = idy;
idy = [lp.nplots+1 : nc]';
for i = 1 : length(idy)
   eval(['lp_id.y.',char(lp.cnames(idy(i))),'= idy(i);']);
end

