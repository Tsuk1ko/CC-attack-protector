# CC attack protector
每10秒钟检测一次指定网站日志，如果超过预设限制的（在单位时间请求数以及请求大小层面）会在防火墙层面进行阻止，并运用Server酱进行通知

## DEV 分支
实验性CC攻击判断法

## 使用
```bash
git clone https://github.com/YKilin/CC-attack-protector.git
cd CC-attack-protector
```

然后修改`ddos.sh`前面的配置内容，根据注释说明修改即可  
其实一般情况下关于CC攻击判断的设置并不用动，如果发现封禁效果与理想有差异再修改

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
1. 请记得开启站点的日志记录，而且面板用户要注意检查并取消掉“静态文件的`access_log off`”，也就是所有访问都要记录日志，以确保最佳的防CC效果
1. 日志的开头的格式必须为例如`x.x.x.x - - [22/Nov/2017:13:20:02 -0500] "GET /xxxxxx HTTP/1.1" 200 3386`，也就是IP在首列，时间格式与此示例相同，请求URL在第七列，请求长度在第十列，一般 nginx 日志的默认格式应该是这样，否则请根据自己的情况魔改`ddos.sh`里的相关截取日志信息的代码
1. 建议定期分割日志，例如使用 crontab 一天分割一次，以确保脚本检测效率
1. 一旦有新 IP 被封禁，会输出封禁信息（当你回到 screen 后就可以看到），同时会输出日志到`cc.log`中
1. 如果想解封 IP，可以执行`bash ban.sh -ua`，这样会解封所有 IP
1. 关于`ban.sh`这个脚本还能做到的其他事情，请直接`bash ban.sh`查看
