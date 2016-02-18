---
-- @module downstroke
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

---
-- Returns the function associated with name `func_name` (or nil if no such
-- function exists).
--
-- If `func_name` is a function, it is returned unchanged.
--
-- @usage
-- local add = _.get_function('+')
-- assert(add(40, 2) == 42)
_.get_function = function(func_name)
  if type(func_name) == 'function' then
    return func_name
  else
    return named_functions[func_name]
  end
end

---
-- Partially applies arguments to `func`.
--
-- @func func
-- @param[opt] ... The partials.
-- @usage
-- local halve = _.partial('/', _, 2)
-- assert(halve(10) == 5)
_.partial = function(...)
  local args, n_args = _.pack(...)
  local func = _.get_function(args[1])
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

---
-- Creates a copy of the array, but with all falsey elements excluded.
_.compact = function(array)
  local compacted_array = {}
  for i=1,#array do
    local element = array[i]
    if element then
      table.insert(compacted_array, element)
    end
  end
  return compacted_array
end

---
-- Converts an array of pairs (eg `{{'foo', 42}, {'bar', 27}}`) into an
-- associative table (eg `{foo=42, bar=27}`).
_.from_pairs = function(array_of_pairs)
  local dict = {}
  for i, pair in ipairs(array_of_pairs) do
    dict[pair[1]] = pair[2]
  end
  return dict
end

---
-- Returns the first `n` elements from the beginning of `array`.
--
-- @tparam table array
-- @tparam[opt=1] integer n
_.take = function(array, n)
  if n == nil then
    n = 1
  end
  local taken = {}
  for i, element in ipairs(array) do
    if i <= n then
      table.insert(taken, element)
    else
      break
    end
  end
  return taken
end

-- Util

---
-- Performs reverse function composition.
--
-- @func ... Functions to compose.
-- @usage
-- local find_min = _.flow(_.sort, _.take)
-- assert(find_min({4, 2, 3}) == 2)
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

---
-- Returns its arguments unchanged.
_.identity = function(...)
  return ...
end

---
-- @return An array containing the arguments
-- @return The number of arguments
_.pack = function(...)
  return {...}, select('#', ...)
end

---
-- Creates an array containing a range of numbers.
_.range = function(start, finish, step)
  if step == nil then step = 1 end
  local array = {}
  for i=start,finish,step do
    table.insert(array, i)
  end
  return array
end

-- Collection

---
-- Checks whether `collection` contains `target_value`.
_.contains = function(collection, target_value)
  for key, value in pairs(collection) do
    if value == target_value then
      return true
    end
  end
  return false
end

---
-- Calls `func` on each value in `collection`.
_.each = function(collection, func)
  func = _.get_function(func)
  for key, value in pairs(collection) do
    func(value, key)
  end
  return collection
end

---
-- Creates an array of values from `collection`, only including a value `v`
-- if `func(v)` is truthy.
_.filter = function(collection, func)
  func = _.get_function(func)
  local filtered_collection = {}
  for key, value in pairs(collection) do
    if func(value, key) then
      table.insert(filtered_collection, value)
    end
  end
  return filtered_collection
end

---
-- Applies `func` to each of the values in `collection`, and returns the results
-- in an array.
_.map = function(collection, func)
  func = _.get_function(func)
  local mapped_collection = {}
  for key, value in pairs(collection) do
    table.insert(mapped_collection, func(value, key))
  end
  return mapped_collection
end

---
-- Performs a left fold.
--
-- @usage
-- local total = _.reduce({1, 2, 3, 4}, '+', 0)
-- assert(total == 10)
_.reduce = function(collection, func, accumulator)
  func = _.get_function(func)
  local first_pass = true
  for key, value in pairs(collection) do
    if first_pass and accumulator == nil then
      first_pass = false
      accumulator = value
    else
      accumulator = func(accumulator, value, key)
    end
  end
  return accumulator
end

---
-- Randomly permutes the collection
_.shuffle = function(collection)
  collection = _.clone(collection)
  local shuffled = {}
  for i=1,#collection do
    table.insert(shuffled, table.remove(collection, math.random(1, #collection)))
  end
  return shuffled
end

---
-- Creates an array containing the values from `collection` in ascending
-- sorted order.
_.sort = function(collection)
  local sorted = _.clone(collection)
  table.sort(sorted)
  return sorted
end

---
-- Creates an array containing the values from `collection` in sorted order.
-- For two elements, a and b, it is guaranteed that a appears before b if
-- func(a) < func(b).
_.sort_by = function(collection, func)
  func = _.get_function(func)
  local sorted = _.clone(collection)
  table.sort(sorted, function(a, b)
    return func(a) < func(b)
  end)
  return sorted
end

-- Dict

---
-- Creates an array of key-value pairs from `dict`.
_.to_pairs = function(dict)
  local pair_array = {}
  for k,v in pairs(dict) do
    table.insert(pair_array, {k, v})
  end
  return pair_array
end

-- String

---
-- Checks if `str` ends with the given target string.
_.ends_with = function(str, target, position)
  if position == nil then position = #str end
  return str:sub((position - #target) + 1, position) == target
end

---
-- Checks if `str` starts with the given target string.
_.starts_with = function(str, target, position)
  if position == nil then position = 1 end
  return str:sub(position, position + #target - 1) == target
end

-- Lang

---
-- Creates a shallow clone of `value`.
_.clone = function(value)
  if type(value) == 'table' then
    local cloned = {}
    for key, value in pairs(value) do
      cloned[key] = value
    end
    return cloned
  else
    return value
  end
end

return _
