# bootstrap_win.ps1
#
# Удалённый запуск get_win.cmd (GUI-версия) одной командой, без скачивания файла на диск:
#
#   irm https://nuttshell.github.io/bootstrap_win.ps1 | iex
#
# Окно консоли НЕ скрывается в этом сценарии (в отличие от обычного запуска через сам
# get_win.cmd, где всегда передаётся -HideConsole).

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

$WIN_CMD_URL = "https://raw.githubusercontent.com/NuttShell/localpython_installer/main/get_win.cmd"

$raw = Invoke-RestMethod -Uri $WIN_CMD_URL

& ([scriptblock]::Create($raw))
