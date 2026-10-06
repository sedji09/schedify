Add-Type -AssemblyName System.Drawing
$imagePath = "c:\Users\seigi\hello_flutter\android\app\src\main\res\mipmap-hdpi\launcher_icon.png"
if (-not (Test-Path $imagePath)) {
    Write-Host "Image not found"
    exit
}
$bmp = [System.Drawing.Bitmap]::new($imagePath)
$width = $bmp.Width
$height = $bmp.Height
Write-Host "Image loaded: $width x $height"

$corner1 = $bmp.GetPixel(0,0)
$corner2 = $bmp.GetPixel($width-1,0)
$center = $bmp.GetPixel($width/2, $height/2)
Write-Host "Corner1: $($corner1.A), $($corner1.R), $($corner1.G), $($corner1.B)"
Write-Host "Corner2: $($corner2.A), $($corner2.R), $($corner2.G), $($corner2.B)"
Write-Host "Center: $($center.A), $($center.R), $($center.G), $($center.B)"
$bmp.Dispose()
