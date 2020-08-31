function discrim_basis = pfda(data, label)

    classes = unique(label); % get a list of all classes
    p = size(data,2); k = length(classes); n = size(data,1);
    vecs = combnk(1:k, 2);  % generate a list of combos
    discrim_basis = zeros(p, size(vecs,1)); % result matrix
    
    % allocate memory space for class data
    mask  = zeros(n, k);
    num   = zeros(1, k);
    mu    = zeros(k, p);
    sigma = zeros(p, p, k);
    
    % compute class means and covariance matrices
    for i = 1:length(classes)
       tmask        = strcmp(label, classes(i));
       num(i)       = sum(tmask);
       mu(i,:)      = mean(data(tmask,:));
       sigma(:,:,i) = cov(data(tmask,:));
       mask(:,i)    = tmask;
    end
    
    for i = 1:size(vecs,1)
        a = vecs(i,1); b = vecs(i,2);
        mu2 = (num(a) * mu(a,:) + num(b) * mu(b,:)) / (num(a) + num(b));
        Sw = (num(a) - 1) * sigma(:,:,a) + (num(b) - 1) * sigma(:,:,b);
        Sb = num(a) * QuadMat(mu(a,:),mu2) + num(b) * QuadMat(mu(b,:),mu2);
        [V,~] = eig(Sw\Sb);
        discrim_basis(:,i) = real(V(:,1));
    end
end

function result = QuadMat(k, g)
   v = k - g;
   result = v' * v;
end