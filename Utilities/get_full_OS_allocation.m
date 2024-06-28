function [hh_list, V_OS_1] = get_full_OS_allocation(hh_list, hh_pop, OS_0, OS_1, hh_state, sticky_parameter)
% ========================================================================
% ** IndoMod function **
% Creates a vector mapped to all household instances to determine which
% optimal solution is relevant for the houesholds.
% For ineligible households, OS_0 is chosen without a choice. 
% For eligible households, they choose between OS_0 and OS_1 based on the
% final npv. 
% If the household chooses to contract, the household is checked
% against whether it meets the minimum p hh level requirements from the
% buyer, if yes it progresses with OS_1, otherwise OS_0 is chosen as they
% determined to be ineligible based on their offer.
% We also retrieve the household npvs in this function as we already read
% them in from the loop.
% ========================================================================

V_OS_1 = zeros(size(hh_list,1),1);

for i = 1:size(hh_list,1)
    hh_idx = hh_list(i,1);
    OS_reference = find(hh_pop.hhid == hh_idx);
    if hh_list(i,2) == 0 % If determined ineligible based on location of hh on the map or from other criteria.  
            hh_list(i,3) = 0;
            V_OS_1(i) = OS_0(OS_reference).npv;  % note OS_0 and OS_1 will be the same for this cohort anyway
    elseif hh_state(OS_reference).eligible == 0 % if determined ineligible before farmer offer due to a_min or other constraint. 
            hh_list(i,2) = 0; % change eligibility, previously only defined by villages only.  
            hh_list(i,3) = 0;
            V_OS_1(i) = OS_0(OS_reference).npv; % note OS_0 and OS_1 will be the same for this cohort anyway
    elseif OS_1(OS_reference).eligible == 0 %If determined ineligible by the buyer given the area contracted. 
        hh_list(i,3) = 0;
        V_OS_1(i) = OS_0(OS_reference).npv;
    elseif OS_0(OS_reference).npv >= OS_1(OS_reference).npv %If the household chooses to opt out of contracting due to high upfront costs.  
        hh_list(i,3) = 0;
        V_OS_1(i) = OS_0(OS_reference).npv;
    else 
        random_draw = rand;
        if random_draw >= (1-sticky_parameter)
            hh_list(i,3) = 1; % Otherwise, choose OS_1 which will mean contracting. 
            V_OS_1(i) = OS_1(OS_reference).npv;
        else
            hh_list(i,3) = 0;
            V_OS_1(i) = OS_0(OS_reference).npv;
        end
 
    end 
end
