
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
        
        %정상 신호
        sim_y0     =  sine_mag1*sin(sine_freq1*(2*pi*sim_time));     % 크기2.0 주파수1Hz 정상 신호(sine wave) 생성
        %노이즈 신호
        sim_y1     =  sine_mag2*sin(sine_freq2*(2*pi*sim_time));     % 크기0.5 주파수10Hz 노이즈 생성
        %White 노이즈 신호      
        sim_y      =  sine_mag1*sin(sine_freq1*(2*pi*sim_time))...   % 크기2.0 주파수1Hz 정상 신호(sine wave) 생성 
                     +sine_mag2*sin(sine_freq2*(2*pi*sim_time))...   % 크기0.5 주파수10Hz 노이즈 생성
                     +0.8 * randn(size(sim_time));                   % 평균0, 표준편차0.8 White 노이즈 생성
  
 %% FIR Low Pass Filter
 
 n     = 100;                    % filter order
 Fc    = 5;                    % cut-offfrequency
 Fs    = 1/delta_t;            % sampling frequency
 Fn    = Fs/2;                 % nyquist frequency
 Wn    = Fc/Fn;                % frequency control condition          
 b_firlow     = fir1(n, Wn, 'low');            % design fir lpf
 % matlab
 sim_y_firlow_mat = filtfilt(b_firlow, 1, sim_y);   % fir low in matlab result
 % c language
 sim_y_firlow_c = zeros(1,length(sim_y)); % 원래신호와 벡터 크기가 같은 0으로 이루어진 벡터 생성
 temp_firlow_c = 1;
 for (t=0:delta_t:end_time)
     sim_y_firlow_c(temp_firlow_c) = 0; % 값이 싸이는걸 방지하기위한 초기화
     if(temp_firlow_c<n+1)
         sim_y_firlow_c(temp_firlow_c) = 0; % temp_firlow_c이 n+1보다 작을때 벡터 인덱스값이 음수가나오기때문에 값을 0으로 설정
     else
         for(i=1:n+1)
         % fir low in c
         sim_y_firlow_c(temp_firlow_c) =...  % 각 샘플링 시간마다 fir의 inverse z transform형식을 취해주었다
         sim_y_firlow_c(temp_firlow_c)+ b_firlow(i)*sim_y(temp_firlow_c+1-i); 
         end
     end
     temp_firlow_c=temp_firlow_c+1;
 end
 %% FIR High Pass Filter
 n     = 2;                    % filter order
 Fc    = 5;                    % cut-offfrequency
 Fs    = 1/delta_t;            % sampling frequency
 Fn    = Fs/2;                 % nyquist frequency
 Wn    = Fc/Fn;                % frequency control condition
 
 b_firhigh     = fir1(n, Wn, 'high');           % design fir hpf 
 % matlab
 sim_y_firhigh_mat = filtfilt(b_firhigh, 1, sim_y);   % fir high in matlab result
 % c language
 sim_y_firhigh_c = zeros(1,length(sim_y)); % 원래신호와 벡터 크기가 같은 0으로 이루어진 벡터 생성
 temp_firhigh_c = 1;
 for (t=0:delta_t:end_time)
     sim_y_firhigh_c(temp_firhigh_c) = 0; % 값이 싸이는걸 방지하기위한 초기화
     if(temp_firhigh_c<n+1)
         sim_y_firhigh_c(temp_firhigh_c) = 0; % temp_firhigh_c이 n+1보다 작을때 벡터 인덱스값이 음수가나오기때문에 값을 0으로 설정
     else
         for(i=1:n+1)
         % fir high in c
         sim_y_firhigh_c(temp_firhigh_c) =...  % 각 샘플링 시간마다 fir의 inverse z transform형식을 취해주었다
         sim_y_firhigh_c(temp_firhigh_c)+ b_firhigh(i)*sim_y(temp_firhigh_c+1-i); 
         end
     end
     temp_firhigh_c=temp_firhigh_c+1;
 end
  %% IIR Low Pass Filter
 
 n     = 2;                    % filter order
 Fc    = 60;                    % cut-offfrequency
 Fs    = 1/delta_t;            % sampling frequency
 Fn    = Fs/2;                 % nyquist frequency
 Wn    = Fc/Fn;                % frequency control condition         
 [b_iirlow, a_iirlow]     = butter(n, Wn, 'low')          % design iir lpf

 % matlab
 sim_y_iirlow_mat = filtfilt(b_iirlow, a_iirlow, sim_y);   % iir low in matlab result
 % c language
 sim_y_iirlow_c = zeros(1,length(sim_y)); % 원래신호와 벡터 크기가 같은 0으로 이루어진 벡터 생성
 temp_iirlow_c = 1;
 for (t=0:delta_t:end_time)
     sim_y_iirlow_c(temp_iirlow_c) = 0; % 값이 싸이는걸 방지하기위한 초기화
     if(temp_iirlow_c < n+1)
         sim_y_iirlow_c(temp_iirlow_c) = 0; % temp_iirlow_c이 n+1 보다 작을때 벡터 인덱스값이 음수가나오기때문에값을 0으로 설정
     else
         for(i=1:n+1)
         % iir low in c
         sim_y_iirlow_c(temp_iirlow_c) =...  % 각 샘플링 시간마다 iir의 inverse z transform형식을 취해주었다
         sim_y_iirlow_c(temp_iirlow_c)+ b_iirlow(i)*sim_y(temp_iirlow_c+1-i)...
         -a_iirlow(i)*sim_y_iirlow_c(temp_iirlow_c+1-i);
         end
     end
     temp_iirlow_c=temp_iirlow_c+1;
 end
 %% IIR High Pass Filter
 n     = 2;                    % filter order
 Fc    = 8;                    % cut-offfrequency
 Fs    = 1/delta_t;            % sampling frequency
 Fn    = Fs/2;                 % nyquist frequency
 Wn    = Fc/Fn;                % frequency control condition
 [b_iirhigh, a_iirhigh]     = butter(n, Wn, 'high')          % design iir hpf 
 % matlab
 sim_y_iirhigh_mat = filtfilt(b_iirhigh, a_iirhigh, sim_y);  % iir hpf in matlab result
  % c language
 sim_y_iirhigh_c = zeros(1,length(sim_y)); % 원래신호와 벡터 크기가 같은 0으로 이루어진 벡터 생성
 temp_iirhigh_c = 1;
 for (t=0:delta_t:end_time)
     sim_y_iirhigh_c(temp_iirhigh_c) = 0; % 값이 싸이는걸 방지하기위한 초기화
     if(temp_iirhigh_c<n+1)
         sim_y_iirhigh_c(temp_iirhigh_c) = 0; % temp_iirhigh_c이 n+1보다 작을때 벡터 인덱스값이 음수가나오기때문에  값을 0으로 설정
     else
         for(i=1:n+1)
         % iir high in c
         sim_y_iirhigh_c(temp_iirhigh_c) =...  % 각 샘플링 시간마다 iir의 inverse z transform형식을 취해주었다
         sim_y_iirhigh_c(temp_iirhigh_c)+ b_iirhigh(i)*sim_y(temp_iirhigh_c+1-i)...
         -a_iirhigh(i)*sim_y_iirhigh_c(temp_iirhigh_c+1-i);
         end
     end
     temp_iirhigh_c=temp_iirhigh_c+1;
 end
