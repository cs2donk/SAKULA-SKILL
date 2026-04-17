#!/usr/bin/env bash
# ==============================================================================
# SAKULA-SKILL 安装脚本
# ------------------------------------------------------------------------------
# 支持将本仓库中的 skills 安装 / 卸载到主流 AI Agent 的 skills 目录。
#
# 支持的 Agent:
#   claude        - Claude Desktop
#   claude-code   - Claude Code CLI
#   opencode      - OpenCode
#   codex         - OpenAI Codex CLI
#   gemini        - Gemini CLI
#   cursor        - Cursor
#   openclaw      - OpenClaw
#   hermes        - Hermes
#
# 用法:
#   ./install.sh install <skill|all> [--target <agent|all>] [--force]
#   ./install.sh uninstall <skill|all> [--target <agent|all>]
#   ./install.sh list
#   ./install.sh help
#
# 示例:
#   ./install.sh install all                         # 安装全部 skill 到全部 agent
#   ./install.sh install boge-style                  # 安装单个 skill 到全部 agent
#   ./install.sh install boge-style --target cursor  # 安装到指定 agent
#   ./install.sh uninstall all --target claude-code  # 卸载某 agent 下全部 skill
#   ./install.sh list                                # 列出本仓库可用 skill
# ==============================================================================

set -euo pipefail

# ------------------------------ 常量与配置 ----------------------------------

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="${SCRIPT_DIR}"

# 颜色输出
if [[ -t 1 ]]; then
    readonly C_RESET=$'\033[0m'
    readonly C_RED=$'\033[0;31m'
    readonly C_GREEN=$'\033[0;32m'
    readonly C_YELLOW=$'\033[0;33m'
    readonly C_BLUE=$'\033[0;34m'
    readonly C_BOLD=$'\033[1m'
else
    readonly C_RESET=''
    readonly C_RED=''
    readonly C_GREEN=''
    readonly C_YELLOW=''
    readonly C_BLUE=''
    readonly C_BOLD=''
fi

# 支持的 Agent 列表
readonly SUPPORTED_AGENTS=(
    "claude"
    "claude-code"
    "opencode"
    "codex"
    "gemini"
    "cursor"
    "openclaw"
    "hermes"
)

# ------------------------------ 通用工具函数 --------------------------------

log_info()    { printf "${C_BLUE}[INFO]${C_RESET} %s\n"    "$*"; }
log_ok()      { printf "${C_GREEN}[ OK ]${C_RESET} %s\n"   "$*"; }
log_warn()    { printf "${C_YELLOW}[WARN]${C_RESET} %s\n"  "$*"; }
log_err()     { printf "${C_RED}[FAIL]${C_RESET} %s\n"     "$*" >&2; }
log_title()   { printf "\n${C_BOLD}==> %s${C_RESET}\n"     "$*"; }

# 判断操作系统类型
detect_os() {
    case "$(uname -s)" in
        Darwin*)  echo "macos"  ;;
        Linux*)   echo "linux"  ;;
        CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
        *)        echo "unknown" ;;
    esac
}

# 获取指定 Agent 的 skills 安装目录
# $1: agent name
get_agent_skill_dir() {
    local agent="$1"
    local os
    os="$(detect_os)"

    case "${agent}" in
        claude)
            if [[ "${os}" == "macos" ]]; then
                echo "${HOME}/Library/Application Support/Claude/skills"
            elif [[ "${os}" == "windows" ]]; then
                echo "${APPDATA:-${HOME}/AppData/Roaming}/Claude/skills"
            else
                echo "${HOME}/.config/Claude/skills"
            fi
            ;;
        claude-code)
            echo "${HOME}/.claude/skills"
            ;;
        opencode)
            echo "${HOME}/.config/opencode/skills"
            ;;
        codex)
            echo "${HOME}/.codex/skills"
            ;;
        gemini)
            echo "${HOME}/.gemini/skills"
            ;;
        cursor)
            echo "${HOME}/.cursor/skills"
            ;;
        openclaw)
            echo "${HOME}/.openclaw/skills"
            ;;
        hermes)
            echo "${HOME}/.hermes/skills"
            ;;
        *)
            return 1
            ;;
    esac
}

# 校验 agent 名是否被支持
is_supported_agent() {
    local agent="$1"
    local a
    for a in "${SUPPORTED_AGENTS[@]}"; do
        [[ "${a}" == "${agent}" ]] && return 0
    done
    return 1
}

