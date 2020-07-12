Config = {}

--[==[
    Runs the blip selection logic in the resource itself without relying on
    a third party system. Due to game limitations only one resource can
    read this data, which is why a third party might be required.
    Default: false (requires Blip Hover Utility)
]==]--
Config.STANDALONE_MODE = true --[[true / false based on above details]]

--[==[
    Allow the creation of new blips by placing Points of Interest
    Upon placing a POI, the Blip Editor menu will appear at the POI's
    location.
]==]--
Config.ALLOW_CREATING = true --[[true / false based on above details]]

--[==[
    Allows you to select and edit a created blip
    Allows you to edit any blip created using this editor
]==]--
Config.ALLOW_EDIT = true --[[true / false based on above details]]

--[==[
    Allows created blips to be deleted
    Default: true
]==]--
Config.ALLOW_DELETE = true --[[true / false based on above details]]

--[==[
    Only the player who created the blip can edit it
    Default: false
]==]--
Config.OWNERSHIP = false --[[true / false based on above details]]

--[==[
    Check for ACE permissions when creating a new blip and
    editing an existing one.
    Creating & Editing: blipeditor.save
    Deleting: blipeditor.delete
    Default: false
]==]--
Config.ACE_PERMISSIONS = false --[[true / false based on above details]]
