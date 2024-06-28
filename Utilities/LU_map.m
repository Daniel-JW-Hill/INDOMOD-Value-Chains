
%Plots map of land uses

function [] = LU_map(ax, x, y, lu, landuse, clrs, names, subd_poly, boundary, map_tab, lgd_on)
    
% Find indices of specified land use
    idx = find(lu == landuse);
    
    % Hold the current plot
    hold(ax, 'on');
    
    % Create scatter plot and set marker face color based on the color of each group
    gs = scatter(ax, x(idx), y(idx), 1, clrs(landuse,:), 's', 'filled');
    
    % Set axis limits and grid
    axis(ax, [-inf, inf, -inf, inf]);
    grid(ax, 'off');
    
    % Get current legend entries
    lgd = legend(ax);
    
    % Check if the legend exists
    if isempty(lgd) || ~isvalid(lgd)
        % Create the legend with the current entry and finish the function
        legend(ax, gs, names{landuse}, 'AutoUpdate', 'off', 'Visible', lgd_on, 'Direction', 'reverse', 'FontSize', 14, 'Orientation', 'vertical');
        
        % Position the legend if it is set to be visible
        if lgd_on
            legend(ax, 'Location', 'eastoutside');
        end
        hold(ax, 'off');
        return;
    else
        % Get current legend entries
        legend_text = lgd.String;
        plots = lgd.PlotChildren';
    end
    
    % Check if the current land use is already in the legend
    new_entry = true;
    for i = 1:length(legend_text)
        if strcmp(legend_text{i}, names{landuse})
            new_entry = false;
            break;
        end
    end

    % Add new legend entry for the current land use if it's not already there
    if new_entry
        legend_text{end+1} = names{landuse};
        plots(end+1) = gs;
    end

    is_data1 = strcmp(legend_text, 'data1');
    legend_text(is_data1) = [];
    plots(is_data1) = [];

    % Update legend
    legend(ax, plots, legend_text);
    
    % Customize legend properties
    lgd.AutoUpdate = 'off';
    lgd.Visible = lgd_on;
    lgd.Direction = 'reverse';
    lgd.FontSize = 14;
    lgd.Orientation = 'vertical';
    lgd.Box = 'off';
    
    % Position the legend if it is set to be visible
    if lgd_on
        lgd.Location = 'eastoutside';
    end

    % Plot subdistrict boundaries
    for s = 1:size(subd_poly,1)
         plot(ax, abs(subd_poly(s).x), abs(subd_poly(s).y), 'k-', 'LineWidth', 0.5);
    end
    
    b = boundary.b;
    
    % Plot boundary for study area
    plot(ax, map_tab.x(b), map_tab.y(b), 'r-', 'LineWidth', 0.5);

    % Release the hold on the current plot
    hold(ax, 'off');
end






