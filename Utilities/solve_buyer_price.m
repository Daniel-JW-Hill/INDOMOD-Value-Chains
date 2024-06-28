function [vil_clusters, Y_npv_buyer] = solve_buyer_price(lu_trans_cf_new, buyer_parameters, farmer_transaction_costs, lpp, n_LuOpts, vil_clusters)
% ========================================================================
% ** IndoMod function **
% Returns a price which maximises the profits of contracting across all
% villages, expected profits for each village for the buyer at this price,
% and flags for village eligibility. 

% The buyer optimises for the price they offer to farmers, recognising that
% this price influences the likely number of plots that will be made
% available to contracting. The buyer does not observe perfect information
% for each household, only the number of plots and the relative returns for
% alternative land uses. 

% The decision function is faced with discontinutities where the number of
% plots for a given land use and slope is either 0 or A_ij depending on the
% outside options for this plot type. For this reason, and the relative
% simplicity of the decision function, we perform a simple comparison of
% profits at 'threshold' prices where it is optimal to switch land uses
% from the representative farmer's perspective (at a plot level). The buyer
% will always choose a price that is just enough to switch plots into
% contracting (and no more), but given village characterstics and
% catchments it may be optimal to not bind these participation constraints
% for certain plot types if the yields from these plots are not worth
% capturing. 

% We find the profits under each threshold price for each village, and
% choose a single landscape-wide price that maximises overall profits.
% Villages where profits are negative at this price for the buyer are not
% eligible to participate. 
% ========================================================================

% Retrieve the relative returns for each land use. 
[V,L,K,Le,Ke,Lo,Ko,t_est] = lp_Get_npv_mat(lu_trans_cf_new, lpp.r, lpp.w(1), n_LuOpts, farmer_transaction_costs);

% To retrieve the farmer outside options, determine for each land use the best
% alternative based on lifetime profits. Notation for this is pi_luS where
% lu = current land use and S is plot slope and pi is the npv of profits
% for the best available land use for this plot per hectare

%For each outside option, add the costs associated with the contracting,
%transaction costs and defined annual payments, to simplify the constraint as a revenue must be
%greater than all costs and net opportunity cost. 
opportunity_cost = zeros(4,3);
Y_npv_buyer = zeros(4,3); % per hectare policy outputs by current lu and slope. 
Y_npv_farmer = zeros(4,3); % per hectare policy outputs by current lu and slope. 
for lu = 1:4
    for s = 1:3
     opportunity_cost(lu,s) = max([V(lu,1,s),...
                                  V(lu,2,s),...
                                  V(lu,3,s),...
                                  V(lu,4,s)]);
     [costs_contracting,Y_x_buyer, Y_x_farmer] = get_plot_policy_costs(lu, s, lu_trans_cf_new, lpp.w(1), lpp.r, farmer_transaction_costs, buyer_parameters.discount_rate_buyer);
     opportunity_cost(lu,s) = opportunity_cost(lu,s) + costs_contracting;  
     Y_npv_buyer(lu,s) = Y_x_buyer; %yields per ha for policy option, at buyer discount rate
     Y_npv_farmer(lu,s) = Y_x_farmer; %yields per ha for policy option, at buyer discount rate
    end
end

% For each outside option, find the threshold price where it is optimal to switch to contracting. 
% These threshold prices are used when comparing profits for the buyer. 
threshold_prices = zeros(4,3);
for lu = 1:4
    for s = 1:3
      threshold_prices(lu,s) = ceil((opportunity_cost(lu,s) / Y_npv_farmer(lu,s))/10)*10; %Rounds up price to nearest 10. 
    end
end

