%%Kalman Filter
function [x_est_volt, P, K_gain] = KF(z)
%
persistent A H Q R                  % 다음 사이클때도 값유지하기위해 사용, 함수호출시 메모리 유지
persistent x_est P_calculated
persistent firstRun

if isempty(firstRun)  % firstrun이 empty면 실행X , 초기설정
    A = 1;   % x_k+1 = x_k + w_k
    H = 1;   % z_k = x_k + v_k
    
    Q = 0;   % w_k = 0
    R = 4;   % v~N(0,2)인 정규분포
    
    x_est = 14;        % 초기 예측전압
    P_calculated = 6;  % 초기예측 공분산 (초깃값 정보없을시에 오차공분산을 크게 잡는것이 중요)
    
    firstRun = 1; % 초기설정왈료후 다음 사이클때는 건너뛰기위해 1로 설정 
end

x_pred = A*x_est;                  % 예측값
P_pred = A*P_calculated*A' +0;     % 오차공분산 예측

K_gain = P_pred*H'*inv(H*P_pred*H'+R);  % 칼만게인 계산
 
x_est = x_pred + K_gain*(z-H*x_pred);   % 추정값
P_calculated = P_pred-K_gain*H*P_pred;  % 오차 공분산

x_est_volt = x_est; % 칼만필터 함수를 통한 추정값 반환
P = P_calculated;   % 칼만필터 함수를 통한 오차 공분산 반환