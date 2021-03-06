%% Init variables
simulated_experience = [20, 30, 50, 100, 150, 200];

performance_per_exp = zeros(6, 1);
std_perf_per_exp = zeros(6, 1);

rt_per_exp = zeros(6, 1);
std_rt_per_exp = zeros(6, 1);

computation_time_per_exp = zeros(6, 1);
std_computation_time_per_exp = zeros(6, 1);

performance_per_exp_rnd = zeros(6, 1);
std_perf_per_exp_rnd = zeros(6, 1);

rt_per_exp_rnd = zeros(6, 1);
std_rt_per_exp_rnd = zeros(6, 1);

computation_time_per_exp_rnd = zeros(6, 1);
std_computation_time_per_exp_rnd = zeros(6, 1);


%% Trajectories
for s=1:6
    % Runs 10 times with trajectories
    performance = zeros(10, 1);
    rise_time = zeros(10, 1);
    computation_time = zeros(10, 1);
    for r=1:10
        [ep, rt, network, comp_time] = ac(simulated_experience(s), 0);
        computation_time(r) = comp_time;
        performance(r) = ep;
        if isempty(rt)
            rise_time(r) = 100;
        else
            rise_time(r) = rt;    
        end
    end
    performance_per_exp(s) = mean(performance);
    std_perf_per_exp(s) = std(performance);
    
    rt_per_exp(s) = mean(rise_time);
    std_rt_per_exp(s) = std(rise_time);
    
    computation_time_per_exp(s) = mean(computation_time);
    std_computation_time_per_exp(s) = std(computation_time);
end

%% Random actions
for s=1:6
    % Runs 10 times with random actions
    performance = zeros(10, 1);
    rise_time = zeros(10, 1);
    computation_time = zeros(10, 1);
    for r=1:10
        [ep, rt, network, comp_time] = ac(simulated_experience(s), 1);
        computation_time(r) = comp_time;
        performance(r) = ep;
        if isempty(rt)
            rise_time(r) = 100;
        else
            rise_time(r) = rt;    
        end
    end
    performance_per_exp_rnd(s) = mean(performance);
    std_perf_per_exp_rnd(s) = std(performance);
    
    rt_per_exp_rnd(s) = mean(rise_time);
    std_rt_per_exp_rnd(s) = std(rise_time);
    
    computation_time_per_exp_rnd(s) = mean(computation_time);
    std_computation_time_per_exp_rnd(s) = std(computation_time);
end


%% Plots graphs
figure();
errorbaralpha(simulated_experience, performance_per_exp, std_perf_per_exp);
title('End performance per simulated experience');
xlabel('Number of simulated transitions per episode');
hold off

figure()
errorbaralpha(simulated_experience, rt_per_exp, std_rt_per_exp);
title('Rise Time per simulated experience');
xlabel('Number of simulated transitions per episode');

figure()
errorbaralpha(simulated_experience, computation_time_per_exp, std_computation_time_per_exp);
title('Computation time per simulated experience');
xlabel('Number of simulated transitions per episode');

figure();
scatter(computation_time_per_exp, rt_per_exp, simulated_experience);
hold on
scatter(computation_time_per_exp_rnd, rt_per_exp_rnd, simulated_experience);
legend('Trajectories', 'Random Actions');
xlabel('Computation time');
ylabel('Rise time');
title('Sample complexity vs computational complexity');
hold off