%  %% Calc FFT
% % Set FFT
%     Fs         = 1/delta_t;         % Sampling Frequency : 1000Hz
%     T          = delta_t;           % Sampling Period    : 0.001s
%     L          = length(sim_y);     % Length of Signal   : 5001 <- 앞서서 5초를0.001의 간격으로 나누었기떄문에 sim_y가 5001번 샘플링 되었기때문
%     T_vector   = (0:L-1)*T;         % Time Vector        : (0:5000)*0.001 <-  0 부터 5.0000까지 0.001간격의  1 X 5001 vector
%     fft_f      = Fs*(0:((L)/2))/L;  % Frequency Range    : 주파수 범위: 0Hz ~ 500Hz, 분해능(간격):0.2Hz
%  % Calc FFT
%     fft_y_temp    = abs(fft(sim_y)/L);    % 허수부제거 <- 절대값함수(abs)를 이용하여 magnitude만 도출
%     fft_y         = fft_y_temp(1:L/2+1);  % 켤레복소수 이기때문에 500Hz기준으로 대칭이므로 대칭부분 처리
%     fft_y(2:end-1)=2*fft_y(2:end-1);      % 대칭부분을 하나로 합쳐서 켤레복소수 대응
%  % Calc firlpf matlab FFT  
%     fft_y_temp_firlow_mat = abs(fft(sim_y_firlow_mat)/L);    % 허수부제거 <- 절대값함수(abs)를 이용하여 magnitude만 도출
%     fft_y_firlow_mat  = fft_y_temp_firlow_mat(1:L/2+1);  % 켤레복소수 이기때문에 500Hz기준으로 대칭이므로 대칭부분 처리
%     fft_y_firlow_mat(2:end-1)=2*fft_y_firlow_mat(2:end-1);      % 대칭부분을 하나로 합쳐서 켤레복소수 대응
%  % Calc firlpf c FFT
%     fft_y_temp_firlow_c = abs(fft(sim_y_firlow_c)/L);    % 허수부제거 <- 절대값함수(abs)를 이용하여 magnitude만 도출
%     fft_y_firlow_c  = fft_y_temp_firlow_c (1:L/2+1);  % 켤레복소수 이기때문에 500Hz기준으로 대칭이므로 대칭부분 처리
%     fft_y_firlow_c(2:end-1)=2*fft_y_firlow_c(2:end-1);      % 대칭부분을 하나로 합쳐서 켤레복소수 대응
%  % Calc firhpf matlab FFT  
%     fft_y_temp_firhigh_mat = abs(fft(sim_y_firhigh_mat)/L);    % 허수부제거 <- 절대값함수(abs)를 이용하여 magnitude만 도출
%     fft_y_firhigh_mat  = fft_y_temp_firhigh_mat(1:L/2+1);  % 켤레복소수 이기때문에 500Hz기준으로 대칭이므로 대칭부분 처리
%     fft_y_firhigh_mat(2:end-1)=2*fft_y_firhigh_mat(2:end-1);      % 대칭부분을 하나로 합쳐서 켤레복소수 대응
%  % Calc firhpf c FFT
%     fft_y_temp_firhigh_c = abs(fft(sim_y_firhigh_c)/L);    % 허수부제거 <- 절대값함수(abs)를 이용하여 magnitude만 도출
%     fft_y_firhigh_c  = fft_y_temp_firhigh_c (1:L/2+1);  % 켤레복소수 이기때문에 500Hz기준으로 대칭이므로 대칭부분 처리
%     fft_y_firhigh_c(2:end-1)=2*fft_y_firhigh_c(2:end-1);      % 대칭부분을 하나로 합쳐서 켤레복소수 대응
%  % Calc iirlpf matlab FFT  
%     fft_y_temp_iirlow_mat = abs(fft(sim_y_iirlow_mat)/L);    % 허수부제거 <- 절대값함수(abs)를 이용하여 magnitude만 도출
%     fft_y_iirlow_mat  = fft_y_temp_iirlow_mat(1:L/2+1);  % 켤레복소수 이기때문에 500Hz기준으로 대칭이므로 대칭부분 처리
%     fft_y_iirlow_mat(2:end-1)=2*fft_y_iirlow_mat(2:end-1);      % 대칭부분을 하나로 합쳐서 켤레복소수 대응
%  % Calc iirlpf c FFT
%     fft_y_temp_iirlow_c = abs(fft(sim_y_iirlow_c)/L);    % 허수부제거 <- 절대값함수(abs)를 이용하여 magnitude만 도출
%     fft_y_iirlow_c  = fft_y_temp_iirlow_c (1:L/2+1);  % 켤레복소수 이기때문에 500Hz기준으로 대칭이므로 대칭부분 처리
%     fft_y_iirlow_c(2:end-1)=2*fft_y_iirlow_c(2:end-1);      % 대칭부분을 하나로 합쳐서 켤레복소수 대응
%  % Calc iirhpf matlab FFT  
%     fft_y_temp_iirhigh_mat = abs(fft(sim_y_iirhigh_mat)/L);    % 허수부제거 <- 절대값함수(abs)를 이용하여 magnitude만 도출
%     fft_y_iirhigh_mat  = fft_y_temp_iirhigh_mat(1:L/2+1);  % 켤레복소수 이기때문에 500Hz기준으로 대칭이므로 대칭부분 처리
%     fft_y_iirhigh_mat(2:end-1)=2*fft_y_iirhigh_mat(2:end-1);      % 대칭부분을 하나로 합쳐서 켤레복소수 대응
%  % Calc iirhpf c FFT
%     fft_y_temp_iirhigh_c = abs(fft(sim_y_iirhigh_c)/L);    % 허수부제거 <- 절대값함수(abs)를 이용하여 magnitude만 도출
%     fft_y_iirhigh_c  = fft_y_temp_iirhigh_c (1:L/2+1);  % 켤레복소수 이기때문에 500Hz기준으로 대칭이므로 대칭부분 처리
%     fft_y_iirhigh_c(2:end-1)=2*fft_y_iirhigh_c(2:end-1);      % 대칭부분을 하나로 합쳐서 켤레복소수 대응
% 
% 
% %% Draw stability circle
% 
% figure('units', 'pixels', 'pos',[100 100 800 600], 'Color', [1,1,1]); % Creating figure
%     viscircles([0,0], 1, 'LineWidth', 1.5, 'Color', 'b'); % Dreating circle
%     hold on;
%     [low_pass_zeros, low_pass_poles] = zplane(b_iirlow, a_iirlow); % Drawing lowpass filter
%     hold on;
%     [high_pass_zeros, high_pass_poles] = zplane(b_iirhigh, a_iirhigh); % Drawing high pass filter
%     hold on;
%     
%     set(findobj(low_pass_zeros, 'Type', 'line'),'Color','r', 'LineWidth', 2,'MarkerSize', 10); % Scrawing setting Low pass zeros
%     set(findobj(low_pass_poles, 'Type', 'line'),'Color','k', 'LineWidth', 2,'MarkerSize', 15); % Scrawing setting Low pass poles
%     set(findobj(high_pass_zeros, 'Type', 'line'),'Color','g', 'LineWidth', 2,'MarkerSize', 10);% Scrawing setting High pass zeros
%     set(findobj(high_pass_poles, 'Type', 'line'),'Color','k', 'LineWidth', 2,'MarkerSize', 15);% Scrawing setting High pass poles
%     
%     grid off;
%     axis([-1.1 1.1 -1.1 1.1])   % axis setting 
%     legend([low_pass_zeros,low_pass_poles,high_pass_zeros,high_pass_poles], ...  % name tag for poles, zeros
%            {'zeros of LPF','poles of LPF','zeros of HPF','poles of HPF'});   
%     xlabel('Real Domain',     'fontsize',20);   % X축 폰트20크기로 라벨링
%     ylabel('Imaginary Domain', 'fontsize',20);   % Y축 폰트20크기로 라벨링
%     title ('Filter Order = 2',  'fontsize',25);   % 폰트25 크기로그래프 이름 설정
%     
% %% Draw Graph 
% figure('units', 'pixels', 'pos',[100 100 800 600], 'Color', [1,1,1]);  % figure창 생성(측정단위(default),창 위치와 크기, 색(white))
%  % FIR LPF Time-Domain
%     subplot(4,2,1)                           
%          Xmin = 0.0; XTick = 1.0; Xmax = end_time;    % Xmin:X축 최소값parameter, XTick:X축 grid간격parameter, Xmax:X축 최대값parameter
%          Ymin =-5.0; YTick = 1.0; Ymax = 5.0;         % Ymin:Y축 최소값parameter, YTick:Y축 grid간격parameter, Ymax:Y축 최대값parameter
%             
%             plot(sim_time,sim_y,'-k', 'LineWidth',2)  % 원래신호
%             hold on
%             plot(sim_time,sim_y_firlow_c,'-r', 'LineWidth',2) % c언어로된 fir lpf를 통과한 신호
%             hold on
%             plot(sim_time,sim_y_firlow_mat,'-c', 'LineWidth',2) % matlabdm로된 fir lpf를 통과한 신호
%             
%             legend('원래신호', 'c', 'matlab') %각 함수(그래프)에 대한 설명
%               
%          grid on; %Grid on
%          axis([Xmin Xmax Ymin Ymax])               % Graph 최대 최소 설정
%          set(gca, 'XTick', [Xmin:XTick:Xmax]);     % X축 Grid 간격
%          set(gca, 'YTick', [Ymin:YTick:Ymax]);     % Y축 Grid 간격
%      xlabel('time(s)',       'fontsize',20);       % X축 폰트20크기로 라벨링
%      ylabel('Magnitude',     'fontsize',20);       % Y축 폰트20크기로 라벨링
%      title ('FIR LPF',   'fontsize',25);       % 폰트25 크기로 그래프 이름 설정
% % FIR HPF Time-Domain
%     subplot(4,2,3)                              
%          Xmin = 0.0; XTick = 1.0; Xmax = end_time;    % Xmin:X축 최소값parameter, XTick:X축 grid간격parameter, Xmax:X축 최대값parameter
%          Ymin =-5.0; YTick = 1.0; Ymax = 5.0;         % Ymin:Y축 최소값parameter, YTick:Y축 grid간격parameter, Ymax:Y축 최대값parameter
%             
%             plot(sim_time,sim_y,'-k', 'LineWidth',2)  % 원래신호
%             hold on
%             plot(sim_time,sim_y_firhigh_c,'-g', 'LineWidth',2) % c언어로된 fir hpf를 통과한 신호
%             hold on
%             plot(sim_time,sim_y_firhigh_mat,'-y', 'LineWidth',2) % matlabdm로된 fir hpf를 통과한 신호
%             
%             legend('원래신호', 'c', 'matlab') %각 함수(그래프)에 대한 설명
%               
%          grid on; %Grid on
%          axis([Xmin Xmax Ymin Ymax])               % Graph 최대 최소 설정
%          set(gca, 'XTick', [Xmin:XTick:Xmax]);     % X축 Grid 간격
%          set(gca, 'YTick', [Ymin:YTick:Ymax]);     % Y축 Grid 간격
%      xlabel('time(s)',       'fontsize',20);       % X축 폰트20크기로 라벨링
%      ylabel('Magnitude',     'fontsize',20);       % Y축 폰트20크기로 라벨링
%      title ('FIR HPF',   'fontsize',25);       % 폰트25 크기로 그래프 이름 설정
%  % IIR LPF Time-Domain
%     subplot(4,2,5)                            
%          Xmin = 0.0; XTick = 1.0; Xmax = end_time;    % Xmin:X축 최소값parameter, XTick:X축 grid간격parameter, Xmax:X축 최대값parameter
%          Ymin =-5.0; YTick = 1.0; Ymax = 5.0;         % Ymin:Y축 최소값parameter, YTick:Y축 grid간격parameter, Ymax:Y축 최대값parameter
%             
%             plot(sim_time,sim_y,'-k', 'LineWidth',2)  % 원래신호
%             hold on
%             plot(sim_time,sim_y_iirlow_c,'-r', 'LineWidth',2) % c언어로된 iir lpf를 통과한 신호
%             hold on
%             plot(sim_time,sim_y_iirlow_mat,'-c', 'LineWidth',2) % matlabdm로된 iir lpf를 통과한 신호
%             
%             legend('원래신호', 'c', 'matlab') %각 함수(그래프)에 대한 설명
%               
%          grid on; %Grid on
%          axis([Xmin Xmax Ymin Ymax])               % Graph 최대 최소 설정
%          set(gca, 'XTick', [Xmin:XTick:Xmax]);     % X축 Grid 간격
%          set(gca, 'YTick', [Ymin:YTick:Ymax]);     % Y축 Grid 간격
%      xlabel('time(s)',       'fontsize',20);       % X축 폰트20크기로 라벨링
%      ylabel('Magnitude',     'fontsize',20);       % Y축 폰트20크기로 라벨링
%      title ('IIR LPF',   'fontsize',25);       % 폰트25 크기로 그래프 이름 설정
% % IIR HPF Time-Domain
%     subplot(4,2,7)                          
%          Xmin = 0.0; XTick = 1.0; Xmax = end_time;    % Xmin:X축 최소값parameter, XTick:X축 grid간격parameter, Xmax:X축 최대값parameter
%          Ymin =-5.0; YTick = 1.0; Ymax = 5.0;         % Ymin:Y축 최소값parameter, YTick:Y축 grid간격parameter, Ymax:Y축 최대값parameter
%             
%             plot(sim_time,sim_y,'-k', 'LineWidth',2)  % 원래신호
%             hold on
%             plot(sim_time,sim_y_iirhigh_c,'-g', 'LineWidth',2) % c언어로된 iir hpf를 통과한 신호
%             hold on
%             plot(sim_time,sim_y_iirhigh_mat,'-y', 'LineWidth',2) % matlabdm로된 iir hpf를 통과한 신호
%             
%             legend('원래신호', 'c', 'matlab') %각 함수(그래프)에 대한 설명
%               
%          grid on; %Grid on
%          axis([Xmin Xmax Ymin Ymax])               % Graph 최대 최소 설정
%          set(gca, 'XTick', [Xmin:XTick:Xmax]);     % X축 Grid 간격
%          set(gca, 'YTick', [Ymin:YTick:Ymax]);     % Y축 Grid 간격
%      xlabel('time(s)',       'fontsize',20);       % X축 폰트20크기로 라벨링
%      ylabel('Magnitude',     'fontsize',20);       % Y축 폰트20크기로 라벨링
%      title ('IIR HPF',   'fontsize',25);       % 폰트25 크기로 그래프 이름 설정
%  % FIR LPF Frequency-Domain    
%     subplot(4,2,2)  
%          Xmin = 0.0;  Xmax = 11;                   % X축 최소 최대 값parameter
%          Ymin = 0.0;  Ymax = 3.0;                  % Y축 최소 최대 값parameter
%          
%             stem(fft_f,fft_y_firlow_c,'-r','LineWidth',2)   % 이산 시퀀스의 data plot
%             hold on;
%             stem(fft_f,fft_y_firlow_mat,'-c','LineWidth',2)   % 이산 시퀀스의 data plot
%             
%          grid on; %Grid on
%          axis([Xmin Xmax Ymin Ymax])               % Graph 최대 최소 설정
%          set(gca, 'XTick', [0 1.0 10.0]);          % X축 Grid 간격
%          set(gca, 'YTick', [0 0.5  2.0]);          % Y축 Grid 간격
%      xlabel('Frequency(Hz)',     'fontsize',20);   % X축 폰트20크기로 라벨링
%      ylabel('Magnitude',         'fontsize',20);   % Y축 폰트20크기로 라벨링
%      title ('FIR LPF Frequency-Domain ',  'fontsize',25);   % 폰트25 크기로그래프 이름 설정
%  % FIR HPF Frequency-Domain    
%     subplot(4,2,4)  
%          Xmin = 0.0;  Xmax = 11;                   % X축 최소 최대 값parameter
%          Ymin = 0.0;  Ymax = 3.0;                  % Y축 최소 최대 값parameter
%          
%             stem(fft_f,fft_y_firhigh_c,'-g','LineWidth',2)   % 이산 시퀀스의 data plot
%             hold on;
%             stem(fft_f,fft_y_firhigh_mat,'-y','LineWidth',2)   % 이산 시퀀스의 data plot
%             
%          grid on; %Grid on
%          axis([Xmin Xmax Ymin Ymax])               % Graph 최대 최소 설정
%          set(gca, 'XTick', [0 1.0 10.0]);          % X축 Grid 간격
%          set(gca, 'YTick', [0 0.5  2.0]);          % Y축 Grid 간격
%      xlabel('Frequency(Hz)',     'fontsize',20);   % X축 폰트20크기로 라벨링
%      ylabel('Magnitude',         'fontsize',20);   % Y축 폰트20크기로 라벨링
%      title ('FIR HPF Frequency-Domain ',  'fontsize',25);   % 폰트25 크기로그래프 이름 설정
%   % IIR LPF Frequency-Domain    
%     subplot(4,2,6)  
%          Xmin = 0.0;  Xmax = 11;                   % X축 최소 최대 값parameter
%          Ymin = 0.0;  Ymax = 3.0;                  % Y축 최소 최대 값parameter
%          
%             stem(fft_f,fft_y_iirlow_c,'-r','LineWidth',2)   % 이산 시퀀스의 data plot
%             hold on;
%             stem(fft_f,fft_y_iirlow_mat,'-c','LineWidth',2)   % 이산 시퀀스의 data plot
%             
%          grid on; %Grid on
%          axis([Xmin Xmax Ymin Ymax])               % Graph 최대 최소 설정
%          set(gca, 'XTick', [0 1.0 10.0]);          % X축 Grid 간격
%          set(gca, 'YTick', [0 0.5  2.0]);          % Y축 Grid 간격
%      xlabel('Frequency(Hz)',     'fontsize',20);   % X축 폰트20크기로 라벨링
%      ylabel('Magnitude',         'fontsize',20);   % Y축 폰트20크기로 라벨링
%      title ('IIR LPF Frequency-Domain ',  'fontsize',25);   % 폰트25 크기로그래프 이름 설정
%  % IIR HPF Frequency-Domain    
%     subplot(4,2,8)  
%          Xmin = 0.0;  Xmax = 11;                   % X축 최소 최대 값parameter
%          Ymin = 0.0;  Ymax = 3.0;                  % Y축 최소 최대 값parameter
%          
%             stem(fft_f,fft_y_iirhigh_c,'-g','LineWidth',2)   % 이산 시퀀스의 data plot
%             hold on;
%             stem(fft_f,fft_y_iirhigh_mat,'-y','LineWidth',2)   % 이산 시퀀스의 data plot
%             
%          grid on; %Grid on
%          axis([Xmin Xmax Ymin Ymax])               % Graph 최대 최소 설정
%          set(gca, 'XTick', [0 1.0 10.0]);          % X축 Grid 간격
%          set(gca, 'YTick', [0 0.5  2.0]);          % Y축 Grid 간격
%      xlabel('Frequency(Hz)',     'fontsize',20);   % X축 폰트20크기로 라벨링
%      ylabel('Magnitude',         'fontsize',20);   % Y축 폰트20크기로 라벨링
%      title ('IIR HPF Frequency-Domain ',  'fontsize',25);   % 폰트25 크기로그래프 이름 설정
