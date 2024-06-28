function [hh_state] = Get_eligible_hhs(a_min_buyer, hh_tab, hh_state, eligible_struct)

% ========================================================================
% ** IndoMod function **
% Returns eligible household flags in the hh_state structure. 
% This is based on criteria such as total landholdings, education, risk
% taking and social member
% ========================================================================

% First assume all households are eligible
eligible_hh_flag = ones(size(hh_tab,1),1);

% Check if each criteria is turned on and change to ineligible if
% applicable. 

% flag indicates minimum education of household head to be eligible.
if eligible_struct.hh.edu_head > 0  
    eligible_hh_flag(find(hh_tab.edu_head < eligible_struct.hh.edu_head)) = 0;
end 

%flag indicates the minimum education for either spouse or hh head.
if eligible_struct.hh.edu_min> 0  
    max_educ = max([hh_tab.edu_head hh_tab.edu_spouse], [],2);
    eligible_hh_flag(find(max_educ < eligible_struct.hh.edu_min)) = 0;
end 

% flag indicates only risk taking households will participate. 
if eligible_struct.hh.risk_takin == 0 
    eligible_hh_flag(find(hh_tab.risk_takin == 0)) = 0;
end 

% flag indicates only households in social networks will participate.
if eligible_struct.hh.soc_memb_a == 0  
    eligible_hh_flag(find(hh_tab.soc_memb_n == 0)) = 0;
end 

% flag indicates those below a maximum distance from market in metres will participate.
if eligible_struct.hh.dist_market_mtr > 0  
    eligible_hh_flag(find(hh_tab.dist_market_mtr > eligible_struct.hh.dist_market_mtr)) = 0;
end 

% Now we determine whether the household meets minimum land holding
% criteria, assuming all land can be converted to the policy option. We
% repeat this after optimisation where households may not convert
% sufficient land under their optimum conditions. 
for i = 1:numel(hh_state)
     nplots = hh_state(i).nplots;
     a_contracted_weighted = 0;
     for p = 1:nplots
       initial_lu = hh_state(:,i).plots.lu_type(p);
       slope = hh_state(:,i).plots.slope(p);
       plot_size = hh_state(:,i).plots.ha(p);
       a_contracted_weighted =  plot_size * (1/a_min_buyer.weights(initial_lu,slope)) + a_contracted_weighted; 
     end
       
      if a_contracted_weighted < a_min_buyer.min_area
         eligible_hh_flag(i) = 0;
     end 
   
end

for i = 1:numel(hh_state)
    hh_state(i).eligible = eligible_hh_flag(i);
end
% End of function