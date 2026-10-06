Add-Type -AssemblyName System.Drawing
$imagePath = "c:\Users\seigi\hello_flutter\android\app\src\main\res\mipmap-hdpi\launcher_icon.png"
$outPath = "c:\Users\seigi\hello_flutter\android\app\src\main\res\drawable\ic_notification_custom.png"

$bmp = [System.Drawing.Bitmap]::new($imagePath)
$width = $bmp.Width
$height = $bmp.Height

# Manually crop the center of the icon to remove all the empty padding
# and ignore the anti-aliased edges of the rounded square.
$minX = 14
$minY = 14
$maxX = 57
$maxY = 57

Write-Host "Bounding box: ($minX, $minY) to ($maxX, $maxY)"

$cropWidth = $maxX - $minX + 1
$cropHeight = $maxY - $minY + 1

# Add slight padding
$padding = 2
$finalWidth = $cropWidth + ($padding * 2)
$finalHeight = $cropHeight + ($padding * 2)

$newBmp = [System.Drawing.Bitmap]::new($finalWidth, $finalHeight)

for ($x = 0; $x -lt $width; $x++) {
    for ($y = 0; $y -lt $height; $y++) {
        $pixel = $bmp.GetPixel($x, $y)
        
        # Calculate new coordinates with padding
        $newX = $x - $minX + $padding
        $newY = $y - $minY + $padding

        if ($newX -ge 0 -and $newX -lt $finalWidth -and $newY -ge 0 -and $newY -lt $finalHeight) {
            if ($pixel.R -gt 235 -and $pixel.G -gt 235 -and $pixel.B -gt 235) {
                $newBmp.SetPixel($newX, $newY, [System.Drawing.Color]::FromArgb(255, 255, 255, 255))
            } else {
                # Ensure transparent background inside the crop area
                $newBmp.SetPixel($newX, $newY, [System.Drawing.Color]::FromArgb(0, 0, 0, 0))
            }
        }
    }
}

$newBmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$newBmp.Dispose()
$bmp.Dispose()
Write-Host "Cropped and converted successfully to $outPath"
