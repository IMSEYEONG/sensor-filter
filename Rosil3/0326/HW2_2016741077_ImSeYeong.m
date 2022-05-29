
clc , clear                          % clc :명령창 초기화, clear : 작업공간 초기화
close all                            % 떠있는 figure를 없애준다

%% Set parameter
    % Set Simulation 
        end_time = 5;              % 시뮬레이션 종료시간
        delta_t = 0.001;           % 시뮬레이션 샘플링 주기
        sim_time = [0:0.001:5];    %  시뮬레이션 Time Matrix 생성 
    % Set Sine Wave
        sine_mag1  = 2.0; sine_freq1 = 1.0;  % Main Signal's parameter 
        sine_mag2  = 0.5; sine_freq2 = 10.0; % Noise Signal's parameter
        
        sim_y      =  sine_mag1*sin(sine_freq1*(2*pi*sim_time))...   % 크기2.0 주파수1Hz 정상 신호(sine wave) 생성 
                     +sine_mag2*sin(sine_freq2*(2*pi*sim_time))...   % 크기0.5 주파수10Hz 노이즈 생성
                     +0.8 * randn(size(sim_time));                   % 평균0, 표준편차0.8 White 노이즈 생성
   
%% LPF C언어
% cut off freq = 2
cutoff = 2;               % cut-off frequency                            
tau = 1/(2*pi*cutoff);    % 시정수  : 완전히 응답하기까지 소요되는 시간                           
lpf(1) = 0;               % 필터링된신호의 초기값 0으로초기화                      
n = 2;                    % 앞에서 첫번째값 설정했으므로 2번쨰 인덱스부터 들어간다

for(t=delta_t:delta_t:end_time)
    output_l = (((delta_t)*sim_y(n))+(tau*lpf(n-1)))/(tau + delta_t); % 1차 RC필터
    % get Data
    lpf(n) = output_l; %필터링된 샘플링값들 배열화
    time(n) = t;
    n = n+1;
end
% cut off freq = 6
cutoff2 = 6;               % cut-off frequency                            
tau2 = 1/(2*pi*cutoff2);    % 시정수  : 완전히 응답하기까지 소요되는 시간                           
lpf2(1) = 0;               % 필터링된신호의 초기값 0으로초기화                      
n2 = 2;                    % 앞에서 첫번째값 설정했으므로 2번쨰 인덱스부터 들어간다

for(t=delta_t:delta_t:end_time)
    output_l2 = (((delta_t)*sim_y(n2))+(tau2*lpf2(n2-1)))/(tau2 + delta_t); % 1차 RC필터
    % get Data
    lpf2(n2) = output_l2; %필터링된 샘플링값들 배열화
    time2(n2) = t;
    n2 = n2+1;
end
% cut off freq = 12
cutoff3 = 12;               % cut-off frequency                            
tau3 = 1/(2*pi*cutoff3);    % 시정수  : 완전히 응답하기까지 소요되는 시간                           
lpf3(1) = 0;               % 필터링된신호의 초기값 0으로초기화                      
n3 = 2;                    % 앞에서 첫번째값 설정했으므로 2번쨰 인덱스부터 들어간다

for(t=delta_t:delta_t:end_time)
    output_l3 = (((delta_t)*sim_y(n3))+(tau3*lpf3(n3-1)))/(tau3 + delta_t); % 1차 RC필터
    % get Data
    lpf3(n3) = output_l3; %필터링된 샘플링값들 배열화
    time3(n3) = t;
    n3 = n3+1;
end
%% MAF
 windowsize = 100;                           %Average Length Control
 num = (1/windowsize)*ones(1,windowsize);
 den = [1];
 maf = filter(num, den, sim_y); % matlab의 maf얻는 함수 사용 
 %분자 및 분모 계수인 num과 den로 정의되는 유리 전달 함수를 사용하여 입력 데이터 sim_y를 필터링
 %% MAF C언어
 maf_c_sum = zeros(1,length(sim_y));
 temp_maf =1;
 for (t=0:delta_t:end_time)
     if(temp_maf<windowsize+1)
         maf_c_sum(temp_maf) = 0; % temp_maf이 windowsize+1보다 작을때 벡터 인덱스값이 음수가나오기때문에 값을 0으로 설정
     else
         for(i=1:windowsize+1)
         % sum of sampling
         maf_c_sum(temp_maf) = maf_c_sum(temp_maf)+ sim_y(temp_maf+1-i); % windoesize만큼 샘플링값더하기
         end
     end
     temp_maf=temp_maf+1;
 end
 %get maf_c
