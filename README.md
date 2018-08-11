# mixcloud-dl
Download musique from mixcloud

« Some time you didn't have access to Internet.  
So you need to have an Internet backup. »  

Require
=======
  
- bash  
- awk  
- wget  
- curl  
- ffmpeg  
  
Setup
=====

```
wget https://raw.githubusercontent.com/Oros42/mixcloud-dl/master/mixcloud-dl -O mixcloud-dl
chmod u+x mixcloud-dl
```

Usage
=====

```
./mixcloud-dl https://www.mixcloud.com/<USERNAME>/<TITLE>/
```
Output : <TITLE>.mp3  
  
Example :  
```
./mixcloud-dl https://www.mixcloud.com/JoachimGarraud/zemixx-662-lightspeed/
```
Output : zemixx-662-lightspeed.mp3