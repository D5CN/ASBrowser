#!/bin/sh

AneVersion="2.11.0"
FreSwiftVersion="4.4.0"
FreSharpVersion="2.4.0"

wget -O ../ane/FreSwift.ane https://github.com/tuarua/Swift-IOS-ANE/releases/download/$FreSwiftVersion/FreSwift.ane?raw=true
wget -O ../ane/WebViewANE.ane https://github.com/tuarua/WebViewANE/releases/download/$AneVersion/WebViewANE.ane?raw=true
wget -O ../ane/FreSharp.ane https://github.com/tuarua/FreSharp/releases/download/$FreSharpVersion/FreSharp.ane?raw=true