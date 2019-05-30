function [ep, rt, network] = ac
%State-value actor-critic for the pendulum.
%   [EP, RT] returns the end performance and rise time of state-value
%   actor-critic on the underactuated pendulum swing-up.
%
%   AUTHOR:
%      Wouter Caarls <wouter@caarls.org>

    % General initialization
    alpha = 0.2;
    beta = 0.01;
    gamma = 0.99;
    hidden_units = [10, 10];
    num_episodes = 100;
    episode_length = 100;
    augmented_size = 20;
    
    % Get feature vector size
    sz = numel(feature([0 0]));
    
    % Initialize features
    theta = randn(sz, 1);
    w = randn(sz, 1);
    
    curve = zeros(1, num_episodes);
    b = zeros(100, 3);
    sigma = 1;
    
    function net = init_net()
        net = feedforwardnet(hidden_units);
        net.trainParam.showWindow = 0;
      %  net = configure(net, features, targets);
    end
    
    function [features, targets] = generate_examples()
        % five columns for angle, velocity, action, next angle and next
        % velocity
        pos = rand() * 2 * pi - pi;
        vel = rand() * 24 * pi - 12 * pi;
        state = zeros(3, 1);
        state(1) = pos;
        state(2) = vel;
        features = zeros(3, episode_length);
        targets = zeros(2, episode_length);
        for si=1:episode_length
            state(3) = rand() * 6 - 3;
            features(1:3, si) = state(1:3);
            stateP = pendulum(state(1:2), state(3));
            targets(1:2, si) = stateP;
            state = stateP;
        end
    end    
    state_action = zeros(3, size(b, 1), numel(curve));
    next_state = zeros(2, size(b, 1), numel(curve));
    network = init_net();
    [test_features, test_targets] = generate_examples();
    errors = zeros(numel(curve) / 5, 1);
    % Episodes
    n_sample = 1;
    epoch = 1;
    for ee = 1:numel(curve)
        sigma = sigma*0.99;
        
        x = [pi, 0];
        fx = feature(x);
        for ii=1:size(b, 1)
            % Choose action
            new_pendulum = @(k) pendulum(k(1:2), k(3));
            [theta, w, state_action, next_state, b, curve, fx, x, sigma] = ...
                ac_loop(new_pendulum, @feature, x, fx, b, ...
                state_action, next_state, ee, theta, w, curve, sigma, ii, gamma, beta, alpha);
        end
        if (rem(ee, 5) == 0)
            inputs = state_action(:, :, 1:ee);
            targets = next_state(:, :, 1:ee);
            inputs = reshape(inputs, [3, size(inputs, 2) * size(inputs, 3)]);
            targets = reshape(targets, [2, size(targets, 2) * size(targets, 3)]);
            network = train(network, inputs, targets);
            
            predictions = network(test_features);
            errors(epoch) = mse(network, test_targets, predictions);
            subplot(3, 2, 5);
            plot(errors(1:epoch));
            epoch = epoch + 1;
            title('Test error');
            xlabel('Episode');
            ylabel('MSE');
            drawnow;
            
            
            x = [pi, 0];
            fx = feature(x);
            for ii=1:augmented_size
                [theta, w, state_action, next_state, b, curve, fx, x, sigma] = ...
                ac_loop(network, @feature, x, fx, b, ...
                    state_action, next_state, ee, theta, w, curve, sigma, ii, gamma, beta, alpha);
            end
        end
        if (rem(ee, 10) == 0)
            subplot(3, 2, 3);
            plot(curve);
            subplot(3, 2, 4);
            x = 1:size(b, 1);
            plot(x, b(:,1), x, b(:, 2), x, b(:, 3));
            axis([0 size(b, 1) -10 10]);
            drawnow;
        end
        
        if (rem(ee, 100) == 0)
            plotip(theta, w, @feature);
        end
    end

    ep = mean(curve(end-10:end));
    
    reached = curve > -1000;
    reached3 = reached(1:end-2) + reached(2:end-1) + reached(3:end) == 3;
    rt = find(reached3, 1);
    
    function phi = feature(x)
        phi = gaussrbf(x, 11, 0.5);
    end

end
