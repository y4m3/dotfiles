# UTF-8 encoding for proper display of Unicode characters

# Console input/output encoding
# Note: [Console]::OutputEncoding setter internally calls SetConsoleOutputCP(65001),
# making a separate `chcp 65001` call redundant.
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# PowerShell output encoding
$OutputEncoding = [System.Text.Encoding]::UTF8

# Default encoding for Out-File, etc.
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['Set-Content:Encoding'] = 'utf8'
$PSDefaultParameterValues['Add-Content:Encoding'] = 'utf8'
