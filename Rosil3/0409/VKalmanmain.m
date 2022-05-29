clc,clear all,close all
%% Main
dt = 0.1;
t = 0: dt:10;

Nsamples = length(t);

X_est_saved = zeros(Nsamples, 2);
Z_measured_saved = zeros(Nsamples, 1);

for k=1:Nsamples
    z_measure = GetVel();
    [pos, vel] = VelKalman(z_measure);
    
    X_est_saved(k,:) = [pos  vel];
    Z_measured_saved(k) = z_measure;
end
       
%% plot
figure('units', 'pixels', 'pos',[100 100 800 600], 'Color', [1,1,1]);  % figure창 생성(측정단위(default),창 위치와 크기, 색(white))
%  %Time-Domain
   subplot(2,1,1)
   plot(t, Z_measured_saved,'-k', 'LineWidth',0.5)  
   hold on;
   plot(t,X_est_saved(:,2),'-r', 'LineWidth',0.5) 
   grid on; 
   subplot(2,1,2)
   plot(t, X_est_saved(:,1),'-ob', 'LineWidth',0.5)  
   grid on; 
%    subplot(1,3,3)
%    plot(t,X_est_saved(:,3)','-ob', 'LineWidth',0.5) 
% 

    grid on; 
%    legend('시그널','평균','중앙값','편차') 
%    set(gca, 'XTick', [0:0.2:1]);     
%    yticks([-160 0 x_Median x_Mean 150 160])
%    axis([0 1 -160 160]) 
%    xlabel('Time(s)',       'fontsize',20);       
%    ylabel('Magnitude',     'fontsize',20);       
%    subplot(1,3,2)
%    plot(x_ND,ND_Range ,'-r', 'LineWidth',2)  % 정규분포 플롯
%    hold on;
%    grid on;
%    yticks([-160 x_Median x_Mean 160])
%    axis([0 0.01 -160 160])
%    xlabel('Probability',       'fontsize',20);       
%    subplot(1,3,3)
%    boxplot(sim_x)     % 박스플롯
%    axis([0 2 -160 160]) 
%    grid on;
%    yticks([-160 x_Median x_Mean 150 160])
%    xlabel('Input Signal',       'fontsize',20);       
%   
  

           
              
         
               