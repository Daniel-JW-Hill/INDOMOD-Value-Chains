function [vil_clusters, offered_price, hh_list] = get_eligible_villages(vil_clusters, hh_list, buyer_parameters)

% Reset parameters
P_b = buyer_parameters.P_b - buyer_parameters.C_by; %net price of coffee without farmer price. 
C_n = buyer_parameters.C_bn / 1e+6 ;
C_f = buyer_parameters.C_bf / 1e+6 ;
I_b = buyer_parameters.I_b / 1e+6;

%Retrieve profit matrix from vil_clusters. 
num_villages = length(vil_clusters);
num_prices = length(vil_clusters(1).P_f);
all_profits = zeros(num_villages, num_prices);
for i = 1:num_villages
    all_profits(i, :) = vil_clusters(i).buyer_profits;
end

%Change all negative profits to zero as they will shut down under this
%condition. 
all_profits(all_profits < 0) = 0;

%Find monoposonist's best price. 
column_sums = sum(all_profits, 1);
[~, max_column] = max(column_sums);
monoposonist_price = vil_clusters(1).P_f(max_column);

% Calculate village profits at new offered price - which is determined
% based on a quasi-competitive scenario dependent on the bargaining power and breakeven prices under a competitive
% market scenario. 
profit_vec = zeros(num_villages,1);
offered_prices = zeros(num_villages,1);
bargaining_power = 0.5;

for i = 1:num_villages
    if isempty(vil_clusters(i).hh)
        continue
    end
      
     % Find competitive price for the buyer at this price
     competitive_price = vil_clusters(i).competitive_prices(max_column);
     % Find actual price at the nominated bargaining power of participants.
     offered_prices(i) = (competitive_price - monoposonist_price)*bargaining_power + monoposonist_price;
    
     % Calculate village profits at new offered price
     % finds the first index where offered price is lower than what farmers will
     % accept, meaning the one before is the index we want to calc profits
     % from. 
     % note if the offered price is better than all other land uses, then we
     % need to account for this (i.e. index will return as zero)
     index = find(vil_clusters(i).P_f > offered_prices(i), 1, 'first') - 1 ; 
     if  isempty(index) && all(vil_clusters(i).P_f < offered_prices(i))
         Y_village = vil_clusters(i).Y_total(end);
         n_farmers = vil_clusters(i).farmers_total(end);
         n_plots = vil_clusters(i).plots_total(end);
         profit_vec(i) = P_b * Y_village - ...
                         offered_prices(i) * Y_village - ...
                         C_f * n_farmers -...
                         C_n * n_plots -...
                         I_b;
     elseif index > 0
         Y_village = vil_clusters(i).Y_total(index);
         n_farmers = vil_clusters(i).farmers_total(index);
         n_plots = vil_clusters(i).plots_total(index);
         profit_vec(i) = P_b * Y_village - ...
                         offered_prices(i) * Y_village - ...
                         C_f * n_farmers -...
                         C_n * n_plots -...
                         I_b;
      else
        profit_vec(i) = 0;
      end 
end 

%Create flag for village eligibility and household eligibility. 
hh_list(:,2) = 0;
for i = 1:num_villages
    if profit_vec(i) > 0
        vil_clusters(i).eligible = 1;
        for hh = 1:size(vil_clusters(i).hh,1)
            hh_list_row = vil_clusters(i).hh.hh_list_row(hh);
            hh_list(hh_list_row,2) = 1; %household instance is flagged as eligible based on village eligibility. 
        end
    else
        vil_clusters(i).eligible = 0;
        offered_prices(i) = 0;
    end

end

%Retrieve the offered price to be consistently applied across the
%landscape. 
offered_price = median(offered_prices(offered_prices ~= 0)); 
offered_price(isnan(offered_price)) = 0;

% end of function