file = {
    'rude',
    exclude={
        'rude/.luarocks',
        'rude/lua_modules'
    }
}

dir='doc'

format='markdown'

--topics='manual'
kind_names={
    topic='Manual'
}

custom_tags={
    {'remark', title='Remarks'}
}

new_type('sfunction', 'Static Methods', false, 'Parameters')
new_type('dEnc', 'Registered Data Encoders', false, 'Parameters')
new_type('dDec', 'Registered Data Decoders', false, 'Parameters')
new_type('assetLoader', 'Registered Asset Loaders', false, 'Parameters')
new_type('patch', 'Patch functions', false, 'Parameters')
