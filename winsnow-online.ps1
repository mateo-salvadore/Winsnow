<#
.SYNOPSIS
Super Important christmas remediation.


.DESCRIPTION
- Removes bad mood
- Removes vulnerable attitude
- Imports chrostmas attitude to your PC

.Made By
Santa Claus 
#>


#Music URL:
$murl = "https://github.com/mateo-salvadore/Winsnow/blob/main/utils/8bitxmass.mp3?raw=true" 
#Music SHA256 Hash:
$mStoredHash = "C9602F3680698ED11204BC430281514D7C3590C99EB06CA0B603F3BF7939B4FD"

#Santa Claus picture URL:
$surl = "https://github.com/mateo-salvadore/Winsnow/blob/main/utils/santa.png?raw=true"
#Picture SHA256 Hash:
$sStoredHash= "08DBF4B1776F010AB8F7F0D095DC6826503C41E4820117102E1E1131525BF576"


Add-Type -AssemblyName PresentationCore,PresentationFramework,WindowsBase

# Parametry
$screenW = [int][System.Windows.SystemParameters]::PrimaryScreenWidth
$screenH = [int][System.Windows.SystemParameters]::PrimaryScreenHeight

# Okno overlay (click-through)
$window = New-Object System.Windows.Window
$window.WindowStyle = 'None'
$window.AllowsTransparency = $true
$window.Background = 'Transparent'
$window.Topmost = $true
$window.ShowInTaskbar = $false
$window.Width = $screenW
$window.Height = $screenH
$window.Left = 0
$window.Top = 0

# Click-through (WS_EX_LAYERED + WS_EX_TRANSPARENT)
$source = @"
using System;
using System.Runtime.InteropServices;
public class WinAPI {
    [DllImport("user32.dll")]
    public static extern int GetWindowLong(IntPtr hWnd, int nIndex);
    [DllImport("user32.dll")]
    public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);
}
"@
Add-Type $source
$handle = (New-Object System.Windows.Interop.WindowInteropHelper $window).Handle
$exStyle = [WinAPI]::GetWindowLong($handle, -20)
[WinAPI]::SetWindowLong($handle, -20, $exStyle -bor 0x80000 -bor 0x20)

# Canvas
$canvas = New-Object System.Windows.Controls.Canvas
$window.Content = $canvas

# Kolekcje elementów do toggle
$snowElements = New-Object System.Collections.ArrayList
$treeElements = New-Object System.Collections.ArrayList
$santaElements = New-Object System.Collections.ArrayList
$lightsElements = New-Object System.Collections.ArrayList

#--- Panel przycisków ---
$panel = New-Object System.Windows.Controls.StackPanel
$panel.Orientation = 'Horizontal'
$panel.Background = [System.Windows.Media.Brushes]::LightGray
$panel.Opacity = 0.85
$panel.Height = 40
$panel.Width = 240
[System.Windows.Controls.Canvas]::SetLeft($panel, 10)
[System.Windows.Controls.Canvas]::SetTop($panel, 10)
[void]$canvas.Children.Add($panel)

# Możliwość przesuwania panelu myszą
$panel.Add_MouseLeftButtonDown({
    $panel.Tag = @{
        StartX = [System.Windows.Input.Mouse]::GetPosition($canvas).X - [System.Windows.Controls.Canvas]::GetLeft($panel)
        StartY = [System.Windows.Input.Mouse]::GetPosition($canvas).Y - [System.Windows.Controls.Canvas]::GetTop($panel)
    }
    $panel.CaptureMouse()
})

$panel.Add_MouseMove({
    if ($panel.IsMouseCaptured) {
        $pos = [System.Windows.Input.Mouse]::GetPosition($canvas)
        $newX = $pos.X - $panel.Tag.StartX
        $newY = $pos.Y - $panel.Tag.StartY
        [System.Windows.Controls.Canvas]::SetLeft($panel, $newX)
        [System.Windows.Controls.Canvas]::SetTop($panel, $newY)
    }
})

$panel.Add_MouseLeftButtonUp({
    $panel.ReleaseMouseCapture()
})

