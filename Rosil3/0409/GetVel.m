function z_measure = GetVel()

persistent Vel_pred Pos_pred


if isempty(Pos_pred)  
    Pos_pred = 0;
    Vel_pred = 80;
end

dt = 0.1;

v_noise = 10*randn;

Pos_pred = Pos_pred + Vel_pred * dt;
Vel_pred = 80 + v_noise;

z_measure = Vel_pred;