--[[ Copyright (C) 2018 Google Inc.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
]]

local maze_generation = require 'dmlab.system.maze_generation'
local tensor = require 'dmlab.system.tensor'
local log = require 'common.log'
local random = require 'common.random'
local make_map = require 'common.make_map'
local pickups = require 'common.pickups'
local custom_observations = require 'decorators.custom_observations'
local setting_overrides = require 'decorators.setting_overrides'

-- Generates a random maze with thick walls.
-- Apples are placed near the goal and spawn points away from it.
-- Timeout is set to 3 minutes.
local api = {}

local function getRandomEvenCoodinate(rows, cols)
  -- Shape must be bigger than 3 and odd.
  assert(rows > 2 and rows % 2 == 1)
  assert(cols > 2 and cols % 2 == 1)
  return {
      random:uniformInt(1, math.floor(rows / 2)) * 2,
      random:uniformInt(1, math.floor(cols / 2)) * 2
  }
end

local function findVisitableCells(r, c, mazeT)
  local shape = mazeT:shape()
  local vistableCells = {}
  if r - 2 > 1 and mazeT(r - 2, c):val() == 0 then
    vistableCells[#vistableCells + 1] = {{r - 2, c}, {r - 1, c}}
  end
  if c - 2 > 1 and mazeT(r, c - 2):val() == 0 then
    vistableCells[#vistableCells + 1] = {{r, c - 2}, {r, c - 1}}
  end

  if r + 2 < shape[1] and mazeT(r + 2, c):val() == 0 then
    vistableCells[#vistableCells + 1] = {{r + 2, c}, {r + 1, c}}
  end
  if c + 2 < shape[2] and mazeT(r, c + 2):val() == 0 then
    vistableCells[#vistableCells + 1] = {{r, c + 2}, {r, c + 1}}
  end
  return vistableCells
end

local function generateTensorMaze(rows, cols)
  local maze = tensor.ByteTensor(rows, cols)
  local start = getRandomEvenCoodinate(rows, cols)
  local stack = {start}
  while #stack ~= 0 do
    local r, c = unpack(stack[#stack])
    maze(r, c):val(1)
    local vistableCells = findVisitableCells(r, c, maze)
    if #vistableCells > 0 then
      local choice = vistableCells[random:uniformInt(1, #vistableCells)]
      maze(unpack(choice[2])):val(1)
      stack[#stack + 1] = choice[1]
    else
      stack[#stack] = nil
    end
  end
  return maze
end

function api:createPickup(classname)
  return pickups.defaults[classname]
end

function api:start(episode, seed, params)
  random:seed(seed)
  local rows, cols = 13, 13 --[[TODO: Change Size of Maze]]
  local mazeT = generateTensorMaze(rows, cols)
  local maze = maze_generation.mazeGeneration{height = rows, width = cols}
  local variations = {'.', 'A', 'B', 'C', 'D'}
  --[[mazeT:applyIndexed(function(val, index)
    local row, col = unpack(index)
    if 1 < row and row < rows and 1 < col and col < cols and
        random:uniformReal(0, 1) < 0.15 then
      maze:setEntityCell(row, col, ' ')
    else
      maze:setEntityCell(row, col, val == 0 and '*' or ' ')
    end
    local variation = 1
    variation = variation + (row > rows / 2 and 1 or 0)
    variation = variation + (col > cols / 2 and 2 or 0)
    maze:setVariationsCell(row, col, variations[variation])
  end)
  
  local goal = getRandomEvenCoodinate(rows, cols)
  maze:setEntityCell(goal[1], goal[2], 'G')

  maze:visitFill{
      cell = goal,
      func = function(row, col, distance)
        if distance > 5 and distance < 10 then
            maze:setEntityCell(row, col, 'P')
        end
        if 0 < distance and distance < 5 then
            maze:setEntityCell(row, col, 'A')
        end
      end
  }
  ]]
  
  --[[TODO: Change Rows/Columns for Walls and Textures (and optionally Goals, Pickups, Player Spawn Points]]

  maze:setEntityCell(1, 1, '*')
  maze:setEntityCell(1, 2, '*')
  maze:setEntityCell(1, 3, '*')
  maze:setEntityCell(1, 4, '*')
  maze:setEntityCell(1, 5, '*')
  maze:setEntityCell(1, 6, '*')
  maze:setEntityCell(1, 7, '*')
  maze:setEntityCell(1, 8, '*')
  maze:setEntityCell(1, 9, '*')
  maze:setEntityCell(1, 10, '*')
  maze:setEntityCell(1, 11, '*')
  maze:setEntityCell(1, 12, '*')
  maze:setEntityCell(1, 13, '*')


  maze:setEntityCell(2, 1, '*')
  maze:setEntityCell(2, 2, ' ')
  maze:setEntityCell(2, 3, ' ')
  maze:setEntityCell(2, 4, ' ')
  maze:setEntityCell(2, 5, '*')
  maze:setEntityCell(2, 6, '*')
  maze:setEntityCell(2, 7, '*')
  maze:setEntityCell(2, 8, '*')
  maze:setEntityCell(2, 9, '*')
  maze:setEntityCell(2, 10, '*')
  maze:setEntityCell(2, 11, '*')
  maze:setEntityCell(2, 12, '*')
  maze:setEntityCell(2, 13, '*')

  maze:setEntityCell(3, 1, '*')
  maze:setEntityCell(3, 2, ' ')
  maze:setEntityCell(3, 3, '*')
  maze:setEntityCell(3, 4, '*')
  maze:setEntityCell(3, 5, '*')
  maze:setEntityCell(3, 6, '*')
  maze:setEntityCell(3, 7, '*')
  maze:setEntityCell(3, 8, '*')
  maze:setEntityCell(3, 9, ' ')
  maze:setEntityCell(3, 10, ' ')
  maze:setEntityCell(3, 11, ' ')
  maze:setEntityCell(3, 12, '*')
  maze:setEntityCell(3, 13, '*')

  
  maze:setEntityCell(4, 1, '*')
  maze:setEntityCell(4, 2, ' ')
  maze:setEntityCell(4, 3, '*')
  maze:setEntityCell(4, 4, '*')
  maze:setEntityCell(4, 5, ' ')
  maze:setEntityCell(4, 6, ' ')
  maze:setEntityCell(4, 7, ' ')
  maze:setEntityCell(4, 8, '*')
  maze:setEntityCell(4, 9, '*')
  maze:setEntityCell(4, 10, '*')
  maze:setEntityCell(4, 11, ' ')
  maze:setEntityCell(4, 12, '*')
  maze:setEntityCell(4, 13, '*')

  maze:setEntityCell(5, 1, '*')
  maze:setEntityCell(5, 2, ' ')
  maze:setEntityCell(5, 3, '*')
  maze:setEntityCell(5, 4, '*')
  maze:setEntityCell(5, 5, ' ')
  maze:setEntityCell(5, 6, '*')
  maze:setEntityCell(5, 7, ' ')
  maze:setEntityCell(5, 8, '*')
  maze:setEntityCell(5, 9, ' ')
  maze:setEntityCell(5, 10, ' ')
  maze:setEntityCell(5, 11, ' ')
  maze:setEntityCell(5, 12, '*')
  maze:setEntityCell(5, 13, '*')


  maze:setEntityCell(6, 1, '*')
  maze:setEntityCell(6, 2, ' ')
  maze:setEntityCell(6, 3, '*')
  maze:setEntityCell(6, 4, '*')
  maze:setEntityCell(6, 5, ' ')
  maze:setEntityCell(6, 6, '*')
  maze:setEntityCell(6, 7, '*')
  maze:setEntityCell(6, 8, '*')
  maze:setEntityCell(6, 9, ' ')
  maze:setEntityCell(6, 10, '*')
  maze:setEntityCell(6, 11, ' ')
  maze:setEntityCell(6, 12, '*')
  maze:setEntityCell(6, 13, '*')


  maze:setEntityCell(7, 1, '*')
  maze:setEntityCell(7, 2, ' ')
  maze:setEntityCell(7, 3, ' ')
  maze:setEntityCell(7, 4, ' ')
  maze:setEntityCell(7, 5, ' ')
  maze:setEntityCell(7, 6, ' ')
  maze:setEntityCell(7, 7, ' ')
  maze:setEntityCell(7, 8, ' ')
  maze:setEntityCell(7, 9, ' ')
  maze:setEntityCell(7, 10, '*')
  maze:setEntityCell(7, 11, ' ')
  maze:setEntityCell(7, 12, '*')
  maze:setEntityCell(7, 13, '*')


  maze:setEntityCell(8, 1, '*')
  maze:setEntityCell(8, 2, ' ')
  maze:setEntityCell(8, 3, '*')
  maze:setEntityCell(8, 4, '*')
  maze:setEntityCell(8, 5, ' ')
  maze:setEntityCell(8, 6, '*')
  maze:setEntityCell(8, 7, '*')
  maze:setEntityCell(8, 8, ' ')
  maze:setEntityCell(8, 9, '*')
  maze:setEntityCell(8, 10, '*')
  maze:setEntityCell(8, 11, ' ')
  maze:setEntityCell(8, 12, ' ')
  maze:setEntityCell(8, 13, '*')


  maze:setEntityCell(9, 1, '*')
  maze:setEntityCell(9, 2, ' ')
  maze:setEntityCell(9, 3, '*')
  maze:setEntityCell(9, 4, '*')
  maze:setEntityCell(9, 5, ' ')
  maze:setEntityCell(9, 6, '*')
  maze:setEntityCell(9, 7, '*')
  maze:setEntityCell(9, 8, ' ')
  maze:setEntityCell(9, 9, '*')
  maze:setEntityCell(9, 10, '*')
  maze:setEntityCell(9, 11, '*')
  maze:setEntityCell(9, 12, '*')
  maze:setEntityCell(9, 13, '*')


  maze:setEntityCell(10, 1, '*')
  maze:setEntityCell(10, 2, ' ')
  maze:setEntityCell(10, 3, '*')
  maze:setEntityCell(10, 4, '*')
  maze:setEntityCell(10, 5, '*')
  maze:setEntityCell(10, 6, '*')
  maze:setEntityCell(10, 7, '*')
  maze:setEntityCell(10, 8, ' ')
  maze:setEntityCell(10, 9, '*')
  maze:setEntityCell(10, 10, '*')
  maze:setEntityCell(10, 11, '*')
  maze:setEntityCell(10, 12, '*')
  maze:setEntityCell(10, 13, '*')
  

  maze:setEntityCell(11, 1, '*')
  maze:setEntityCell(11, 2, ' ')
  maze:setEntityCell(11, 3, ' ')
  maze:setEntityCell(11, 4, ' ')
  maze:setEntityCell(11, 5, ' ')
  maze:setEntityCell(11, 6, ' ')
  maze:setEntityCell(11, 7, ' ')
  maze:setEntityCell(11, 8, ' ')
  maze:setEntityCell(11, 9, '*')
  maze:setEntityCell(11, 10, '*')
  maze:setEntityCell(11, 11, '*')
  maze:setEntityCell(11, 12, '*')
  maze:setEntityCell(11, 13, '*')


  maze:setEntityCell(12, 1, '*')
  maze:setEntityCell(12, 2, '*')
  maze:setEntityCell(12, 3, '*')
  maze:setEntityCell(12, 4, '*')
  maze:setEntityCell(12, 5, '*')
  maze:setEntityCell(12, 6, '*')
  maze:setEntityCell(12, 7, '*')
  maze:setEntityCell(12, 8, '*')
  maze:setEntityCell(12, 9, '*')
  maze:setEntityCell(12, 10, '*')
  maze:setEntityCell(12, 11, '*')
  maze:setEntityCell(12, 12, '*')
  maze:setEntityCell(12, 13, '*')

  maze:setEntityCell(13, 1, '*')
  maze:setEntityCell(13, 2, '*')
  maze:setEntityCell(13, 3, '*')
  maze:setEntityCell(13, 4, '*')
  maze:setEntityCell(13, 5, '*')
  maze:setEntityCell(13, 6, '*')
  maze:setEntityCell(13, 7, '*')
  maze:setEntityCell(13, 8, '*')
  maze:setEntityCell(13, 9, '*')
  maze:setEntityCell(13, 10, '*')
  maze:setEntityCell(13, 11, '*')
  maze:setEntityCell(13, 12, '*')
  maze:setEntityCell(13, 13, '*')



  log.info('Maze Generated:\n' .. maze:entityLayer())

  log.info('Adding Layer Variations:')


  maze:setVariationsCell(7, 5, 'A')
  maze:setVariationsCell(8, 5, 'A')
  maze:setVariationsCell(9, 5, 'A')

  maze:setVariationsCell(2, 2, 'E')
  maze:setVariationsCell(2, 3, 'E')
  maze:setVariationsCell(2, 4, 'E')

  maze:setVariationsCell(3, 2, 'E')
  maze:setVariationsCell(4, 2, 'E')
  maze:setVariationsCell(5, 2, 'E')
  maze:setVariationsCell(6, 2, 'E')

  maze:setVariationsCell(7, 2, 'E')
  maze:setVariationsCell(7, 3, 'E')
  maze:setVariationsCell(7, 4, 'E')

  maze:setVariationsCell(8, 2, 'E')
  maze:setVariationsCell(9, 2, 'E')
  maze:setVariationsCell(10, 2, 'E')
  maze:setVariationsCell(11, 2, 'E')

  maze:setVariationsCell(11, 2, 'E')
  maze:setVariationsCell(11, 3, 'E')
  maze:setVariationsCell(11, 4, 'E')
  maze:setVariationsCell(11, 5, 'E')
  maze:setVariationsCell(11, 6, 'E')
  maze:setVariationsCell(11, 7, 'E')


  maze:setVariationsCell(4, 5, 'F')
  maze:setVariationsCell(4, 6, 'F')
  maze:setVariationsCell(4, 7, 'F')
  maze:setVariationsCell(5, 5, 'F')
  maze:setVariationsCell(5, 7, 'F')
  maze:setVariationsCell(6, 5, 'F')


  maze:setVariationsCell(3, 9, 'G')
  maze:setVariationsCell(3, 10, 'G')
  maze:setVariationsCell(3, 11, 'G')
  maze:setVariationsCell(4, 11, 'G')
  maze:setVariationsCell(5, 9, 'G')
  maze:setVariationsCell(5, 10, 'G')
  maze:setVariationsCell(5, 11, 'G')
  maze:setVariationsCell(6, 9, 'G')
  maze:setVariationsCell(6, 11, 'G')


  maze:setVariationsCell(7, 6, 'G')
  maze:setVariationsCell(7, 7, 'G')
  maze:setVariationsCell(7, 8, 'G')
  maze:setVariationsCell(7, 9, 'G')
  maze:setVariationsCell(7, 11, 'G')

  maze:setVariationsCell(8, 8, 'G')
  maze:setVariationsCell(8, 11, 'G')
  maze:setVariationsCell(8, 12, 'G')

  maze:setVariationsCell(9, 8, 'G')
  maze:setVariationsCell(10, 8, 'G')
  maze:setVariationsCell(11, 8, 'G')



  log.info('Adding Goal and Spawn points and Pickups:')
  maze:setEntityCell(8, 12, 'G')
  maze:setEntityCell(9, 5, 'P')
  --maze:setEntityCell(2, 2, 'A')
  --maze:setEntityCell(2, 7, 'A')
  --maze:setEntityCell(2, 11, 'W')

  log.info('Maze:\n' .. maze:entityLayer())
  api._maze_name = make_map.makeMap{
      mapName = '5_5_maze',
      mapEntityLayer = maze:entityLayer(),
      mapVariationsLayer = maze:variationsLayer()
  }
end

function api:nextMap()
  return api._maze_name
end

custom_observations.decorate(api)
setting_overrides.decorate{
    api = api,
    apiParams = {episodeLengthSeconds = 8 * 60, camera = {750, 750, 750}},
    decorateWithTimeout = true
}

return api
