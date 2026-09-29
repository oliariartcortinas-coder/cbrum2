$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Web.Extensions
$ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer
$ser.RecursionLimit = 200
$ser.MaxJsonLength = 200000000

$rsText = Get-Content "$env:TEMP\br_rs.json" -Raw
$scText = Get-Content "$env:TEMP\br_sc.json" -Raw
$rs = $ser.DeserializeObject($rsText)
$sc = $ser.DeserializeObject($scText)

function Get-Rings($geojson) {
    $rings = New-Object System.Collections.ArrayList
    foreach ($feature in $geojson['features']) {
        $geom = $feature['geometry']
        $type = $geom['type']
        if ($type -eq 'Polygon') {
            foreach ($ring in $geom['coordinates']) {
                [void]$rings.Add($ring)
            }
        } elseif ($type -eq 'MultiPolygon') {
            foreach ($poly in $geom['coordinates']) {
                foreach ($ring in $poly) {
                    [void]$rings.Add($ring)
                }
            }
        }
    }
    ,$rings
}

$rsRings = Get-Rings $rs
$scRings = Get-Rings $sc

Write-Output "RS rings: $($rsRings.Count)"
Write-Output "SC rings: $($scRings.Count)"

$lonMin = [double]::MaxValue; $lonMax = [double]::MinValue
$latMin = [double]::MaxValue; $latMax = [double]::MinValue
foreach ($ring in ($rsRings + $scRings)) {
    foreach ($pt in $ring) {
        $lon = [double]$pt[0]
        $lat = [double]$pt[1]
        if ($lon -lt $lonMin) { $lonMin = $lon }
        if ($lon -gt $lonMax) { $lonMax = $lon }
        if ($lat -lt $latMin) { $latMin = $lat }
        if ($lat -gt $latMax) { $latMax = $lat }
    }
}

Write-Output "lon: $lonMin .. $lonMax   lat: $latMin .. $latMax"

$avgLat = ($latMin + $latMax) / 2.0
$latRad = $avgLat * [Math]::PI / 180.0
$cosLat = [Math]::Cos($latRad)

$targetW = 420
$targetH = 520
$pad = 10

$spanLon = ($lonMax - $lonMin) * $cosLat
$spanLat = ($latMax - $latMin)

$scale = [Math]::Min( ($targetW - 2*$pad) / $spanLon, ($targetH - 2*$pad) / $spanLat )

function Project($lon, $lat) {
    $x = ($lon - $lonMin) * $cosLat * $scale + $pad
    $y = ($latMax - $lat) * $scale + $pad
    return @($x, $y)
}

function Ring-To-Path($ring, [int]$targetPoints) {
    $n = $ring.Count
    $stride = [Math]::Max(1, [Math]::Floor($n / $targetPoints))
    $sb = New-Object System.Text.StringBuilder
    $first = $true
    for ($i = 0; $i -lt $n; $i += $stride) {
        $pt = $ring[$i]
        $proj = Project ([double]$pt[0]) ([double]$pt[1])
        $x = [Math]::Round($proj[0], 2)
        $y = [Math]::Round($proj[1], 2)
        if ($first) {
            [void]$sb.Append("M$x,$y ")
            $first = $false
        } else {
            [void]$sb.Append("L$x,$y ")
        }
    }
    [void]$sb.Append("Z ")
    return $sb.ToString()
}

function Rings-To-Path($rings) {
    $sb = New-Object System.Text.StringBuilder
    foreach ($ring in $rings) {
        $n = $ring.Count
        if ($n -lt 6) { continue }
        $target = if ($n -gt 800) { 220 } elseif ($n -gt 200) { 140 } else { 60 }
        [void]$sb.Append( (Ring-To-Path $ring $target) )
    }
    return $sb.ToString().Trim()
}

$rsPath = Rings-To-Path $rsRings
$scPath = Rings-To-Path $scRings

Set-Content -Path "$env:TEMP\rs_path.txt" -Value $rsPath -NoNewline
Set-Content -Path "$env:TEMP\sc_path.txt" -Value $scPath -NoNewline

Write-Output "RS path length: $($rsPath.Length)"
Write-Output "SC path length: $($scPath.Length)"

$cities = @{
    "Santa Maria"   = @(-53.8069, -29.6842)
    "Osorio"        = @(-50.2698, -29.8883)
    "Porto Alegre"  = @(-51.2177, -30.0346)
    "Viamao"        = @(-51.0233, -30.0811)
    "Santo Antonio da Patrulha" = @(-50.5306, -29.8994)
    "Santiago"      = @(-54.8689, -29.1711)
    "Paraiso do Sul"= @(-52.8961, -29.6389)
    "Capao da Canoa"= @(-50.0072, -29.7452)
    "Florianopolis" = @(-48.5480, -27.5954)
}

$result = @()
foreach ($key in $cities.Keys) {
    $lon = $cities[$key][0]
    $lat = $cities[$key][1]
    $proj = Project $lon $lat
    $x = [Math]::Round($proj[0], 1)
    $y = [Math]::Round($proj[1], 1)
    $result += "$key : $x, $y"
}
$result | Sort-Object
Write-Output "viewBox: 0 0 $targetW $targetH"
