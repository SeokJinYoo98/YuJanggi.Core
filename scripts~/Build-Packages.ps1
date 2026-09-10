param([string]$Version)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Push-Location $root
try {
    $manifest = Get-Content package.json -Raw | ConvertFrom-Json
    if (-not $Version) { $Version = $manifest.version }
    if ($Version -cnotmatch '^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$') { throw 'Expected major.minor.patch' }
    if ($Version -cne $manifest.version) { throw 'Tag version must match package.json' }
    if ($manifest.name -ne 'com.seokjinyoo.yujanggi.core') { throw 'Unexpected UPM name' }
    $revision = git rev-parse HEAD
    if ($LASTEXITCODE -ne 0) { throw 'Cannot read commit' }
    $output = Join-Path $root "artifacts/$Version"
    if (Test-Path $output) { throw "Output exists: $output. Use a clean checkout." }
    dotnet test ./Tests~/YuJanggi.Core.Tests.csproj -c Release
    if ($LASTEXITCODE -ne 0) { throw 'Core tests failed' }
    dotnet pack YuJanggi.Core.csproj -c Release "-p:Version=$Version" "-p:RepositoryCommit=$revision" -p:ContinuousIntegrationBuild=true -o "$output/nuget"
    if ($LASTEXITCODE -ne 0) { throw 'NuGet pack failed' }
    $package = "$output/upm/package"
    New-Item -ItemType Directory $package -Force | Out-Null
    foreach ($file in @('package.json','package.json.meta','README.md','README.md.meta','Runtime','Runtime.meta')) {
        Copy-Item -LiteralPath $file -Destination $package -Recurse
    }
    if (-not (Test-Path "$package/Runtime/YuJanggi.Core.asmdef")) { throw 'Missing asmdef' }
    if (Get-ChildItem $package -Filter *.dll -Recurse) { throw 'Source UPM must not contain DLLs' }
    $archive = "$output/com.seokjinyoo.yujanggi.core-$Version.tgz"
    tar -czf $archive -C "$output/upm" package
    if ($LASTEXITCODE -ne 0) { throw 'Tar failed' }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $nuget = "$output/nuget/YuJanggi.Core.$Version.nupkg"
    $zip = [IO.Compression.ZipFile]::OpenRead($nuget)
    try {
        if (-not $zip.GetEntry('lib/net10.0/YuJanggi.Core.dll')) { throw 'Missing NuGet DLL' }
    } finally { $zip.Dispose() }
    @{
        version=$Version; commit=$revision
        nugetSha256=(Get-FileHash $nuget -Algorithm SHA256).Hash
        upmSha256=(Get-FileHash $archive -Algorithm SHA256).Hash
    } | ConvertTo-Json | Set-Content "$output/core-version.json" -Encoding utf8
    Write-Host "Packages verified: $output"
} finally { Pop-Location }
