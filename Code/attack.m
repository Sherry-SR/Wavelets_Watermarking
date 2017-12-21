function AttackedImg = attack(IMAGE,attacktype,parameter)
if length(attacktype)~=length(parameter)
    error(message('attack set and parameter set should have same length'));
end
AttackedImg = cell(size(attacktype));
for i = length(attacktype)
    switch attacktype{i}
        case 'gaussian'
            if length(parameter{i})~=2
                error(message('Gaussian noise should have 2 parameters M and V'));
            end         
            AttackedImg{i} = imnoise(IMAGE,'gaussian',parameter{i}(1),parameter{i}(2));
        case 'salt & pepper'
            if length(parameter{i})~=2
                error(message('salt & pepper noise should have 1 parameter d'));
            end
            AttackedImg{i} = imnoise(IMAGE,'salt & pepper', parameter{i});
        case 'scale'
            if length(parameter{i})~=1
                error(message('scale transform should have 1 parameter s'));
            end
            AttackedImg{i} = imresize(IMAGE, parameter{i});
        otherwise
            error(message('error attacktype'));
    end
end

