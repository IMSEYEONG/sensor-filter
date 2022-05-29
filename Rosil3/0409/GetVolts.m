function [z_measure1,z_measure2]  = GetVolts()  % 측정값 받는 함수
%
%
v1 = 0 + 4*randn(1,1);         %  randz를 이용한 표준편차4인 노이즈
v2 = 0 + 33*randn(1,1);         % randz를 이용한 표준편차33인 노이즈
 
z_measure1 = 14.4 + v1;         % z = x + v
z_measure2 = 14.4 + v2;         