maf_c = maf_c_sum / windowsize; % 샘플링값의 합을 샘플링횟수(windowsize)로 나누기
 %% Calc FFT
% Set FFT
    Fs         = 1/delta_t;         % Sampling Frequency : 1000Hz
    T          = delta_t;           % Sampling Period    : 0.001s
    L          = length(sim_y);     % Length of Signal   : 5001 <- 앞서서 5초를0.001의 간격으로 나누었기떄문에 sim_y가 5001번 샘플링 되었기때문
    T_vector   = (0:L-1)*T;         % Time Vector        : (0:5000)*0.001 <-  0 부터 5.0000까지 0.001간격의  1 X 5001 vector
    fft_f      = Fs*(0:((L)/2))/L;  % Frequency Range    : 주파수 범위: 0Hz ~ 500Hz, 분해능(간격):0.2Hz
 % Calc FFT
    fft_y_temp    = abs(fft(sim_y)/L);    % 허수부제거 <- 절대값함수(abs)를 이용하여 magnitude만 도출
    fft_y         = fft_y_temp(1:L/2+1);  % 켤레복소수 이기때문에 500Hz기준으로 대칭이므로 대칭부분 처리
    fft_y(2:end-1)=2*fft_y(2:end-1);      % 대칭부분을 하나로 합쳐서 켤레복소수 대응
    %% Calc FFT - LPF
    fft_y_temp_lpf   = abs(fft(lpf)/L);    % 허수부제거 <- 절대값함수(abs)를 이용하여 magnitude만 도출
    fft_y_lpf         = fft_y_temp_lpf(1:L/2+1);  % 켤레복소수 이기때문에 500Hz기준으로 대칭이므로 대칭부분 처리
    fft_y_lpf(2:end-1)=2*fft_y_lpf(2:end-1);      % 대칭부분을 하나로 합쳐서 켤레복소수 대응
    %% Calc FFT - maf
    fft_y_temp_maf   = abs(fft(maf)/L);    % 허수부제거 <- 절대값함수(abs)를 이용하여 magnitude만 도출
    fft_y_maf         = fft_y_temp_maf(1:L/2+1);  % 켤레복소수 이기때문에 500Hz기준으로 대칭이므로 대칭부분 처리
    fft_y_maf(2:end-1)=2*fft_y_maf(2:end-1);      % 대칭부분을 하나로 합쳐서 켤레복소수 대응
    %% Calc FFT - maf-C
    fft_y_temp_maf_c   = abs(fft(maf_c)/L);    % 허수부제거 <- 절대값함수(abs)를 이용하여 magnitude만 도출
    fft_y_maf_c         = fft_y_temp_maf(1:L/2+1);  % 켤레복소수 이기때문에 500Hz기준으로 대칭이므로 대칭부분 처리
    fft_y_maf_c(2:end-1)=2*fft_y_maf_c(2:end-1);      % 대칭부분을 하나로 합쳐서 켤레복소수 대응

