<#
.SYNOPSIS
    Imports PNG files as GameMaker (LTS2026) sprite resources for "The Inferno's Curse".

.DESCRIPTION
    For every PNG in -SourceFolder this script:
      1. Derives a sprite name  ->  spr_<sanitized-filename>
      2. Creates sprites/<name>/<name>.yy  (a valid $GMSprite v2 record)
      3. Copies the PNG into the GM layout:
            sprites/<name>/<frameGuid>.png
            sprites/<name>/layers/<frameGuid>/<layerGuid>.png
      4. Registers the sprite in the project .yyp "resources" array.

    Sprite pixel dimensions are read straight from each PNG's IHDR chunk.
    Existing sprite folders are SKIPPED (with a warning) so the script is
    safely re-runnable. .yyp entries already present are not duplicated.

.PARAMETER SourceFolder
    Folder to scan (non-recursive) for *.png. Default: .\sprite_import

.PARAMETER ProjectRoot
    Folder containing the GameMaker project. Default: "The Inferno's Curse"
    next to this script.

.EXAMPLE
    .\import_sprites.ps1
    .\import_sprites.ps1 -SourceFolder C:\art\dump
#>
[CmdletBinding()]
param(
    [string]$SourceFolder = (Join-Path $PSScriptRoot 'sprite_import'),
    [string]$ProjectRoot  = (Join-Path $PSScriptRoot "The Inferno's Curse")
)

$ErrorActionPreference = 'Stop'

# --- Single-quoted template: $ stays literal, %%TOKENS%% get substituted -----
$SpriteYyTemplate = @'
{
  "$GMSprite":"v2",
  "%Name":"%%NAME%%",
  "bboxMode":1,
  "bbox_bottom":%%BBOXB%%,
  "bbox_left":0,
  "bbox_right":%%BBOXR%%,
  "bbox_top":0,
  "collisionKind":1,
  "collisionTolerance":0,
  "DynamicTexturePage":false,
  "edgeFiltering":false,
  "For3D":false,
  "frames":[
    {"$GMSpriteFrame":"v1","%Name":"%%FRAMEGUID%%","name":"%%FRAMEGUID%%","resourceType":"GMSpriteFrame","resourceVersion":"2.0",},
  ],
  "gridX":0,
  "gridY":0,
  "height":%%HEIGHT%%,
  "HTile":false,
  "layers":[
    {"$GMImageLayer":"","%Name":"%%LAYERGUID%%","blendMode":0,"displayName":"default","isLocked":false,"name":"%%LAYERGUID%%","opacity":100.0,"resourceType":"GMImageLayer","resourceVersion":"2.0","visible":true,},
  ],
  "name":"%%NAME%%",
  "nineSlice":{
    "$GMNineSliceData":"",
    "bottom":0,
    "enabled":false,
    "guideColour":[4294902015,4294902015,4294902015,4294902015,],
    "highlightColour":1728023040,
    "highlightStyle":0,
    "left":0,
    "resourceType":"GMNineSliceData",
    "resourceVersion":"2.0",
    "right":0,
    "tileMode":[
      0,
      0,
      0,
      0,
      0,
    ],
    "top":0,
  },
  "origin":0,
  "parent":{
    "name":"The Inferno's Curse",
    "path":"The Inferno's Curse.yyp",
  },
  "preMultiplyAlpha":false,
  "resourceType":"GMSprite",
  "resourceVersion":"2.0",
  "sequence":{
    "$GMSequence":"v1",
    "%Name":"%%NAME%%",
    "autoRecord":true,
    "backdropHeight":768,
    "backdropImageOpacity":0.5,
    "backdropImagePath":"",
    "backdropWidth":1366,
    "backdropXOffset":0.0,
    "backdropYOffset":0.0,
    "events":{
      "$KeyframeStore<MessageEventKeyframe>":"",
      "Keyframes":[],
      "resourceType":"KeyframeStore<MessageEventKeyframe>",
      "resourceVersion":"2.0",
    },
    "eventStubScript":null,
    "eventToFunction":{},
    "length":1.0,
    "lockOrigin":false,
    "moments":{
      "$KeyframeStore<MomentsEventKeyframe>":"",
      "Keyframes":[],
      "resourceType":"KeyframeStore<MomentsEventKeyframe>",
      "resourceVersion":"2.0",
    },
    "name":"%%NAME%%",
    "playback":1,
    "playbackSpeed":30.0,
    "playbackSpeedType":0,
    "resourceType":"GMSequence",
    "resourceVersion":"2.0",
    "showBackdrop":true,
    "showBackdropImage":false,
    "timeUnits":1,
    "tracks":[
      {"$GMSpriteFramesTrack":"","builtinName":0,"events":[],"inheritsTrackColour":true,"interpolation":1,"isCreationTrack":false,"keyframes":{"$KeyframeStore<SpriteFrameKeyframe>":"","Keyframes":[
            {"$Keyframe<SpriteFrameKeyframe>":"","Channels":{
                "0":{"$SpriteFrameKeyframe":"","Id":{"name":"%%FRAMEGUID%%","path":"sprites/%%NAME%%/%%NAME%%.yy",},"resourceType":"SpriteFrameKeyframe","resourceVersion":"2.0",},
              },"Disabled":false,"id":"%%KEYFRAMEID%%","IsCreationKey":false,"Key":0.0,"Length":1.0,"resourceType":"Keyframe<SpriteFrameKeyframe>","resourceVersion":"2.0","Stretch":false,},
          ],"resourceType":"KeyframeStore<SpriteFrameKeyframe>","resourceVersion":"2.0",},"modifiers":[],"name":"frames","resourceType":"GMSpriteFramesTrack","resourceVersion":"2.0","spriteId":null,"trackColour":0,"tracks":[],"traits":0,},
    ],
    "visibleRange":null,
    "volume":1.0,
    "xorigin":0,
    "yorigin":0,
  },
  "swatchColours":null,
  "swfPrecision":0.5,
  "textureGroupId":{
    "name":"Default",
    "path":"texturegroups/Default",
  },
  "type":0,
  "VTile":false,
  "width":%%WIDTH%%,
}
'@