# Przyciski toggle
$btnSnow = New-Object System.Windows.Controls.Primitives.ToggleButton
$btnSnow.Content = "❄"
$btnSnow.Width = 20
$btnSnow.IsChecked = $true
$btnSnow.Margin = [System.Windows.Thickness]::new(10,5,5,5)
$panel.Children.Add($btnSnow)

$btnTree = New-Object System.Windows.Controls.Primitives.ToggleButton
$btnTree.Content = "🎄"
$btnTree.Width = 20
$btnTree.IsChecked = $true
$btnTree.Margin = [System.Windows.Thickness]::new(5,5,5,5)
$panel.Children.Add($btnTree)

$btnSanta = New-Object System.Windows.Controls.Primitives.ToggleButton
$btnSanta.Content = "🎅"
$btnSanta.Width = 20
$btnSanta.IsChecked = $true
$btnSanta.Margin = [System.Windows.Thickness]::new(5,5,5,5)
$panel.Children.Add($btnSanta)

$btnMusic = New-Object System.Windows.Controls.Primitives.ToggleButton
$btnMusic.Content = "♫"
$btnMusic.Width = 20
$btnMusic.IsChecked = $false
$btnMusic.Margin = [System.Windows.Thickness]::new(5,5,5,5)
$panel.Children.Add($btnMusic)

$btnLights = New-Object System.Windows.Controls.Primitives.ToggleButton
$btnLights.Content = "💡"
$btnLights.Width = 20
$btnLights.IsChecked = $false
$btnLights.Margin = [System.Windows.Thickness]::new(5,5,5,5)
$panel.Children.Add($btnLights)

$btnInfo = New-Object System.Windows.Controls.Button
$btnInfo.Content = "🛈"
$btnInfo.Width = 20
$btnInfo.Margin = [System.Windows.Thickness]::new(10,5,5,5)
$btnInfo.Add_Click({ 
	$ButtonType = [System.Windows.MessageBoxButton]::OK
	$MessageIcon = [System.Windows.MessageBoxImage]::Information
	$MessageBody = "Ho ho ho, Merry Christmas from MW team! (zr7)"
	$MessageTitle = "Merry Christmas!"
	$Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
})
$panel.Children.Add($btnInfo)


# Przycisk zamknięcia
$btnX = New-Object System.Windows.Controls.Button
$btnX.Content = "🗙"
$btnX.Width = 20
$btnX.Margin = [System.Windows.Thickness]::new(10,5,10,5)
$btnX.Add_Click({ $window.Close() })
$panel.Children.Add($btnX)

# --- Player muzyki  ---

$player = $null
$MFile = "$($env:USERPROFILE)\"+[guid]::NewGuid().ToString()+".mp3"
try{
Invoke-WebRequest -Uri $murl -OutFile $MFile  -ErrorAction Stop
}catch{ exit 1 }

$MHash = Get-FileHash -Algorithm SHA256 $MFile
if ($MHash.Hash -ne $mStoredHash){
Write-Output "Music Hash Mismatch"
Remove-Item $MFile -Force -ErrorAction SilentlyContinue
$window.Close()
exit 1
} 

Add-Type -AssemblyName PresentationCore,PresentationFramework
$Player = New-Object System.Windows.Media.MediaPlayer
$Player.Volume = 0.8;
$Player.Open($MFile)




# Funkcja do odtwarzania muzyki
function Start-Music {

# When media ends, reset position and play again (loop)
# Use $event.Sender inside the handler to refer to the MediaPlayer instance
$null = Register-ObjectEvent -InputObject $Player -EventName MediaEnded -Action {
    $event.Sender.Position = [TimeSpan]::Zero
    $event.Sender.Play()
}

# Start playback
$Player.Play()

}

function Stop-Music {
	$player.Stop()
}

# Event handler dla przycisku muzyki
$btnMusic.Add_Checked({
    Start-Music
})

$btnMusic.Add_Unchecked({
    Stop-Music
})

