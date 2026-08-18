# bootstrap_win.ps1
#
# Удалённый запуск get_win.cmd (GUI-версия) одной командой, без скачивания файла на диск:
#
#   irm https://nuttshell.github.io/bootstrap_win.ps1 | iex
#
# Как это работает: скрипт скачивает актуальный get_win.cmd из репозитория, вырезает из
# него PowerShell-часть (всё после метки REM_PS1_CODE_START - той же самой, что использует
# сам .cmd при локальном запуске) и выполняет её. Один источник правды - сам get_win.cmd,
# этот загрузчик ничего не дублирует и почти никогда не должен меняться.
#
# Окно консоли НЕ скрывается в этом сценарии (в отличие от обычного запуска через сам
# get_win.cmd) - здесь это ваш собственный терминал, а не выделенное под скрипт окно,
# прятать его было бы плохим UX. Открывается только окно GUI-инсталлятора.
#
# bootstrap_win.ps1 раздаётся через GitHub Pages, включённый на репозитории nuttshell.github.io
# (Settings -> Pages -> Deploy from a branch -> main / root, плюс пустой файл .nojekyll).
# get_win.cmd при этом по-прежнему читается напрямую с raw.githubusercontent.com из
# репозитория localpython_installer.

# TLS 1.2/1.3 нужно включить ДО скачивания самого этого файла, а не внутри get_win.cmd -
# иначе PowerShell 5.1 на многих машинах по умолчанию не сможет установить соединение с
# GitHub Pages и упадёт с "The underlying connection was closed" ещё на этом irm-вызове.

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

$WIN_CMD_URL = "https://raw.githubusercontent.com/NuttShell/localpython_installer/main/get_win.cmd"

$raw  = Invoke-RestMethod -Uri $WIN_CMD_URL
$idx  = $raw.LastIndexOf('REM_PS1_CODE_START')
if ($idx -lt 0) {
    throw "REM_PS1_CODE_START marker not found in $WIN_CMD_URL - is this really get_win.cmd?"
}
$code = $raw.Substring($idx + 18).TrimStart([char]13, [char]10)

& ([scriptblock]::Create($code))
