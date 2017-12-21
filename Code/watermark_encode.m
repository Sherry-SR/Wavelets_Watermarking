function Im = watermark_encode(IMAGE,WM,bin_len,pos_shift,code_len)

Im = IMAGE;
for i = 1:length(WM{1})
    tag = dec2bin([int8(WM{1}{i}),int8(':')],bin_len);
    value = dec2bin([int8(WM{2}{i}),int8(';')],bin_len);
    
    empt_spc = dec2bin(double(' '),bin_len);
    
    if ( mod(size(tag,1) , 2) == 1)
        tag = [tag;empt_spc];
    end
    if ( mod(size(value,1) , 2) == 1)
        value = [value;empt_spc];
    end

    for j = 1:(size(tag,1)/2)

        Code = gf2dec(bchenc(gf([double(tag(2*j-1,:)),double(tag(2*j,:))] - 48),31,16),1,3);

        for k = 1:code_len
            if mod(IMAGE(pos_shift+code_len*(j-1)+k),2) ~= int64(Code(k))
                if IMAGE(pos_shift+code_len*(j-1)+k)<0
                    Im(pos_shift+code_len*(j-1)+k) = IMAGE(pos_shift+code_len*(j-1)+k) + 1;
                else
                    Im(pos_shift+code_len*(j-1)+k) = IMAGE(pos_shift+code_len*(j-1)+k) - 1;
                end
            end
        end
     end
    pos_shift = pos_shift + code_len * size(tag,1)/2 ;
    for j = 1:(size(value,1)/2)
        
                Code = gf2dec(bchenc(gf([double(value(2*j-1,:)),double(value(2*j,:))] - 48),31,16),1,3);

        for k = 1:code_len
            if mod(IMAGE(pos_shift+code_len*(j-1)+k),2) ~= int64(Code(k))
                if IMAGE(pos_shift+code_len*(j-1)+k)<0
                    Im(pos_shift+code_len*(j-1)+k) = IMAGE(pos_shift+code_len*(j-1)+k) + 1;
                else
                    Im(pos_shift+code_len*(j-1)+k) = IMAGE(pos_shift+code_len*(j-1)+k) - 1;
                end
            end
        end
    end    
    pos_shift = pos_shift + code_len*size(value,1)/2;
end
pos_end = dec2bin(pos_shift,16);

code_pos_end = gf2dec(bchenc(gf(double(pos_end) - 48),31,16),1,3);

for j = 1:31
    if mod(IMAGE(j),2) ~= int64(code_pos_end(j))
        if IMAGE(j)<0
            Im(j) = IMAGE(j) + 1;
        else
            Im(j) = IMAGE(j) - 1;
        end
    end
end
end