file = {
    'rude',
    exclude={
        'rude/.luarocks',
        'rude/lua_modules',
        'rude/lib'
    }
}

dir='doc'

format='markdown'

topics='manual'
kind_names={
    topic='Manual'
}

custom_tags={
    {'remark', title='Remarks'}
}

new_type('sfunction', 'Static Methods', false, 'Parameters')

