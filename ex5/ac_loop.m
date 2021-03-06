function [theta, w, state_action, next_state, b, curve, sigma] = ...
     ac_loop(transitions, transition_function, feature, b, state_action, ...
     next_state, ee, theta, w, curve, sigma, gamma, beta, alpha, random)
    x = [pi, 0];
    fx = feature(x);
    for ii=1:transitions
        actor_u = fx'*theta;    
        u = actor_u+randn*sigma;
 

        b(ii, 1:2) = x;
        b(ii, 3) = u;
        s = zeros(3, 1);
        s(1:2) = x;
        s(3) = u;
        % Get next state
        if random == 1
            xP = zeros(2, 1);
            xP(1) = rand() * 2 * pi - pi;
            xP(2) = rand() * 24 * pi - 12 * pi;
        else
            xP = transition_function(s);
        end
        % Breaks if state is out-of-bounds of system expected dynamics
        if xP(1) < -pi || xP(1) > pi || xP(2) < -12 * pi || xP(2) > 12 *pi
            break
        else
            fxP = feature(xP');
            % save transitions to train the network
            state_action(1:2, ii, ee) = x;
            state_action(3, ii, ee) = u;
            next_state(1:2, ii, ee) = xP;
            % Calculate reward
            r = -5*xP(1)^2-0.1*xP(2)^2-1*u^2;
            curve(ee) = curve(ee) + r;

            % TD error
            delta = r + (gamma*fxP - fx)'*w;

            % Update critic
            w = w + alpha*delta*fx;

            % Update actor
            theta = min(max(theta + beta*(u-actor_u)*delta*fx, -3), 3);

            x = xP;
            fx = fxP;
        end
    end    
end            
% Choose action
