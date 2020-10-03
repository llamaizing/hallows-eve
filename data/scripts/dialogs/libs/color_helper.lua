-- this wrapper provides an easy way to select common colors
-- if you'd like to set your own color short cut add it to the list
-- below (the 3 numbers correspond to the RGB values)
--
-- color - Either a string or a 3 value table corresponding to the 3 RGB values (0-255)
--
-- Examples
--   get_color('yellow')
--     #=> {200,200,0}
--
--   get_color({0,0,0})
--     #=> {0,0,0}
--
-- Returns a 3 value array corresponding to the color
function get_color(color)
  if type(color) == "string" then
    color = color:lower()
    if color == "white" then color = {255,255,255}
    elseif color == "red" then color = {255,0,0}
    elseif color == "green" then color = {0,255,0}
    elseif color == "blue" then color = {50,200,255}
    elseif color == "yellow" then color = {200,200,0}
    elseif color == "pink" then color = {255,0,150}
    elseif color == "black" then color = {0,0,0}
    elseif string.match(color, "{%d+,%d+,%d+}") then
      R,G,B = string.match(color, "{(%d+),(%d+),(%d+)}")
      color = {R,G,B}
    else color = {255,255,255}
    end
  elseif type(color) ~= 'table' or #color ~= 3 then
    color = {255,255,255}
  end

  return color
end