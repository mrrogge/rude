-- catch accidental global scope assignments using the strict module.
require('rude.lib.strict')

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
