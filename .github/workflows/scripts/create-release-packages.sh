#!/usr/bin/env bash
set -euo pipefail

# create-release-packages.sh (workflow-local)
# Build Spec Kit template release archives for each supported AI assistant and script type.
# Usage: .github/workflows/scripts/create-release-packages.sh <version>
#   Version argument should include leading 'v'.
#   Optionally set AGENTS and/or SCRIPTS env vars to limit what gets built.
#     AGENTS  : space or comma separated subset of: claude gemini copilot cursor-agent qwen opencode windsurf codex amp shai bob (default: all)
#     SCRIPTS : space or comma separated subset of: sh ps (default: both)
#     LANGS   : space or comma separated subset of: en cn (default: both)
#   Examples:
#     AGENTS=claude SCRIPTS=sh $0 v0.2.0
#     AGENTS="copilot,gemini" $0 v0.2.0
#     SCRIPTS=ps $0 v0.2.0

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <version-with-v-prefix>" >&2
  exit 1
fi
NEW_VERSION="$1"
if [[ ! $NEW_VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Version must look like v0.0.0" >&2
  exit 1
fi

echo "Building release packages for $NEW_VERSION"

# Create and use .genreleases directory for all build artifacts
GENRELEASES_DIR=".genreleases"
mkdir -p "$GENRELEASES_DIR"
rm -rf "$GENRELEASES_DIR"/* || true

rewrite_paths() {
  sed -E \
    -e 's@(/?)memory/@.specify/memory/@g' \
    -e 's@(/?)scripts/@.specify/scripts/@g' \
    -e 's@(/?)templates/@.specify/templates/@g'
}

generate_commands() {
  local agent=$1 ext=$2 arg_format=$3 output_dir=$4 script_variant=$5 lang=$6
  mkdir -p "$output_dir"
  for template in templates/commands/*.md; do
    [[ -f "$template" ]] || continue
    local name description script_command agent_script_command body file_content
    name=$(basename "$template" .md)
    
    # Normalize line endings
    file_content=$(tr -d '\r' < "$template")
    
    # 1. Body extraction based on language
    if [[ $lang == "en" ]]; then
      # Remove all [CN]...[/CN] blocks
      body=$(printf '%s\n' "$file_content" | sed '/\[CN\]/,/\[\/CN\]/d')
      # Remove all -cn fields from frontmatter
      body=$(printf '%s\n' "$body" | sed '/^description-cn:/d' | sed '/^[[:space:]]*label-cn:/d' | sed '/^[[:space:]]*prompt-cn:/d')
      # Extract description from YAML frontmatter
      description=$(printf '%s\n' "$file_content" | awk '/^description:/ {sub(/^description:[[:space:]]*/, ""); print; exit}')
    else
      # For CN: Extract frontmatter and [CN] blocks separately, then combine
      
      # 1. Extract and transform frontmatter
      frontmatter=$(printf '%s\n' "$file_content" | awk '
        BEGIN { dash_count=0 }
        /^---$/ { dash_count++; print; if (dash_count >= 2) exit; next }
        dash_count == 1 { print }
      ')
      
      processed_fm=$(printf '%s\n' "$frontmatter" | awk '
        /^---$/ { print; next }
        /^description-cn:/ { 
          sub(/^description-cn:/, "description:")
          print
          next 
        }
        /^description:/ { next }
        /^[[:space:]]*-[[:space:]]+label:/ { next }
        /^[[:space:]]*label-cn:/ {
          indent_len = match($0, /[^[:space:]]/) - 1
          value = $0
          sub(/^[[:space:]]*label-cn:[[:space:]]*/, "", value)
          if (indent_len >= 4) {
            printf "  - label: %s\n", value
          } else {
            sub(/label-cn:/, "label:", $0)
            print
          }
          next
        }
        /^[[:space:]]*prompt:/ { 
          getline next_line
          if (next_line ~ /prompt-cn:/) {
            $0 = next_line
            sub(/prompt-cn:/, "prompt:")
            print
          }
          next
        }
        /^[[:space:]]*prompt-cn:/ {
          sub(/prompt-cn:/, "prompt:")
          print
          next
        }
        { print }
      ')
      
      # Extract description
      description=$(printf '%s\n' "$file_content" | awk '/^description-cn:/ {sub(/^description-cn:[[:space:]]*/, ""); print; exit}')
      if [[ -z $description ]]; then
    description=$(printf '%s\n' "$file_content" | awk '/^description:/ {sub(/^description:[[:space:]]*/, ""); print; exit}')
      fi
      
      # 2. Extract [CN] blocks
      cn_blocks=$(printf '%s\n' "$file_content" | awk '/\[CN\]/ {in_cn=1; next} /\[\/CN\]/ {in_cn=0; next} in_cn {print}')
      
      # 3. Combine frontmatter and CN blocks
      body=$(printf '%s\n%s' "$processed_fm" "$cn_blocks")
    fi
    
    # Extract script command from YAML frontmatter
    # Use -cn variant if lang=cn and it exists
    if [[ $lang == "cn" ]]; then
      script_command=$(printf '%s\n' "$file_content" | awk -v sv="$script_variant" '/^[[:space:]]*'"$script_variant"'-cn:[[:space:]]*/ {sub(/^[[:space:]]*'"$script_variant"'-cn:[[:space:]]*/, ""); print; exit}')
    fi
    if [[ -z ${script_command:-} ]]; then
    script_command=$(printf '%s\n' "$file_content" | awk -v sv="$script_variant" '/^[[:space:]]*'"$script_variant"':[[:space:]]*/ {sub(/^[[:space:]]*'"$script_variant"':[[:space:]]*/, ""); print; exit}')
    fi
    
    if [[ -z ${script_command:-} ]]; then
      echo "Warning: no script command found for $script_variant in $template" >&2
      script_command="(Missing script command for $script_variant)"
    fi
    
    # Extract agent_script command from YAML frontmatter if present
    agent_script_command=""
    if [[ $lang == "cn" ]]; then
      agent_script_command=$(printf '%s\n' "$file_content" | awk -v sv="$script_variant" '
        /^agent_scripts:$/ { in_agent_scripts=1; next }
        in_agent_scripts && /^[[:space:]]*'"$script_variant"'-cn:[[:space:]]*/ {
          sub(/^[[:space:]]*'"$script_variant"'-cn:[[:space:]]*/, "")
          print
          exit
        }
        in_agent_scripts && /^[a-zA-Z]/ { in_agent_scripts=0 }
      ')
    fi
    if [[ -z ${agent_script_command:-} ]]; then
      agent_script_command=$(printf '%s\n' "$file_content" | awk -v sv="$script_variant" '
      /^agent_scripts:$/ { in_agent_scripts=1; next }
      in_agent_scripts && /^[[:space:]]*'"$script_variant"':[[:space:]]*/ {
        sub(/^[[:space:]]*'"$script_variant"':[[:space:]]*/, "")
        print
        exit
      }
      in_agent_scripts && /^[a-zA-Z]/ { in_agent_scripts=0 }
    ')
    fi
    
    # Replace {SCRIPT} placeholder with the script command
    body=$(printf '%s\n' "$body" | sed "s|{SCRIPT}|${script_command}|g")
    
    # Replace {AGENT_SCRIPT} placeholder with the agent script command if found
    if [[ -n ${agent_script_command:-} ]]; then
      body=$(printf '%s\n' "$body" | sed "s|{AGENT_SCRIPT}|${agent_script_command}|g")
    fi
    
    # Remove the scripts: and agent_scripts: sections from frontmatter
    body=$(printf '%s\n' "$body" | awk '
      /^---$/ { print; if (++dash_count == 1) in_frontmatter=1; else in_frontmatter=0; next }
      in_frontmatter {
        if (/^scripts:$/ || /^agent_scripts:$/) { skip_scripts=1; next }
        if (/^[a-zA-Z].*:/ && skip_scripts) { skip_scripts=0 }
        if (skip_scripts && /^[[:space:]]/) { next }
      }
      { print }
    ')
    
    # Clean up multiple consecutive blank lines (keep max 1 blank line)
    body=$(printf '%s\n' "$body" | awk 'NF {blank=0; print; next} !blank {blank=1; print}')
    
    # Apply other substitutions
    body=$(printf '%s\n' "$body" | sed "s/{ARGS}/$arg_format/g" | sed "s/__AGENT__/$agent/g" | rewrite_paths)
    
    case $ext in
      toml)
        body=$(printf '%s\n' "$body" | sed 's/\\/\\\\/g')
        { echo "description = \"$description\""; echo; echo "prompt = \"\"\""; echo "$body"; echo "\"\"\""; } > "$output_dir/speckit.$name.$ext" ;;
      md)
        echo "$body" > "$output_dir/speckit.$name.$ext" ;;
      agent.md)
        echo "$body" > "$output_dir/speckit.$name.$ext" ;;
    esac
  done
}

generate_copilot_prompts() {
  local agents_dir=$1 prompts_dir=$2
  mkdir -p "$prompts_dir"
  
  # Generate a .prompt.md file for each .agent.md file
  for agent_file in "$agents_dir"/speckit.*.agent.md; do
    [[ -f "$agent_file" ]] || continue
    
    local basename=$(basename "$agent_file" .agent.md)
    local prompt_file="$prompts_dir/${basename}.prompt.md"
    
    # Create prompt file with agent frontmatter
    cat > "$prompt_file" <<EOF
---
agent: ${basename}
---
EOF
  done
}

build_variant() {
  local agent=$1 script=$2 lang=$3
  local base_dir="$GENRELEASES_DIR/sdd-${agent}-package-${script}-${lang}"
  echo "Building $agent ($script) ($lang) package..."
  mkdir -p "$base_dir"
  
  # Copy base structure but filter scripts by variant
  SPEC_DIR="$base_dir/.specify"
  mkdir -p "$SPEC_DIR"
  
  [[ -d memory ]] && { cp -r memory "$SPEC_DIR/"; echo "Copied memory -> .specify"; }
  
  # Only copy the relevant script variant directory
  if [[ -d scripts ]]; then
    mkdir -p "$SPEC_DIR/scripts"
    case $script in
      sh)
        [[ -d scripts/bash ]] && { cp -r scripts/bash "$SPEC_DIR/scripts/"; echo "Copied scripts/bash -> .specify/scripts"; }
        # Copy any script files that aren't in variant-specific directories
        find scripts -maxdepth 1 -type f -exec cp {} "$SPEC_DIR/scripts/" \; 2>/dev/null || true
        ;;
      ps)
        [[ -d scripts/powershell ]] && { cp -r scripts/powershell "$SPEC_DIR/scripts/"; echo "Copied scripts/powershell -> .specify/scripts"; }
        # Copy any script files that aren't in variant-specific directories
        find scripts -maxdepth 1 -type f -exec cp {} "$SPEC_DIR/scripts/" \; 2>/dev/null || true
        ;;
    esac
  fi
  
  [[ -d templates ]] && { mkdir -p "$SPEC_DIR/templates"; find templates -type f -not -path "templates/commands/*" -not -name "vscode-settings.json" -exec cp --parents {} "$SPEC_DIR"/ \; ; echo "Copied templates -> .specify/templates"; }
  
  # NOTE: We substitute {ARGS} internally. Outward tokens differ intentionally:
  #   * Markdown/prompt (claude, copilot, cursor-agent, opencode): $ARGUMENTS
  #   * TOML (gemini, qwen): {{args}}
  # This keeps formats readable without extra abstraction.

  case $agent in
    claude)
      mkdir -p "$base_dir/.claude/commands"
      generate_commands claude md "\$ARGUMENTS" "$base_dir/.claude/commands" "$script" "$lang" ;;
    gemini)
      mkdir -p "$base_dir/.gemini/commands"
      generate_commands gemini toml "{{args}}" "$base_dir/.gemini/commands" "$script" "$lang"
      [[ -f agent_templates/gemini/GEMINI.md ]] && cp agent_templates/gemini/GEMINI.md "$base_dir/GEMINI.md" ;;
    copilot)
      mkdir -p "$base_dir/.github/agents"
      generate_commands copilot agent.md "\$ARGUMENTS" "$base_dir/.github/agents" "$script" "$lang"
      # Generate companion prompt files
      generate_copilot_prompts "$base_dir/.github/agents" "$base_dir/.github/prompts"
      # Create VS Code workspace settings
      mkdir -p "$base_dir/.vscode"
      [[ -f templates/vscode-settings.json ]] && cp templates/vscode-settings.json "$base_dir/.vscode/settings.json"
      ;;
    cursor-agent)
      mkdir -p "$base_dir/.cursor/commands"
      generate_commands cursor-agent md "\$ARGUMENTS" "$base_dir/.cursor/commands" "$script" "$lang" ;;
    qwen)
      mkdir -p "$base_dir/.qwen/commands"
      generate_commands qwen toml "{{args}}" "$base_dir/.qwen/commands" "$script" "$lang"
      [[ -f agent_templates/qwen/QWEN.md ]] && cp agent_templates/qwen/QWEN.md "$base_dir/QWEN.md" ;;
    opencode)
      mkdir -p "$base_dir/.opencode/command"
      generate_commands opencode md "\$ARGUMENTS" "$base_dir/.opencode/command" "$script" "$lang" ;;
    windsurf)
      mkdir -p "$base_dir/.windsurf/workflows"
      generate_commands windsurf md "\$ARGUMENTS" "$base_dir/.windsurf/workflows" "$script" "$lang" ;;
    codex)
      mkdir -p "$base_dir/.codex/prompts"
      generate_commands codex md "\$ARGUMENTS" "$base_dir/.codex/prompts" "$script" "$lang" ;;
    kilocode)
      mkdir -p "$base_dir/.kilocode/workflows"
      generate_commands kilocode md "\$ARGUMENTS" "$base_dir/.kilocode/workflows" "$script" "$lang" ;;
    auggie)
      mkdir -p "$base_dir/.augment/commands"
      generate_commands auggie md "\$ARGUMENTS" "$base_dir/.augment/commands" "$script" "$lang" ;;
    roo)
      mkdir -p "$base_dir/.roo/commands"
      generate_commands roo md "\$ARGUMENTS" "$base_dir/.roo/commands" "$script" "$lang" ;;
    codebuddy)
      mkdir -p "$base_dir/.codebuddy/commands"
      generate_commands codebuddy md "\$ARGUMENTS" "$base_dir/.codebuddy/commands" "$script" "$lang" ;;
    qoder)
      mkdir -p "$base_dir/.qoder/commands"
      generate_commands qoder md "\$ARGUMENTS" "$base_dir/.qoder/commands" "$script" "$lang" ;;
    amp)
      mkdir -p "$base_dir/.agents/commands"
      generate_commands amp md "\$ARGUMENTS" "$base_dir/.agents/commands" "$script" "$lang" ;;
    shai)
      mkdir -p "$base_dir/.shai/commands"
      generate_commands shai md "\$ARGUMENTS" "$base_dir/.shai/commands" "$script" "$lang" ;;
    q)
      mkdir -p "$base_dir/.amazonq/prompts"
      generate_commands q md "\$ARGUMENTS" "$base_dir/.amazonq/prompts" "$script" "$lang" ;;
    bob)
      mkdir -p "$base_dir/.bob/commands"
      generate_commands bob md "\$ARGUMENTS" "$base_dir/.bob/commands" "$script" "$lang" ;;
  esac
  local zip_name
  if [[ "$lang" == "en" ]]; then
    zip_name="spec-kit-template-${agent}-${script}-${NEW_VERSION}.zip"
  else
    zip_name="spec-kit-template-${agent}-${script}-${lang}-${NEW_VERSION}.zip"
  fi
  ( cd "$base_dir" && zip -r "../$zip_name" . )
  echo "Created $GENRELEASES_DIR/$zip_name"
}

