local EventEmitterMixin = require('rude.EventEmitterMixin')
local class = require('middleclass')

local testFunction = function() end

describe('EventEmitterMixin', function()
    local TestClass
    before_each(function()
        TestClass = class('TestClass')
        TestClass:include(EventEmitterMixin)
    end)

    describe('registerEventHandler()', function()
        describe('with no handlers registered', function()
            describe('and when called with no handler ID', function()
                it('returns 1', function()
                    local o = TestClass()
                    assert.is.equal(o:registerEventHandler('test', testFunction), 1)
                end)
            end)
            describe('and when called with a handler ID', function()
                it('returns the handler ID', function()
                    local o = TestClass()
                    assert.is.equal(o:registerEventHandler('test', testFunction, 2), 2)
                end)
            end)
        end)
        describe('with handlers registered', function()
            local o
            before_each(function()
                o = TestClass()
                o:registerEventHandler('test', testFunction, 1)
                o:registerEventHandler('test', testFunction, 3)
            end)
            describe('and when called with no handler ID', function()
                it('returns the next available handler ID', function()
                    assert.is.equal(o:registerEventHandler('test', testFunction), 2)
                end)
            end)
            describe('and when called with a handler ID', function()
                it('returns the handler ID', function()
                    assert.is.equal(o:registerEventHandler('test', testFunction, 4), 4)
                end)
            end)
        end)
    end)

    describe('emit()', function()
        it('calls all registered handlers', function()
            local o = TestClass()
            local s1 = spy.new(function() end)
            local s2 = spy.new(function() end)
            local f1 = function() s1() end
            local f2 = function() s2() end
            o:registerEventHandler('test', f1)
            o:registerEventHandler('test', f2)
            o:emit('test')
            assert.spy(s1).was.called(1)
            assert.spy(s2).was.called(1)
        end)
        it('calls all registered handlers in order', function()
            local o = TestClass()
            local result = ''
            local f1 = function() result = result..'1' end
            local f2 = function() result = result..'2' end
            o:registerEventHandler('test', f1)
            o:registerEventHandler('test', f2)
            o:emit('test')
            assert.is.equal(result, '12')
        end)
        it('only calls handlers registered to emitted event ID', function()
            local o = TestClass()
            local s1 = spy.new(function() end)
            local s2 = spy.new(function() end)
            local f1 = function() s1() end
            local f2 = function() s2() end
            o:registerEventHandler('test1', f1)
            o:registerEventHandler('test2', f2)
            o:emit('test1')
            assert.spy(s1).was.called(1)
            assert.spy(s2).was_not.called()
        end)
        it('passes args to event handlers', function()
            local o = TestClass()
            local s = spy.new(function(...) end)
            local f = function(...) s(...) end
            o:registerEventHandler('test', f)
            o:emit('test', 'foo', 'bar')
            assert.spy(s).was.called_with('foo', 'bar')
        end)
    end)

    describe('removeEventHandler()', function()
        it('removes previously registered handlers', function()
            local o = TestClass()
            local s1 = spy.new(function() end)
            local f1 = function() s1() end
            local ehId = o:registerEventHandler('test', f1)
            o:removeEventHandler('test', ehId)
            o:emit('test')
            assert.spy(s1).was_not.called()
        end)
    end)
end)