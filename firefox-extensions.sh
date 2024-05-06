#from https://askubuntu.com/questions/73474/how-to-install-firefox-addon-from-command-line-in-scripts
#updated here https://stackoverflow.com/questions/37728865/install-webextensions-on-firefox-from-the-command-line
iAddon() {
  xpi=$(curl "$1" | grep -o "https://[a-z./0-9_+-]*.xpi") || exit 1
  temp=$(mktemp)
  wget "$xpi" --output-document="$temp"
  id=$(unzip -p "$temp" "manifest.json" | grep '"id": "' | sed -r 's|.*"(.*)".*|\1|')
  find "$HOME/.mozilla/firefox/" -name "extensions" -type d | while read f
  do
    if ! test -f "$f/$id.xpi"
    then
      ln "$temp" "$f/$id.xpi"
    fi
  done
  rm "$temp"
}

#tests
#I don't care about cookies
#iAddon "https://addons.mozilla.org/en-US/firefox/addon/i-dont-care-about-cookies/"
iAddon "https://addons.mozilla.org/firefox/downloads/file/4261710/ublock_origin-1.57.2.xpi"
#RSS preview
#iAddon "https://addons.mozilla.org/en-US/firefox/addon/rsspreview/
