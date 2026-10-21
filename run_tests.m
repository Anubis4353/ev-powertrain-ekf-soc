% run_tests.m  -- EKF robustness tests
cases = {'matched model',     1.0, 1.0,  0.80;
         'R0 +20%',           1.2, 1.0,  0.80;
         'Capacity -5%',      1.0, 0.95, 0.80;
         'R0 +20% & Cap -5%', 1.2, 0.95, 0.80;
         'bad start (0.5)',   1.0, 1.0,  0.50};

rm = zeros(size(cases,1),1);
for i = 1:size(cases,1)
    init_params;                                    % reset everything
    ekfb = batt;                                    % EKF's belief
    ekfb.R0          = batt.R0*cases{i,2};
    ekfb.Capacity_Ah = batt.Capacity_Ah*cases{i,3};
    ekf.SoC0         = cases{i,4};

    out = sim('ev_powertrain');
    t = out.SoC_true.Time;  k = t > 10;             % skip start-up transient
    e = out.SoC_true.Data - out.SoC_est.Data;
    rm(i) = 100*sqrt(mean(e(k).^2));
    fprintf('%-20s RMSE = %.4f %%\n', cases{i,1}, rm(i));
end