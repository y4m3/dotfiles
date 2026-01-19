# UTF-8 encoding for proper display of Unicode characters

# Set console code page to UTF-8
chcp 65001 | Out-Null

# Console input/output encoding
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# PowerShell output encoding
$OutputEncoding = [System.Text.Encoding]::UTF8

# Default encoding for Out-File, etc.
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['Set-Content:Encoding'] = 'utf8'
$PSDefaultParameterValues['Add-Content:Encoding'] = 'utf8'
