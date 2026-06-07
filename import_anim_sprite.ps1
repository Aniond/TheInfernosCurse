<#
.SYNOPSIS
    Imports an ordered set of PNG frames as ONE multi-frame GameMaker (LTS2026)
    sprite for "The Inferno's Curse". Extends import_sprites.ps1 to animations.

.DESCRIPTION
    Given a folder + filename pattern (e.g. "walk_south_*.png"), this script:
      1. Collects the matching PNGs, sorted by their trailing frame number.
      2. Writes sprites/<SpriteName>/<SpriteName>.yy - a valid $GMSprite v2 record
         with N frames and N sequence keyframes (one shared layer GUID).
      3. Copies each frame PNG into the GM layout:
            sprites/<SpriteName>/<frameGuid_i>.png
            sprites/<SpriteName>/layers/<frameGuid_i>/<layerGuid>.png
      4. Registers the sprite in the project .yyp "resources" array.

    Uses a single-quoted literal template + .Replace() (same proven approach as
    import_sprites.ps1) so JSON quotes/$ never hit the PowerShell parser.

.EXAMPLE
    .\import_anim_sprite.ps1 -FramesFolder assets\sprites\player\benedetto\walk `
        -Pattern "walk_south_*.png" -SpriteName spr_benedetto_walk_south
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$FramesFolder,
    [Parameter(Mandatory)][string]$Pattern,
    [Parameter(Mandatory)][string]$SpriteName,
    [string]$ProjectRoot   = (Join-Path $PSScriptRoot "The Inferno's Curse"),
    [double]$PlaybackSpeed = 8.0
)

$ErrorActionPreference = 'Stop'

# --- Single-quoted template: $ and quotes stay literal, %%TOKENS%% substituted ---
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
%%FRAMES%%
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
    "length":%%LENGTH%%,
    "lockOrigin":false,
    "moments":{
      "$KeyframeStore<MomentsEventKeyframe>":"",
      "Keyframes":[],
      "resourceType":"KeyframeStore<MomentsEventKeyframe>",
      "resourceVersion":"2.0",
    },
    "name":"%%NAME%%",
    "playback":1,
    "playbackSpeed":%%PLAYBACKSPEED%%,
    "playbackSpeedType":0,
    "resourceType":"GMSequence",
    "resourceVersion":"2.0",
    "showBackdrop":true,
    "showBackdropImage":false,
    "timeUnits":1,
    "tracks":[
      {"$GMSpriteFramesTrack":"","builtinName":0,"events":[],"inheritsTrackColour":true,"interpolation":1,"isCreationTrack":false,"keyframes":{"$KeyframeStore<SpriteFrameKeyframe>":"","Keyframes":[
%%KEYFRAMES%%
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

# Per-frame templates (single-quoted; %%..%% substituted per iteration).
$FrameTemplate = '    {"$GMSpriteFrame":"v1","%Name":"%%FG%%","name":"%%FG%%","resourceType":"GMSpriteFrame","resourceVersion":"2.0",},'
$KeyframeTemplate = '            {"$Keyframe<SpriteFrameKeyframe>":"","Channels":{"0":{"$SpriteFrameKeyframe":"","Id":{"name":"%%FG%%","path":"sprites/%%NAME%%/%%NAME%%.yy",},"resourceType":"SpriteFrameKeyframe","resourceVersion":"2.0",},},"Disabled":false,"id":"%%KFID%%","IsCreationKey":false,"Key":%%KEY%%.0,"Length":1.0,"resourceType":"Keyframe<SpriteFrameKeyframe>","resourceVersion":"2.0","Stretch":false,},'

# --- Helpers -----------------------------------------------------------------
function Get-PngSize {
    param([string]$Path)
    $bytes = New-Object byte[] 24
    $fs = [System.IO.File]::OpenRead($Path)
    try { $read = $fs.Read($bytes, 0, 24) } finally { $fs.Dispose() }
    if ($read -lt 24 -or $bytes[0] -ne 0x89 -or $bytes[1] -ne 0x50) { throw "Not a valid PNG: $Path" }
    $width  = ([int]$bytes[16] -shl 24) -bor ([int]$bytes[17] -shl 16) -bor ([int]$bytes[18] -shl 8) -bor [int]$bytes[19]
    $height = ([int]$bytes[20] -shl 24) -bor ([int]$bytes[21] -shl 16) -bor ([int]$bytes[22] -shl 8) -bor [int]$bytes[23]
    return [pscustomobject]@{ Width = $width; Height = $height }
}
function Write-NoBom {
    param([string]$Path, [string]$Content)
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $enc)
}

# --- Validate ----------------------------------------------------------------
if (-not (Test-Path -LiteralPath $FramesFolder)) { throw "Frames folder not found: $FramesFolder" }
$yypPath = Join-Path $ProjectRoot "The Inferno's Curse.yyp"
if (-not (Test-Path -LiteralPath $yypPath)) { throw "Project file not found: $yypPath" }
$spritesRoot = Join-Path $ProjectRoot 'sprites'
$spriteDir   = Join-Path $spritesRoot $SpriteName
if (Test-Path -LiteralPath $spriteDir) { Write-Warning "SKIP - sprite already exists: $SpriteName"; return }

$frames = @(Get-ChildItem -LiteralPath $FramesFolder -Filter $Pattern -File |
    Sort-Object { [int]([regex]::Match($_.BaseName, '(\d+)$').Value) })
if ($frames.Count -eq 0) { throw "No frames matched '$Pattern' in $FramesFolder" }

$size  = Get-PngSize $frames[0].FullName
$W     = $size.Width; $H = $size.Height

$layerGuid  = [guid]::NewGuid().ToString()
$frameGuids = @($frames | ForEach-Object { [guid]::NewGuid().ToString() })

# --- Lay out frame files -----------------------------------------------------
for ($i = 0; $i -lt $frames.Count; $i++) {
    $fg       = $frameGuids[$i]
    $layerDir = Join-Path $spriteDir (Join-Path 'layers' $fg)
    New-Item -ItemType Directory -Path $layerDir -Force | Out-Null
    Copy-Item -LiteralPath $frames[$i].FullName -Destination (Join-Path $spriteDir "$fg.png") -Force
    Copy-Item -LiteralPath $frames[$i].FullName -Destination (Join-Path $layerDir "$layerGuid.png") -Force
}

# --- Build frame + keyframe blocks -------------------------------------------
$frameLines = foreach ($fg in $frameGuids) { $FrameTemplate.Replace('%%FG%%', $fg) }
$kfLines = for ($i = 0; $i -lt $frameGuids.Count; $i++) {
    $KeyframeTemplate.Replace('%%FG%%', $frameGuids[$i]).Replace('%%NAME%%', $SpriteName).Replace('%%KFID%%', [guid]::NewGuid().ToString()).Replace('%%KEY%%', "$i")
}
$framesJson = $frameLines -join "`r`n"
$kfJson     = $kfLines    -join "`r`n"

# --- Fill the sprite template ------------------------------------------------
$yy = $SpriteYyTemplate.
    Replace('%%FRAMES%%',       $framesJson).
    Replace('%%KEYFRAMES%%',    $kfJson).
    Replace('%%NAME%%',         $SpriteName).
    Replace('%%LAYERGUID%%',    $layerGuid).
    Replace('%%WIDTH%%',        "$W").
    Replace('%%HEIGHT%%',       "$H").
    Replace('%%BBOXR%%',        "$($W - 1)").
    Replace('%%BBOXB%%',        "$($H - 1)").
    Replace('%%LENGTH%%',       "$($frameGuids.Count).0").
    Replace('%%PLAYBACKSPEED%%', "$PlaybackSpeed")

Write-NoBom (Join-Path $spriteDir "$SpriteName.yy") $yy
Write-Host ("CREATE {0}  ({1}x{2}, {3} frames)" -f $SpriteName, $W, $H, $frameGuids.Count)

# --- Register in .yyp --------------------------------------------------------
$raw = [System.IO.File]::ReadAllText($yypPath)
$nl  = if ($raw.Contains("`r`n")) { "`r`n" } else { "`n" }
$anchor = '  "resources":['
$idx = $raw.IndexOf($anchor)
if ($idx -lt 0) { throw "Could not locate resources array in $yypPath" }
$entry = '{"id":{"name":"' + $SpriteName + '","path":"sprites/' + $SpriteName + '/' + $SpriteName + '.yy",},},'
if (-not $raw.Contains($entry)) {
    $insertAt = $idx + $anchor.Length
    $raw = $raw.Substring(0, $insertAt) + $nl + '    ' + $entry + $raw.Substring($insertAt)
    Write-NoBom $yypPath $raw
    Write-Host "Registered $SpriteName in $(Split-Path $yypPath -Leaf)"
} else {
    Write-Host "$SpriteName already registered"
}

Write-Host "Done. Fully quit + reopen GameMaker so it re-reads the project."
