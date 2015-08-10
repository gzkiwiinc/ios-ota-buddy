iOS OTA Buddy
=============

### 内部OTA使用文档

#### 局域网共享服务器设置

  * 将测试ipa文件放到“共享服务器->公共文件夹->distribution文件夹”内
  
  * 双击运行“start.command”文件
  
  * 访问“192.168.1.239:8080”，点击“Install App”即可
  
#### Linode设置

  * 将测试ipa文件放到东京linode主机的指定文件夹内
  
  * 运行"otabuddy.sh"文件
  
  * 访问"[域名]/distribution/index.html"，用户只需点击“Install App”即可


#### 七牛命令行工具配置

  * http://developer.qiniu.com/docs/v6/tools/qrsync.html

  需要配置七牛命令行

#### OTA文件改进事项

  1，配置上更人性化，在otabuddy.sh 文件上

  2，能够连接更多自动化脚本，提供一定的接口

  3，能够建立一个自动化运作的小系统
