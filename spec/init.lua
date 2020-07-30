local say = require('say')
local luassert = require('luassert')

-- create a local reference for the "spy" global variable
local spy = spy

-- The rude.assert module defines some new assertions that are useful for
-- testing purposes.
require('rude.assert')

-- To handle floating-point comparisons, we define a new assertion isClose()
-- that checks if a value within a certain range defined by an error amount.
local function isClose(state, args)
    local val1,val2 = args[1], args[2]
    local mTol, eTol = math.abs(args[3] or 1e-12), math.abs(args[4] or 0)
    local m1,e1 = math.frexp(val1)
    local m2,e2 = math.frexp(val2)
    local mErr,eErr = math.abs(m1-m2), math.abs(e1-e2)
    return mErr <= mTol and eErr <= eTol
end
say:set('assertion.close.positive', 'Expected objects to be (essentially) equal.\nPassed in:\n%s\nExpected:\n%s')
say:set('assertion.close.negative', 'Expected objects to not be (essentially) equal.\nPassed in:\n%s\nExpected:\n%s')
luassert:register('assertion', 'close', isClose, 'assertion.close.positive', 'assertion.close.negative')

-- Running busted from within LOVE has proven challenging. To allow specs to run
-- outside of LOVE (i.e. in a vanilla Lua environment), we use the lovedummy
-- module as a mock object for the LOVE framework.
love = require('spec.lovedummy')

--luassert configuration
luassert:set_parameter('TableFormatLevel', 1)

--configure alert module to ignore all alerts
local alert = require('rude.alert')
alert.registerClass('fatal', 'ignore')
alert.registerClass('warning', 'ignore')
alert.registerClass('info', 'ignore')
alert.registerClass('default', 'ignore')

-- catch accidental global scope assignments using the strict module.
require('rude.lib.strict')