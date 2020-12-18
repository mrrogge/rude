local alert = require('rude.alert')
local Engine = require('rude.Engine')
local Scene = require('rude.Scene')

describe('a Scene instance', function()
    local engine, scene
    before_each(function()
        engine = Engine()
        scene = Scene(engine)
    end)
    describe('initialize()', function()
        it('assigns passed engine to engine prop', function()
            scene = Scene(engine)
            assert.is.equal(scene.engine, engine)
        end)
        it('returns returns the instance', function()
            scene = Scene(engine)
            assert.is.equal(scene, scene:initialize(engine))
        end)
    end)

    describe('whileStarting()', function()
        it('calls finishStarting()', function()
            spy.on(scene, 'finishStarting')
            scene:whileStarting(0.1)
            assert.spy(scene.finishStarting).was.called()
        end)
    end)

    describe('finishStarting()', function()
        it('prevents whileStarting() from being called on future updates', function()
            spy.on(scene, 'whileStarting')
            scene:finishStarting()
            scene:update(0.1)
            assert.spy(scene.whileStarting).was_not.called()
        end)
    end)

    describe('pause()', function()
        it('while scene is running, enables whilePausing() to be called during update()', function()
            scene:resume()
            scene:update(0.1)
            spy.on(scene, 'whilePausing')
            scene:pause()
            scene:update(0.1)
            assert.spy(scene.whilePausing).was.called()
        end)
        it('when whilePausing() does NOT call finishPausing() right away, this does not stop onUpdate() from being called', function()
            scene:resume()
            scene:update(0.1)
            scene.whilePausing = function(dt) end
            spy.on(scene, 'onUpdate')
            scene:pause()
            scene:update(0.1)
            assert.spy(scene.onUpdate).was.called()
        end)
    end)

    describe('whilePausing()', function()
        it('calls finishPausing()', function()
            spy.on(scene, 'finishPausing')
            scene:whilePausing(0.1)
            assert.spy(scene.finishPausing).was.called()
        end)
    end)

    describe('finishPausing()', function()
        it('pauses the scene, preventing onUpdate() from being called', function()
            scene:resume()
            scene:update(0.1)
            scene:pause()
            spy.on(scene, 'onUpdate')
            scene:finishPausing()
            scene:update(0.1)
            assert.spy(scene.onUpdate).was_not.called()
        end)
        it('prevents whilePausing() from being called', function()
            scene:resume()
            scene:update(0.1)
            scene:pause()
            spy.on(scene, 'whilePausing')
            scene:finishPausing()
            scene:update(0.1)
            assert.spy(scene.whilePausing).was_not.called()
        end)
    end)

    describe('resume()', function()
        it('while scene is paused, allows whileResuming() to be called during update', function()
            spy.on(scene, 'whileResuming')
            scene:resume()
            scene:update(0.1)
            assert.spy(scene.whileResuming).was.called()
        end)
        it('when whileResuming() does NOT call finishResuming() right away, this does not allow onUpdate() to be called while updating', function()
            scene.whileResuming = function(dt) end
            spy.on(scene, 'onUpdate')
            scene:resume()
            scene:update(0.1)
            assert.spy(scene.onUpdate).was_not.called()
        end)
    end)

    describe('whileResuming()', function()
        it('calls finishResuming()', function()
            spy.on(scene, 'finishResuming')
            scene:whileResuming(0.1)
            assert.spy(scene.finishResuming).was.called()
        end)
    end)

    describe('finishResuming()', function()
        it('resumes the scene, allowing onUpdate() to be called again', function()
            scene:resume()
            spy.on(scene, 'onUpdate')
            scene:finishResuming()
            scene:update(0.1)
            assert.spy(scene.onUpdate).was.called()
        end)
        it('prevents whileResuming() from being called', function()
            scene:resume()
            spy.on(scene, 'whileResuming')
            scene:finishResuming()
            scene:update(0.1)
            assert.spy(scene.whileResuming).was_not.called()
        end)
    end)

    describe('hide()', function()
        it('allows whileHiding() to be called when updating', function()
            scene:show()
            scene:finishShowing()
            spy.on(scene, 'whileHiding')
            scene:hide()
            scene:update(0.1)
            assert.spy(scene.whileHiding).was.called()
        end)
        it('does not stop onDraw() from being called', function()
            scene:show()
            scene:finishShowing()
            spy.on(scene, 'onDraw')
            scene:hide()
            scene:draw()
            assert.spy(scene.onDraw).was.called()
        end)
    end)

    describe('whileHiding()', function()
        it('calls finishHiding()', function()
            spy.on(scene, 'finishHiding')
            scene:whileHiding(0.1)
            assert.spy(scene.finishHiding).was.called()
        end)
    end)

    describe('finishHiding()', function()
        it('prevents onDraw() from being called during draws', function()
            scene:show()
            scene:finishShowing()
            scene:hide()
            spy.on(scene, 'onDraw')
            scene:finishHiding()
            scene:draw()
            assert.spy(scene.onDraw).was_not.called()
        end)
        it('prevents whileHiding() from being called during update', function()
            scene:show()
            scene:finishShowing()
            scene:hide()
            spy.on(scene, 'whileHiding')
            scene:finishHiding()
            scene:update(0.1)
            assert.spy(scene.whileHiding).was_not.called()
        end)
    end)

    describe('show()', function()
        it('allows whileShowing() to be called when updating', function()
            spy.on(scene, 'whileShowing')
            scene:show()
            scene:update(0.1)
            assert.spy(scene.whileShowing).was.called()
        end)
        it('allows onDraw() to be called when drawing', function()
            spy.on(scene, 'onDraw')
            scene:show()
            scene:draw()
            assert.spy(scene.onDraw).was.called()
        end)
    end)

    describe('whileShowing()', function()
        it('calls finishShowing()', function()
            spy.on(scene, 'finishShowing')
            scene:whileShowing(0.1)
            assert.spy(scene.finishShowing).was.called()
        end)
    end)

    describe('finishShowing()', function()
        it('allows onDraw() to be called when drawing', function()
            scene:show()
            spy.on(scene, 'onDraw')
            scene:finishShowing()
            scene:draw()
            assert.spy(scene.onDraw).was.called()
        end)
        it('prevents whileShowing() from being called when updating', function()
            scene:show()
            spy.on(scene, 'whileShowing')
            scene:finishShowing()
            scene:update(0.1)
            assert.spy(scene.whileShowing).was_not.called()
        end)
    end)

    describe('onUpdate()', function()
        it('does not error', function()
            assert.has_no.errors(function()
                scene:onUpdate(0.1)
            end)
        end)
    end)

    describe('update()', function()
        it('when starting calls whileStarting()', function()
            spy.on(scene, 'whileStarting')
            scene:update(0.1)
            assert.spy(scene.whileStarting).was.called()
        end)
        it('when started does not call whileStarting()', function()
            scene:finishStarting()
            spy.on(scene, 'whileStarting')
            scene:update(0.1)
            assert.spy(scene.whileStarting).was_not.called()
        end)
        it('when paused does not call onUpdate()', function()
            spy.on(scene, 'onUpdate')
            scene:update(0.1)
            assert.spy(scene.onUpdate).was_not.called()
        end)
        it('when running calls onUpdate()', function()
            scene:resume()
            scene:finishResuming()
            spy.on(scene, 'onUpdate')
            scene:update(0.1)
            assert.spy(scene.onUpdate).was.called()
        end)
        it('when pausing calls onUpdate()', function()
            scene:resume()
            scene:finishResuming()
            scene:pause()
            scene.whilePausing = function(dt) end
            spy.on(scene, 'onUpdate')
            scene:update(0.1)
            assert.spy(scene.onUpdate).was.called()
        end)
        it('when pausing calls whilePausing()', function()
            scene:resume()
            scene:finishResuming()
            scene:pause()
            spy.on(scene, 'whilePausing')
            scene:update(0.1)
            assert.spy(scene.whilePausing).was.called()
        end)
        it('when resuming calls whileResuming()', function()
            scene:resume()
            spy.on(scene, 'whileResuming')
            scene:update(0.1)
            assert.spy(scene.whileResuming).was.called()
        end)
        it('when resuming does not call onUpdate()', function()
            scene:resume()
            scene.whileResuming = function(dt) end
            spy.on(scene, 'onUpdate')
            scene:update(0.1)
            assert.spy(scene.onUpdate).was_not.called()
        end)
        it('when showing calls whileShowing()', function()
            scene:show()
            spy.on(scene, 'whileShowing')
            scene:update(0.1)
            assert.spy(scene.whileShowing).was.called()        
        end)
        it('when hiding calls whileHiding()', function()
            scene:show()
            scene:finishShowing()
            scene:hide()
            spy.on(scene, 'whileHiding')
            scene:update(0.1)
            assert.spy(scene.whileHiding).was.called()
        end)
    end)

    describe('onDraw()', function()
        it('does not error', function()
            assert.has_no.errors(function()
                scene:onDraw()
            end)
        end)
    end)

    describe('draw()', function()
        it('when invisible does not call onDraw()', function()
            spy.on(scene, 'onDraw')
            scene:draw()
            assert.spy(scene.onDraw).was_not.called()
        end)
        it('when showing calls onDraw()', function()
            scene:show()
            spy.on(scene, 'onDraw')
            scene:draw()
            assert.spy(scene.onDraw).was.called()
        end)
        it('when visible calls onDraw()', function()
            scene:show()
            scene:finishShowing()
            spy.on(scene, 'onDraw')
            scene:draw()
            assert.spy(scene.onDraw).was.called()
        end)
        it('when hiding calls onDraw()', function()
            scene:show()
            scene:finishShowing()
            scene:hide()
            spy.on(scene, 'onDraw')
            scene:draw()
            assert.spy(scene.onDraw).was.called()
        end)
    end)

    describe('onKeypressed()', function()
        it('does not error', function()
            assert.has_no.errors(function()
                scene:onKeypressed('','',false)
            end)
        end)
    end)

    describe('keypressed()', function()
        it('calls onKeypressed()', function()
            spy.on(scene, 'onKeypressed')
            scene:keypressed('','',false)
            assert.spy(scene.onKeypressed).was.called()
        end)
    end)

    describe('onKeyreleased()', function()
        it('does not error', function()
            assert.has_no.errors(function()
                scene:onKeyreleased('','')
            end)
        end)
    end)

    describe('keyreleased()', function()
        it('calls onKeyreleased()', function()
            spy.on(scene, 'onKeyreleased')
            scene:keyreleased('','')
            assert.spy(scene.onKeyreleased).was.called()
        end)
    end)

    describe('onMousemoved()', function()
        it('does not error', function()
            assert.has_no.errors(function()
                scene:onMousemoved(0,0,0,0,false)
            end)
        end)
    end)

    describe('mousemoved()', function()
        it('calls onMousemoved()', function()
            spy.on(scene, 'onMousemoved')
            scene:mousemoved(0,0,0,0,false)
            assert.spy(scene.onMousemoved).was.called()
        end)
    end)

    describe('onMousepressed()', function()
        it('does not error', function()
            assert.has_no.errors(function()
                scene:onMousepressed(0,0,0,false,1)
            end)
        end)
    end)

    describe('mousepressed()', function()
        it('calls onMousepressed()', function()
            spy.on(scene, 'onMousepressed')
            scene:mousepressed(0,0,0,false,1)
            assert.spy(scene.onMousepressed).was.called()
        end)
    end)

    describe('onMousereleased()', function()
        it('does not error', function()
            assert.has_no.errors(function()
                scene:onMousereleased(0,0,0,false,1)
            end)
        end)
    end)

    describe('mouserelased()', function()
        it('calls onMousereleased()', function()
            spy.on(scene, 'onMousereleased')
            scene:mousereleased(0,0,0,false,1)
            assert.spy(scene.onMousereleased).was.called()
        end)
    end)

    describe('onWheelmoved()', function()
        it('does not error', function()
            assert.has_no.errors(function()
                scene:onWheelmoved(0,0)
            end)
        end)
    end)

    describe('wheelmoved()', function()
        it('calls onWheelmoved()', function()
            spy.on(scene, 'onWheelmoved')
            scene:wheelmoved(0,0,0,false,1)
            assert.spy(scene.onWheelmoved).was.called()
        end)
    end)

    describe('addEnt()', function()
        it('when passed nothing adds entity with next available numeric ID', function()
            scene:addEnt()
            assert.is.True(scene:entExists(1))
        end)
        it('when passed nothing returns the used ID', function()
            assert.is.equal(1, scene:addEnt())
        end)
        it('when passed an ID adds an entity with that same ID', function()
            scene:addEnt(nil, 4)
            assert.is.True(scene:entExists(4))
        end)
        it('when passed an ID returns that same ID', function()
            assert.is.equal(4, scene:addEnt(nil, 4))
        end)
        it('when passed nothing fills the next available gap in numeric IDs', function()
            scene:addEnt(nil, 1)
            scene:addEnt(nil, 3)
            scene:addEnt()
            assert.is.True(scene:entExists(2))
        end)
        it('accepts string IDs', function()
            scene:addEnt(nil, 'test')
            assert.is.True(scene:entExists('test'))
        end)
        it('when passed a source merges the data into the entity', function()
            local source = {foo={}}
            scene:addEnt(source)
            assert.is.same({}, scene:getEnt(1).foo)
        end)
    end)

    describe('removeEnt()', function()
        it('removes an existing entity', function()
            scene:addEnt(nil, 1)
            scene:removeEnt(1)
            assert.is.False(scene:entExists(1))
        end)
        it('does not error if entity does not exist', function()
            assert.has_no.errors(function()
                scene:removeEnt(1)
            end)            
        end)
    end)

    describe('removeEntDelayed()', function()
        it('does not remove the entity immediately', function()
            scene:addEnt(nil, 1)
            scene:removeEntDelayed(1)
            assert.is.True(scene:entExists(1))
        end)
        it('removes the entity after the next update', function()
            scene:addEnt(nil, 1)
            scene:removeEntDelayed(1)
            scene:update(1)
            assert.is.False(scene:entExists(1))
        end)
        it('does not error if entity does not exist', function()
            assert.has_no.errors(function()
                scene:removeEntDelayed(1)
            end)
        end)
    end)

    describe('getEnt()', function()

    end)

    describe('entExists()', function()
    
    end)

    describe('addCom()', function()

    end)

    describe('removeCom()', function()

    end)

    describe('getCom()', function()

    end)

    describe('entIter()', function()

    end)

    describe('hasComIter()', function()

    end)

    describe('clearHasComIterCache()', function()
    
    end)

    describe('clearAllHasComIterCache()', function()
    
    end)

    describe('getEntWithCom()', function()
    
    end)

    describe('hasCom()', function()

    end)

    describe('exportEntities()', function()
    
    end)

    describe('importEntities()', function()
    
    end)

    describe('usePlugin()', function()
    
    end)

    describe('registerComponentClass()', function()
    
    end)

    describe('componentClassExists()', function()
    
    end)

    describe('getComponentClass()', function()
    
    end)
end)