# --- Śnieg i akumulacja ---
$flakeCount = 180
$flakes = @()
$cellSize = 4
$cells = [int]([Math]::Ceiling($screenW / $cellSize))
$ground = @(for ($i=0;$i -lt $cells; $i++) { 0 })

# Warstwa wizualna akumulacji
$accumGroup = New-Object System.Windows.Controls.Canvas
[void]$canvas.Children.Add($accumGroup)
[void]$snowElements.Add($accumGroup)
[System.Windows.Controls.Canvas]::SetLeft($accumGroup, 0)
[System.Windows.Controls.Canvas]::SetTop($accumGroup, 0)

# Inicjalizacja płatków
for ($i=0; $i -lt $flakeCount; $i++) {
    $e = New-Object System.Windows.Shapes.Ellipse
    $size = Get-Random -Minimum 2 -Maximum 5
    $e.Width = $size
    $e.Height = $size
    $e.Fill = 'White'
    $x = Get-Random -Minimum 0 -Maximum $screenW
    $y = Get-Random -Minimum -$screenH -Maximum 0
    $spd = Get-Random -Minimum 1 -Maximum 3.5
    [void]$canvas.Children.Add($e)
    [void]$snowElements.Add($e)
    $flakes += [pscustomobject]@{Shape=$e; X=$x; Y=$y; Speed=$spd; Size=$size}
    [System.Windows.Controls.Canvas]::SetLeft($e, $x)
    [System.Windows.Controls.Canvas]::SetTop($e, $y)
}

# Event handler dla przycisku śniegu
$btnSnow.Add_Checked({
    foreach ($elem in $snowElements) {
        $elem.Visibility = 'Visible'
    }
})

$btnSnow.Add_Unchecked({
    foreach ($elem in $snowElements) {
        $elem.Visibility = 'Collapsed'
    }
})

# --- Choinki ---
$treeCount = 8
for ($i=0; $i -lt $treeCount; $i++) {
    $x = Get-Random -Minimum 40 -Maximum ($screenW - 80)
    $h = Get-Random -Minimum 40 -Maximum 80

    $trunkH = [int]($h * 0.30)
    $trunk = New-Object System.Windows.Shapes.Rectangle
    $trunk.Width  = 8
    $trunk.Height = $trunkH
    $trunk.Fill   = 'SaddleBrown'
    [void]$canvas.Children.Add($trunk)
    [void]$treeElements.Add($trunk)
    [System.Windows.Controls.Canvas]::SetLeft($trunk, $x + 20 - ($trunk.Width/2))
    [System.Windows.Controls.Canvas]::SetTop($trunk, $screenH - $trunkH)

    $levels = [int]([Math]::Max(3, [Math]::Floor($h / 4)))
    $baseX = $x + 20
    $baseTopY = ($screenH - $trunkH) - $h

    for ($levelIndex = 0; $levelIndex -lt $levels; $levelIndex++) {
        if ($levels -gt 1) {
            $levelRatio = $levelIndex / ([double]($levels - 1))
        } else {
            $levelRatio = 1
        }

        $yLevel = [int]($baseTopY + ($levelRatio * $h))
        $needlesAtLevel = [int](2 + ($levelRatio * 12))
        $maxSpread = [int](3 + $levelRatio * 20)

        for ($ni=0; $ni -lt $needlesAtLevel; $ni++) {
            if ($maxSpread -le 0) {
                $offset = 0
            } else {
                $offset = Get-Random -Minimum (-$maxSpread) -Maximum $maxSpread
            }
            $nx = $baseX + $offset

            $g = Get-Random -Minimum 100 -Maximum 240
            $needleColor = [System.Windows.Media.Color]::FromRgb(0, $g, 0)
            $brush = New-Object System.Windows.Media.SolidColorBrush $needleColor

            $needle = New-Object System.Windows.Shapes.Rectangle
            $needle.Width  = Get-Random -Minimum 2 -Maximum 4
            $needle.Height = Get-Random -Minimum 3 -Maximum 6
            $needle.Fill = $brush

            $yJitter = Get-Random -Minimum -1 -Maximum 3
            $drawY = $yLevel + $yJitter

            [void]$canvas.Children.Add($needle)
            [void]$treeElements.Add($needle)
            [System.Windows.Controls.Canvas]::SetLeft($needle, $nx)
            [System.Windows.Controls.Canvas]::SetTop($needle, $drawY)
        }
    }

    $topX = $baseX
    $topY = $baseTopY - 4
    $lines = @(
        @{x1=$topX; y1=$topY; x2=$topX; y2=($topY-5)},
        @{x1=$topX; y1=$topY; x2=($topX-4); y2=($topY+3)},
        @{x1=$topX; y1=$topY; x2=($topX+4); y2=($topY+3)},
        @{x1=$topX; y1=$topY; x2=($topX-4); y2=($topY-1)},
        @{x1=$topX; y1=$topY; x2=($topX+4); y2=($topY-1)}
    )
    foreach ($ln in $lines) {
        $l = New-Object System.Windows.Shapes.Line
        $l.X1 = $ln.x1; $l.Y1 = $ln.y1
        $l.X2 = $ln.x2; $l.Y2 = $ln.y2
        $l.StrokeThickness = 2
        $l.Stroke = 'Red'
        [void]$canvas.Children.Add($l)
        [void]$treeElements.Add($l)
    }
}

