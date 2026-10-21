% init_params.m -- all vehicle, drivetrain, battery and EKF parameters.
% Run this before simulating ev_powertrain.

%% Vehicle and drivetrain
veh = struct('m',1500,'Cd',0.28,'A',2.2,'Crr',0.015,'rho',1.225, ...
             'g',9.81,'rw',0.30,'Fmax',6000);
drv = struct('G',9,'rw',veh.rw,'Tmax',250,'Pmax',100e3,'Fbrake',8000, ...
             'kc',0.08,'ki',1.5,'kw',2e-7,'P0',300);

%% Battery (true plant: 1 RC-pair model)
batt.Capacity_Ah = 50;  batt.V_nom = 400;  batt.SoC_init = 0.90;
batt.R0 = 0.05;  batt.R1 = 0.02;  batt.C1 = 2500;
batt.soc_lut = [0 0.1 0.2 0.5 0.8 0.9 1.0];
batt.ocv_lut = [300 340 360 380 400 410 420];
batt.Ts = 0.1;                      % must equal the solver fixed step size

%% EKF
ekf.Q    = diag([1e-6 1e-4]);       % process noise
ekf.R    = 1e-2;                    % measurement noise (0.1 V sensor)
ekf.P0   = diag([1e-2 1e-3]);       % initial covariance
ekf.SoC0 = 0.80;                    % deliberately wrong start (truth is 0.90)

% The EKF's own copy of the battery parameters.
% Matched to the true battery by default. run_tests.m overwrites these
% to test model mismatch (e.g. R0 +20 %, capacity -5 %).
ekfb = batt;

%% Drive cycle (WLTP Class 3, Low phase)
raw   = readmatrix('class3-1-Low.csv');
t_vec = raw(:,1);
v_mps = raw(:,2)/3.6;
wltp_data = [t_vec, v_mps];
wltp_ts   = timeseries(v_mps, t_vec);

fprintf('Params loaded\n');
