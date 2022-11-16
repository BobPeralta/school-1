#!/bin/bash

# installation
sudo apt -qq update;
sudo apt -qq upgrade;
sudo apt -qq install asterisk;

# sip-config
sudo mv sip.conf sip.conf.bak >/dev/null 2>&1;

{
    echo -e "[general]
    context=public                  ; Default context for incoming calls. Defaults to 'default'
    allowoverlap=no                 ; Disable overlap dialing support. (Default is yes)
    udpbindaddr=0.0.0.0             ; IP address to bind UDP listen socket to (0.0.0.0 binds to all)
    tcpenable=no                    ; Enable server for incoming TCP connections (default is no)
    tcpbindaddr=0.0.0.0             ; IP address for TCP server to bind to (0.0.0.0 binds to all interfaces)
    transport=udp                   ; Set the default transports.  The order determines the primary default transport.
    srvlookup=yes                   ; Enable DNS SRV lookups on outbound calls
    qualify=yes                     ; monitors the phone (available, speed, etc.)"
} >> sip.conf;

while [ "$OK" != 1 ]
do
    read -rp "What language do you want to use (nl/en): " LANGUAGE;
    
    if [ "$LANGUAGE" == "nl" ]
    then
        echo -e "language=nl" >> sip.conf;
        
        sudo wget "https://github.com/Smile4Blitz/school/raw/main/MediaNetworks/LAB3/audio_nl.zip"
        sudo apt -qq install unzip;
        sudo unzip "audio_nl.zip";
        sudo rm -R /usr/share/asterisk/sounds/nl >/dev/null 2>&1;
        sudo mv "audio_nl" "nl";
        sudo mv "nl" "/usr/share/asterisk/sounds";
        
        OK=1;
    fi
    
    if [ "$LANGUAGE" == "en" ]
    then
        echo -e "language=en" >> sip.conf;

        sudo wget "https://github.com/Smile4Blitz/school/raw/main/MediaNetworks/LAB3/audio_en.zip"
        sudo apt -qq install unzip;
        sudo unzip "audio_en.zip";
        sudo rm -R /usr/share/asterisk/sounds/en >/dev/null 2>&1;
        sudo mv "audio_en" "en";
        sudo mv "en" "/usr/share/asterisk/sounds";

        OK=1;
    fi
    
    if [ "$OK" != 1 ]
    then
        echo -e "Not a supported language";
    fi
    
done

{
    echo -e "[authentication]
    [basic-options](!)
    dtmfmode=rfc2833
    context=from-office
    type=friend
    [natted-phone](!,basic-options)
    directmedia=no
    host=dynamic
    [public-phone](!,basic-options)
    directmedia=yes
    [my-codecs](!)
    allow=all
    [ulaw-phone](!)
    allow=all"
} >> sip.conf;

OK=0;

# dialplan and voicemail
sudo mv extensions.conf extensions.conf.bak >/dev/null 2>&1;
sudo mv voicemail.conf voicemail.conf.bak >/dev/null 2>&1;

echo "";
echo "Provide the usernames and their voicemail IDs.";

# extensions default config
echo -e "[phones]" >> extensions.conf

# voicemail default config
{
    echo -e "[general]
    format=wav49|gsm|wav
    serveremail=asterisk
    attach=yes
    skipms=3000
    maxsilence=10
    silencethreshold=128
    maxlogins=3
    emaildateformat=%A, %B %d, %Y at %r
    pagerdateformat=%A, %B %d, %Y at %r
    sendvoicemail=yes ; Allow the user to compose and send a voicemail while inside
[zonemessages]
    eastern=America/New_York|'vm-received' Q 'digits/at' IMp
    central=America/Chicago|'vm-received' Q 'digits/at' IMp
    central24=America/Chicago|'vm-received' q 'digits/at' H N 'hours'
    military=Zulu|'vm-received' q 'digits/at' H N 'hours' 'phonetic/z_p'
    european=Europe/Copenhagen|'vm-received' a d b 'digits/at' HM
    [default]"
} >> voicemail.conf;

while [ "$OK" != 1 ]
do
    echo "";
    read -rp "Enter a username (Leave blank when done): " NAME;
    if [ "$NAME" != "" ]
    then
        # SIP
        read -rp "Enter a phone number for this $NAME: " TEL_NR;
        read -rp "Enter a password (Leave blank for none): " PASSWORD;
        read -rp "Enter the voicemail-ID: " VOICEMAIL;
        read -rp "Enter the voicemail-password (numbers only): " VC_PASSWORD;

        if [ "$PASSWORD" != "" ]
        then
            {
                echo -e "[$NAME]
                type=friend
                context=phones
                secret=$PASSWORD
                host=dynamic
                mailbox=$VOICEMAIL@default"
            } >> sip.conf
        else
            {
                echo -e "[$NAME]
                type=friend
                context=phones
                host=dynamic
                mailbox=$VOICEMAIL@default"
            } >> sip.conf
        fi
        
        # extensions
        {
            echo -e "exten => $TEL_NR,1,Playback(custom/lalala)
same => n,Dial(SIP/$NAME,5)
same => n,Voicemail($VOICEMAIL@default,u)
same => n,Hangup()
exten => $VOICEMAIL,1,VoiceMailMain($VOICEMAIL@default)" 
        } >> extensions.conf;
        
        # voicemail
        {
            echo -e "$VOICEMAIL => $VC_PASSWORD,$NAME"
        } >> voicemail.conf;
        
        # reset variables
        NAME="";
        VOICEMAIL="";
    else
        OK=1;
    fi
done

# Move from tmp to dest
sudo mv sip.conf /etc/asterisk;
sudo mv voicemail.conf /etc/asterisk;
sudo mv extensions.conf /etc/asterisk;

# reload config
sudo systemctl restart asterisk

echo "";
echo "Done";
exit;