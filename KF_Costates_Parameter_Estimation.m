clear all 
close all
x=[10000;10000];
A=[-4,0;
    0,2];
B=[1;1];
[n,n]=size(A);
X_c=eye(n);
U_c=eye(1);
k=dlqr(A,B,X_c,U_c)
T=5;
Q_x=1e-3*eye(n);
noise=sqrt(Q_x)*randn(n,1);
for t=1:T
    u(t)=-k*x(:,t);
    x(:,t+1)=A*x(:,t)+B*u(t)+0*noise;
end
plot(1:T+1,x(1,:))
figure
plot(1:T+1,x(2,:))
%%

%Initialization
w=[1;2;1;1];
n_w=length(w);
phi=zeros(n_w,1);
F_u=B;
F_x=A;
n_lambda=n;
w_hat=zeros(n_w,1,T);
lambda_hat=zeros(n_lambda,1,T);
P_hat=zeros(n_w,n_w,T);
P_lambda_hat=zeros(n,n,T);
Q=1e-2*eye(n_w);
R=1e-2*eye(1);
Q_lambda=1e-2*eye(n);
R_lambda=1e-2*eye(1);

% Q(:,:,t)=1e-2*eye(n);
% R(:,:,t)=1e-2*eye(1);
for t=2:T
    phi(:,t)=[x(1,t)^2;x(1,t)*x(2,t);x(2,t)^2;u(t)^2];
    phi_u=[0;0;0;2*u(t)]
    phi_x=[2*x(1,t),0;
           x(2,t),x(1,t);
           0,2*x(2,t);
           0,0];

    % 'a'
    %Prediction
    % 'b'
    w_predict=w_hat(:,1,t-1);
    P_predict=P_hat(:,:,t-1)+ Q
    % display('c')
    %Use of Measurements
    noise_R=sqrt(R)*randn(1);
    y_residual= (F_u'*lambda_hat(:,1,t-1)+noise_R)+phi_u'*w_predict
    % 'd'
    % Kalman Gain
    S=R + (-phi_u')*P_predict*(-phi_u')'
    % 'e'
    K=P_predict*(-phi_u')'*S^(-1)
    %Updates
    K*y_residual
    w_hat(:,1,t)=w_predict +K*y_residual;
    P_hat(:,:,t)=(eye(n_w)-K*(-phi_u'))*P_predict*(eye(n_w)-K*(-phi_u'))'+ K*R*K';

    % display('Check1')
    %Prediction
    lambda_predict=phi_x' *w_hat(:,1,t-1)+ F_x'*lambda_hat(:,1,t-1);
    P_lambda_pred=(F_x')*P_lambda_hat(t-1)*(F_x')'+ Q_lambda;
    % 'f'
    %Use of Measurments
    y_lambda_resid=F_u'*lambda_predict+phi_u'*w_hat(:,1,t-1);
    %Kalman Gain
    S_lambda=R_lambda + (-F_u')*P_lambda_pred*(-F_u')';
    K_lambda=P_lambda_pred*(-F_u')'*S_lambda^(-1); 
    % 'g'
    %Updates
    lambda_hat(:,1,t)=lambda_predict+K_lambda*y_lambda_resid;
    % 'h'
    P_lambda_hat(:,:,t)=(eye(n_lambda)-K_lambda*(-F_u'))*P_lambda_pred*(eye(n_lambda)-K_lambda*(-F_u'))'+ K_lambda*R_lambda*K_lambda';

end
w_hat_plot=reshape(w_hat,[n_w,T]);
figure
for i=1:n_w
hold on
plot(w_hat_plot(i,:))
end