%% Draw Graph 
figure('units', 'pixels', 'pos',[100 100 800 600], 'Color', [1,1,1]);  % figure창 생성(측정단위(default),창 위치와 크기, 색(white))
 %Time-Domain
 % LPF
    subplot(2,2,1)                             
         Xmin = 0.0; XTick = 1.0; Xmax = end_time;    % Xmin:X축 최소값parameter, XTick:X축 grid간격parameter, Xmax:X축 최대값parameter
         Ymin =-3.0; YTick = 1.0; Ymax = 3.0;         % Ymin:Y축 최소값parameter, YTick:Y축 grid간격parameter, Ymax:Y축 최대값parameter
            
            plot(sim_time,sim_y,'-k', 'LineWidth',2)  % 원래 신호 그래프 그리기
            hold on
            plot(sim_time,lpf3,'-g', 'LineWidth',1) % LPF(cut-off freq =12)거친 신호 그래프 그리기
            hold on
            plot(sim_time,lpf2,'-c', 'LineWidth',1) % LPF(cut-off freq =6)거친 신호 그래프 그리기
            hold on
            plot(sim_time,lpf,'-r', 'LineWidth',2) % LPF(cut-off freq =2)거친 신호 그래프 그리기
         
            
            legend('노이즈 신호', 'cutoff=12', 'cutoff=6', 'cutoff=2') %각 함수(그래프)에 대한 설명
              
         grid on; %Grid on
         axis([Xmin Xmax Ymin Ymax])               % Graph 최대 최소 설정
         set(gca, 'XTick', [Xmin:XTick:Xmax]);     % X축 Grid 간격
         set(gca, 'YTick', [Ymin:YTick:Ymax]);     % Y축 Grid 간격
     xlabel('time(s)',       'fontsize',20);       % X축 폰트20크기로 라벨링
     ylabel('Magnitude',     'fontsize',20);       % Y축 폰트20크기로 라벨링
     title ('LPF-Time Domain',   'fontsize',25);       % 폰트25 크기로 그래프 이름 설정
  % MAF
     subplot(2,2,3)                             
         Xmin = 0.0; XTick = 1.0; Xmax = end_time;    % Xmin:X축 최소값parameter, XTick:X축 grid간격parameter, Xmax:X축 최대값parameter
         Ymin =-3.0; YTick = 1.0; Ymax = 3.0;         % Ymin:Y축 최소값parameter, YTick:Y축 grid간격parameter, Ymax:Y축 최대값parameter
            
            plot(sim_time,sim_y,'-k', 'LineWidth',2)  % 원래 신호 그래프 그리기
            hold on
            plot(sim_time,maf,'-r', 'LineWidth',2) % maf_matlab거친 신호 그래프 그리기
            hold on
            plot(sim_time,maf_c,'-c', 'LineWidth',2) % maf_c거친 신호 그래프 그리기
         
            
            legend('노이즈 신호', 'MAF(Matlab)', 'MAF(C)') %각 함수(그래프)에 대한 설명
              
         grid on; %Grid on
         axis([Xmin Xmax Ymin Ymax])               % Graph 최대 최소 설정
         set(gca, 'XTick', [Xmin:XTick:Xmax]);     % X축 Grid 간격
         set(gca, 'YTick', [Ymin:YTick:Ymax]);     % Y축 Grid 간격
     xlabel('time(s)',       'fontsize',20);       % X축 폰트20크기로 라벨링
     ylabel('Magnitude',     'fontsize',20);       % Y축 폰트20크기로 라벨링
     title ('MAF-Time Domain',   'fontsize',25);       % 폰트25 크기로 그래프 이름 설정
 %Frequency-Domain_lpf     
    subplot(2,2,2)  
         Xmin = 0.0;  Xmax = 11;                   % X축 최소 최대 값parameter
         Ymin = 0.0;  Ymax = 3.0;                  % Y축 최소 최대 값parameter
         
            stem(fft_f,fft_y_lpf,'-k','LineWidth',2)   % 이산 시퀀스의 data plot
            
         grid on; %Grid on
         axis([Xmin Xmax Ymin Ymax])               % Graph 최대 최소 설정
         set(gca, 'XTick', [0 1.0 10.0]);          % X축 Grid 간격
         set(gca, 'YTick', [0 0.5  2.0]);          % Y축 Grid 간격
     xlabel('Frequency(Hz)',     'fontsize',20);   % X축 폰트20크기로 라벨링
     ylabel('Magnitude',         'fontsize',20);   % Y축 폰트20크기로 라벨링
     title ('LPF-Frequency Domain,cut_off freq = 2',  'fontsize',25);   % 폰트25 크기로그래프 이름 설정
  %Frequency-Domain_maf    
    subplot(2,2,4)  
         Xmin = 0.0;  Xmax = 11;                   % X축 최소 최대 값parameter
         Ymin = 0.0;  Ymax = 3.0;                  % Y축 최소 최대 값parameter

            stem(fft_f,fft_y_maf_c ,'-r','LineWidth',2)   % 이산 시퀀스의 data plot
            hold on;
            stem(fft_f,fft_y_maf ,'-k','LineWidth',2)   % 이산 시퀀스의 data plot

         grid on; %Grid on
         axis([Xmin Xmax Ymin Ymax])               % Graph 최대 최소 설정
         set(gca, 'XTick', [0 1.0 10.0]);          % X축 Grid 간격
         set(gca, 'YTick', [0 0.5  2.0]);          % Y축 Grid 간격
     xlabel('Frequency(Hz)',     'fontsize',20);   % X축 폰트20크기로 라벨링
     ylabel('Magnitude',         'fontsize',20);   % Y축 폰트20크기로 라벨링
     title ('MAF-Frequency Domain',  'fontsize',25);   % 폰트25 크기로그래프 이름 설정

 

