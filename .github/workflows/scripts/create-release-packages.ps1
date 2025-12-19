#!/usr/bin/env pwsh
#requires -Version 7.0

<#
.SYNOPSIS
    Build Spec Kit template release archives for each supported AI assistant and script type.

.DESCRIPTION
    create-release-packages.ps1 (workflow-local)
    Build Spec Kit template release archives for each supported AI assistant and script type.
    
.PARAMETER Version
    Version string with leading 'v' (e.g., v0.2.0)

.PARAMETER Agents
    Comma or space separated subset of agents to build (default: all)
    Valid agents: claude, gemini, copilot, cursor-agent, qwen, opencode, windsurf, codex, kilocode, auggie, roo, codebuddy, amp, q, bob, qoder

.PARAMETER Scripts
    Comma or space separated subset of script types to build (default: both)
    Valid scripts: sh, ps

.PARAMETER Langs
    Comma or space separated subset of languages to build (default: both)
    Valid languages: en, cn

.EXAMPLE
    .\create-release-packages.ps1 -Version v0.2.0

.EXAMPLE
    .\create-release-packages.ps1 -Version v0.2.0 -Agents claude,copilot -Scripts sh

.EXAMPLE
    .\create-release-packages.ps1 -Version v0.2.0 -Agents claude -Scripts ps
#>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Version,
    
    [Parameter(Mandatory=$false)]
    [string]$Agents = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Scripts = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Langs = ""
)

$ErrorActionPreference = "Stop"

# Validate version format
if ($Version -notmatch '^v\d+\.\d+\.\d+$') {
    Write-Error "Version must look like v0.0.0"
    exit 1
}

Write-Host "Building release packages for $Version"

