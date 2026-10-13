# Gera os assets de imagem do site Pimenta Fitness a partir das imagens originais (img/_orig).
# Uso: powershell -ExecutionPolicy Bypass -File .\build-img.ps1
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$src  = Join-Path $root 'img\_orig'
$out  = Join-Path $root 'img'
New-Item -ItemType Directory -Force -Path $out | Out-Null
Add-Type -AssemblyName System.Drawing

function Get-Crop([string]$path, [int]$x, [int]$y, [int]$w, [int]$h) {
  $img = [System.Drawing.Image]::FromFile($path)
  $rect = [System.Drawing.Rectangle]::new($x, $y, [Math]::Min($w, $img.Width - $x), [Math]::Min($h, $img.Height - $y))
  $bmp = [System.Drawing.Bitmap]::new($rect.Width, $rect.Height)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.DrawImage($img, ([System.Drawing.Rectangle]::new(0, 0, $bmp.Width, $bmp.Height)), $rect, [System.Drawing.GraphicsUnit]::Pixel)
  $g.Dispose(); $img.Dispose()
  return $bmp
}

function Save-Jpg([System.Drawing.Bitmap]$bmp, [string]$name, [long]$quality) {
  $enc = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
  $p = New-Object System.Drawing.Imaging.EncoderParameters(1)
  $p.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, $quality)
  $bmp.Save((Join-Path $out $name), $enc, $p)
  $bmp.Dispose()
}

function Scale([System.Drawing.Bitmap]$bmp, [int]$maxW) {
  if ($bmp.Width -le $maxW) { return $bmp }
  $h = [int]($bmp.Height * $maxW / $bmp.Width)
  $n = [System.Drawing.Bitmap]::new($maxW, $h)
  $g = [System.Drawing.Graphics]::FromImage($n)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.DrawImage($bmp, 0, 0, $maxW, $h)
  $g.Dispose()
  return $n
}

# ---------- FOTOS ----------
Save-Jpg (Scale (Get-Crop (Join-Path $src 'p02.jpg') 0 0 1600 1200) 1600) 'hero.jpg' 82        # vista aerea do salao
Save-Jpg (Get-Crop (Join-Path $src 'p01.jpg') 0 0 1290 885) 'fachada.jpg' 84                   # fachada com letreiro
Save-Jpg (Get-Crop (Join-Path $src 'p03.jpg') 0 0 1234 848) 'equipe.jpg' 84                    # equipe na inauguracao
Save-Jpg (Scale (Get-Crop (Join-Path $src 'p05.jpg') 0 60 1200 1540) 1200) 'mezanino.jpg' 84    # mezanino sobre o salao
Save-Jpg (Scale (Get-Crop (Join-Path $src 'p09.jpg') 0 0 1200 1600) 1100) 'recepcao.jpg' 84    # recepcao / balcao
Save-Jpg (Get-Crop (Join-Path $src 'p08.jpg') 0 470 900 655) 'aulas.jpg' 85                    # aula coletiva de step (recorte do story)
Save-Jpg (Get-Crop (Join-Path $src 'p06.jpg') 0 0 900 1380) 'turma.jpg' 85                     # turma na escada (sem texto do story)
Save-Jpg (Scale (Get-Crop (Join-Path $src 'p07.jpg') 0 70 1238 1530) 1100) 'inauguracao.jpg' 84 # corte de fita (sem texto do story)
Save-Jpg (Scale (Get-Crop (Join-Path $src 'p10.jpg') 0 0 1200 1600) 1100) 'alunos.jpg' 84      # alunos em frente ao logo

