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

custom_tags={
    {'remark', title='Remarks'}
}

new_type('sfunction', 'Static Methods', false, 'Parameters')

topics={
    'topics/Getting_Started.md'
}