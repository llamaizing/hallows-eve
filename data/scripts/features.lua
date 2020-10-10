-- Sets up all non built-in gameplay features specific to this quest.

-- Usage: require("scripts/features")

-- Features can be enabled to disabled independently by commenting
-- or uncommenting lines below.

--require"scripts/multiple_events"
require"scripts/multi_events"

require"scripts/coroutine_helper"
require"scripts/dialogs/visual_novel_manager"
require"scripts/fx/hero_shadow"
require"scripts/hud/hud"
--require"scripts/menus/dialog_box"
require"scripts/meta/bush"
require"scripts/meta/camera"
require"scripts/meta/carried_object"
require"scripts/meta/enemy"
require"scripts/meta/input"
require"scripts/meta/game"
require"scripts/meta/hero"
require"scripts/meta/map"

return true
