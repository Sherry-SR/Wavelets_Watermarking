function information = watermark_decode(Im,bin_len,pos_shift,code_len)

code_pos_end = [];
for j = 1:31
    if mod(Im(j),2) == 0
        code_pos_end = [code_pos_end,'0'];
    else
        code_pos_end = [code_pos_end,'1'];
    end
end

pos_end = char(gf2dec(bchdec(gf(double(code_pos_end) - 48),31,16),1,3) + 48);

pos_end = bin2dec(pos_end);

num = (pos_end-pos_shift)/31;

information = [];
for j = 1:num
    temp = [];
    for k = 1:code_len
        if mod(Im(pos_shift+code_len*(j-1)+k),2) == 0
            temp = [temp,'0'];
        else
            temp = [temp,'1'];
        end
    end
    
    Decoded = char(gf2dec(bchdec(gf(double(temp) - 48),31,16),1,3) + 48);
    information = [information,char(bin2dec(Decoded(1:bin_len))),char(bin2dec(Decoded(bin_len+1:end)))];
end

end