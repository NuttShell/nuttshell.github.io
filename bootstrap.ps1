# bootstrap.ps1
#
# Удалённый запуск get_con.cmd одной командой, без скачивания файла на диск:
#
#   irm https://nuttshell.github.io/bootstrap.ps1 | iex
#
# Если нужно передать -PyVer/-Arch/-NoWait ("чистый" iex это не умеет - Invoke-Expression не
# принимает параметры) - используйте вариант со scriptblock:
#
#   & ([scriptblock]::Create((irm https://nuttshell.github.io/bootstrap.ps1))) -PyVer 3.14.1 -Arch amd64 -NoWait
#

param(
    [string]$PyVer = "",
    [string]$Arch  = "",
    [switch]$NoWait
)

# TLS 1.2/1.3 нужно включить ДО скачивания самого этого файла, а не внутри get_con.cmd -
# иначе PowerShell 5.1 на многих машинах по умолчанию не сможет установить соединение с
# GitHub Pages и упадёт с "The underlying connection was closed" ещё на этом irm-вызове.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

$CON_CMD_URL = "https://raw.githubusercontent.com/NuttShell/localpython_installer/main/get_con.cmd"

$raw = Invoke-RestMethod -Uri $CON_CMD_URL

& ([scriptblock]::Create($raw)) -PyVer $PyVer -Arch $Arch -NoWait:$NoWait
