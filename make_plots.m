% make_plots.m -- generates the figures for the README / LinkedIn post
% Run from the project folder. Creates 4 PNG files.

try, theme(groot,'light'); catch, end   % light figures (needs R2025a+, skipped otherwise)
init_params;
ekfb = batt;            % EKF uses the correct model for these plots
ekf.SoC0 = 0.80;        % deliberately wrong start (true value is 0.90)
out = sim('ev_powertrain');

t   = out.SoC_true.Time;
st  = 100*out.SoC_true.Data;
se  = 100*out.SoC_est.Data;
err = st - se;

if isa(out.v, 'timeseries')
    tv = out.v.Time;  vv = out.v.Data;
else
    tv = out.tout;    vv = out.v;
end

% 1) SoC tracking
f = figure('Position',[100 100 900 450]);
plot(t, st, 'k', 'LineWidth', 2.5); hold on
plot(t, se, 'r', 'LineWidth', 0.7);
grid on; xlabel('Time (s)'); ylabel('SoC (%)');
legend('True SoC', 'EKF estimate', 'Location', 'northeast');
title('EKF state-of-charge estimate vs true SoC (WLTP Class 3, Low phase)');
exportgraphics(f, 'soc_tracking.png', 'Resolution', 200);

% 1b) Zoomed view so both lines are visible
f = figure('Position',[100 100 900 450]);
plot(t, st, 'k', 'LineWidth', 3); hold on
plot(t, se, 'r', 'LineWidth', 0.8);
xlim([200 260]); grid on; xlabel('Time (s)'); ylabel('SoC (%)');
legend('True SoC', 'EKF estimate', 'Location', 'northeast');
title('Zoom: EKF estimate follows the true SoC through measurement noise');
exportgraphics(f, 'soc_zoom.png', 'Resolution', 200);

% 2) Estimation error
f = figure('Position',[100 100 900 400]);
plot(t, err, 'b'); hold on; yline(0, 'k--');
grid on; xlabel('Time (s)'); ylabel('SoC error (% points)');
title('Estimation error (true - estimate)');
ylim([-1 1]);
exportgraphics(f, 'soc_error.png', 'Resolution', 200);

% 3) Start-up convergence (EKF starts at 80%, truth is 90%)
f = figure('Position',[100 100 900 400]);
plot(t, st, 'k', 'LineWidth', 2.5); hold on
plot(t, se, 'r', 'LineWidth', 1.2);
xlim([0 20]); grid on; xlabel('Time (s)'); ylabel('SoC (%)');
legend('True SoC', 'EKF estimate', 'Location', 'southeast');
title('Convergence from a wrong initial guess (80% vs true 90%)');
exportgraphics(f, 'soc_startup.png', 'Resolution', 200);

% 4) Drive cycle speed
f = figure('Position',[100 100 900 350]);
plot(tv, vv*3.6, 'Color', [0 0.4 0.8]);
grid on; xlabel('Time (s)'); ylabel('Speed (km/h)');
title('Vehicle speed over the WLTP Class 3 Low phase');
exportgraphics(f, 'speed_profile.png', 'Resolution', 200);

% 5) Robustness results (values from run_tests.m)
names = {'Matched','R0 +20%','Cap -5%','R0+20% & Cap-5%','Bad start 0.5'};
vals  = [0.0693 0.1586 0.0693 0.1586 0.0697];
f = figure('Position',[100 100 900 400]);
bar(vals); grid on;
set(gca, 'XTickLabel', names);
ylabel('SoC RMSE (% points, t > 10 s)');
title('EKF robustness to model error and bad initial guess');
exportgraphics(f, 'rmse_cases.png', 'Resolution', 200);

disp('Done: soc_tracking.png, soc_zoom.png, soc_error.png, soc_startup.png, speed_profile.png, rmse_cases.png');