# --- Helpers -----------------------------------------------------------------

function Get-PngSize {
    param([string]$Path)
    # PNG: 8-byte signature, 4-byte IHDR length, "IHDR", width(4 BE), height(4 BE).
    $bytes = New-Object byte[] 24
    $fs = [System.IO.File]::OpenRead($Path)
    try {
        $read = $fs.Read($bytes, 0, 24)
    } finally {
        $fs.Dispose()
    }
    if ($read -lt 24 -or $bytes[0] -ne 0x89 -or $bytes[1] -ne 0x50) {
        throw "Not a valid PNG: $Path"
    }
    $width  = ($bytes[16] -shl 24) -bor ($bytes[17] -shl 16) -bor ($bytes[18] -shl 8) -bor $bytes[19]
    $height = ($bytes[20] -shl 24) -bor ($bytes[21] -shl 16) -bor ($bytes[22] -shl 8) -bor $bytes[23]
    return [pscustomobject]@{ Width = $width; Height = $height }
}

function ConvertTo-SpriteName {
    param([string]$BaseName)
    # Lowercase, non-alphanumerics -> underscore, collapse repeats, trim.
    $clean = $BaseName.ToLowerInvariant()
    $clean = ($clean -replace '[^a-z0-9]+', '_').Trim('_')
    if ($clean -eq '') { $clean = 'sprite' }
    return "spr_$clean"
}

function Write-NoBom {
    param([string]$Path, [string]$Content)
    $enc = New-Object System.Text.UTF8Encoding($false)   # no BOM (GM requires first byte = '{')
    [System.IO.File]::WriteAllText($Path, $Content, $enc)
}

# --- Validate paths ----------------------------------------------------------

if (-not (Test-Path -LiteralPath $SourceFolder)) {
    throw "Source folder not found: $SourceFolder"
}
$yypPath = Join-Path $ProjectRoot "The Inferno's Curse.yyp"
if (-not (Test-Path -LiteralPath $yypPath)) {
    throw "Project file not found: $yypPath"
}
$spritesRoot = Join-Path $ProjectRoot 'sprites'
if (-not (Test-Path -LiteralPath $spritesRoot)) {
    New-Item -ItemType Directory -Path $spritesRoot -Force | Out-Null
}

