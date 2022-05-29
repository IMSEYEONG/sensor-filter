 
clc , clear                          % clc :명령창 초기화, clear : 작업공간 초기화
close all                            % 떠있는 figure를 없애준다

%% Set parameter
    % Set Simulation 
        end_time = 10;              % 시뮬레이션 종료시간
        delta_t = 0.01;           % 시뮬레이션 샘플링 주기
        sim_time = [0:0.01:10];    %  시뮬레이션 Time Matrix 생성 
        psd_data
        signal= psd_signal.'; %psd signal
   
%% Calc FFT
% Set FFT
    Fs         = 1/delta_t;         % Sampling Frequency : 1000Hz
    T          = delta_t;           % Sampling Period    : 0.001s
    L          = length(signal);     % Length of Signal   : 5001 <- 앞서서 5초를0.001의 간격으로 나누었기떄문에 sim_y가 5001번 샘플링 되었기때문
    T_vector   = (0:L-1)*T;         % Time Vector        : (0:5000)*0.001 <-  0 부터 5.0000까지 0.001간격의  1 X 5001 vector
    fft_f      = Fs*(0:((L)/2))/L;  % Frequency Range    : 주파수 범위: 0Hz ~ 500Hz, 분해능(간격):0.2Hz
    fft_f1     = Fs*(0:((L))-1)/L; % Frequency Range    : 주파수 범위: 0Hz ~ 1000Hz, 분해능(간격):0.2Hz
 % Calc FFT
    fft_y_temp    = abs(fft(signal)/L);    % 허수부제거 <- 절대값함수(abs)를 이용하여 magnitude만 도출
    fft_y         = fft_y_temp(1:L/2+1);  % 켤레복소수 이기때문에 500Hz기준으로 대칭이므로 대칭부분 처리
    fft_y(2:end-1)=2*fft_y(2:end-1);      % 대칭부분을 하나로 합쳐서 켤레복소수 대응
%% Draw Graph 
figure('units', 'pixels', 'pos',[100 100 800 600], 'Color', [1,1,1]);  % figure창 생성(측정단위(default),창 위치와 크기, 색(white))
 %Time-Domain
    subplot(2,1,1)  % figure창 안에 2x1의 2개의 plot중 첫번쨰에 플롯 그리기                               
            
            plot(sim_time,signal,'-k', 'LineWidth',2)  
            
            legend('psd') %각 함수(그래프)에 대한 설명
              
         grid on; %Grid on
     
     xlabel('time(s)',       'fontsize',20);       % X축 폰트20크기로 라벨링
     ylabel('Magnitude',     'fontsize',20);       % Y축 폰트20크기로 라벨링
     title ('Time Domain',   'fontsize',25);       % 폰트25 크기로 그래프 이름 설정
 %Frequency-Domain    
    subplot(2,1,2)  % figure창 안에 2x1의 2개의 plot중 두번쨰에 플롯 그리기 
         Xmin = 0.0;  Xmax = 11;                   % X축 최소 최대 값parameter
         Ymin = 0.0;  Ymax = 3.0;                  % Y축 최소 최대 값parameter
         
            stem(fft_f,fft_y,'-k','LineWidth',2)   % 이산 시퀀스의 data plot
            
         grid on; %Grid on
         axis([Xmin Xmax Ymin Ymax])               % Graph 최대 최소 설정
         set(gca, 'XTick', [0 1.0 10.0]);          % X축 Grid 간격
         set(gca, 'YTick', [0 0.5  2.0]);          % Y축 Grid 간격
     xlabel('Frequency(Hz)',     'fontsize',20);   % X축 폰트20크기로 라벨링
     ylabel('Magnitude',         'fontsize',20);   % Y축 폰트20크기로 라벨링
     title ('Frequency Domain',  'fontsize',25);   % 폰트25 크기로그래프 이름 설정
 
