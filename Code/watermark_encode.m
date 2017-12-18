function Im = watermark_encode(IMAGE,WM,bin_len,pos_shift)

Im = IMAGE;
for i = 1:length(WM{1})
    tag = dec2bin([int8(WM{1}{i}),int8(':')],bin_len);
    value = dec2bin([int8(WM{2}{i}),int8(';')],bin_len);
    for j = 1:length(tag(:,1))
        for k = 1:bin_len
            if mod(IMAGE(pos_shift+bin_len*(j-1)+k),2) ~= str2num(tag(j,k))
                if IMAGE(pos_shift+bin_len*(j-1)+k)<0
                    Im(pos_shift+bin_len*(j-1)+k) = IMAGE(pos_shift+bin_len*(j-1)+k) + 1;
                else Im(pos_shift+bin_len*(j-1)+k) = IMAGE(pos_shift+bin_len*(j-1)+k) - 1;
                end
            end
        end
    end
    pos_shift = pos_shift + bin_len*length(tag(:,1));
    for j = 1:length(value(:,1))
        for k = 1:bin_len
            if mod(IMAGE(pos_shift+bin_len*(j-1)+k),2) ~= str2num(value(j,k))
                if IMAGE(pos_shift+bin_len*(j-1)+k)<0
                    Im(pos_shift+bin_len*(j-1)+k) = IMAGE(pos_shift+bin_len*(j-1)+k) + 1;
                else Im(pos_shift+bin_len*(j-1)+k) = IMAGE(pos_shift+bin_len*(j-1)+k) - 1;
                end
            end
        end
    end    
    pos_shift = pos_shift + bin_len*length(value(:,1));
end
pos_end = dec2bin(pos_shift,16);
for j = 1:16
    if mod(IMAGE(j),2) ~= str2num(pos_end(j))
        if IMAGE(j)<0
            Im(j) = IMAGE(j) + 1;
        else Im(j) = IMAGE(j) - 1;
        end
    end
end

end