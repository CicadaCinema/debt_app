#!/bin/sh
# scale down large png into smaller icon files and move them into an appropriate folder

convert icon-large-rendered.png -resize 192 ic_launcher.png
mv ./ic_launcher.png ./android/app/src/main/res/mipmap-hdpi/

convert icon-large-rendered.png -resize 144 ic_launcher.png
mv ./ic_launcher.png ./android/app/src/main/res/mipmap-mdpi/

convert icon-large-rendered.png -resize 96 ic_launcher.png
mv ./ic_launcher.png ./android/app/src/main/res/mipmap-xhdpi/

convert icon-large-rendered.png -resize 48 ic_launcher.png
mv ./ic_launcher.png ./android/app/src/main/res/mipmap-xxhdpi/

convert icon-large-rendered.png -resize 72 ic_launcher.png
mv ./ic_launcher.png ./android/app/src/main/res/mipmap-xxxhdpi/
