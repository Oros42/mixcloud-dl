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
wget https://raw.githubusercontent.com/Oros42/mixcloud-dl/master/mixcloud-dl.sh -O mixcloud-dl.sh
chmod u+x mixcloud-dl.sh
```

Usage
=====

```
./mixcloud-dl.sh https://www.mixcloud.com/<USERNAME>/<TITLE>/
```
Output : ./out/<USERNAME>/<TITLE>.mp3  
  
Example :  
```
./mixcloud-dl.sh https://www.mixcloud.com/JoachimGarraud/zemixx-662-lightspeed/
```
Output : ./out/JoachimGarraud/zemixx-662-lightspeed.mp3
