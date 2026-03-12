# Reparar dispositivos com falha via PnP
# Execute este script em PowerShell como ADMINISTRADOR

# (Opcional) Filtrar apenas algumas classes de dispositivo
# Ex: "Display", "Media", "System", "HIDClass", "Net" etc.
# Deixe vazio para pegar todos os dispositivos com erro.
$allowedClasses = @(
    # "Display",   # Placa de vídeo
    # "Media",     # Áudio
    # "System"     # Componentes de sistema (ACPI, etc.)
)

Write-Host "Procurando dispositivos com falha..." -ForegroundColor Cyan

# Carrega o módulo (normalmente já está carregado)
Import-Module PnpDevice -ErrorAction SilentlyContinue

# Pega todos os dispositivos que NÃO estão com status OK
$problemDevices = Get-PnpDevice -PresentOnly |
    Where-Object {
        $_.Status -ne 'OK' -and
        ($allowedClasses.Count -eq 0 -or $allowedClasses -contains $_.Class)
    }

if (-not $problemDevices) {
    Write-Host "Nenhum dispositivo com falha encontrado." -ForegroundColor Green
    return
}

Write-Host "Foram encontrados os seguintes dispositivos com problema:`n" -ForegroundColor Yellow
$problemDevices | Select-Object Class, FriendlyName, InstanceId, Status | Format-Table -AutoSize

# Confirmação opcional (se quiser tirar, remova este bloco)
$answer = Read-Host "Deseja remover esses dispositivos para forçar reinstalação? (S/N)"
if ($answer -notin @('S','s','Y','y')) {
    Write-Host "Operação cancelada pelo usuário."
    return
}

foreach ($dev in $problemDevices) {
    Write-Host "`nRemovendo dispositivo:" -ForegroundColor Cyan
    Write-Host "  Classe  : $($dev.Class)"
    Write-Host "  Nome    : $($dev.FriendlyName)"
    Write-Host "  ID      : $($dev.InstanceId)"
    try {
        Remove-PnpDevice -InstanceId $dev.InstanceId -Confirm:$false -ErrorAction Stop
        Write-Host "  -> Removido com sucesso." -ForegroundColor Green
    }
    catch {
        Write-Host "  -> ERRO ao remover: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nForçando nova varredura de dispositivos (pnputil /scan-devices)..." -ForegroundColor Cyan
try {
    pnputil /scan-devices | Out-Null
    Write-Host "Varredura concluída. Os dispositivos devem ser recriados com os drivers existentes." -ForegroundColor Green
}
catch {
    Write-Host "Não foi possível executar pnputil /scan-devices. Você pode forçar a varredura manualmente no Gerenciador de Dispositivos." -ForegroundColor Yellow
}