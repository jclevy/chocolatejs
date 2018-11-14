@echo off & setlocal enabledelayedexpansion
IF  "%1" == "" (
    ECHO chocomake ^<project_name^>
) ELSE (
    ECHO Creating new project %1...

    mkdir %1

    mkdir %1\client
    mkdir %1\general
    mkdir %1\server
    mkdir %1\data
    mkdir %1\static

    ECHO exports.interface = ^-^>> %1\default.coffee
    ECHO.    ''>> %1\default.coffee
    ECHO {"by": {"id":{}, "root":[], "Priority":{}, "Scope":{}, "Action":{}, "Intention":{}, "Wish":{}, "Need":{}, "Share":{}}} > %1\data\newnotes_data.json
    openssl genrsa -out %1\data\privatekey.pem 1024
    openssl req -new -key %1\data\privatekey.pem -out %1\data\certrequest.csr
    openssl x509 -req -in %1\data\certrequest.csr -signkey %1\data\privatekey.pem -out %1\data\certificate.pem
    ECHO.
    ECHO.

    :loop
    SET /P firstkey="Enter a master key (password) for your project, followed by [Enter]:"
    SET /P verifkey="Enter it again, followed by [Enter]:"

    if "!firstkey!" NEQ "!verifkey!" (
        ECHO Your password and confirmation password do not match
        ECHO Try again
        SET firstkey=
        SET verifkey=
        GOTO loop
    )
    ECHO.

    for /f %%i in ('node -e "process.stdout.write(require('crypto').createHash('sha256').update('%firstkey%').digest('hex'));"') do set hashed_key=%%i

    ECHO {> %1\data\app.config.json
    ECHO.    "sofkey":"%hashed_key%",>> %1\data\app.config.json
    ECHO.    "debug":false,>> %1\data\app.config.json
    ECHO.    "displayErrors":true,>> %1\data\app.config.json
    ECHO.    "debug_url":"http://localhost:8081/debug?ws=localhost:8081&port=5858">> %1\data\app.config.json
    ECHO.}>> %1\data\app.config.json

    git init %1
    cd %1
    git add .
    git commit -m "Initial commit"

    ECHO Done
)