# ---------- LOGO (selo circular com alpha, recorte do perfil oficial) ----------
$raw = [System.Drawing.Bitmap]::new((Join-Path $src 'logo-raw-s1024.png'))
# acha o anel vermelho do selo para localizar centro e raio
$minX = $raw.Width; $maxX = 0; $minY = $raw.Height; $maxY = 0
for ($y = 0; $y -lt $raw.Height; $y += 2) {
  for ($x = 0; $x -lt $raw.Width; $x += 2) {
    $c = $raw.GetPixel($x, $y)
    if ($c.R -gt 110 -and ($c.R - $c.G) -gt 50 -and ($c.R - $c.B) -gt 50) {
      if ($x -lt $minX) { $minX = $x }; if ($x -gt $maxX) { $maxX = $x }
      if ($y -lt $minY) { $minY = $y }; if ($y -gt $maxY) { $maxY = $y }
    }
  }
}
$cx = ($minX + $maxX) / 2.0; $cy = ($minY + $maxY) / 2.0
$rad = [Math]::Max(($maxX - $minX), ($maxY - $minY)) / 2.0 + 4
$side = [int][Math]::Ceiling($rad * 2)
$logo = [System.Drawing.Bitmap]::new($side, $side)
for ($y = 0; $y -lt $side; $y++) {
  for ($x = 0; $x -lt $side; $x++) {
    $sx = [int]($cx - $rad + $x); $sy = [int]($cy - $rad + $y)
    if ($sx -lt 0 -or $sy -lt 0 -or $sx -ge $raw.Width -or $sy -ge $raw.Height) { continue }
    $d = [Math]::Sqrt([Math]::Pow($x - $rad + 0.5, 2) + [Math]::Pow($y - $rad + 0.5, 2))
    $a = [int](255 * [Math]::Min(1.0, [Math]::Max(0.0, ($rad - $d) + 0.5)))
    $c = $raw.GetPixel($sx, $sy)
    $logo.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($a, $c.R, $c.G, $c.B))
  }
}
$logoOut = Scale $logo 320
$logoOut.Save((Join-Path $out 'logo.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$logoOut.Dispose()
$fav = Scale $logo 96
$fav.Save((Join-Path $out 'favicon.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$fav.Dispose()
$raw.Dispose(); $logo.Dispose()

# ---------- OG IMAGE (1200x630) ----------
$og = [System.Drawing.Bitmap]::new(1200, 630)
$g = [System.Drawing.Graphics]::FromImage($og)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear([System.Drawing.Color]::FromArgb(255, 12, 12, 14))
$hero = [System.Drawing.Image]::FromFile((Join-Path $out 'hero.jpg'))
$s = [Math]::Max(1200 / $hero.Width, 630 / $hero.Height)
$w = [int]($hero.Width * $s); $h = [int]($hero.Height * $s)
$g.DrawImage($hero, ([System.Drawing.Rectangle]::new([int]((1200 - $w) / 2), [int]((630 - $h) / 2), $w, $h)))
$hero.Dispose()
$sc = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
  [System.Drawing.Rectangle]::new(0, 0, 1200, 630),
  [System.Drawing.Color]::FromArgb(245, 10, 10, 12),
  [System.Drawing.Color]::FromArgb(60, 10, 10, 12),
  [System.Drawing.Drawing2D.LinearGradientMode]::Horizontal)
$g.FillRectangle($sc, 0, 0, 1200, 630)
$sc.Dispose()
$redPen = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 217, 26, 34))
$g.FillPolygon($redPen, [System.Drawing.Point[]]@(
    [System.Drawing.Point]::new(0, 630), [System.Drawing.Point]::new(430, 630),
    [System.Drawing.Point]::new(360, 560), [System.Drawing.Point]::new(0, 560)))
$redPen.Dispose()
$lg = [System.Drawing.Image]::FromFile((Join-Path $out 'logo.png'))
$g.DrawImage($lg, ([System.Drawing.Rectangle]::new(70, 205, 220, 220)))
$lg.Dispose()
$f1 = New-Object System.Drawing.Font('Impact', 62)
$f2 = New-Object System.Drawing.Font('Impact', 25)
$white = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
$red = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 232, 38, 45))
$g.DrawString('PIMENTA', $f1, $white, 330, 215)
$g.DrawString('FITNESS', $f1, $red, 330, 285)
$g.DrawString('Musculacao e aulas coletivas | Aguas Lindas de Goias', $f2, [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 214, 216, 220)), 332, 380)
$white.Dispose(); $red.Dispose(); $f1.Dispose(); $f2.Dispose(); $g.Dispose()
Save-Jpg $og 'og-image.jpg' 86

Write-Output 'Assets gerados em img\:'
Get-ChildItem $out -File | ForEach-Object {
  $i = [System.Drawing.Image]::FromFile($_.FullName)
  '{0,-22} {1,5}x{2,-5} {3,7:N0} KB' -f $_.Name, $i.Width, $i.Height, ($_.Length / 1KB)
  $i.Dispose()
}
