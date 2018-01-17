# CC attack protector
每10秒钟检测一次指定网站日志，如果超过预设限制的会在防火墙层面进行阻止，并运用Server酱进行通知

## 使用
```bash
git clone https://github.com/YKilin/CC-attack-protector.git
cd CC-attack-protector
```

然后修改`ddos.sh`前面的配置内容，根据注释说明修改即可  
其实一般情况下前三项设置并不用动，如果发现封禁效果与理想有差异再修改

建议使用 screen 来运行
```bash
#没有 screen 就安装
apt-get install screen
screen
#运行
bash run.sh
```

然后按下 Ctrl+A，再按下 D，即可退出 screen 界面

想回去的话就
```bash
screen -r
```

## 其他说明
1. 一旦有新 IP 被封禁，会输出封禁信息（当你回到 screen 后就可以看到），同时会输出日志到`ban.log`中
1. 如果想解封 IP，可以执行`bash ban.sh -ua`，这样会解封所有 IP
1. 关于`ban.sh`这个脚本还能做到的其他事情，请直接`bash ban.sh`查看
