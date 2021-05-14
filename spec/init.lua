local luassert = require('luassert')
local say = require('say')

-- add spec.lib to require path so external libraries can be imported.
package.path = package.path..';spec/lib/?.lua'

-- catch accidental global scope assignments using the strict module.
require('strict')

-- register "package" as a global, used to test various modules that rely on other modules existing
global('package')

--register "jit" as a global, used to test jit requirement for certain modules
global('jit')

--register "love" as a global, used to test LOVE requirement for certain modules. So far I am unable to successfully run busted from within LOVE. For now, I'm just going to mock the love API.
global('love')
love = {
    filesystem={
        write=function() return true end
    }
}

--assert that a class instance is an instance of a specified class.
local function isInstanceOf(state, args)
    local instance = args[1]
    local cls = args[2]
    if type(instance) ~= 'table' or type(cls) ~= 'table' then
        return false
    end
    if not instance.isInstanceOf then
        return false
    end
    return instance:isInstanceOf(cls)
end
say:set('assertion.instanceOf.positive', 'Expected object %s to be instance of %s')
say:set('assertion.instanceOf.negative', 'Expected object %s to not be instance of %s')
luassert:register('assertion', 'instanceOf', isInstanceOf, 'assertion.instanceOf.positive', 'assertion.instanceOf.negative')

--assert that a value is the specified type.
local function isType(state, args)
    return type(args[1]) == args[2]
end
say:set('assertion.isType.positive', 'Expected %s to be type: %s')
say:set('assertion.isType.negative', 'Expected %s to not be type: %s')
luassert:register('assertion', 'Type', isType, 'assertion.isType.positive', 'assertion.isType.negative')

--assert that tested value is equal to one of several choices
local function isOneOf(state, args)
    local testVal = args[1]
    if args[2] == nil then return false end
    for i=2, #args, 1 do
        if testVal == args[i] then
            return true
        end
    end
    return false
end
say:set('assertion.oneOf.positive', '%s is not any of the allowed choices.')
say:set('assertion.oneOf.negative', '%s is one of the allowed choices.')
luassert:register('assertion', 'oneOf', isOneOf, 'assertion.oneOf.positive', 'assertion.oneOf.negative')