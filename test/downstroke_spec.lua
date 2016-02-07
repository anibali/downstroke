local _ = require('downstroke')

describe('downstroke', function()
  describe('partial', function()
    it('works', function()
      local concat_args = function(...) return table.concat({...}) end
      local expected = 'abcde'
      local actual = _.partial(concat_args, 'a', _, 'c', _)('b', 'd', 'e')
      assert.are.same(expected, actual)
    end)
  end)

  describe('chunk', function()
    it('works', function()
      local array = {'a', 'b', 'c', 'd', 'e'}
      local expected = {{'a', 'b'},  {'c', 'd'}, {'e'}}
      local actual = _.chunk(array, 2)
      assert.are.same(expected, actual)
    end)
  end)

  describe('compact', function()
    it('works', function()
      local array = {'a', nil, 'b', 'c', nil}
      local expected = {'a', 'b', 'c'}
      local actual = _.compact(array)
      assert.are.same(expected, actual)
    end)
  end)

  describe('take', function()
    it('works', function()
      local array = {'a', 'b', 'c', 'd', 'e'}
      local expected = {'a', 'b', 'c'}
      local actual = _.take(array, 3)
      assert.are.same(expected, actual)
    end)
  end)

  describe('flow', function()
    it('works', function()
      local f = function(s) return 'f(' .. s .. ')' end
      local g = function(s) return 'g(' .. s .. ')' end
      local expected = 'g(f(x))'
      local actual = _.flow(f, g)('x')
      assert.are.same(expected, actual)
    end)
  end)

  describe('identity', function()
    it('works', function()
      local a = 'foo'
      local b = 'bar'
      local actual_a, actual_b = _.identity(a, b)
      assert.are.same(a, actual_a)
      assert.are.same(b, actual_b)
    end)
  end)

  describe('range', function()
    it('works', function()
      local expected = {-2, -1, 0, 1, 2, 3}
      local actual = _.range(-2, 3)
      assert.are.same(expected, actual)
    end)
  end)

  describe('contains', function()
    it('works', function()
      local array = {2, 4, 6}
      assert.is_true(_.contains(array, 4))
      assert.is_false(_.contains(array, 5))
    end)
  end)

  describe('each', function()
    it('works', function()
      local array = {2, 4, 6}
      local array_copy = {}
      _.each(array, function(value, key)
        array_copy[key] = value
      end)
      assert.are.same(array, array_copy)
    end)
  end)

  describe('filter', function()
    it('works', function()
      local array = {1, 2, 3, 4, 5}
      local is_even = function(x) return x % 2 == 0 end
      local expected = {2, 4}
      local actual = _.filter(array, is_even)
      assert.are.same(expected, actual)
    end)
  end)

  describe('map', function()
    it('works', function()
      local array = {4, 8}
      local expected = {16, 64}
      local actual = _.map(array, 'square')
      assert.are.same(expected, actual)
    end)
  end)

  describe('reduce', function()
    it('works', function()
      local array = {'w', 'o', 'r', 'l', 'd'}
      local concat = function(x, y) return x .. y end
      local expected = 'Hello world'
      local actual = _.reduce(array, concat, 'Hello ')
      assert.are.same(expected, actual)
    end)
  end)

  describe('sort_by', function()
    it('works', function()
      local array = {5, 2, -6}
      local expected = {2, 5, -6}
      local actual = _.sort_by(array, math.abs)
      assert.are.same(expected, actual)
    end)
  end)

  describe('to_pairs', function()
    it('works', function()
      local map = {foo=42, bar=27}
      local expected = {{'foo', 42}, {'bar', 27}}
      assert.are.same(expected, _.to_pairs(map))
    end)
  end)

  describe('ends_with', function()
    it('works', function()
      assert.is_true(_.ends_with('institution', 'ion'))
    end)
  end)

  describe('starts_with', function()
    it('works', function()
      assert.is_true(_.starts_with('institution', 'ins'))
    end)
  end)
end)
