function information = watermark_decode(Im,bin_len,pos_shift);

pos_end = [];
for j = 1:16;
    if mod(Im(j),2) == 0;
        pos_end = [pos_end,'0'];
    else pos_end = [pos_end,'1'];
    end;
end;
pos_end = bin2dec(pos_end);
num = (pos_end-16)/8;

information = [];
for j = 1:num;
    temp = [];
    for k = 1:bin_len;
        if mod(Im(pos_shift+bin_len*(j-1)+k),2) == 0;
            temp = [temp,'0'];
        else temp = [temp,'1'];
        end;
    end;
    information = [information,char(bin2dec(temp))];
end;

end