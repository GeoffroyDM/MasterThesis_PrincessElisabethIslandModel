n_wt_agg = 150; %200;  % Number of wind turbines in aggregated model

f = 50;   % Stator frequency
Ps = 2e6*n_wt_agg;   % Rated stator power

p=2;   % Number of pair of poles
u=1/3; % stator/rotor turns ratio
n=1500;   % Rated rotational speed [rpm] (2 pair of poles)
omega_sync =  2*pi*50/p; 
Vs = 690;  %Rated stator voltage
Is = Ps/(sqrt(3)*Vs); %Rated stator current
Tm_rated = Ps/omega_sync; %Rated torque = Ps*p/(2*pi*f)


Vr = Vs/u; %Rated rotor voltage (non-reached)
smax = 1/3; %maximum slip
Vr_stator = (Vr*smax)*u; %Rated rotor voltage referred to stator
Rs = 2.6e-3 /n_wt_agg;
Lsi = 0.087e-3 /n_wt_agg;
Lm = 2.5e-3 /n_wt_agg;
Rr = 2.9e-3 /n_wt_agg; % Rotor resistance referred to stator (ratio u is taken into account)
Ls = Lm + Lsi;
Lr = Lm + Lsi;
Vbus = 1150/u;


Idr_rated = sqrt(2)*Is;
Idg_rated = sqrt(2)*Is*u; 

sigma = 1 - Lm^2 / (Ls*Lr);
Fs = Vs * sqrt(2/3)/(2*pi*f); %stator flux approximation


J = 127*n_wt_agg ;  %Inertia
D = 1e-3 ; %Damping


fsw = 4e3;
Ts = 1/fsw/50;


% PI regulators rotor-side

tau_i = sigma * Lr / Rr;
tau_n = 0.05;
wni = 100*(1/tau_i);
wnn = 1/tau_n;

kp_id = (2*wni*sigma*Lr) - Rr;
kp_iq = kp_id;
ki_id = (wni^2)*Lr*sigma;
ki_iq = ki_id;
kp_n = (2*wnn*J)/p;
ki_n = (wnn^2)*J / p;


%Three blade wind turbine model
N = 100;
Radius = 42;
rho = 1.225;   %air density

% Cp and Ct curves     Ct = torque coef
beta = 0;
ind2 = 1;
    for lambda_idx=0.1:0.01:11.8

        lambdai(ind2) = (1./((1./(lambda_idx-0.02.*beta)+(0.003./(beta^3+1)))));
        Cp(ind2) = 0.73.*(151./lambdai(ind2)-0.58.*beta-0.002.*beta^2.14-13.2).*(exp(-18.4./lambdai(ind2)));
        Ct(ind2) = Cp(ind2)/lambda_idx;
        ind2 = ind2+1;
    end
    tab_lambda = [0.1:0.01:11.8];
   
 %Kopt for MPPT
 Cp_max = 0.44;
 lambda_opt =7.2;
 Kopt = ((0.5*rho*pi*(Radius^5)*Cp_max)/(lambda_opt^3));

 %Power curve in function of wind speed
 P = 1.e+06*[0.0,0.0,0.0,0.0,0.0,0.0,0.0472,0.1097,0.1815,0.2568,0.3418, ...
    0.4317,0.5642,0.7064,0.8617,1.0512,1.2616,1.4976,1.7613,2.0534, ...
    2.3532,2.4042,2.4042,2.4042,2.4042,2.4042,2.4042,2.4042];

 P = P*n_wt_agg;

v = [0.0000,0.5556,1.1111,1.6667,2.2222,2.7778,3.3333,3.8889,4.4444, ...
    5.0000,5.5556,6.1111,6.6667,7.2222,7.7778,8.3333,8.8889,9.4444, ...
    10.0000,10.5556,11.1111,11.6667,12.2222,12.7778,13.3333,13.8889, ...
    14.4444,15.0000];

% figure
% subplot(1,3,1)
% plot(tab_lambda,Cp,'linewidth',1.5)
% xlabel('\lambda','fontsize',14)
% ylabel('C_p','fontsize',14)
% 
% subplot(1,3,2)
% plot(tab_lambda,Ct,'linewidth',1.5)
% xlabel('\lambda','fontsize',14)
% ylabel('C_t','fontsize',14)
% 
% subplot(1,3,3)
% plot(v,P,'linewidth',1.5)
% grid
% xlabel('Wind speed (m/s)','fontsize',14)
% ylabel('Power (W)','fontsize',14)

%Grid side converter

Cbus = 80e-3*n_wt_agg*u^2;         %DC bus capacitance
Rg=20e-6 /n_wt_agg;            % Grid side filter's resistance
Lg = 400e-6 /n_wt_agg;         % Grid side filter's inductance



%Pi regulators 
tau_ig = Lg/Rg;
wnig = 50*2*pi;

Kpg = 1/(1.5*Vr*sqrt(2/3));
Kqg = -Kpg;

kp_idg = ((2*wnig*Lg)-Rg);
kp_iqg = kp_idg;
ki_idg = (wnig^2)*Lg;
ki_iqg = ki_idg;

kp_v = -1000*n_wt_agg;
ki_v = -300000*n_wt_agg;





% HVDC link


Rv = 0.74529;
Lv = 7.4529/(2*pi*50);
Imax = 1905;
id_max = Imax;
id_min = 0;
iq_min = 0;

% PI PQ windfarm
Ed_max = 220e3;  %Ed_windfarm
tau_p_windfarm = 20e-3;
Kp_P_windfarm = 1 / (1-Ed_max);
Ki_P_windfarm = 1 / ((1-Ed_max) * Ed_max*tau_p_windfarm);
Kp_Q_windfarm = Kp_P_windfarm;
Ki_Q_windfarm = Ki_P_windfarm;



% PI idq windfarm
tau_id_windfarm = 5e-3;
Kp_id_windfarm = Lv / tau_id_windfarm;
Ki_id_windfarm = Rv / tau_id_windfarm;
Kp_iq_windfarm = Kp_id_windfarm; 
Ki_iq_windfarm = Ki_id_windfarm;


% PI Q grid
tau_Q_grid = 20e-3;
Ed_max_grid = 380e3;
Kp_Q_grid = 1 / (1-Ed_max_grid);
Ki_Q_grid = 1 / ((1-Ed_max_grid) * Ed_max_grid*tau_Q_grid);



tau_id_grid = 5e-3;
Kp_id_grid= Lv / tau_id_grid;
Ki_id_grid= Rv / tau_id_grid;
Kp_iq_grid= Kp_id_grid; 
Ki_iq_grid= Ki_id_grid;





