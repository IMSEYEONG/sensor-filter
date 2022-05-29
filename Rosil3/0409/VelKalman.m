%% Velocity Kalman Filter

function [pos, vel] = VelKalman(z)
%
persistent A H Q R
persistent x_est P_calculated 
persistent firstRun

if isempty(firstRun)  % firstrun이 empty면 실행X
    dt = 0.1;
    
    A = [1 dt; 0 1];
    H = [0 1];
    
    Q = [1 0 ; 0 3];
    R = 1;
    
    x_est = [0; 20];
    P_calculated = 5 * eye(2);
    
    firstRun = 1;
end

x_pred = A*x_est;
P_pred = A*P_calculated*A' +0;

K_gain = P_pred*H'*inv(H*P_pred*H'+R);

x_est = x_pred + K_gain*(z-H*x_pred);
P_calculated = P_pred-K_gain*H*P_pred;

pos = x_est(1);
vel = x_est(2);