function OS = lp_fixed_trans_costs_add(OS, farmer_transaction_costs, a_min_buyer, hh_state, Y_npv_buyer, buyer_parameters, P_f)
% ========================================================================
% ** IndoMod function **
% Adds fixed transaction costs to optimal solution if they contract. 
% As these are fixed costs, they do not influence the household decision. 
% But this is the simplest approach to adjusting the hh returns from a land
% use, in which households can make a binary decision between the non-contracting 
% and contracting optimal solutions. 

%In this script, we also check if the household is eligible based on
% minimum expected yields. 
% Output - OS - updated npv for each household
% ========================================================================
P_b = buyer_parameters.P_b;
C_bn = buyer_parameters.C_bn/1e+6;
C_bf = buyer_parameters.C_bf/1e+6;
C_by = buyer_parameters.C_by;

for i = 1:size(OS,1)
 OS(i).eligible = 0;   
 nplots = OS(i).nplots;
 a_contracted_weighted = 0;
 n_contracted_plots = 0;
 y_contracted = 0;
 for p = 1:nplots
   initial_lu = hh_state(:,i).plots.lu_type(p);
   slope = hh_state(:,i).plots.slope(p);
   a_contracted_weighted =  OS(i).x_star{5*p,2} * (1/a_min_buyer.weights(initial_lu,slope)) + a_contracted_weighted; 
   if OS(i).x_star{5*p,2} > 0 %calculate farmer yields and plots, discounted at buyer discount rate. 
      n_contracted_plots =  n_contracted_plots + 1 ; 
      initial_lu = hh_state(i).plots.lu_type(p);
      slope =  hh_state(i).plots.slope(p);
      y_contracted = Y_npv_buyer(initial_lu,slope) * OS(i).x_star{5*p,2} + y_contracted;
   end
 end
  
 if a_contracted_weighted > 0
     OS(i).npv = OS(i).npv - farmer_transaction_costs.c_ff/1e+6;
 end

 % Now flag if household is eligible for contracting based on area offered.
     farm_level_profits = P_b*y_contracted  - P_f*y_contracted  - C_by*y_contracted - C_bn * n_contracted_plots - C_bf;
     if farm_level_profits >= 0
         OS(i).eligible = 1;
     end
   
 end
 
end