# Determine agent list
ALL_AGENTS=(claude gemini copilot cursor-agent qwen opencode windsurf codex kilocode auggie roo codebuddy amp shai q bob qoder)
ALL_SCRIPTS=(sh ps)
ALL_LANGS=(en cn)

norm_list() {
  # convert comma+space separated -> line separated unique while preserving order of first occurrence
  tr ',\n' '  ' | awk '{for(i=1;i<=NF;i++){if(!seen[$i]++){printf((out?"\n":"") $i);out=1}}}END{printf("\n")}'
}

validate_subset() {
  local type=$1; shift; local -n allowed=$1; shift; local items=("$@")
  local invalid=0
  for it in "${items[@]}"; do
    local found=0
    for a in "${allowed[@]}"; do [[ $it == "$a" ]] && { found=1; break; }; done
    if [[ $found -eq 0 ]]; then
      echo "Error: unknown $type '$it' (allowed: ${allowed[*]})" >&2
      invalid=1
    fi
  done
  return $invalid
}

if [[ -n ${AGENTS:-} ]]; then
  mapfile -t AGENT_LIST < <(printf '%s' "$AGENTS" | norm_list)
  validate_subset agent ALL_AGENTS "${AGENT_LIST[@]}" || exit 1
else
  AGENT_LIST=("${ALL_AGENTS[@]}")
fi

if [[ -n ${SCRIPTS:-} ]]; then
  mapfile -t SCRIPT_LIST < <(printf '%s' "$SCRIPTS" | norm_list)
  validate_subset script ALL_SCRIPTS "${SCRIPT_LIST[@]}" || exit 1
else
  SCRIPT_LIST=("${ALL_SCRIPTS[@]}")
fi

if [[ -n ${LANGS:-} ]]; then
  mapfile -t LANG_LIST < <(printf '%s' "$LANGS" | norm_list)
  validate_subset lang ALL_LANGS "${LANG_LIST[@]}" || exit 1
else
  LANG_LIST=("${ALL_LANGS[@]}")
fi

echo "Agents: ${AGENT_LIST[*]}"
echo "Scripts: ${SCRIPT_LIST[*]}"
echo "Langs: ${LANG_LIST[*]}"

for agent in "${AGENT_LIST[@]}"; do
  for script in "${SCRIPT_LIST[@]}"; do
    for lang in "${LANG_LIST[@]}"; do
      build_variant "$agent" "$script" "$lang"
    done
  done
done

echo "Archives in $GENRELEASES_DIR:"
ls -1 "$GENRELEASES_DIR"/spec-kit-template-*-"${NEW_VERSION}".zip