# Event handler dla przycisku choinek
$btnTree.Add_Checked({
    foreach ($elem in $treeElements) {
        $elem.Visibility = 'Visible'
    }
})

$btnTree.Add_Unchecked({
    foreach ($elem in $treeElements) {
        $elem.Visibility = 'Collapsed'
    }
})

# --- Mikołaj (latający po ekranie) ---



# Get raw bytes 
[byte[]]$santaBytes = (Invoke-WebRequest -Uri $surl -UseBasicParsing).Content


# Create MemoryStream from the byte array
$santaStream = New-Object System.IO.MemoryStream(,$santaBytes)
$santaHash = Get-FileHash -InputStream $santaStream -Algorithm SHA256

if ($santaHash.Hash -ne $sStoredHash){
Write-Output "Santa Hash Mismatch"
$window.Close()
exit 1
} 

$santaBitmap = New-Object System.Windows.Media.Imaging.BitmapImage
$santaBitmap.BeginInit()
$santaBitmap.StreamSource = $santaStream
$santaBitmap.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
$santaBitmap.EndInit()
$santaBitmap.Freeze()

$imgSanta = New-Object System.Windows.Controls.Image
$imgSanta.Source = $santaBitmap
$imgSanta.Width = 200
$imgSanta.Height = 200
[void]$canvas.Children.Add($imgSanta)
[void]$santaElements.Add($imgSanta)

$santaX = -$imgSanta.Width
$santaY = $screenH/3
$santaDir = 1

# Event handler dla przycisku Mikołajów
$btnSanta.Add_Checked({
    foreach ($elem in $santaElements) {
        $elem.Visibility = 'Visible'
    }
})

$btnSanta.Add_Unchecked({
    foreach ($elem in $santaElements) {
        $elem.Visibility = 'Collapsed'
    }
})

# --- Migające lampki świąteczne ---

$lightColors = @(
    [System.Windows.Media.Brushes]::Red,
    [System.Windows.Media.Brushes]::Green,
    [System.Windows.Media.Brushes]::Blue,
    [System.Windows.Media.Brushes]::Yellow,
    [System.Windows.Media.Brushes]::Orange,
    [System.Windows.Media.Brushes]::Purple
)

# Lampki na górze
for ($i = 0; $i -lt 20; $i++) {
    $light = New-Object System.Windows.Shapes.Ellipse
    $light.Width = 12
    $light.Height = 12
    $light.Fill = $lightColors[$i % $lightColors.Count]
    $light.Visibility = 'Collapsed'
    [System.Windows.Controls.Canvas]::SetLeft($light, $i * ($screenW / 20))
    [System.Windows.Controls.Canvas]::SetTop($light, 5)
    [void]$canvas.Children.Add($light)
    [void]$lightsElements.Add($light)
}

