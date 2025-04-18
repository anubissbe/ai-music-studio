#!/bin/bash

# Genereer SVG logos
echo '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32"><rect width="32" height="32" fill="#3B82F6"/><text x="16" y="20" font-family="Arial" font-size="12" text-anchor="middle" fill="white">M</text></svg>' > public/favicon.svg
echo '<svg xmlns="http://www.w3.org/2000/svg" width="192" height="192"><rect width="192" height="192" fill="#3B82F6"/><text x="96" y="108" font-family="Arial" font-size="72" text-anchor="middle" fill="white">M</text></svg>' > public/logo192.svg
echo '<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512"><rect width="512" height="512" fill="#3B82F6"/><text x="256" y="280" font-family="Arial" font-size="180" text-anchor="middle" fill="white">M</text></svg>' > public/logo512.svg

# Gebruik SVG's als basis voor favicons
cp public/favicon.svg public/favicon.ico
cp public/logo192.svg public/logo192.png
cp public/logo512.svg public/logo512.png
