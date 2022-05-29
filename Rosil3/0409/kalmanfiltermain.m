clc , clear all, close all
%% Main
dt = 0.2;
t = 0: dt:10;

Nsamples = length(t); % 샘플링시간의 크기

X_est_saved1 = zeros(Nsamples, 3); % 각 성분이 0인 51x3 matrix 생성
X_est_saved2 = zeros(Nsamples, 3);
Z_measured_saved1 = zeros(Nsamples, 1); % 각 성분이 0인 51x1 matrix 생성
Z_measured_saved2 = zeros(Nsamples, 1);

for k=1:Nsamples
    [z_measure1, z_measure2] = GetVolts(); % 전압값 읽어오기
    [x_est_volt1, Cov1, KG1] = KF(z_measure1); %칼만필터 함수 호출
    [x_est_volt2, Cov2, KG2] = KF(z_measure2);
    X_est_saved1(k,:) = [x_est_volt1 Cov1 KG1 ]; % [추정전압 오차공분산 칼만게인]
    X_est_saved2(k,:) = [x_est_volt2 Cov2 KG2 ];
    Z_measured_saved1(k) = z_measure1;
    Z_measured_saved2(k) = z_measure2;
end
       
%% plot
figure('units', 'pixels', 'pos',[100 100 800 600], 'Color', [1,1,1]);  
%  %Time-Domain
   subplot(1,4,1)
   plot(t, Z_measured_saved1,'-*k', 'LineWidth',0.5)  
   hold on;
   plot(t,X_est_saved1(:,1),'-*r', 'LineWidth',0.5) 
   legend('측정 데이터','추정 값') 
   xlabel('Time[s]',       'fontsize',20);       
   ylabel('Voltage[v]',     'fontsize',20); 
   title ('추정 전압값(노이즈 표준편차 4)',     'fontsize',20); 
   axis ([0 10 5 40])
   subplot(1,4,2)
   plot(t, Z_measured_saved2,'-*k', 'LineWidth',0.5)  
   hold on;
   plot(t,X_est_saved2(:,1),'-*b', 'LineWidth',0.5) 
   legend('측정 데이터','추정 값') 
   axis ([0 10 5 40])
   xlabel('Time[s]',       'fontsize',20);       
   ylabel('Voltage[v]',     'fontsize',20); 
   title ('추정 전압값(노이즈 표준편차 33)',     'fontsize',20); 
   subplot(1,4,3)
   plot(t, X_est_saved1(:,2),'-or', 'LineWidth',0.5)  
   hold on
   plot(t, X_est_saved2(:,2),'-ob', 'LineWidth',0.5)  
   legend('노이즈 표준편차 4인 공분산','노이즈 표준편차 33인 공분산')
   xlabel('Time[s]',       'fontsize',20);       
   ylabel('P',     'fontsize',20); 
   title ('오차 공분산의 변화',     'fontsize',20); 
   subplot(1,4,4)
   plot(t,X_est_saved1(:,3)','-or', 'LineWidth',0.5) 
   hold on;
   plot(t,X_est_saved2(:,3)','-ob', 'LineWidth',0.5) 
   xlabel('Time[s]',       'fontsize',20);       
   ylabel('K',     'fontsize',20); 
   legend('노이즈 표준편차 4인 칼만게인','노이즈 표준편차 33인 칼만게인')
   title ('칼만 게인의 변화',     'fontsize',20); 


%%
  

           
              
         
               