# Lampki na dole
for ($i = 0; $i -lt 20; $i++) {
    $light = New-Object System.Windows.Shapes.Ellipse
    $light.Width = 12
    $light.Height = 12
    $light.Fill = $lightColors[($i + 3) % $lightColors.Count]
    $light.Visibility = 'Collapsed'
    [System.Windows.Controls.Canvas]::SetLeft($light, $i * ($screenW / 20))
    [System.Windows.Controls.Canvas]::SetTop($light, $screenH - 20)
    [void]$canvas.Children.Add($light)
    [void]$lightsElements.Add($light)
}

# Lampki po lewej
for ($i = 0; $i -lt 15; $i++) {
    $light = New-Object System.Windows.Shapes.Ellipse
    $light.Width = 12
    $light.Height = 12
    $light.Fill = $lightColors[($i + 1) % $lightColors.Count]
    $light.Visibility = 'Collapsed'
    [System.Windows.Controls.Canvas]::SetLeft($light, 5)
    [System.Windows.Controls.Canvas]::SetTop($light, $i * ($screenH / 15))
    [void]$canvas.Children.Add($light)
    [void]$lightsElements.Add($light)
}

# Lampki po prawej
for ($i = 0; $i -lt 15; $i++) {
    $light = New-Object System.Windows.Shapes.Ellipse
    $light.Width = 12
    $light.Height = 12
    $light.Fill = $lightColors[($i + 4) % $lightColors.Count]
    $light.Visibility = 'Collapsed'
    [System.Windows.Controls.Canvas]::SetLeft($light, $screenW - 20)
    [System.Windows.Controls.Canvas]::SetTop($light, $i * ($screenH / 15))
    [void]$canvas.Children.Add($light)
    [void]$lightsElements.Add($light)
}

# Event handler dla przycisku lampek
$btnLights.Add_Checked({
    foreach ($elem in $lightsElements) {
        $elem.Visibility = 'Visible'
    }
})

$btnLights.Add_Unchecked({
    foreach ($elem in $lightsElements) {
        $elem.Visibility = 'Collapsed'
    }
})

# Timer
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromMilliseconds(25)
$rand = { Get-Random -Minimum -3 -Maximum 3 }
$lightBlinkCounter = 0

