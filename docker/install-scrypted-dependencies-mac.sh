#!/usr/bin/env bash

if [ "$USER" == "root" ]
then
    echo "Installation must not be run as 'root'."
    exit 1
fi

set -x

RUN() {
    $@
    if [ "$?" != "0" ]
    then
        echo 'Error during previous command.'
        exit 1
    fi
}

echo "Installing Scrypted dependencies..."
# needed by scrypted-ffmpeg
RUN brew install sdl2
# gstreamer plugins
RUN brew install gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly
# gst python bindings
RUN brew install gst-python
RUN pip3 install --upgrade pip
RUN pip3 install aiofiles debugpy typing_extensions typing opencv-python

echo "Installing Scrypted..."
RUN npx -y scrypted install-server

RUN mkdir -p ~/Library/LaunchAgents
RUN cat << EOF | tee -a ~/Library/LaunchAgents/com.scrypted.server.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>RunAtLoad</key>
        <true/>
    <key>KeepAlive</key>
        <true/>
    <key>Label</key>
        <string>com.scrypted.server</string>
    <key>ProgramArguments</key>
        <array>
             <string>$(brew --prefix)/bin/npx</string>
             <string>-y</string>
             <string>scrypted</string>
             <string>serve</string>
        </array>
    <key>WorkingDirectory</key>
         <string>/Users/$(whoami)/.scrypted</string>
    <key>StandardOutPath</key>
        <string>/Users/$(whoami)/.scrypted/scrypted.log</string>
    <key>StandardErrorPath</key>
        <string>/Users/$(whoami)/.scrypted/scrypted.log</string>
    <key>UserName</key>
        <string>$(whoami)</string>
    <key>EnvironmentVariables</key>
        <dict>
            <key>PATH</key>
                <string>$(brew --prefix)/bin:$(brew --prefix)/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
            <key>HOME</key>
                <string>/Users/$(whoami)</string>
        </dict>
</dict>
</plist>
EOF

RUN launchctl load ~/Library/LaunchAgents/com.scrypted.server.plist
RUN launchctl start ~/Library/LaunchAgents/com.scrypted.server.plist

set +x
echo
echo
echo
echo
echo "Launch Scrypted with the following:"
echo "  npx -y scrypted serve"
echo
echo "Follow these instructions to create a service that runs on boot:"
echo "  https://github.com/koush/scrypted/wiki/Local-Installation#mac"
echo
echo
