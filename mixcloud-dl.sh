#!/bin/bash
# Author : Oros
# Version 2018-08-11
# https://github.com/Oros42/mixcloud-dl
#
# « Some time you didn't have access to Internet.
# So you need to have an Internet backup. »
# :-/


if [ ! `which awk` ]; then
	echo "Please install awk."
    exit
fi
if [ ! `which wget` ]; then
	echo "Please install wget."
    exit
fi
if [ ! `which curl` ]; then
	echo "Please install curl."
    exit
fi
if [ ! `which ffmpeg` ]; then
	echo "Please install ffmpeg."
    exit
fi


if [ $# -eq 1 ]; then

    url=$1
    p=${url:25}

    username=$(echo $p | awk '{split($0,a,"/"); print a[1]}')
    slug=$(echo $p | awk '{split($0,a,"/"); print a[2]}')

    tmpFolder="./tmp/$username_$slug"
    mkdir -p $tmpFolder
    outFolder="./out/$username"
    mkdir -p $outFolder
    filename=$slug

    # Get cookie and csrftoken
    page=$(curl -c $tmpFolder/cookies.txt -b $tmpFolder/cookies.txt https://www.mixcloud.com/$username/$slug/)
    CSRFToken=$(grep "csrftoken" $tmpFolder/cookies.txt |awk -F"csrftoken\t" '{ print $NF}'|awk -F"'" '{ print $NR}')

    # Get URL for download
    repJson=$(
    curl --cookie $tmpFolder/cookies.txt \
      -H "Content-Type: application/json" \
      -H "X-CSRFToken: $CSRFToken" \
      -H "Referer: $url" \
      --request POST \
      --data "{\"id\":\"q10\",\"query\":\"query CloudcastHeader(\$lookup_0:CloudcastLookup!,\$lighten_1:Int!,\$alpha_2:Float!) {cloudcastLookup(lookup:\$lookup_0) {id,...Fo}} fragment F0 on Picture {urlRoot,primaryColor} fragment F1 on Cloudcast {picture {urlRoot,primaryColor},id} fragment F2 on Cloudcast {id,name,slug,owner {username,id}} fragment F3 on Cloudcast {owner {id,displayName,followers {totalCount}},id} fragment F4 on Cloudcast {restrictedReason,owner {username,id},slug,id,isAwaitingAudio,isDraft,isPlayable,streamInfo {hlsUrl,dashUrl,url,uuid},audioLength,currentPosition,proportionListened,seekRestriction,previewUrl,picture {primaryColor,isLight,_primaryColor2pfPSM:primaryColor(lighten:\$lighten_1),_primaryColor3Yfcks:primaryColor(alpha:\$alpha_2)}} fragment F5 on Node {id,__typename} fragment F6 on Cloudcast {id,isFavorited,isPublic,hiddenStats,favorites {totalCount},slug,owner {id,isFollowing,username,displayName,isViewer}} fragment F7 on Cloudcast {id,isUnlisted,isPublic} fragment F8 on Cloudcast {id,isReposted,isPublic,hiddenStats,reposts {totalCount},owner {isViewer,id}} fragment F9 on Cloudcast {id,isUnlisted,isPublic,slug,description,picture {urlRoot},owner {displayName,isViewer,username,id}} fragment Fa on Cloudcast {id,slug,isSpam,owner {username,isViewer,id}} fragment Fb on Cloudcast {owner {isViewer,username,id},sections {__typename,...F5},slug,canShowTracklist,id,...F6,...F7,...F8,...F9,...Fa} fragment Fc on TrackSection {artistName,songName,startSeconds,id} fragment Fd on ChapterSection {chapter,startSeconds,id} fragment Fe on Cloudcast {slug,owner {username,isViewer,id},sections {__typename,...Fc,...Fd,...F5},id} fragment Ff on Cloudcast {qualityScore,listenerMinutes,id} fragment Fg on Cloudcast {slug,plays,publishDate,hiddenStats,owner {username,id},id,...Ff} fragment Fh on User {id} fragment Fi on User {username,hasProFeatures,hasPremiumFeatures,isStaff,isSelect,id} fragment Fj on User {id,isFollowed,isFollowing,isViewer,followers {totalCount},username,displayName} fragment Fk on Cloudcast {owner {id,username,displayName,...Fh,...Fi,...Fj},id} fragment Fl on Cloudcast {id,streamInfo {uuid,url,hlsUrl,dashUrl},audioLength,seekRestriction,currentPosition} fragment Fm on Cloudcast {id,waveformUrl,previewUrl,audioLength,isPlayable,streamInfo {hlsUrl,dashUrl,url,uuid},seekRestriction,currentPosition} fragment Fn on Cloudcast {owner {isSelect,isSubscribedTo,username,displayName,id},id} fragment Fo on Cloudcast {id,name,juno {guid,chartUrl},picture {isLight,primaryColor,...F0},owner {displayName,isViewer,isBranded,selectUpsell {text},id},...F1,...F2,...F3,...F4,...Fb,...Fe,...Fg,...Fk,...Fl,...Fm,...Fn}\",\"variables\":{\"lookup_0\":{\"username\":\"$username\",\"slug\":\"$slug\"},\"lighten_1\":15,\"alpha_2\":0.3}}" \
        https://www.mixcloud.com/graphql
    )

    if [[ $(echo $repJson|grep '"waveformUrl":"') != "" ]]; then
        url=$(echo $repJson|awk -F'"waveformUrl":"' '{ print $NF}'|awk -F'.json?' '{ print $NR}')
        if [[ $(echo ${url:0:30}) == 'https://waveform.mixcloud.com/' ]]; then
            # $url == https://waveform.mixcloud.com/d/1/d/7/30a2-8bc7-4181-a03b-e713bf5fee31

            url="https://testcdn.mixcloud.com/secure/dash2/"${url:30}".m4a"
            # $url == https://testcdn.mixcloud.com/secure/dash2/d/1/d/7/30a2-8bc7-4181-a03b-e713bf5fee31.m4a

            wget -c $url/init-a1-x3.mp4 -O $tmpFolder/init-a1-x3.mp4 || exit
            cat $tmpFolder/init-a1-x3.mp4 > $outFolder/$filename.mp4
            #for i in {1..361}; do
            for i in {1..600}; do # fixme need to fine the true end
                wget -c $url/fragment-$i-a1-x3.m4s -O $tmpFolder/fragment-$i-a1-x3.m4s || break
                cat $tmpFolder/fragment-$i-a1-x3.m4s >> $outFolder/$filename.mp4
                sleep 2
            done
            ffmpeg -i $outFolder/$filename.mp4 $outFolder/$filename.mp3
            #rm -r $tmpFolder
            rm -f $outFolder/$filename.mp4
            echo "Done $outFolder/$filename.mp3"
        else
            echo "Error url :-("
        fi
    else
        #echo $repJson
        echo "Error :-("
    fi

else

    echo "Usage :"
    echo "$0 https://www.mixcloud.com/<USERNAME>/<TITLE>/"
    echo "$0 https://www.mixcloud.com/JoachimGarraud/zemixx-662-lightspeed/"

fi