$timer.Add_Tick({
    # Śnieg
    if ($btnSnow.IsChecked -eq $false) { 
        # Pomiń animację śniegu
    } else {
        foreach ($f in $flakes) {
            $f.X += (&$rand)
            $f.Y += $f.Speed

            if ($f.X -lt 0) { $f.X = $screenW + $f.X }
            if ($f.X -gt $screenW) { $f.X = $f.X - $screenW }

            $cell = [int]([Math]::Floor($f.X / $cellSize))
            if ($cell -lt 0) { $cell = 0 } elseif ($cell -ge $cells) { $cell = $cells-1 }

            $groundY = $screenH - $ground[$cell]
            
            if ($f.Y + $f.Size -ge $groundY) {
                $r = New-Object System.Windows.Shapes.Rectangle
                $r.Width = $cellSize
                $r.Height = 1
                $r.Fill = 'White'
                $rx = $cell * $cellSize
                $ry = $screenH - $ground[$cell] - 1
                [void]$accumGroup.Children.Add($r)
                [System.Windows.Controls.Canvas]::SetLeft($r, $rx)
                [System.Windows.Controls.Canvas]::SetTop($r, $ry)

                $ground[$cell] = [int]($ground[$cell] + 1)

                $spreadProb = Get-Random
                if ($spreadProb -lt 0.55) {
                    $left = $cell - 1
                    if ($left -ge 0 -and $ground[$left] -lt ($ground[$cell] + 2)) {
                        $ground[$left] = [int]([Math]::Min($screenH, $ground[$left] + 1))
                        $rL = New-Object System.Windows.Shapes.Rectangle
                        $rL.Width = $cellSize
                        $rL.Height = 1
                        $rL.Fill = 'White'
                        [void]$accumGroup.Children.Add($rL)
                        [System.Windows.Controls.Canvas]::SetLeft($rL, $left * $cellSize)
                        [System.Windows.Controls.Canvas]::SetTop($rL, $screenH - $ground[$left])
                    }
                    $right = $cell + 1
                    if ($right -lt $cells -and $ground[$right] -lt ($ground[$cell] + 2)) {
                        $ground[$right] = [int]([Math]::Min($screenH, $ground[$right] + 1))
                        $rR = New-Object System.Windows.Shapes.Rectangle
                        $rR.Width = $cellSize
                        $rR.Height = 1
                        $rR.Fill = 'White'
                        [void]$accumGroup.Children.Add($rR)
                        [System.Windows.Controls.Canvas]::SetLeft($rR, $right * $cellSize)
                        [System.Windows.Controls.Canvas]::SetTop($rR, $screenH - $ground[$right])
                    }
                }

                $f.X = Get-Random -Minimum 0 -Maximum $screenW
                $f.Y = Get-Random -Minimum -200 -Maximum -10
                $f.Speed = Get-Random -Minimum 1 -Maximum 3.5
            } else {
                [System.Windows.Controls.Canvas]::SetLeft($f.Shape, $f.X)
                [System.Windows.Controls.Canvas]::SetTop($f.Shape, $f.Y)
            }
        }
    }
    
    # Mikołaj
    if ($btnSanta.IsChecked -eq $true) {
        $script:santaX += 2 * $script:santaDir
		
        $randsanta = { Get-Random -Minimum -5 -Maximum 5 }
		$randjumpsanta = { Get-Random -Minimum -250 -Maximum 250 }
        # Lekkie losowe odchylenia góra-dół
        $script:santaY += (&$randsanta)
        if ($script:santaY -lt 50) { $script:santaY = 50 }
        if ($script:santaY -gt $screenH - 100) { $script:santaY = $screenH - 100 }
        
        # Zmiana kierunku na krawędziach
        if ($script:santaX -gt $screenW) { $script:santaDir = -1; $script:santaY += &$randjumpsanta  }
        if ($script:santaX + $imgSanta.Width -lt 0) { $script:santaDir = 1; $script:santaY += &$randjumpsanta }
        
        # Lustrzane odbicie gdy leci z prawej do lewej
        $scale = New-Object System.Windows.Media.ScaleTransform
        $scale.ScaleX = $script:santaDir
        $scale.ScaleY = 1
        $imgSanta.RenderTransform = $scale
        $imgSanta.RenderTransformOrigin = [System.Windows.Point]::new(0.5, 0.5)
        
        [System.Windows.Controls.Canvas]::SetLeft($imgSanta, $script:santaX)
        [System.Windows.Controls.Canvas]::SetTop($imgSanta, $script:santaY)
    }
    
    # Lampki migające
    if ($btnLights.IsChecked -eq $true) {
        $script:lightBlinkCounter++
        
        if ($script:lightBlinkCounter % 10 -eq 0) {
            for ($i = 0; $i -lt $lightsElements.Count; $i++) {
                if ((Get-Random -Minimum 0 -Maximum 10) -gt 3) {
                    $lightsElements[$i].Opacity = 1.0
                } else {
                    $lightsElements[$i].Opacity = 0.3
                }
            }
        }
    }
})

# Zatrzymanie timera i sprzątanie przy zamknięciu okna
$null = $window.Add_Closing({
    try { $timer.Stop() } catch {}
    try { Stop-Music } catch {}
    try { 
        $canvas.Children.Clear()
        $accumGroup.Children.Clear()
        $flakes = @()
        $snowElements.Clear()
        $treeElements.Clear()
        $santaElements.Clear()
        $lightsElements.Clear()
    } catch {}
	
	if ($player -ne $null) {
        try {
            $player.Stop()
            $player.Dispose()
            $player = $null
        } catch {}
    }
	
	#Sprzątanie:
    if ($MFile -ne $null -and (Test-Path $MFile)) {
        try {
            Remove-Item $MFile -Force -ErrorAction SilentlyContinue
        } catch {}
    }
	
	exit 0
})

$timer.Start()
$window.ShowDialog() | Out-Null