<#
.SYNOPSIS
    Downloads completed Benedetto animation frames from PixelLab/Backblaze
    and imports each direction into GameMaker via import_anim_sprite.ps1.
    Run this script whenever new animations complete — it skips already-imported
    sprites (import_anim_sprite.ps1 SKIPs if the sprite folder already exists).
#>

$base   = 'https://backblaze.pixellab.ai/file/pixellab-characters/d2cf38ae-8b52-401f-baff-382d6cf22af2/1999bcc4-6cb7-43ad-834a-99bef3163a5c/animations'
$assets = 'C:\TheInfernoCurse\assets\sprites\player\benedetto'
$proj   = 'C:\TheInfernoCurse\The Inferno''s Curse'
$import = 'C:\TheInfernoCurse\import_anim_sprite.ps1'

function Download-Frames($folder, $prefix, $animId, $dirName, $dirSlug, $frameCount) {
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
    for ($f = 0; $f -lt $frameCount; $f++) {
        $dest = Join-Path $folder "${prefix}_${dirSlug}_${f}.png"
        if (-not (Test-Path $dest)) {
            $url = "$base/$animId/$dirName/$f.png"
            Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
        }
    }
}

function Import-AnimDir($folder, $prefix, $slug, $spriteName, $fps) {
    & $import -FramesFolder $folder -Pattern "${prefix}_${slug}_*.png" `
              -SpriteName $spriteName -ProjectRoot $proj -PlaybackSpeed $fps
}

# ── IDLE (breathing-idle, 4 frames each) ─────────────────────────────────────
Write-Host '=== IDLE (breathing-idle) ===' -ForegroundColor Cyan
$idleFolder = Join-Path $assets 'idle'
$idleAnims = @(
    [pscustomobject]@{id='4e87a46c-026a-4700-b2bd-26f4640dfd24'; dir='south';      slug='south'     },
    [pscustomobject]@{id='9fb35725-29d4-497b-9da6-1be40ae616b9'; dir='north';      slug='north'     },
    [pscustomobject]@{id='fedd1db9-86ac-42bd-9a65-9f4c049dbf4a'; dir='east';       slug='east'      },
    [pscustomobject]@{id='cc005679-1cdc-446e-bd0d-4194863fb8aa'; dir='west';       slug='west'      },
    [pscustomobject]@{id='e2886cc5-465f-4b3e-ba1a-24b67d56b63e'; dir='south-east'; slug='south_east'},
    [pscustomobject]@{id='52b882a2-9aa3-48be-8e0e-acfff7244ed8'; dir='north-east'; slug='north_east'},
    [pscustomobject]@{id='8375e161-862b-4ae4-9eba-76342e8fa496'; dir='north-west'; slug='north_west'},
    [pscustomobject]@{id='4c962e5a-fecd-4887-8ad2-7ce533d92d42'; dir='south-west'; slug='south_west'}
)
foreach ($a in $idleAnims) {
    Write-Host "  Downloading idle/$($a.slug)..."
    Download-Frames $idleFolder 'idle' $a.id $a.dir $a.slug 4
}
foreach ($a in $idleAnims) {
    Import-AnimDir $idleFolder 'idle' $a.slug "spr_benedetto_idle_$($a.slug)" 4.0
}

# ── RUN (running-6-frames, 6 frames each) ────────────────────────────────────
Write-Host '=== RUN (running-6-frames) ===' -ForegroundColor Cyan
$runFolder = Join-Path $assets 'run'
$runAnims = @(
    [pscustomobject]@{id='ac5892d3-78a3-47e7-9426-5a7c478a0d7c'; dir='south';      slug='south'     },
    [pscustomobject]@{id='bcf3c0fc-aab7-4022-86f6-8c74267acf7a'; dir='north';      slug='north'     },
    [pscustomobject]@{id='adcc8774-6d66-4790-bef9-a38c8e50301c'; dir='east';       slug='east'      },
    [pscustomobject]@{id='f220ba2d-3a95-4147-a73f-b15b598580ad'; dir='west';       slug='west'      },
    [pscustomobject]@{id='30f169fd-9af7-492a-a884-6dc26091cf75'; dir='south-east'; slug='south_east'},
    [pscustomobject]@{id='f08d81cb-f535-4123-8cdb-04a3bf219dfa'; dir='south-west'; slug='south_west'},
    [pscustomobject]@{id='b76b6cc7-66a7-4078-ae3e-33e2116934af'; dir='north-west'; slug='north_west'}
)
foreach ($a in $runAnims) {
    Write-Host "  Downloading run/$($a.slug)..."
    Download-Frames $runFolder 'run' $a.id $a.dir $a.slug 6
}
foreach ($a in $runAnims) {
    Import-AnimDir $runFolder 'run' $a.slug "spr_benedetto_run_$($a.slug)" 12.0
}

# ── JUMP (jumping-1, 9 frames each — 3 dirs done, 5 missing/failed) ──────────
Write-Host '=== JUMP (jumping-1, partial: S/E/W only) ===' -ForegroundColor Cyan
$jumpFolder = Join-Path $assets 'jump'
$jumpAnims = @(
    [pscustomobject]@{id='1ee70218-01e0-4d1a-ae26-b322e6b0d88b'; dir='south'; slug='south'},
    [pscustomobject]@{id='df50560e-55f0-482d-9094-32886cc778c2'; dir='east';  slug='east' },
    [pscustomobject]@{id='6b8d72a5-c356-4a48-a94c-c90eb6286d41'; dir='west';  slug='west' }
)
foreach ($a in $jumpAnims) {
    Write-Host "  Downloading jump/$($a.slug)..."
    Download-Frames $jumpFolder 'jump' $a.id $a.dir $a.slug 9
}
foreach ($a in $jumpAnims) {
    Import-AnimDir $jumpFolder 'jump' $a.slug "spr_benedetto_jump_$($a.slug)" 9.0
}

Write-Host ''
Write-Host '=== DONE ===' -ForegroundColor Green
Write-Host 'Imported: idle x8, run x7, jump x3 (5 jump dirs still pending re-queue)'