# 列出仓库中全部 skill 目录名（包含 SKILL.md 的子目录）
list_available_skills() {
    local dir
    for dir in "${REPO_ROOT}"/*/; do
        [[ -d "${dir}" ]] || continue
        [[ -f "${dir}/SKILL.md" ]] || continue
        basename "${dir}"
    done
}

# 校验 skill 是否存在于本仓库
is_valid_skill() {
    local skill="$1"
    [[ -d "${REPO_ROOT}/${skill}" && -f "${REPO_ROOT}/${skill}/SKILL.md" ]]
}

# ------------------------------ 核心操作函数 --------------------------------

# 安装单个 skill 到单个 agent
# $1: skill name
# $2: agent name
# $3: force (0/1)
install_one() {
    local skill="$1"
    local agent="$2"
    local force="$3"

    local src="${REPO_ROOT}/${skill}"
    local target_dir
    target_dir="$(get_agent_skill_dir "${agent}")"
    local dest="${target_dir}/${skill}"

    mkdir -p "${target_dir}"

    if [[ -e "${dest}" ]]; then
        if [[ "${force}" -eq 1 ]]; then
            log_warn "已存在 ${dest}，--force 模式覆盖"
            rm -rf "${dest}"
        else
            log_warn "已存在 ${dest}，跳过（使用 --force 可覆盖）"
            return 0
        fi
    fi

    # 使用 cp -R 递归复制整个 skill 目录
    cp -R "${src}" "${dest}"
    log_ok "已安装: ${skill}  ->  ${dest}"
}

# 卸载单个 skill 从单个 agent
# $1: skill name
# $2: agent name
uninstall_one() {
    local skill="$1"
    local agent="$2"

    local target_dir
    target_dir="$(get_agent_skill_dir "${agent}")"
    local dest="${target_dir}/${skill}"

    if [[ ! -e "${dest}" ]]; then
        log_warn "未安装: ${skill} @ ${agent}（${dest} 不存在），跳过"
        return 0
    fi

    rm -rf "${dest}"
    log_ok "已卸载: ${skill}  <-  ${dest}"
}

# ------------------------------ 命令入口 ------------------------------------

cmd_list() {
    log_title "本仓库可用的 Skill"
    local skills=()
    while IFS= read -r s; do skills+=("${s}"); done < <(list_available_skills)

    if [[ "${#skills[@]}" -eq 0 ]]; then
        log_warn "未发现任何 skill（目录下应包含 SKILL.md 的子目录）"
        return 0
    fi

    local s
    for s in "${skills[@]}"; do
        printf "  - ${C_GREEN}%s${C_RESET}\n" "${s}"
    done

    log_title "支持的 Agent 及对应目录"
    local a dir
    for a in "${SUPPORTED_AGENTS[@]}"; do
        dir="$(get_agent_skill_dir "${a}")"
        printf "  - ${C_BLUE}%-12s${C_RESET} -> %s\n" "${a}" "${dir}"
    done
}

cmd_help() {
    cat <<EOF
${C_BOLD}${C_BLUE}SAKULA-SKILL 安装脚本${C_RESET}

${C_BOLD}${C_GREEN}用法:${C_RESET}
  ${C_YELLOW}$0${C_RESET} install   <skill|all> [--target <agent|all>] [--force]
  ${C_YELLOW}$0${C_RESET} uninstall <skill|all> [--target <agent|all>]
  ${C_YELLOW}$0${C_RESET} list
  ${C_YELLOW}$0${C_RESET} help

${C_BOLD}${C_GREEN}参数说明:${C_RESET}
  ${C_BLUE}<skill|all>${C_RESET}        指定 skill 名称，或 'all' 代表全部
  ${C_BLUE}--target <agent>${C_RESET}   指定目标 agent，默认 'all'
                     可选值: ${C_YELLOW}$(IFS=,; echo "${SUPPORTED_AGENTS[*]}")${C_RESET}
  ${C_BLUE}--force${C_RESET}            覆盖已存在的同名 skill

${C_BOLD}${C_GREEN}示例:${C_RESET}
  ${C_YELLOW}$0${C_RESET} install all
  ${C_YELLOW}$0${C_RESET} install boge-style --target cursor
  ${C_YELLOW}$0${C_RESET} install boge-style --target claude-code --force
  ${C_YELLOW}$0${C_RESET} uninstall all --target claude-code
  ${C_YELLOW}$0${C_RESET} uninstall boge-style --target all
  ${C_YELLOW}$0${C_RESET} list
EOF
}

# 解析通用参数（--target / --force）
# 兼容 bash 3.2（macOS 自带），不使用 nameref（bash 4.3+ 特性）。
# 结果通过以下全局变量返回：
#   PF_TARGET: 目标 agent 名，默认 "all"
#   PF_FORCE : 是否强制覆盖，0/1
parse_flags() {
    PF_TARGET="all"
    PF_FORCE=0

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --target)
                [[ $# -ge 2 ]] || { log_err "--target 需要一个参数"; exit 2; }
                PF_TARGET="$2"
                shift 2
                ;;
            --target=*)
                PF_TARGET="${1#--target=}"
                shift
                ;;
            --force|-f)
                PF_FORCE=1
                shift
                ;;
            *)
                log_err "未知参数: $1"
                exit 2
                ;;
        esac
    done
}

# 将 target 参数展开为真实的 agent 列表
# $1: target string
# 输出: agent 列表（换行分隔）
expand_targets() {
    local target="$1"
    if [[ "${target}" == "all" ]]; then
        printf "%s\n" "${SUPPORTED_AGENTS[@]}"
        return 0
    fi

    if ! is_supported_agent "${target}"; then
        log_err "不支持的 agent: ${target}"
        log_err "支持列表: $(IFS=,; echo "${SUPPORTED_AGENTS[*]}")"
        exit 2
    fi
    echo "${target}"
}

# 将 skill 参数展开为真实的 skill 列表
# $1: skill string
expand_skills() {
    local skill="$1"
    if [[ "${skill}" == "all" ]]; then
        list_available_skills
        return 0
    fi

    if ! is_valid_skill "${skill}"; then
        log_err "仓库中不存在 skill: ${skill}"
        log_err "可使用 '$0 list' 查看全部可用 skill"
        exit 2
    fi
    echo "${skill}"
}

cmd_install() {
    [[ $# -ge 1 ]] || { log_err "install 需要指定 skill 名或 all"; cmd_help; exit 2; }
    local skill_arg="$1"; shift

    parse_flags "$@"
    local target="${PF_TARGET}"
    local force="${PF_FORCE}"

    local skills=() targets=()
    while IFS= read -r s; do skills+=("${s}");  done < <(expand_skills   "${skill_arg}")
    while IFS= read -r a; do targets+=("${a}"); done < <(expand_targets  "${target}")

    [[ "${#skills[@]}"  -gt 0 ]] || { log_err "没有可安装的 skill"; exit 1; }
    [[ "${#targets[@]}" -gt 0 ]] || { log_err "没有可安装的 agent"; exit 1; }

    log_title "开始安装 (skills=${#skills[@]}, agents=${#targets[@]}, force=${force})"

    local s a
    local ok=0 fail=0
    for s in "${skills[@]}"; do
        for a in "${targets[@]}"; do
            if install_one "${s}" "${a}" "${force}"; then
                ok=$((ok + 1))
            else
                fail=$((fail + 1))
            fi
        done
    done

    log_title "安装完成: 成功 ${ok}，失败 ${fail}"
    [[ "${fail}" -eq 0 ]]
}

cmd_uninstall() {
    [[ $# -ge 1 ]] || { log_err "uninstall 需要指定 skill 名或 all"; cmd_help; exit 2; }
    local skill_arg="$1"; shift

    parse_flags "$@"
    local target="${PF_TARGET}"
    # 卸载不使用 --force，这里只是忽略它

    # 卸载范围仅限本仓库中定义的 skill，不会影响其他来源的 skill
    local skills=() targets=()
    while IFS= read -r a; do targets+=("${a}"); done < <(expand_targets "${target}")

    if [[ "${skill_arg}" == "all" ]]; then
        # 仅卸载本仓库中定义的 skill，避免误删其他来源的 skill
        while IFS= read -r s; do skills+=("${s}"); done < <(list_available_skills)

        if [[ "${#skills[@]}" -eq 0 ]]; then
            log_warn "本仓库中未发现任何 skill，无需卸载"
            return 0
        fi
    else
        # 指定单个 skill 名的卸载：限制必须是本仓库中定义的 skill
        if ! is_valid_skill "${skill_arg}"; then
            log_err "仓库中不存在 skill: ${skill_arg}"
            log_err "可使用 '$0 list' 查看本仓库定义的 skill"
            log_err "uninstall 仅作用于本仓库中定义的 skill，不会影响其他来源的 skill"
            exit 2
        fi
        skills=("${skill_arg}")
    fi

    log_title "开始卸载 (skills=${#skills[@]}, agents=${#targets[@]})"
    local s a
    local ok=0 fail=0
    for s in "${skills[@]}"; do
        for a in "${targets[@]}"; do
            if uninstall_one "${s}" "${a}"; then
                ok=$((ok + 1))
            else
                fail=$((fail + 1))
            fi
        done
    done
    log_title "卸载完成: 成功 ${ok}，失败 ${fail}"
    [[ "${fail}" -eq 0 ]]
}

# ------------------------------ 主入口 --------------------------------------

main() {
    if [[ $# -lt 1 ]]; then
        cmd_help
        exit 0
    fi

    local cmd="$1"; shift
    case "${cmd}" in
        install)    cmd_install   "$@" ;;
        uninstall)  cmd_uninstall "$@" ;;
        list|ls)    cmd_list            ;;
        help|-h|--help) cmd_help        ;;
        *)
            log_err "未知命令: ${cmd}"
            cmd_help
            exit 2
            ;;
    esac
}

main "$@"
