# Derives the icon from the existing Fraunces font and Exquisssita palette.
# No network, external images, or installed fonts required.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = Split-Path $PSScriptRoot -Parent
$fonts = [System.Drawing.Text.PrivateFontCollection]::new()
$fonts.AddFontFile((Join-Path $root 'assets/fonts/Fraunces-SemiBold.ttf'))
$frames = [System.Collections.Generic.List[byte[]]]::new()
$sizes = @(16, 32, 48, 64, 128, 256)
try {
    foreach ($size in $sizes) {
        $bitmap = [System.Drawing.Bitmap]::new(256, 256)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $font = [System.Drawing.Font]::new($fonts.Families[0], 160, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
        $navy = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#1A2744'))
        $yellow = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#F5A623'))
        $stream = [System.IO.MemoryStream]::new()
        $scaled = $null
        try {
            $graphics.Clear([System.Drawing.ColorTranslator]::FromHtml('#FBE9DF'))
            $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
            $format = [System.Drawing.StringFormat]::new()
            $format.Alignment = [System.Drawing.StringAlignment]::Center
            $format.LineAlignment = [System.Drawing.StringAlignment]::Center
            $graphics.DrawString('E', $font, $navy, [System.Drawing.RectangleF]::new(0, 0, 256, 256), $format)
            $graphics.FillEllipse($yellow, 198, 198, 30, 30)
            $format.Dispose()
            $scaled = [System.Drawing.Bitmap]::new($bitmap, $size, $size)
            $scaled.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
            $frames.Add($stream.ToArray())
        } finally {
            if ($scaled) { $scaled.Dispose() }
            $stream.Dispose(); $yellow.Dispose(); $navy.Dispose()
            $font.Dispose(); $graphics.Dispose(); $bitmap.Dispose()
        }
    }
    $output = Join-Path $root 'windows/runner/resources/app_icon.ico'
    $writer = [System.IO.BinaryWriter]::new([System.IO.File]::Create($output))
    try {
        $writer.Write([uint16]0); $writer.Write([uint16]1); $writer.Write([uint16]$frames.Count)
        $offset = 6 + 16 * $frames.Count
        for ($i = 0; $i -lt $frames.Count; $i++) {
            $dimension = if ($sizes[$i] -eq 256) { 0 } else { $sizes[$i] }
            $writer.Write([byte]$dimension); $writer.Write([byte]$dimension)
            $writer.Write([byte]0); $writer.Write([byte]0)
            $writer.Write([uint16]1); $writer.Write([uint16]32)
            $writer.Write([uint32]$frames[$i].Length); $writer.Write([uint32]$offset)
            $offset += $frames[$i].Length
        }
        foreach ($frame in $frames) { $writer.Write($frame) }
    } finally { $writer.Dispose() }
    Write-Host 'Icono de marca generado: 16/32/48/64/128/256 px.'
} finally { $fonts.Dispose() }