% Vectorise and sort these prices to loop through
threshold_prices_vec = reshape(threshold_prices.', 1, []);
threshold_prices_vec  = sort(threshold_prices_vec)';

% Profile out buyer parameters for the optimisation. Note these already
% net present values where relevant. 
P_b = buyer_parameters.P_b - buyer_parameters.C_by; %net price of coffee without farmer price. 
C_n = buyer_parameters.C_bn / 1e+6 ;
C_f = buyer_parameters.C_bf / 1e+6 ;
I_b = buyer_parameters.I_b / 1e+6;

% Loop through all villages, parameterise remaining variables, and for each threshold price find the village level profits. Save P_f in the Vil_cluster dataframe, and buyer profits at this price. 
Y_v_0 = zeros(4,3);
n_plots_0 = zeros(4,3);
profit_vec = zeros(size(threshold_prices_vec,1),1);
competitive_prices = zeros(size(threshold_prices_vec,1),1);
Y_total = zeros(size(threshold_prices_vec,1),1);
plots_total = zeros(size(threshold_prices_vec,1),1);
farmers_total = zeros(size(threshold_prices_vec,1),1);

for v = 1:size(vil_clusters,2)
    if isempty(vil_clusters(v).hh) %if village has no farmers. 
         vil_clusters(v).P_f = 0;
         vil_clusters(v).buyer_profits = 0;   
         continue
    else
    
    % Retrieve total number of farmers in catchment. 
    n_farmers = size(vil_clusters(v).hh,1);

    % Retrieve the number of plots, npv of yields from these plots if
    % contracted, and average per farmer. 
    
    for lu = 1:4
        for s = 1:3
            plot_idx = sprintf('plots_%d_%d',lu,s);
            n_plots_0(lu,s) = sum(vil_clusters(v).hh.(plot_idx));
            if s == 1
                plot_area = n_plots_0(lu,s) * mean(vil_clusters(v).hh.abar_flat);
            elseif s == 2
                plot_area = n_plots_0(lu,s) * mean(vil_clusters(v).hh.abar_moderate);
            else
                plot_area = n_plots_0(lu,s) * mean(vil_clusters(v).hh.abar_steep);
            end
            Y_v_0(lu,s) = Y_npv_buyer(lu,s) * plot_area; 
        end
    end

    plots_per_farmer = sum(n_plots_0(:)) / n_farmers;

    %Loop through profit function for each threshold price. 
    %Includes net costs of buying from farmers, 
    %Net revenue from sales of coffee,
    %farmer level transaction costs for the buyer
    %Plot level transaction costs for the buyer
    %Investment costs at a village level. 
    for p = 1:size(threshold_prices_vec,1)
        % Update contracting yields (note we check all land uses each time in the
        % unlikely event that the threshold price is relevant for more than
        % one land use and slope combination). 
        P_f = threshold_prices_vec(p);
        [Y_v, n_plots] = get_Y_v(P_f, Y_v_0, Y_npv_farmer,  n_plots_0, opportunity_cost);
       
        %Solve for buyer profits. 
        profit_vec(p) = - buyer_profit(P_f, P_b, Y_v, C_f, plots_per_farmer, C_n, n_plots, I_b); 
        competitive_prices(p) = buyer_price_competitive(P_f, P_b, Y_v, plots_per_farmer , C_f, C_n, n_plots, I_b);
        Y_total(p) = sum(Y_v(:));
        plots_total(p) = sum(n_plots(:));
        farmers_total(p) = sum(n_plots(:)) * plots_per_farmer;
    end
    % Save optimal price for the village, and associated buyer profits into
    % vil_clusters. 
    vil_clusters(v).P_f = threshold_prices_vec;
    vil_clusters(v).buyer_profits = profit_vec;
    vil_clusters(v).competitive_prices = competitive_prices;
    vil_clusters(v).Y_total = Y_total;
    vil_clusters(v).plots_total = plots_total;
    vil_clusters(v).farmers_total = farmers_total;
    end
end

    function [profit] =  buyer_profit(P_f, P_b, Y_v, C_f, plots_per_farmer, C_n, n_plots, I_b)
    profit = P_f * (sum(Y_v(:))) - ...
             P_b * (sum(Y_v(:))) + ...
             C_f * sum(n_plots(:))/plots_per_farmer+...
             C_n * sum(n_plots(:))+...
             I_b;
end

function [P_f_competitive] =  buyer_price_competitive(P_f, P_b, Y_v, plots_per_farmer , C_f, C_n, n_plots, I_b)
    P_f_competitive = (P_b * sum(Y_v(:)) - ...
                     C_f * sum(n_plots(:))/plots_per_farmer -...
                     C_n * sum(n_plots(:)) -...
                     I_b)/...
                     sum(Y_v(:));
    if P_f_competitive < P_f
        P_f_competitive = P_f;
    end
end


function [Y_v, n_plots] = get_Y_v(P_f, Y_v_0, Y, n_plots_0, opportunity_cost)
    threshold_price = P_f; 
    Y_v = zeros(4,3);
    n_plots = zeros(4,3);
    for land_use = 1:4
        for slope = 1:3
            if threshold_price * Y(land_use, slope) > opportunity_cost(land_use,slope)
                Y_v(land_use,slope) = Y_v_0(land_use,slope);
                n_plots(land_use,slope) = n_plots_0(land_use,slope);
            else 
                Y_v(land_use,slope) = 0;
                n_plots(land_use,slope) = 0;
            end
        end
    end
end

end

