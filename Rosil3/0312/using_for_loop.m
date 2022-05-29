%{
%% Set parameter 1 using for loop
    % Set Simulation 
        end_time =5;
        delta_t = 0.001;
    % Set Sine Wave
        sine_mag  = 2;
        sine_freq = 1;
%% Simulation 1 using for

n = 1;
for(t =0 :delta_t:end_time)
    y = sine_mag * sin(sine_freq*(2*pi*t));
    % get dat
    sim_y(n)    = y;
    sim_time(n) = t;
    n = n + 1;
end
%}

%% Draw Graph
%{
% Time-Domain
Xmin = 0.0; XTick = 1.0; Xmax = end_time;
Ymin =-3.0; YTick = 1.0; Ymax = 3.0;

figure('units', 'pixels', 'pos',[100 100 450 400], 'Color', [1,1,1]);
    plot(sim_time,sim_y,'-k', 'LineWidth',2)
    
    grid on;                                  % Grid on
    axis([Xmin Xmax Ymin Ymax])               % Graph 최대 최소 설정
    set(gca, 'XTick', [Xmin:XTick:Xmax]);     % X축 Grid 간격
    set(gca, 'YTick', [Ymin:YTick:Ymax]);     % Y축 Grid 간격
 xlabel('time(s)',       'fontsize',20);
 ylabel('Magnitude',     'fontsize',20);
 title ('Sine Wave',     'fontsize',20);
%}