$pngs = @(Get-ChildItem -LiteralPath $SourceFolder -Filter *.png -File)
if ($pngs.Count -eq 0) {
    Write-Host "No PNG files found in $SourceFolder"
    return
}

Write-Host "Found $($pngs.Count) PNG(s) in $SourceFolder`n"

$created   = @()   # names to register in the .yyp
$skipped   = @()

# --- Process each PNG --------------------------------------------------------

foreach ($png in $pngs) {
    $spriteName = ConvertTo-SpriteName $png.BaseName
    $spriteDir  = Join-Path $spritesRoot $spriteName

    if (Test-Path -LiteralPath $spriteDir) {
        Write-Warning "SKIP '$($png.Name)' -> sprite folder already exists: sprites\$spriteName"
        $skipped += $spriteName
        continue
    }

    $size = Get-PngSize $png.FullName

    $frameGuid   = [guid]::NewGuid().ToString()
    $layerGuid   = [guid]::NewGuid().ToString()
    $keyframeId  = [guid]::NewGuid().ToString()

    # Folder layout: sprites/<name>/  and  sprites/<name>/layers/<frameGuid>/
    $layerDir = Join-Path $spriteDir (Join-Path 'layers' $frameGuid)
    New-Item -ItemType Directory -Path $layerDir -Force | Out-Null

    # Copy the source PNG to both the composited-frame slot and the layer slot.
    Copy-Item -LiteralPath $png.FullName -Destination (Join-Path $spriteDir "$frameGuid.png") -Force
    Copy-Item -LiteralPath $png.FullName -Destination (Join-Path $layerDir  "$layerGuid.png") -Force

    # Build the .yy from the template.
    $yy = $SpriteYyTemplate
    $yy = $yy.Replace('%%NAME%%',       $spriteName)
    $yy = $yy.Replace('%%WIDTH%%',      "$($size.Width)")
    $yy = $yy.Replace('%%HEIGHT%%',     "$($size.Height)")
    $yy = $yy.Replace('%%BBOXR%%',      "$($size.Width - 1)")
    $yy = $yy.Replace('%%BBOXB%%',      "$($size.Height - 1)")
    $yy = $yy.Replace('%%FRAMEGUID%%',  $frameGuid)
    $yy = $yy.Replace('%%LAYERGUID%%',  $layerGuid)
    $yy = $yy.Replace('%%KEYFRAMEID%%', $keyframeId)

    Write-NoBom (Join-Path $spriteDir "$spriteName.yy") $yy

    Write-Host ("CREATE {0}  ({1}x{2})" -f $spriteName, $size.Width, $size.Height)
    $created += $spriteName
}

# --- Register new sprites in the .yyp ----------------------------------------

if ($created.Count -gt 0) {
    $raw = [System.IO.File]::ReadAllText($yypPath)
    $nl  = if ($raw.Contains("`r`n")) { "`r`n" } else { "`n" }

    $anchor = '  "resources":['
    $idx = $raw.IndexOf($anchor)
    if ($idx -lt 0) { throw "Could not locate `"resources`":[ in $yypPath" }

    $insertAt = $idx + $anchor.Length
    $newLines = ''
    foreach ($name in $created) {
        $entry = '{"id":{"name":"' + $name + '","path":"sprites/' + $name + '/' + $name + '.yy",},},'
        if ($raw.Contains($entry)) { continue }   # already registered, don't duplicate
        $newLines += $nl + '    ' + $entry
    }

    if ($newLines -ne '') {
        $raw = $raw.Substring(0, $insertAt) + $newLines + $raw.Substring($insertAt)
        $enc = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($yypPath, $raw, $enc)
        Write-Host "`nRegistered $($created.Count) sprite(s) in $(Split-Path $yypPath -Leaf)"
    }
}

# --- Summary -----------------------------------------------------------------

Write-Host ""
Write-Host "Done. Created: $($created.Count)  Skipped: $($skipped.Count)"
if ($skipped.Count -gt 0) {
    Write-Host "Skipped (already existed): $($skipped -join ', ')"
}
Write-Host "Restart GameMaker (fully quit first) so it re-reads the project."
