clc,clear,close all
%% set simulation time

end_time = 1; % 관측 종료 시간
delta_t = 0.1; % 샘플링 주기
sim_time = [0:delta_t:end_time]; % 관측 시간 벡터

%% Make input signal
sim_x = 14.4+2*randn(length(sim_time),1); %평균 14.4 표준편차 2 인 시그널
sim_x(3) = 150; % 시그널 중간에 심하게 튀는값 성정
%% analysis the signal
% Mean
    x_Mean         = mean(sim_x);  % Average
    temp           = ones(length(sim_x)); % 평균을 플롯에 띄우기 위해 Mean,Median크기의 각성분이 1인 벡터를 만들어준다
    sim_x_Mean     = x_Mean*temp(:,1); % sim_x와 성분이 벡터 크기가 같은 Mean
% Deviation
    sim_x_Deviation = sim_x-sim_x_Mean; % 각 관측 값에서의 편차
    deviation_sum = sum(sim_x_Deviation) % 편차의 합 = 0
% Variance
    x_Variance = var(sim_x) % 분산 : 편차제곱총합의 평균
% Median
    x_Median       = median(sim_x);  % Median
    sim_x_Median   = x_Median*temp(:,1);% sim_x와 성분이 벡터 크기가 같은 Median
% Normal Distirbution
    ND_Range       = [-200:1:200]; % 정규분포에서 
    x_SD           = std(sim_x)            % Standard Deviation
    x_ND           = normpdf(ND_Range,x_Mean,x_SD); % 편균 x_Mean 표준편차 x_SD인 정규분포
       
%% plot
figure('units', 'pixels', 'pos',[100 100 800 600], 'Color', [1,1,1]);  % figure창 생성(측정단위(default),창 위치와 크기, 색(white))
 %Time-Domain
   subplot(1,3,1)
   plot(sim_time,sim_x,'ok', 'LineWidth',2)  % 관측 시스널 플롯
   hold on;
   plot(sim_time,sim_x_Mean,'-r', 'LineWidth',2) % 평균 플롯
   hold on;
   plot(sim_time,sim_x_Median,'-b', 'LineWidth',2) % 중앙값 플롯
   hold on;
   plot(sim_time,sim_x_Deviation,'om', 'LineWidth',2) %각 관측 값에서의 편차 플롯
   grid on; 
   legend('시그널','평균','중앙값','편차') 
   set(gca, 'XTick', [0:0.2:1]);     
   yticks([-160 0 x_Median x_Mean 150 160])
   axis([0 1 -160 160]) 
   xlabel('Time(s)',       'fontsize',20);       
   ylabel('Magnitude',     'fontsize',20);       
   subplot(1,3,2)
   plot(x_ND,ND_Range ,'-r', 'LineWidth',2)  % 정규분포 플롯
   hold on;
   grid on;
   yticks([-160 x_Median x_Mean 160])
   axis([0 0.01 -160 160])
   xlabel('Probability',       'fontsize',20);       
   subplot(1,3,3)
   boxplot(sim_x)     % 박스플롯
   axis([0 2 -160 160]) 
   grid on;
   yticks([-160 x_Median x_Mean 150 160])
   xlabel('Input Signal',       'fontsize',20);       
  
  

           
              
         
               