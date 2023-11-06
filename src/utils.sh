# vim: ft=sh noet
BG_BLACK="\033[40m"
BG_RED="\033[41m"
BG_GREEN="\033[42m"
BG_YELLOW="\033[43m"
BG_BLUE="\033[44m"
BG_MAGENTA="\033[45m"
BG_CYAN="\033[46m"
BG_WHITE="\033[47m"
BG_RESET="\033[49m"

FG_BLACK="\033[30m"
FG_RED="\033[31m"
FG_GREEN="\033[32m"
FG_YELLOW="\033[33m"
FG_BLUE="\033[34m"
FG_MAGENTA="\033[35m"
FG_CYAN="\033[36m"
FG_WHITE="\033[37m"
FG_RESET="\033[39m"

BOLD="\033[1m"
RESET="\033[0m"
PS1="$BG_MAGENTA$FG_BLACK$BOLD ONE $BG_RESET$FG_MAGENTA$RESET "

print_welcome() {
    # print a colorful logo
    # ╭─────────────────────────────────────╮
    # │                              _      │
    # │   ___  ____   ____  ___  ___| | _   │
    # │  / _ \|  _ \ / _  )/___)/___) || \  │
    # │ | |_| | | | ( (/ /|___ |___ | | | | │
    # │  \___/|_| |_|\____|___/(___/|_| |_| │
    # │                                     │
    # ╰─────────────────────────────────────╯
    local fg_border="$FG_RED"
    local fg_one="$FG_YELLOW"
    local fg_ssh="$FG_GREEN"
    echo -e "$BOLD${fg_border}╭────────────$FG_RESET WELCOME TO ${fg_border}─────────────╮"
    echo -e "│                              ${fg_ssh}_     ${fg_border} │"
    echo -e "│   ${fg_one}___  ____   ____  ${fg_ssh}___  ___| | _  ${fg_border} │"
    echo -e "│  ${fg_one}/ _ \|  _ \ / _  )${fg_ssh}/___)/___) || \ ${fg_border} │"
    echo -e "│ ${fg_one}| |_| | | | ( (/ /${fg_ssh}|___ |___ | | | |${fg_border} │"
    echo -e "│  ${fg_one}\___/|_| |_|\____${fg_ssh}|___/(___/|_| |_|${fg_border} │"
    echo -e "│                                    ${fg_border} │"
    echo -e "╰─────────────────────────────────────╯$RESET"
    echo -en "Type ${FG_YELLOW}help${FG_RESET} to see available commands, "
    echo -e "${FG_YELLOW}exit${FG_RESET} to exit the shell."
    echo

	if [ -z "$ONESSH_ALLOWED_USERS" ]; then
		print_warning "\$ONESSH_ALLOWED_USERS is not set," \
			"please set it in \$HOME/.onesshrc"
	fi
}

has_command() {
	local command="$1"
	if [ -x "$ONESSH_LIB/commands/$command" ]; then
		return 0
	else
		return 1
	fi
}

print_prompt() {
	echo -en "$PS1"
}

print_error() {
    echo -en "$FG_RED$BOLD"
    echo -n "ERROR: "
    echo "$*"
    echo -en "$RESET"
}

print_warning() {
    echo -en "$FG_YELLOW$BOLD"
    echo -n "WARNING: "
    echo "$*"
    echo -en "$RESET"
}

print_debug() {
	if [ -z "$ONESSH_DEBUG" ]; then
		return
	fi
    echo -en "$FG_BLUE$BOLD"
    echo -n "DEBUG: "
    echo "$*"
    echo -en "$RESET"
}

print_info() {
    echo -en "$FG_GREEN$BOLD"
    echo -n "INFO: "
    echo "$*"
    echo -en "$RESET"
}

enter_alt_screen() {
	tput smcup || tput -T xterm-256color smcup
}

exit_alt_screen() {
	tput rmcup || tput -T xterm-256color rmcup
}
