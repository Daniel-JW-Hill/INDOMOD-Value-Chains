function [V_OS_0]= os_get_hh_NPV(OS_0, hh_list, hh_pop)
% ========================================================================
% ** IndoMod function **
% Returns household npvs for all household instances for comparison with
% policy option.
% ========================================================================
V_OS_0 = zeros(size(hh_list,1),1);

for i = 1:size(hh_list,1)
   hh_idx = hh_list(i,1);
   OS_reference = find(hh_pop.hhid == hh_idx);
   V_OS_0(i) = OS_0(OS_reference).npv;
end