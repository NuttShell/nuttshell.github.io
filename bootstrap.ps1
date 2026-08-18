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
# Как это работает: скрипт скачивает актуальный get_con.cmd из репозитория, вырезает из
# него PowerShell-часть (всё после метки REM_PS1_CODE_START - той же самой, что использует
# сам .cmd при локальном запуске) и выполняет её. Один источник правды - сам get_con.cmd,
# этот загрузчик ничего не дублирует и почти никогда не должен меняться.
#
# bootstrap.ps1 раздаётся через GitHub Pages, включённый на репозитории nuttshell.github.io
# (Settings -> Pages -> Deploy from a branch -> main / root, плюс пустой файл .nojekyll) -
# это даёт более короткий адрес, чем raw.githubusercontent.com. get_con.cmd при этом
# по-прежнему читается напрямую с raw.githubusercontent.com из репозитория
# localpython_installer (не нужно ждать сборку Pages при каждой правке get_con.cmd -
# только сам bootstrap.ps1 идёт через Pages).

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

$raw  = Invoke-RestMethod -Uri $CON_CMD_URL
$idx  = $raw.LastIndexOf('REM_PS1_CODE_START')
if ($idx -lt 0) {
    throw "REM_PS1_CODE_START marker not found in $CON_CMD_URL - is this really get_con.cmd?"
}
$code = $raw.Substring($idx + 18).TrimStart([char]13, [char]10)

& ([scriptblock]::Create($code)) -PyVer $PyVer -Arch $Arch -NoWait:$NoWait
