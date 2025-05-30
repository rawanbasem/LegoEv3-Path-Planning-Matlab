clear all;
close all;
clc;

trackinit;
L = 0.98;   % No need to change

katt = 1;
krep = 1;
ktheta = 1;
rho0 = 0.5;
calib = 38.5/480;

start(mB);
start(mC);

while ~readButton(mylego, 'up')
    tracker;  
    N = size(obstacles,1);  % Number of obstacles
    % robot     : (1x3) [x y theta]
    % goal      : (1x2) [x y]
    % obstacles : (Nx2) [x y] 

    % distance between the robot and the goal
    distance_to_goal = norm(robot(1:2) - goal);


    if distance_to_goal < rho0
        vR = 0;
        vL = 0;
    else

        Fatt = -katt * (robot(1:2) - goal);

        Ftot = Fatt;

        for i = 1:N
            qobst = obstacles(i, :);

            rho = norm(robot(1:2) - qobst);

            if rho <= rho0
                Frep = krep * (1 / rho - 1 / rho0) * (robot(1:2) - qobst) / rho^3;
                Ftot = Ftot + Frep;
            end
        end

        V = alpha * Ftot;

        v = norm(V);
        theta_d = atan2d(V(2), V(1));
        omega = ktheta * (theta_d - robot(3));

        vR = (2 * v + omega * L) / 2;
        vL = (2 * v - omega * L) / 2;
    end

    mB.Speed = vL;
    mC.Speed = vR;
end

release(videoPlayer);
release(pointTracker);
stop(mB);
stop(mC);
