% https://github.com/slowpeek/my-reddit/bash-read-vs-head

a = dlmread(stdin);

u = a(:,1) / 1e3;
v = a(:,3:4) - a(:,2:3);

w = 1024;
h = 600;

ss = get(0, 'screensize');
figure('position', [(ss(3)-w)/2, (ss(4)-h)/2, w, h]);
hold;
grid on;

grey = [1, 1, 1]/2;
xlabel('Bytes per read, thousands', 'color', grey);
ylabel('Time, sec', 'color', grey);

[l, r] = deal(min(u), max(u));
xlim([l r]);
set(gca, 'xtick', l:(r-l)/10:r);

plot(u, v(:,1), 'b+;read -N;');
plot(u, v(:,2), 'r+;head -c;');

pause(0);
uiwait;
