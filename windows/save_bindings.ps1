<#
Copies the current PowerToys Keyboard Manager configuration into this repository
#>

Copy-Item "$HOME\AppData\Local\Microsoft\PowerToys\Keyboard Manager\default.json" -Destination (Get-Location)
