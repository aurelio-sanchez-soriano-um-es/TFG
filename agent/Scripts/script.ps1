
# 1. Obtener el porcentaje de uso de RAM
try {
    $os = Get-CimInstance Win32_OperatingSystem
    $totalRAM = $os.TotalVisibleMemorySize
    $freeRAM  = $os.FreePhysicalMemory
    $usedRAM  = $totalRAM - $freeRAM
    $ramPercent = [math]::Round(($usedRAM / $totalRAM * 100), 2)
} catch {
    $ramPercent = "N/A"
}

# 2. Obtener el porcentaje de uso del disco en la unidad C:
try {
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
    $diskUsed = $disk.Size - $disk.FreeSpace
    $diskPercent = [math]::Round(($diskUsed / $disk.Size * 100), 2)
} catch {
    $diskPercent = "N/A"
}

# 3. Obtener el porcentaje de uso de CPU
try {
    $cpuUsageValue = (Get-WmiObject Win32_Processor).LoadPercentage | Out-String | ForEach-Object { $_.Trim() }
} catch {
    $cpuUsageValue = "N/A"
}

"$cpuUsageValue $ramPercent $diskPercent" | Write-Output
