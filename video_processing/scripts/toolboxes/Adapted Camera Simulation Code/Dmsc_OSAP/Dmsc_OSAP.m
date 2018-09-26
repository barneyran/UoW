function [Dmsc_img]=Dmsc_OSAP(img,Bayer_type)

% Defines constants for processing, and loads pre-specified filters:    
    % 0 for partial convergence, 1 for full convergence
    IsConvergence = 1; 
    % Truncate all polyphase filters to the size of K-by-K
    K = 6;  
    % 0: use the original nonseparable filters; 1: use separable approximations
    % (i.e. rank-one approximations); 2: use rank-two approximations; and so on
    approx_rank = 1; 
    % load the pre-computed filters
    if IsConvergence
        [flts_r, flts_b] = Dmsc_OSAP_simplify_filters(20, K);
    end
    if strcmp(Bayer_type,'grbg')
        % Applies OSAP Conv or Part processing, as specified
        if IsConvergence
            [Dmsc_img, ~] = Dmsc_OSAP_DmscProc_conv(img, flts_r, flts_b, approx_rank);
        end
    elseif strcmp(Bayer_type,'rggb')
        % Circshifts
        img=circshift(img, [0,-1]);
        % Applies OSAP Conv or Part processing, as specified
        if IsConvergence
            [Dmsc_img, ~] = Dmsc_OSAP_DmscProc_conv(img, flts_r, flts_b, approx_rank);
        end
        % Circshifts back to orig position
        Dmsc_img=circshift(Dmsc_img, [0, 1]);
    elseif strcmp(Bayer_type,'gbrg')
        % Circshifts
        img=circshift(img, [-1,-1]);
        % Applies OSAP Conv or Part processing, as specified
        if IsConvergence
            [Dmsc_img, ~] = Dmsc_OSAP_DmscProc_conv(img, flts_r, flts_b, approx_rank);
        end
        % Circshifts back to orig position
        Dmsc_img=circshift(Dmsc_img, [1,1]);
    elseif strcmp(Bayer_type,'bggr')
        % Circshifts
        img=circshift(img, [-1,0]);
        % Applies OSAP Conv or Part processing, as specified
        if IsConvergence
            [Dmsc_img, ~] = Dmsc_OSAP_DmscProc_conv(img, flts_r, flts_b, approx_rank);
        end
        % Circshifts back to orig position
        Dmsc_img=circshift(Dmsc_img, [1, 0]);
    end