# 200-starship.ps1 - Starship prompt
# Category: 2xx (Prompt)
# See: https://starship.rs/

# Starship prompt initialization
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