--old tests, need to reuse later
--[[
describe('an EntityManager instance', function()
    local engine, entMan
    before_each(function()
        engine = Engine()
    end)
    describe('init()', function()
        it('assigns passed engine to engine prop', function()
            local entMan = EntityManager(engine)
            assert.is.equal(entMan.engine, engine)
        end)
        it('creates a new ents table', function()
            local entMan = EntityManager(engine)
            assert.is.same(entMan.ents, {})
        end)
    end)
    describe('add()', function()
        before_each(function()
            entMan = EntityManager(engine)
        end)
        it('adds new entity', function()
            entMan:add()
            assert.is.Type(entMan:get(1), 'table')
        end)
        describe('when passed no entity table', function()
            it('adds a new empty entity', function()
                entMan:add()
                assert.is.same(entMan:get(1), {})
            end)
        end)
        it('returns the new entity id', function()
            local id = entMan:add()
            assert.is.equal(id, 1)
        end)
        it('assigns entity IDs sequentially', function()
            id1 = entMan:add()
            id2 = entMan:add()
            assert.is.equal(id2, 2)
        end)
        describe('when passed an id', function()
            it('assigns new entity to that id', function()
                entMan:add(nil, 9)
                assert.is.Type(entMan:get(9), 'table')
            end)
            describe('and an entity with that ID already exists', function()
                it('raises an alert', function()
                    entMan:add()
                    spy.on(alert, 'raise')
                    entMan:add(nil, 1)
                    assert.spy(alert.raise).was_called()
                    alert.raise:revert()
                end)
                it('does not overwrite existing entity', function()
                    entMan:add()
                    local e = entMan:get(1)
                    entMan:add(nil, 1)
                    assert.is.equal(entMan:get(1), e)
                end)
            end)
        end)
        it('fills holes in entity table', function()
            entMan:add(nil, 1)
            entMan:add(nil, 3)
            assert.is.equal(entMan:add(), 2)
        end)
        describe('when passed an entity table', function()
            it('adds that table as an entity', function()
                local ent = {'foo','bar'}
                entMan:add(ent)
                assert.is.equal(entMan:get(1), ent)
            end)
        end)
    end)

    describe('get()', function()
        it('returns an existing entity', function()
            local entMan = EntityManager(engine)
            entMan:add(nil, 9)
            assert.is.Type(entMan:get(9), 'table')
        end)
        it('errors if the entity does not exist', function()
            local entMan = EntityManager(engine)
            assert.has.errors(function()
                entMan:get(1)
            end)
        end)
    end)

    describe('exists()', function()
        it('returns true if entity exists', function()
            local entMan = EntityManager(engine)
            entMan:add(nil, 9)
            assert.is.True(entMan:exists(9))
        end)
        it('returns false if entity does not exist', function()
            local entMan = EntityManager(engine)
            assert.is.False(entMan:exists(1))
        end)
    end)
    
    describe('remove()', function()
        it('removes an existing entity', function()
            local entMan = EntityManager(engine)
            entMan:add()
            entMan:remove(1)
            assert.is_not.existingEntity(entMan, 1)
        end)
    end)

    describe('attachCom()', function()
        it('attaches component table to entity', function()
            local entMan = EntityManager(engine)
            entMan:add()
            local com = {}
            entMan:attachCom(1, 'test', com)
            assert.is.equal(entMan:get(1).test, com)
        end)
        it('overwrites an existing component on entity', function()
            local entMan = EntityManager(engine)
            entMan:add()
            local com1 = {}
            local com2 = {}
            entMan:attachCom(1, 'test', com1)
            entMan:attachCom(1, 'test', com2)
            assert.is_not.equal(entMan:get(1).test, com1)
            assert.is.equal(entMan:get(1).test, com2)
        end)
        it('returns the component', function()
            local entMan = EntityManager(engine)
            entMan:add()
            local com = {}
            assert.is.equal(com, entMan:attachCom(1, 'test', com))
        end)
    end)

    describe('removeCom()', function()
        it('removes an existing component from entity', function()
            local entMan = EntityManager(engine)
            entMan:add()
            entMan:attachCom(1, 'test', {})
            entMan:removeCom(1, 'test')
            assert.is.equal(entMan:get(1).test, nil)
        end)
    end)

    describe('getCom()', function()
        it('returns an existing component', function()
            local entMan = EntityManager(engine)
            entMan:add()
            local com = {}
            entMan:attachCom(1, 'test', com)
            assert.is.equal(entMan:getCom(1, 'test'), com)
        end)
    end)

    describe('entIter()', function()
        it('returns an iterator function', function()
            local entMan = EntityManager(engine)
            assert.is.Type(entMan:entIter(), 'function')
        end)
        it('creates iterator that returns nils if no entities exist', function()
            local entMan = EntityManager(engine)
            local k,v = entMan:entIter()()
            assert.is.equal(k, nil)
            assert.is.equal(v, nil)
        end)
        it('creates iterator that iterates through all sequential entities', function()
            local entMan = EntityManager(engine)
            t1 = {'foo'}
            t2 = {'bar'}
            expected = {}
            expected[1], expected[2] = t1, t2
            entMan:add(t1, 1)
            entMan:add(t2, 2)
            local result = {}
            for k,v in entMan:entIter() do
                result[k] = v
            end
            assert.is.same(result, expected)
        end)
        it('creates iterator that iterates through all non-sequential entities', function()
            local entMan = EntityManager(engine)
            t1 = {'foo'}
            t2 = {'bar'}
            expected = {}
            expected[1], expected[3] = t1, t2
            entMan:add(t1, 1)
            entMan:add(t2, 3)
            local result = {}
            for k,v in entMan:entIter() do
                result[k] = v
            end
            assert.is.same(result, expected)
        end)
    end)

    describe('hasComIter()', function()
        it('returns an iterator function', function()
            local entMan = EntityManager(engine)
            assert.is.Type(entMan:hasComIter(), 'function')
        end)
        it('creates iterator that returns nil if no component ID is specified', function()
            local entMan = EntityManager(engine)
            entMan:add(nil, 1)
            local id = entMan:hasComIter()()
            assert.is.equal(id, nil)
        end)
        it('creates iterator that returns nil if no entities exist', function()
            local entMan = EntityManager(engine)
            local id = entMan:hasComIter('test')()
            assert.is.equal(id, nil)
        end)
        it('creates iterator that iterates over only the entities with one component ID specified', function()
            local entMan = EntityManager(engine)
            entMan:add({test={}}, 1)
            entMan:add({}, 2)
            entMan:add({test={}}, 3)
            entMan:add({}, 4)
            local expected = {true, nil, true}
            local result = {}
            for id in entMan:hasComIter('test') do
                result[id] = true
            end
            assert.is.same(expected, result)
        end)
        it('creates iterator that iterates over only the entities with all components specified', function()
            local entMan = EntityManager(engine)
            entMan:add({}, 1)
            entMan:add({foo={}, bar={}, baz={}}, 2)
            entMan:add({foo={}}, 3)
            entMan:add({foo={}, bar={}}, 4)
            entMan:add({foo={}, bar={}, baz={}}, 5)
            local expected = {nil, true, nil, nil, true}
            local result = {}
            for id in entMan:hasComIter('foo', 'bar', 'baz') do
                result[id] = true
            end
            assert.is.same(expected, result)
        end)
    end)

    describe('getEntWithCom()', function()
        it('returns nil if no entities exist', function()
            local entMan = EntityManager(engine)
            assert.is.equal(entMan:getEntWithCom(), nil)
        end)
        it('returns nil if no entities have the specified component IDs', function()
            local entMan = EntityManager(engine)
            entMan:add{{}, 1}
            entMan:add{{foo={}}, 2}
            entMan:add{{bar={}}, 3}
            assert.is.equal(entMan:getEntWithCom('foo', 'bar'), nil)
        end)
        it('returns an ID of an entity that has the specified component IDs', function()
            local entMan = EntityManager(engine)
            entMan:add({}, 1)
            entMan:add({foo={}, bar={}}, 2)
            assert.is.equal(entMan:getEntWithCom('foo', 'bar'), 2)
        end)
    end)

    describe('hasCom()', function()
        it('returns false if entity ID does not exist', function()
            local entMan = EntityManager(engine)
            assert.is.False(entMan:hasCom(1, 'test'))
        end)
        it('returns false if entity ID does not have specified component IDs', function()
            local entMan = EntityManager(engine)
            entMan:add({}, 1)
            assert.is.False(entMan:hasCom(1, 'test'))
        end)
        it('returns true if entity ID does have specified component IDs', function()
            local entMan = EntityManager(engine)
            entMan:add({foo={},bar={}}, 1)
            assert.is.True(entMan:hasCom(1, 'foo', 'bar'))
        end)
        it('returns false if entity ID only has some of the specified component IDs', function()
            local entMan = EntityManager(engine)
            entMan:add({foo={}, bar={}}, 1)
            assert.is.False(entMan:hasCom(1, 'foo', 'bar', 'baz'))
        end)
    end)

    describe('saveSnapshot()', function()
        it('does not error', function()
            local entMan = EntityManager(engine)
            entMan:add({foo={}})
            assert.has_no.errors(function() entMan:saveSnapshot('testsave') end)
        end)
        it('calls love.filesystem.write()', function()
            local entMan = EntityManager(engine)
            spy.on(love.filesystem, 'write')
            entMan:saveSnapshot('testsave')
            assert.spy(love.filesystem.write).was.called()
            love.filesystem.write:revert()
        end)
        it('calls love.filesystem.write() with passed filename', function()
            local entMan = EntityManager(engine)
            spy.on(love.filesystem, 'write')
            entMan:saveSnapshot('testsave')
            assert.spy(love.filesystem.write).was.called_with('testsave', match._)
            love.filesystem.write:revert()
        end)
        --Integration testing is needed within actual LOVE environment
    end)

    describe('loadSnapshot()', function()
        --note: there isn't a great way to test this currently.
    end)
end)
]]