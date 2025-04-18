#!/bin/bash

# Maak de public directory aan als deze nog niet bestaat
mkdir -p public

# Download een favicon.ico placeholder
echo "Downloading placeholder favicon.ico..."
curl -s -o public/favicon.ico "https://placehold.co/32x32.png" || {
  echo "Failed to download favicon.ico, creating an empty file instead"
  touch public/favicon.ico
}

# Download een logo192.png placeholder
echo "Downloading placeholder logo192.png..."
curl -s -o public/logo192.png "https://placehold.co/192x192.png" || {
  echo "Failed to download logo192.png, creating an empty file instead"
  touch public/logo192.png
}

# Download een logo512.png placeholder
echo "Downloading placeholder logo512.png..."
curl -s -o public/logo512.png "https://placehold.co/512x512.png" || {
  echo "Failed to download logo512.png, creating an empty file instead"
  touch public/logo512.png
}

echo "Logo placeholders created successfully!"
