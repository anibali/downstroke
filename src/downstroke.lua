local _ = {}
local placeholder = _

local named_functions = {
  ['+'] = function(x, y) return x + y end,
  ['-'] = function(x, y) return x - y end,
  ['*'] = function(x, y) return x * y end,
  ['/'] = function(x, y) return x / y end,
  ['and'] = function(x, y) return x and y end,
  ['or'] = function(x, y) return x or y end,
  square = function(x) return x * x end
}

-- Function

_.get_function = function(func)
  if type(func) == 'function' then
    return func
  else
    return named_functions[func]
  end
end

_.partial = function(...)
  local args, n_args = _.pack(...)
  local func = args[1]
  return function(...)
    local passed_args, n_passed_args = _.pack(...)
    local passed_args_pos = 1
    local combined_args = {}
    local combined_args_pos = 1
    for i=2,n_args do
      if args[i] == placeholder then
        combined_args[combined_args_pos] = passed_args[passed_args_pos]
        passed_args_pos = passed_args_pos + 1
      else
        combined_args[combined_args_pos] = args[i]
      end
      combined_args_pos = combined_args_pos + 1
    end
    while passed_args_pos <= n_passed_args do
      combined_args[combined_args_pos] = passed_args[passed_args_pos]
      passed_args_pos = passed_args_pos + 1
      combined_args_pos = combined_args_pos + 1
    end
    return func(unpack(combined_args, 1, combined_args_pos - 1))
  end
end

-- Array

_.chunk = function(array, size)
  local chunked_array = {{}}
  local current_chunk = chunked_array[1]
  for i, element in ipairs(array) do
    if #current_chunk >= size then
      current_chunk = {}
      table.insert(chunked_array, current_chunk)
    end
    table.insert(current_chunk, element)
  end
  return chunked_array
end

_.compact = function(array)
  local compacted_array = {}
  for key, element in pairs(array) do
    if element then
      table.insert(compacted_array, element)
    end
  end
  return compacted_array
end

-- Util

_.flow = function(...)
  local functions = {...}
  local composed_function = function(...)
    local result = functions[1](...)
    for i=2,#functions do
      result = functions[i](result)
    end
    return result
  end
  return composed_function
end

_.identity = function(...)
  return ...
end

-- Returns the args in a table and the number of args
_.pack = function(...)
  return {...}, select('#', ...)
end

_.range = function(start, finish, step)
  if step == nil then step = 1 end
  local array = {}
  for i=start,finish,step do
    table.insert(array, i)
  end
  return array
end

-- Collection

_.filter = function(collection, func)
  func = _.get_function(func)
  local filtered_collection = {}
  for key, value in pairs(collection) do
    if func(value) then
      table.insert(filtered_collection, value)
    end
  end
  return filtered_collection
end

_.map = function(collection, func)
  func = _.get_function(func)
  local mapped_collection = {}
  for key, value in pairs(collection) do
    table.insert(mapped_collection, func(value))
  end
  return mapped_collection
end

_.reduce = function(collection, func, accumulator)
  func = _.get_function(func)
  local first_pass = true
  for key, value in pairs(collection) do
    if first_pass and accumulator == nil then
      first_pass = false
      accumulator = value
    else
      accumulator = func(accumulator, value)
    end
  end
  return accumulator
end

-- Map

_.to_pairs = function(map)
  local pair_array = {}
  for k,v in pairs(map) do
    table.insert(pair_array, {k, v})
  end
  return pair_array
end

-- String

_.ends_with = function(str, target, position)
  if position == nil then position = #str end
  return str:sub((position - #target) + 1, position) == target
end

_.starts_with = function(str, target, position)
  if position == nil then position = 1 end
  return str:sub(position, position + #target - 1) == target
end

return _
