name "Blip Editor"
author "glitchdetector"
contact "glitchdetector@gmail.com"
version "1.0"
download "https://github.com/glitchdetector/fivem-blip-editor"

game "gta5"
fx_version "adamant"

usage [[
    Create a blip:
    1. Open the pause menu map
    2. Place a POI marker (TAB, MMB, PS Triangle or Xbox Y)
    3. A window pops up, tweak as you see fit
    4. Click Save, Delete or Discard to close the window

    Edit a blip:
    1. Open the pause menu map
    2. Hover over the blip to edit (must be a blip created using the editor!)
    3. Hit the Edit button (Spacebar, PS Square, Xbox X)
    4. A window pops up, tweak as you see fit
    5. Click Save, Delete or Discard to close the window
]]
description "Allows you to place and edit blips using an in-game editor"

-- Config file
shared_script '_CONFIG.lua'
config_file '_CONFIG.lua'

shared_script 'sh_editor.lua'
server_script 'sv_editor.lua'
client_script 'cl_editor.lua'

files {'blips/*.png'}
file 'colorlist.js'
file 'spritelist.js'
file 'index.js'
file 'index.css'
file 'editor.html'

ui_page 'editor.html'
