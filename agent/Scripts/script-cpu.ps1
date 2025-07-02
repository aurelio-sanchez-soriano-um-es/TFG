Write-Host "Generando carga de CPU al 70%..."
Write-Host "Presiona CTRL+C para detener"

try {
    while ($true) {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        
        # Fase activa (70 ms de cálculos)
        while ($stopwatch.ElapsedMilliseconds -lt 70) {
            1..100000 | ForEach-Object { [math]::Sqrt($_) } | Out-Null
        }
        
        # Fase de descanso (30 ms de pausa)
        Start-Sleep -Milliseconds 30
    }
}
finally {
    Write-Host "`nSimulación detenida. Carga de CPU normalizada."
}