# Create and use .genreleases directory for all build artifacts
$GenReleasesDir = ".genreleases"
if (Test-Path $GenReleasesDir) {
    Remove-Item -Path $GenReleasesDir -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $GenReleasesDir -Force | Out-Null

function Rewrite-Paths {
    param([string]$Content)
    
    $Content = $Content -replace '(/?)\bmemory/', '.specify/memory/'
    $Content = $Content -replace '(/?)\bscripts/', '.specify/scripts/'
    $Content = $Content -replace '(/?)\btemplates/', '.specify/templates/'
    return $Content
}

function Generate-Commands {
    param(
        [string]$Agent,
        [string]$Extension,
        [string]$ArgFormat,
        [string]$OutputDir,
        [string]$ScriptVariant,
        [string]$Lang
    )
    
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    
    $templates = Get-ChildItem -Path "templates/commands/*.md" -File -ErrorAction SilentlyContinue
    
    foreach ($template in $templates) {
        $name = [System.IO.Path]::GetFileNameWithoutExtension($template.Name)
        
        # Read file content and normalize line endings
        $fileContent = (Get-Content -Path $template.FullName -Raw) -replace "`r`n", "`n"
        
        $body = ""
        $description = ""

        if ($Lang -eq "en") {
            # Remove all [CN]...[/CN] blocks
            $body = $fileContent -replace '(?ms)\[CN\].*?\[/CN\]', ''
            
            # Remove all -cn fields from frontmatter
            $body = $body -replace '(?m)^description-cn:.*$\r?\n?', ''
            $body = $body -replace '(?m)^\s*label-cn:.*$\r?\n?', ''
            $body = $body -replace '(?m)^\s*prompt-cn:.*$\r?\n?', ''
            
            # Extract description from YAML frontmatter
            if ($fileContent -match '(?m)^description:\s*(.+)$') {
                $description = $matches[1].Trim()
            }
        } else {
            # For CN: Extract frontmatter and [CN] blocks separately, then combine
            
            # 1. Extract and transform frontmatter
            if ($fileContent -match '(?ms)^(---.*?---)') {
                $frontmatter = $matches[1]
                
                # Check if frontmatter contains [CN] blocks for entire handoffs section
                $hasCnHandoffs = $frontmatter -match '(?ms)handoffs:.*?\[CN\]'
                
                if ($hasCnHandoffs) {
                    # Replace everything between "handoffs:" and "[CN]" with the CN content
                    $processed = $frontmatter -replace '(?ms)(handoffs:\s*\r?\n)(.*?)\[CN\]\s*\r?\n(.*?)\s*\[/CN\]', '$1$3'
                    $body = $processed
                    
                    # Extract description
                    if ($frontmatter -match '(?m)^description-cn:\s*(.+)$') {
                        $description = $matches[1].Trim()
                        $body = $body -replace '(?m)^description:.*\r?\n', ''
                        $body = $body -replace '(?m)^description-cn:', 'description:'
                    } elseif ($frontmatter -match '(?m)^description:\s*(.+)$') {
                        $description = $matches[1].Trim()
                    }
                    
                    # Clean up blank lines before closing ---
                    $body = $body -replace '(?ms)\s*\r?\n(\s*\r?\n)+---', "`n---"
                } else {
                    # Original logic for inline label-cn/prompt-cn
                    $lines = $frontmatter -split "`n"
                    $newFrontmatterLines = @()
                    
                    for ($i = 0; $i -lt $lines.Length; $i++) {
                        $line = $lines[$i]
                        
                        if ($line -match '^description-cn:\s*(.+)$') {
                            $newFrontmatterLines += "description: $($matches[1].Trim())"
                            $description = $matches[1].Trim()
                            continue
                        }
                        if ($line -match '^description:\s*(.+)$') {
                            if ([string]::IsNullOrEmpty($description)) {
                                $description = $matches[1].Trim()
                            }
                            continue
                        }
                        
                        if ($line -match '^(\s*)-\s+label:\s*(.+)$') {
                            continue
                        }
                        
                        if ($line -match '^(\s*)label-cn:\s*(.+)$') {
                            $indent = $matches[1]
                            $value = $matches[2].Trim()
                            if ($indent.Length -ge 4) {
                                $newFrontmatterLines += "  - label: $value"
                            } else {
                                $newFrontmatterLines += "${indent}label: $value"
                            }
                            continue
                        }
                        
                        if ($line -match '^(\s*)prompt:\s*(.+)$') {
                            $hasPromptCn = $false
                            for ($j = $i + 1; $j -lt [Math]::Min($i + 5, $lines.Length); $j++) {
                                if ($lines[$j] -match '^\s*prompt-cn:') {
                                    $hasPromptCn = $true
                                    break
                                }
                                if ($lines[$j] -match '^\s*-\s+\w+:') {
                                    break
                                }
                            }
                            if ($hasPromptCn) {
                                continue
                            }
                            $newFrontmatterLines += $line
                            continue
                        }
                        
                        if ($line -match '^(\s*)prompt-cn:\s*(.+)$') {
                            $newFrontmatterLines += ($line -replace 'prompt-cn:', 'prompt:')
                            continue
                        }
                        
                        $newFrontmatterLines += $line
                    }
                    
                    $body = $newFrontmatterLines -join "`n"
                }
            }
            
            # 2. Extract [CN] blocks from AFTER frontmatter only
            $bodyAfterFrontmatter = ""
            if ($fileContent -match '(?ms)^---.*?---(.*)$') {
                $bodyAfterFrontmatter = $matches[1]
            }
            $matches_cn = [regex]::Matches($bodyAfterFrontmatter, '(?ms)\[CN\](.*?)\[/CN\]')
            foreach ($match in $matches_cn) {
                $body += "`n" + $match.Groups[1].Value.Trim()
            }
        }

        # Extract script command from YAML frontmatter
        $scriptCommand = ""
        if ($Lang -eq "cn") {
            if ($fileContent -match "(?m)^\s*${ScriptVariant}-cn:\s*(.+)$") {
                $scriptCommand = $matches[1].Trim()
            }
        }
        if ([string]::IsNullOrEmpty($scriptCommand)) {
            if ($fileContent -match "(?m)^\s*${ScriptVariant}:\s*(.+)$") {
                $scriptCommand = $matches[1].Trim()
            }
        }
        
        if ([string]::IsNullOrEmpty($scriptCommand)) {
            Write-Warning "No script command found for $ScriptVariant in $($template.Name)"
            $scriptCommand = "(Missing script command for $ScriptVariant)"
        }
        
        # Extract agent_script command from YAML frontmatter if present
        $agentScriptCommand = ""
        if ($Lang -eq "cn") {
            if ($fileContent -match "(?ms)agent_scripts:.*?^\s*${ScriptVariant}-cn:\s*(.+?)$") {
                $agentScriptCommand = $matches[1].Trim()
            }
        }
        if ([string]::IsNullOrEmpty($agentScriptCommand)) {
            if ($fileContent -match "(?ms)agent_scripts:.*?^\s*${ScriptVariant}:\s*(.+?)$") {
                $agentScriptCommand = $matches[1].Trim()
            }
        }
        
        # Replace {SCRIPT} placeholder with the script command
        $body = $body -replace '\{SCRIPT\}', $scriptCommand
        
        # Replace {AGENT_SCRIPT} placeholder with the agent script command if found
        if (-not [string]::IsNullOrEmpty($agentScriptCommand)) {
            $body = $body -replace '\{AGENT_SCRIPT\}', $agentScriptCommand
        }
        
        # Remove the scripts: and agent_scripts: sections from frontmatter
        $lines = $body -split "`n"
        $outputLines = @()
        $inFrontmatter = $false
        $skipScripts = $false
        $dashCount = 0
        
        foreach ($line in $lines) {
            if ($line -match '^---$') {
                $outputLines += $line
                $dashCount++
                if ($dashCount -eq 1) {
                    $inFrontmatter = $true
                } else {
                    $inFrontmatter = $false
                }
                continue
            }
            
            if ($inFrontmatter) {
                if ($line -match '^(scripts|agent_scripts):$') {
                    $skipScripts = $true
                    continue
                }
                if ($line -match '^[a-zA-Z].*:' -and $skipScripts) {
                    $skipScripts = $false
                }
                if ($skipScripts -and $line -match '^\s+') {
                    continue
                }
            }
            
            $outputLines += $line
        }
        
        $body = $outputLines -join "`n"
        
        # Clean up multiple consecutive blank lines (keep max 1 blank line)
        $body = $body -replace '(?m)(\r?\n){3,}', "`n`n"
        
        # Apply other substitutions
        $body = $body -replace '\{ARGS\}', $ArgFormat
        $body = $body -replace '__AGENT__', $Agent
        $body = Rewrite-Paths -Content $body
        
        # Generate output file based on extension
        $outputFile = Join-Path $OutputDir "speckit.$name.$Extension"
        
        switch ($Extension) {
            'toml' {
                $body = $body -replace '\\', '\\'
                $output = "description = `"$description`"`n`nprompt = `"`"`"`n$body`n`"`"`""
                Set-Content -Path $outputFile -Value $output -NoNewline
            }
            'md' {
                Set-Content -Path $outputFile -Value $body -NoNewline
            }
            'agent.md' {
                Set-Content -Path $outputFile -Value $body -NoNewline
            }
        }
    }
}

function Generate-CopilotPrompts {
    param(
        [string]$AgentsDir,
        [string]$PromptsDir
    )
    
    New-Item -ItemType Directory -Path $PromptsDir -Force | Out-Null
    
    $agentFiles = Get-ChildItem -Path "$AgentsDir/speckit.*.agent.md" -File -ErrorAction SilentlyContinue
    
    foreach ($agentFile in $agentFiles) {
        $basename = $agentFile.Name -replace '\.agent\.md$', ''
        $promptFile = Join-Path $PromptsDir "$basename.prompt.md"
        
        $content = @"
---
agent: $basename
---
"@
        Set-Content -Path $promptFile -Value $content
    }
}

function Build-Variant {
    param(
        [string]$Agent,
        [string]$Script,
        [string]$Lang
    )
    
    $baseDir = Join-Path $GenReleasesDir "sdd-${Agent}-package-${Script}-${Lang}"
    Write-Host "Building $Agent ($Script) ($Lang) package..."
    New-Item -ItemType Directory -Path $baseDir -Force | Out-Null
    
    # Copy base structure but filter scripts by variant
    $specDir = Join-Path $baseDir ".specify"
    New-Item -ItemType Directory -Path $specDir -Force | Out-Null
    
    # Copy memory directory
    if (Test-Path "memory") {
        Copy-Item -Path "memory" -Destination $specDir -Recurse -Force
        Write-Host "Copied memory -> .specify"
    }
    
    # Only copy the relevant script variant directory
    if (Test-Path "scripts") {
        $scriptsDestDir = Join-Path $specDir "scripts"
        New-Item -ItemType Directory -Path $scriptsDestDir -Force | Out-Null
        
        switch ($Script) {
            'sh' {
                if (Test-Path "scripts/bash") {
                    Copy-Item -Path "scripts/bash" -Destination $scriptsDestDir -Recurse -Force
                    Write-Host "Copied scripts/bash -> .specify/scripts"
                }
            }
            'ps' {
                if (Test-Path "scripts/powershell") {
                    Copy-Item -Path "scripts/powershell" -Destination $scriptsDestDir -Recurse -Force
                    Write-Host "Copied scripts/powershell -> .specify/scripts"
                }
            }
        }
        
        # Copy any script files that aren't in variant-specific directories
        Get-ChildItem -Path "scripts" -File -ErrorAction SilentlyContinue | ForEach-Object {
            Copy-Item -Path $_.FullName -Destination $scriptsDestDir -Force
        }
    }
    
    # Copy templates (excluding commands directory and vscode-settings.json)
    if (Test-Path "templates") {
        $templatesDestDir = Join-Path $specDir "templates"
        New-Item -ItemType Directory -Path $templatesDestDir -Force | Out-Null
        
        Get-ChildItem -Path "templates" -Recurse -File | Where-Object {
            $_.FullName -notmatch 'templates[/\\]commands[/\\]' -and $_.Name -ne 'vscode-settings.json'
        } | ForEach-Object {
            $relativePath = $_.FullName.Substring((Resolve-Path "templates").Path.Length + 1)
            $destFile = Join-Path $templatesDestDir $relativePath
            $destFileDir = Split-Path $destFile -Parent
            New-Item -ItemType Directory -Path $destFileDir -Force | Out-Null
            Copy-Item -Path $_.FullName -Destination $destFile -Force
        }
        Write-Host "Copied templates -> .specify/templates"
    }
    
    # Generate agent-specific command files
    switch ($Agent) {
        'claude' {
            $cmdDir = Join-Path $baseDir ".claude/commands"
            Generate-Commands -Agent 'claude' -Extension 'md' -ArgFormat '$ARGUMENTS' -OutputDir $cmdDir -ScriptVariant $Script -Lang $Lang
        }
        'gemini' {
            $cmdDir = Join-Path $baseDir ".gemini/commands"
            Generate-Commands -Agent 'gemini' -Extension 'toml' -ArgFormat '{{args}}' -OutputDir $cmdDir -ScriptVariant $Script -Lang $Lang
            if (Test-Path "agent_templates/gemini/GEMINI.md") {
                Copy-Item -Path "agent_templates/gemini/GEMINI.md" -Destination (Join-Path $baseDir "GEMINI.md")
            }
        }
        'copilot' {
            $agentsDir = Join-Path $baseDir ".github/agents"
            Generate-Commands -Agent 'copilot' -Extension 'agent.md' -ArgFormat '$ARGUMENTS' -OutputDir $agentsDir -ScriptVariant $Script -Lang $Lang
            
            # Generate companion prompt files
            $promptsDir = Join-Path $baseDir ".github/prompts"
            Generate-CopilotPrompts -AgentsDir $agentsDir -PromptsDir $promptsDir
            
            # Create VS Code workspace settings
            $vscodeDir = Join-Path $baseDir ".vscode"
            New-Item -ItemType Directory -Path $vscodeDir -Force | Out-Null
            if (Test-Path "templates/vscode-settings.json") {
                Copy-Item -Path "templates/vscode-settings.json" -Destination (Join-Path $vscodeDir "settings.json")
            }
        }
        'cursor-agent' {
            $cmdDir = Join-Path $baseDir ".cursor/commands"
            Generate-Commands -Agent 'cursor-agent' -Extension 'md' -ArgFormat '$ARGUMENTS' -OutputDir $cmdDir -ScriptVariant $Script -Lang $Lang
        }
        'qwen' {
            $cmdDir = Join-Path $baseDir ".qwen/commands"
            Generate-Commands -Agent 'qwen' -Extension 'toml' -ArgFormat '{{args}}' -OutputDir $cmdDir -ScriptVariant $Script -Lang $Lang
            if (Test-Path "agent_templates/qwen/QWEN.md") {
                Copy-Item -Path "agent_templates/qwen/QWEN.md" -Destination (Join-Path $baseDir "QWEN.md")
            }
        }
        'opencode' {
            $cmdDir = Join-Path $baseDir ".opencode/command"
            Generate-Commands -Agent 'opencode' -Extension 'md' -ArgFormat '$ARGUMENTS' -OutputDir $cmdDir -ScriptVariant $Script -Lang $Lang
        }
        'windsurf' {
            $cmdDir = Join-Path $baseDir ".windsurf/workflows"
            Generate-Commands -Agent 'windsurf' -Extension 'md' -ArgFormat '$ARGUMENTS' -OutputDir $cmdDir -ScriptVariant $Script -Lang $Lang
        }
        'codex' {
            $cmdDir = Join-Path $baseDir ".codex/prompts"
            Generate-Commands -Agent 'codex' -Extension 'md' -ArgFormat '$ARGUMENTS' -OutputDir $cmdDir -ScriptVariant $Script -Lang $Lang
        }
        'kilocode' {
            $cmdDir = Join-Path $baseDir ".kilocode/workflows"
            Generate-Commands -Agent 'kilocode' -Extension 'md' -ArgFormat '$ARGUMENTS' -OutputDir $cmdDir -ScriptVariant $Script -Lang $Lang
        }
        'auggie' {
            $cmdDir = Join-Path $baseDir ".augment/commands"
            Generate-Commands -Agent 'auggie' -Extension 'md' -ArgFormat '$ARGUMENTS' -OutputDir $cmdDir -ScriptVariant $Script -Lang $Lang
        }
        'roo' {
            $cmdDir = Join-Path $baseDir ".roo/commands"
            Generate-Commands -Agent 'roo' -Extension 'md' -ArgFormat '$ARGUMENTS' -OutputDir $cmdDir -ScriptVariant $Script -Lang $Lang
        }
        'codebuddy' {
            $cmdDir = Join-Path $baseDir ".codebuddy/commands"
            Generate-Commands -Agent 'codebuddy' -Extension 'md' -ArgFormat '$ARGUMENTS' -OutputDir $cmdDir -ScriptVariant $Script -Lang $Lang
        }
        'amp' {
            $cmdDir = Join-Path $baseDir ".agents/commands"
            Generate-Commands -Agent 'amp' -Extension 'md' -ArgFormat '$ARGUMENTS' -OutputDir $cmdDir -ScriptVariant $Script -Lang $Lang
        }
        'q' {
            $cmdDir = Join-Path $baseDir ".amazonq/prompts"
            Generate-Commands -Agent 'q' -Extension 'md' -ArgFormat '$ARGUMENTS' -OutputDir $cmdDir -ScriptVariant $Script -Lang $Lang
        }
        'bob' {
            $cmdDir = Join-Path $baseDir ".bob/commands"
            Generate-Commands -Agent 'bob' -Extension 'md' -ArgFormat '$ARGUMENTS' -OutputDir $cmdDir -ScriptVariant $Script -Lang $Lang
        }
        'qoder' {
            $cmdDir = Join-Path $baseDir ".qoder/commands"
            Generate-Commands -Agent 'qoder' -Extension 'md' -ArgFormat '$ARGUMENTS' -OutputDir $cmdDir -ScriptVariant $Script -Lang $Lang
        }
    }
    
    # Create zip archive
    $zipFile = Join-Path $GenReleasesDir "spec-kit-template-${Agent}-${Script}-${Lang}-${Version}.zip"
    Compress-Archive -Path "$baseDir/*" -DestinationPath $zipFile -Force
    Write-Host "Created $zipFile"
}

# Define all agents, scripts, and langs
$AllAgents = @('claude', 'gemini', 'copilot', 'cursor-agent', 'qwen', 'opencode', 'windsurf', 'codex', 'kilocode', 'auggie', 'roo', 'codebuddy', 'amp', 'q', 'bob', 'qoder')
$AllScripts = @('sh', 'ps')
$AllLangs = @('en', 'cn')

function Normalize-List {
    param([string]$RawString)
    
    if ([string]::IsNullOrEmpty($RawString)) {
        return @()
    }
    
    # Split by comma or space and remove duplicates while preserving order
    $items = $RawString -split '[,\s]+' | Where-Object { $_ } | Select-Object -Unique
    return $items
}

function Validate-Subset {
    param(
        [string]$Type,
        [string[]]$Allowed,
        [string[]]$Items
    )
    
    $ok = $true
    foreach ($item in $Items) {
        if ($item -notin $Allowed) {
            Write-Error "Unknown $Type '$item' (allowed: $($Allowed -join ', '))"
            $ok = $false
        }
    }
    return $ok
}

# Determine agent list
if (-not [string]::IsNullOrEmpty($Agents)) {
    $AgentList = Normalize-List -RawString $Agents
    if (-not (Validate-Subset -Type 'agent' -Allowed $AllAgents -Items $AgentList)) {
        exit 1
    }
} else {
    $AgentList = $AllAgents
}

# Determine script list
if (-not [string]::IsNullOrEmpty($Scripts)) {
    $ScriptList = Normalize-List -RawString $Scripts
    if (-not (Validate-Subset -Type 'script' -Allowed $AllScripts -Items $ScriptList)) {
        exit 1
    }
} else {
    $ScriptList = $AllScripts
}

# Determine lang list
if (-not [string]::IsNullOrEmpty($Langs)) {
    $LangList = Normalize-List -RawString $Langs
    if (-not (Validate-Subset -Type 'lang' -Allowed $AllLangs -Items $LangList)) {
        exit 1
    }
} else {
    $LangList = $AllLangs
}

Write-Host "Agents: $($AgentList -join ', ')"
Write-Host "Scripts: $($ScriptList -join ', ')"
Write-Host "Langs: $($LangList -join ', ')"

# Build all variants
foreach ($agent in $AgentList) {
    foreach ($script in $ScriptList) {
        foreach ($lang in $LangList) {
            Build-Variant -Agent $agent -Script $script -Lang $lang
        }
    }
}

Write-Host "`nArchives in ${GenReleasesDir}:"
Get-ChildItem -Path $GenReleasesDir -Filter "spec-kit-template-*-${Version}.zip" | ForEach-Object {
    Write-Host "  $($_.Name)"
}