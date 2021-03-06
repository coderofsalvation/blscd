#!/usr/bin/env bash

# blscd
# Copyright (C) 2014 D630, GNU GPLv3
# <https://github.com/D630/blscd>

# Fork and rewrite in GNU bash of lscd v0.1 [2014, GNU GPLv3] by Roman
# Zimbelmann aka. hut, <https://github.com/hut/lscd>

# -- DEBUGGING.

#printf '%s (%s)\n' "$BASH_VERSION" "${BASH_VERSINFO[5]}" && exit 0
#set -o xtrace
#exec 2>> ~/blscd.log
#set -o verbose
#set -o noexec
#set -o errexit
#set -o nounset
#set -o pipefail
#trap '(read -p "[$BASH_SOURCE:$LINENO] $BASH_COMMAND?")' DEBUG

#declare vars_base=$(set -o posix ; set)
#fgrep -v -e "$vars_base" < <(set -o posix ; set) | \
#egrep -v -e "^BASH_REMATCH=" \
#         -e "^OPTIND=" \
#         -e "^REPLY=" \
#         -e "^BASH_LINENO=" \
#         -e "^BASH_SOURCE=" \
#         -e "^FUNCNAME=" | \
#less

# -- FUNCTIONS.

__blscd_version ()
{
    echo "0.1.4.13"
}

__blscd_build_col_list ()
{
    builtin declare -i i=

    for i
    do
        case $i in
            1)
                if [[ $_blscd_dir_col_1_string == / ]]
                then
                    _blscd_col_1_list=()
                else
                    __blscd_test_data list "$_blscd_dir_col_0_string" || __blscd_build_data -c "$_blscd_dir_col_0_string"
                    builtin mapfile -t _blscd_col_1_list < <(__blscd_print_data list "$_blscd_dir_col_0_string")
                fi
                _blscd_col_1_list_total=${#_blscd_col_1_list[@]}
                if ((_blscd_col_1_list_total > _blscd_screen_lines_browser))
                then
                    _blscd_screen_lines_browser_col_1_visible=$_blscd_screen_lines_browser
                else
                    _blscd_screen_lines_browser_col_1_visible=$_blscd_col_1_list_total
                fi
                ;;
            2)
                __blscd_test_data list "$_blscd_dir_col_1_string" || __blscd_build_data -c "$_blscd_dir_col_1_string"
                builtin mapfile -t _blscd_col_2_list < <(__blscd_print_data list "$_blscd_dir_col_1_string")
                _blscd_col_2_list_total=${#_blscd_col_2_list[@]}
                ((_blscd_col_2_list_total == 0)) && _blscd_col_2_list_total=1
                ;;
            3)
                builtin declare dir_col_2_string=${_blscd_dir_col_1_string}/${_blscd_screen_lines_browser_col_2_cursor_string}
                dir_col_2_string=${dir_col_2_string//\/\//\/}
                __blscd_test_data list "$dir_col_2_string" || [[ -f $dir_col_2_string ]] || __blscd_build_data -c "$dir_col_2_string"
                if __blscd_test_data "list" "$dir_col_2_string"
                then
                    builtin mapfile -t _blscd_col_3_list < <(__blscd_print_data list "$dir_col_2_string")
                else
                    _blscd_col_3_list=()
                fi
                _blscd_col_3_list_total=${#_blscd_col_3_list[@]}
                [[ $_blscd_col_3_list_total -eq 0 && -f $_blscd_screen_lines_browser_col_2_cursor_string ]] && \
                    screen_col_2_width=$((screen_col_2_width * 2))
                ;;
        esac
    done
}

__blscd_build_col_view ()
{
    builtin declare -i i=

    for i
    do
        case $i in
            1)
                if [[ $_blscd_dir_col_1_string == / ]]
                then
                    _blscd_col_1_view_offset=1
                    _blscd_col_1_view=()
                    _blscd_screen_lines_browser_col_1_cursor=0
                elif __blscd_test_data view "$_blscd_dir_col_0_string" $_blscd_screen_lines_browser
                then
                    _blscd_col_1_view_offset=${_blscd_data[view offset ${_blscd_dir_col_0_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse} ${_blscd_screen_lines_browser}]}
                    builtin mapfile -t _blscd_col_1_view < <(__blscd_print_data view "$_blscd_dir_col_0_string" $_blscd_screen_lines_browser)
                    _blscd_screen_lines_browser_col_1_cursor=${_blscd_data[view cursor ${_blscd_dir_col_0_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse} ${_blscd_screen_lines_browser}]}
                else
                    if __blscd_test_data_index "$_blscd_dir_col_1_string" $_blscd_screen_lines_browser
                    then
                        _blscd_col_1_view_offset=$((${_blscd_data[index ${_blscd_dir_col_1_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse}]} - _blscd_screen_lines_browser + 2))
                        _blscd_col_1_view=("${_blscd_col_1_list[@]:$((${_blscd_col_1_view_offset} - 1)):${_blscd_data[index ${_blscd_dir_col_1_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse}]}}")
                        _blscd_screen_lines_browser_col_1_cursor=$((_blscd_screen_lines_browser - 1))
                    else
                        _blscd_col_1_view_offset=1
                        _blscd_col_1_view=("${_blscd_col_1_list[@]:$(($_blscd_col_1_view_offset - 1)):${_blscd_screen_lines_browser}}")
                        _blscd_screen_lines_browser_col_1_cursor=${_blscd_data[index ${_blscd_dir_col_1_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse}]}
                    fi
                    _blscd_data[view ${_blscd_dir_col_0_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse} ${_blscd_screen_lines_browser}]=$(builtin printf '%s\n' "${_blscd_col_1_view[@]}")
                    _blscd_data[view offset ${_blscd_dir_col_0_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse} ${_blscd_screen_lines_browser}]=$_blscd_col_1_view_offset
                    _blscd_data[view cursor ${_blscd_dir_col_0_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse} ${_blscd_screen_lines_browser}]=$_blscd_screen_lines_browser_col_1_cursor
                fi
                _blscd_screen_lines_browser_col_1_cursor_string=${_blscd_col_1_view[$_blscd_screen_lines_browser_col_1_cursor]}
                _blscd_col_1_view_total=${#_blscd_col_1_view[@]}
                ;;
            2)
                [[ $_blscd_search_pattern && $_blscd_search_block != _blscd_search_block ]] && \
                    __blscd_build_search
                if [[ $_blscd_action_last == __blscd_set_sort || $_blscd_action_last == __blscd_set_hide ]]
                then
                    if __blscd_test_data_index "${_blscd_dir_col_1_string}/${_blscd_screen_lines_browser_col_2_cursor_string}" $_blscd_screen_lines_browser
                    then
                        _blscd_col_2_view_offset=$((${_blscd_data[index ${_blscd_dir_col_1_string}/${_blscd_screen_lines_browser_col_2_cursor_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse}]} - _blscd_screen_lines_browser + 2))
                        _blscd_col_2_view=("${_blscd_col_2_list[@]:$((${_blscd_col_2_view_offset} - 1)):${_blscd_data[index ${_blscd_dir_col_1_string}/${_blscd_screen_lines_browser_col_2_cursor_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse}]}}")
                        _blscd_screen_lines_browser_col_2_cursor=$((_blscd_screen_lines_browser - 1))
                    else
                        _blscd_col_2_view_offset=1
                        _blscd_col_2_view=("${_blscd_col_2_list[@]:$(($_blscd_col_2_view_offset - 1)):${_blscd_screen_lines_browser}}")
                        _blscd_screen_lines_browser_col_2_cursor=${_blscd_data[index ${_blscd_dir_col_1_string}/${_blscd_screen_lines_browser_col_2_cursor_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse}]}
                    fi
                    _blscd_data[view ${_blscd_dir_col_1_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse} ${_blscd_screen_lines_browser}]=$(builtin printf '%s\n' "${_blscd_col_2_view[@]}")
                    _blscd_data[view offset ${_blscd_dir_col_1_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse} ${_blscd_screen_lines_browser}]=$_blscd_col_2_view_offset
                    _blscd_data[view cursor ${_blscd_dir_col_1_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse} ${_blscd_screen_lines_browser}]=$_blscd_screen_lines_browser_col_2_cursor
                elif [[ $_blscd_action_last != __blscd_move_line ]] && __blscd_test_data view "$_blscd_dir_col_1_string" $_blscd_screen_lines_browser
                then
                    _blscd_col_2_view_offset=${_blscd_data[view offset ${_blscd_dir_col_1_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse} ${_blscd_screen_lines_browser}]}
                     builtin mapfile -t _blscd_col_2_view < <(__blscd_print_data view "$_blscd_dir_col_1_string" $_blscd_screen_lines_browser)
                     _blscd_screen_lines_browser_col_2_cursor=${_blscd_data[view cursor ${_blscd_dir_col_1_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse} ${_blscd_screen_lines_browser}]}
                else
                    _blscd_col_2_view=("${_blscd_col_2_list[@]:$((_blscd_col_2_view_offset - 1)):${_blscd_screen_lines_browser}}")
                    _blscd_data[view ${_blscd_dir_col_1_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse} ${_blscd_screen_lines_browser}]=$(builtin printf '%s\n' "${_blscd_col_2_view[@]}")
                    _blscd_data[view offset ${_blscd_dir_col_1_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse} ${_blscd_screen_lines_browser}]=$_blscd_col_2_view_offset
                    _blscd_data[view cursor ${_blscd_dir_col_1_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse} ${_blscd_screen_lines_browser}]=$_blscd_screen_lines_browser_col_2_cursor
                fi
                _blscd_screen_lines_browser_col_2_cursor_string=${_blscd_col_2_view[$_blscd_screen_lines_browser_col_2_cursor]}
                _blscd_col_2_view_total=${#_blscd_col_2_view[@]}
                ;;
            3)
                declare dir_col_2_string=${_blscd_dir_col_1_string}/${_blscd_screen_lines_browser_col_2_cursor_string}
                dir_col_2_string=${dir_col_2_string//\/\//\/}
                if [[ $_blscd_action_last == __blscd_set_sort || $_blscd_action_last == __blscd_set_hide ]]
                then
                    dir_col_2_string=${dir_col_2_string}/${_blscd_screen_lines_browser_col_3_cursor_string}
                    if __blscd_test_data_index "$dir_col_2_string" $_blscd_screen_lines_browser
                    then
                        _blscd_col_3_view_offset=$((${_blscd_data[index ${dir_col_2_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse}]} - _blscd_screen_lines_browser + 2))
                        _blscd_col_3_view=("${_blscd_col_3_list[@]:$((${_blscd_col_3_view_offset} - 1)):${_blscd_data[index ${dir_col_2_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse}]}}")
                        _blscd_screen_lines_browser_col_3_cursor=$((_blscd_screen_lines_browser - 1))
                    else
                        _blscd_col_3_view_offset=1
                        _blscd_col_3_view=("${_blscd_col_3_list[@]:$(($_blscd_col_3_view_offset - 1)):${_blscd_screen_lines_browser}}")
                        _blscd_screen_lines_browser_col_3_cursor=${_blscd_data[index ${dir_col_2_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse}]}
                    fi
                    _blscd_data[view ${_blscd_dir_col_1_string}/${_blscd_screen_lines_browser_col_2_cursor_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse} ${_blscd_screen_lines_browser}]=$(builtin printf '%s\n' "${_blscd_col_3_view[@]}")
                    _blscd_data[view offset ${_blscd_dir_col_1_string}/${_blscd_screen_lines_browser_col_2_cursor_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse} ${_blscd_screen_lines_browser}]=$_blscd_col_3_view_offset
                    _blscd_data[view cursor ${_blscd_dir_col_1_string}/${_blscd_screen_lines_browser_col_2_cursor_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse} ${_blscd_screen_lines_browser}]=$_blscd_screen_lines_browser_col_3_cursor
                elif __blscd_test_data view "$dir_col_2_string" $_blscd_screen_lines_browser
                then
                    _blscd_col_3_view_offset=${_blscd_data[view offset ${dir_col_2_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse} ${_blscd_screen_lines_browser}]}
                     builtin mapfile -t _blscd_col_3_view < <(__blscd_print_data view "$dir_col_2_string" $_blscd_screen_lines_browser)
                     _blscd_screen_lines_browser_col_3_cursor=${_blscd_data[view cursor ${dir_col_2_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse} ${_blscd_screen_lines_browser}]}
                else
                    _blscd_col_3_view_offset=1
                    _blscd_col_3_view=("${_blscd_col_3_list[@]}")
                    _blscd_screen_lines_browser_col_3_cursor=0
                    _blscd_data[view ${dir_col_2_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse} ${_blscd_screen_lines_browser}]=$(builtin printf '%s\n' "${_blscd_col_3_view[@]}")
                    _blscd_data[view offset ${dir_col_2_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse} ${_blscd_screen_lines_browser}]=$_blscd_col_3_view_offset
                    _blscd_data[view cursor ${dir_col_2_string} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse} ${_blscd_screen_lines_browser}]=$_blscd_screen_lines_browser_col_3_cursor
                fi
                _blscd_screen_lines_browser_col_3_cursor_string=${_blscd_col_3_view[$_blscd_screen_lines_browser_col_3_cursor]}
                _blscd_col_3_view_total=${#_blscd_col_3_view[@]}
                ;;
        esac
    done
}
__blscd_build_data ()
{
    if [[ $1 == -c ]]
    then
        builtin shift 1
        builtin declare current_only=current_only
    else
        builtin declare current_only=
    fi

    function __blscd_build_data_do_stat
    {
        [[ -z ${_blscd_data[stat ${@:-/}]} ]] && \
            _blscd_data[stat ${@:-/}]=$(\
                command paste -d '|'\
                    <(command find -L "${@:-/}" -mindepth 1 -maxdepth 1 \
                        \( -xtype l -a -printf "l%y %s %A@ %T@ %C@ |%P\n" \) -prune \
                        -o -printf "r%y %s %A@ %T@ %C@ |%P\n" |& \
                    command sed "s|^find: .\(.*\)/\([^/]*\)': Permission denied$|ll 0 0  0 0 \|\2|" | \
                    command sort --stable -u -k 6 | \
                    command numfmt --delimiter=' ' --field=2  --format='%4f' \
                        --from=none --from-unit=1 --invalid=warn \
                        --round=from-zero --to=iec --to-unit=1) \
                    <(command ls --format=single-column -A --color=always --indicator-style=none --quoting-style=clocale "${@:-/}" 2>/dev/null))

        builtin printf '%s\n' "${_blscd_data[stat ${@:-/}]}" | \
            command tr '\n' '\0'
    }

    function __blscd_build_data_do_1
    for dir
    do
        if [[ $dir == / ]]
        then
            __blscd_build_data_do_2
        else
            __blscd_build_data_do_2 "$dir"
            if [[ $current_only != current_only && ${dir%/*} ]]
            then
                __blscd_build_data_do_1 "${dir%/*}"
            else
                builtin return 1
            fi
        fi
    done

    function __blscd_build_data_do_2
    {
        builtin declare \
            atime= \
            basename= \
            ctime= \
            color= \
            dir="$@" \
            file= \
            mtime= \
            size= \
            type=
        builtin declare -i i=0
        builtin declare -a "array=()"

        while IFS=' ' builtin read -r -d '' type size atime mtime ctime basename
        do
            IFS='|' read -r _ basename color <<< "$basename"
            file=${dir}/${basename}
            color=${color//[‘’]/}
            [[ $_blscd_show_hidden != _blscd_show_hidden && $basename =~ $_blscd_hidden_filter ]] && \
                builtin continue
            #_blscd_data[atime ${file}]=$atime
            #_blscd_data[basename ${file}]=$basename
            #_blscd_data[color ${file}]=$color
            _blscd_data[color prae ${file}]=${color%${basename}*}
            _blscd_data[color post ${file}]=${color#*${basename}}
            #_blscd_data[ctime ${file}]=$ctime
            _blscd_data[index ${file} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse}]=$i
            _blscd_data[mtime ${file}]=$mtime
            _blscd_data[size ${file}]=$size
            _blscd_data[type ${file}]=$type
            array[$i]=$basename
            ((i++))
        done < <(__blscd_build_data_do_3 "$dir")

        _blscd_data[list ${dir:-/} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse}]=$(builtin printf '%s\n' "${array[@]}")
    }

    function __blscd_build_data_do_3
    case ${_blscd_sort_mechanism##*_} in
        atime)
            __blscd_build_data_do_stat "$@" | \
                command sort -z --stable \
                        -k 3n${_blscd_sort_reverse:+r} \
                        -k 6${_blscd_sort_reverse:+r}
            ;;
        basename)
            if [[ $_blscd_sort_reverse == _blscd_sort_reverse ]]
            then
                __blscd_build_data_do_stat "$@" | \
                    command sort -z --stable -k 6r
            else
                __blscd_build_data_do_stat "$@"
            fi
            ;;
        ctime)
            __blscd_build_data_do_stat "$@" | \
                command sort -z --stable \
                        -k 5n${_blscd_sort_reverse:+r} \
                        -k 6${_blscd_sort_reverse:+r}
            ;;
        mtime)
            __blscd_build_data_do_stat "$@" | \
                command sort -z --stable \
                        -k 4n${_blscd_sort_reverse:+r} \
                        -k 6${_blscd_sort_reverse:+r}
            ;;
        natural)
            __blscd_build_data_do_stat "$@" | \
                LC_COLLATE=$LANG \
                command sort -z --stable -k 6${_blscd_sort_reverse:+r}
            ;;
        size)
            __blscd_build_data_do_stat "$@" | \
                command sort -z --stable \
                        -k 2h${_blscd_sort_reverse:+r} \
                        -k 6${_blscd_sort_reverse:+r}
            ;;
        type)
            __blscd_build_data_do_stat "$@" | \
                command sort -z --stable \
                        -k 1${_blscd_sort_reverse:+r} \
                        -k 6${_blscd_sort_reverse:+r}
            ;;
    esac

    __blscd_build_data_do_1 "$@"
}

__blscd_build_mtime ()
{
    function __blscd_build_mtime_do
    {
        builtin declare i=

        for i in "${!_blscd_data[@]}"
        do
            [[ $i =~ ^mtime.${_blscd_dir_col_1_string}/[^\/]*$ ]] && \
                builtin printf '%f|%d\n' "${_blscd_data[$i]}" "${_blscd_data[index ${i#mtime } ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse}]}"
        done
    }

    builtin mapfile -t _blscd_col_2_mtime < <(__blscd_build_mtime_do | command sort -n)
}

__blscd_build_search ()
{
    _blscd_col_2_search=()

    function __blscd_build_search_do
    {
        builtin printf '%s\n' "${_blscd_col_2_list[@]}" | \
        command egrep -i -n -C "${#_blscd_col_2_list[@]}" -e "$_blscd_search_pattern"
    }

    while builtin read -r
    do
        [[ $REPLY =~ ^[0-9]*:.*$ ]] && \
            _blscd_col_2_search+=(${REPLY%%:*})
    done < <(__blscd_build_search_do)

    ((${#_blscd_col_2_search[@]} != 0)) && \
        _blscd_search_block=_blscd_search_block
}

__blscd_draw_screen ()
{
    builtin declare -i \
        i= \
        j= \
        screen_col_1_width= \
        screen_col_2_1_width= \
        screen_col_2_width= \
        screen_col_3_width= \
        screen_dimension_cols= \
        screen_dimension_lines=

    builtin declare \
        screen_lines_browser_col_1_color_1= \
        screen_lines_browser_col_1_color_reset= \
        screen_lines_browser_col_2_color_1= \
        screen_lines_browser_col_2_color_reset= \
        screen_lines_browser_col_3_color_1= \
        screen_lines_browser_col_3_color_reset= \
        screen_lines_statusbar_string= \
        statusbar10_string= \
        statusbar11_string= \
        statusbar12_string= \
        statusbar13_string= \
        statusbar1_string= \
        statusbar2_string= \
        statusbar3_string= \
        statusbar4_string= \
        statusbar5_string= \
        statusbar6_string= \
        statusbar7_string= \
        statusbar8_string= \
        statusbar9_string=

    # Get dimension.
    builtin read -r screen_dimension_cols screen_dimension_lines \
        <<<$(command tput -S < <(builtin printf '%s\n' cols lines))
    screen_col_1_width=$(((screen_dimension_cols - 2) / 5))
    screen_col_3_width=$((screen_col_1_width * 2))
    screen_col_2_1_width=5
    screen_col_2_width=$(((screen_col_1_width * 2) - screen_col_2_1_width))
    _blscd_screen_lines_browser=$((screen_dimension_lines - _blscd_screen_lines_offset + 1))

    # Save directories.
    _blscd_dir_col_1_string=$PWD
    _blscd_dir_col_0_string=${_blscd_dir_col_1_string%/*}
    _blscd_dir_col_0_string=${_blscd_dir_col_0_string:-/}

    if [[ ($_blscd_reprint == _blscd_reprint && $_blscd_action_last != __blscd_move_line) || \
            ($_blscd_search_pattern && $_blscd_search_block != _blscd_search_block) ]]
    then
        builtin printf "$_blscd_tput_clear"
        # Build column 1 and 2.
        __blscd_build_col_list 1 2
        __blscd_build_col_view 1 2
    else
        # Delete obsolete lines in column 3.
        if ((_blscd_col_3_list_total <= 15))
        then
            if ((_blscd_col_3_list_total < _blscd_screen_lines_browser))
            then
                i=$_blscd_col_3_list_total
            else
                i=$_blscd_screen_lines_browser
            fi
            for ((i=$i ; i > 1 ; --i))
            do
                #command tput cup "$i" "$((screen_col_1_width + screen_col_2_width + 2))"
                builtin printf "\033[$((i + 1));$((screen_col_1_width + screen_col_2_width + 3))H${_blscd_tput_eel}"
                #builtin printf "$_blscd_tput_eel"
            done
        else
            ((_blscd_col_3_list_total < _blscd_screen_lines_browser && _blscd_col_1_view_total > 5)) && {
                    builtin printf "$_blscd_tput_cup_2_0"
                    for ((i=${_blscd_col_3_list_total} ; i < _blscd_screen_lines_browser ; ++i))
                    do
                        builtin printf "%-${screen_col_1_width}.${screen_col_1_width}s\n" ""
                    done
            }
        fi
       __blscd_build_col_view 2
    fi

    # Build column 3.
    __blscd_build_col_list 3
    __blscd_build_col_view 3

     # Savings.
    _blscd_dir_last=$_blscd_dir_col_1_string
    _blscd_line_last=$_blscd_screen_lines_browser_col_2_cursor_string

    # Preparing for __blscd_move_line(): Determine the number of visible files.
    if ((_blscd_col_2_list_total > _blscd_screen_lines_browser))
    then
        _blscd_screen_lines_browser_col_2_visible=$_blscd_screen_lines_browser
    else
        _blscd_screen_lines_browser_col_2_visible=$_blscd_col_2_list_total
    fi

    if ((_blscd_col_3_list_total > _blscd_screen_lines_browser))
    then
        _blscd_screen_lines_browser_col_3_visible=$_blscd_screen_lines_browser
    else
        _blscd_screen_lines_browser_col_3_visible=$_blscd_col_3_list_total
    fi

    [[ $_blscd_dir_col_1_string == / ]] && _blscd_dir_col_1_string=
    [[ $_blscd_dir_col_0_string == / ]] && _blscd_dir_col_0_string=

    # Print the titlebar.
    __blscd_draw_screen_lines 1
    builtin printf '%s\n' "${_blscd_screen_lines_titlebar_string//\/\//\/}"
    builtin printf "$_blscd_tput_reset"

    # Print the browser.
    for ((i=0 ; i < _blscd_screen_lines_browser ; ++i))
    do
        __blscd_draw_screen_lines 2
        builtin printf "${_blscd_data[color prae ${_blscd_dir_col_0_string}/${_blscd_col_1_view[$i]}]}${screen_lines_browser_col_1_color_1}%-${screen_col_1_width}.${screen_col_1_width}s${_blscd_data[color post ${_blscd_dir_col_0_string}/${_blscd_col_1_view[$i]}]}${screen_lines_browser_col_1_color_reset} ${_blscd_data[color prae ${_blscd_dir_col_1_string}/${_blscd_col_2_view[$i]}]}${screen_lines_browser_col_2_color_1}%-${screen_col_2_width}.${screen_col_2_width}s%${screen_col_2_1_width}s${_blscd_data[color post ${_blscd_dir_col_1_string}/${_blscd_col_2_view[$i]}]}${screen_lines_browser_col_2_color_reset} ${_blscd_data[color prae ${_blscd_dir_col_1_string}/${_blscd_screen_lines_browser_col_2_cursor_string}/${_blscd_col_3_view[$i]}]}${screen_lines_browser_col_3_color_1}%-${screen_col_3_width}.${screen_col_3_width}s${_blscd_data[color post ${_blscd_dir_col_1_string}/${_blscd_screen_lines_browser_col_2_cursor_string}/${_blscd_col_3_view[$i]}]}${screen_lines_browser_col_3_color_reset}\n" " ${_blscd_col_1_view[$i]} " " ${_blscd_col_2_view[$i]} " "${_blscd_data[size ${_blscd_dir_col_1_string}/${_blscd_col_2_view[$i]}]} " " ${_blscd_col_3_view[$i]} "
        screen_lines_browser_col_1_color_1=
        screen_lines_browser_col_1_color_reset=
        screen_lines_browser_col_2_color_1=
        screen_lines_browser_col_2_color_reset=
        screen_lines_browser_col_3_color_1=
        screen_lines_browser_col_3_color_reset=
    done

    # Print the statusbar.
    builtin printf "${_blscd_tput_blue_f}${_blscd_tput_bold}"
    __blscd_draw_screen_lines 3
    builtin printf "%s${_blscd_tput_reset} %s %s %s %s %s${statusbar8_string:+ %s ->} %-$((screen_dimension_cols - ${#screen_lines_statusbar_string} + ${#statusbar7_string} ${statusbar8_string:++ $((${#statusbar8_string} - ${#statusbar7_string}))}))s  %s/%s  %d%% %s${statusbar13_string:+  %d}" "$statusbar1_string" "$statusbar2_string" "$statusbar3_string" "$statusbar4_string" "$statusbar5_string" "$statusbar6_string" "$statusbar7_string" ${statusbar8_string:+\"${statusbar8_string}\"} "$statusbar9_string" "$statusbar10_string" "$statusbar11_string" "$statusbar12_string" $statusbar13_string

    # Set new position of the _blscd_screen_lines_browser_col_2_cursor.
    #builtin printf "$_blscd_tput_reset"
    #command tput cup "$((_blscd_screen_lines_browser_col_2_cursor + 1))" "$((screen_col_1_width + 1))"
    builtin printf "${_blscd_tput_reset}\033[$((_blscd_screen_lines_browser_col_2_cursor + 2));$((screen_col_1_width + 2))H"
}

__blscd_draw_screen_check ()
{
    [[ $_blscd_redraw == _blscd_redraw ]] && {
        __blscd_draw_screen
        __blscd_set_resize 0
        ((++_blscd_redraw_number))
    }
}

__blscd_draw_screen_lines ()
{
    builtin declare -i j=

    for j
    do
        case $j in
            1)
                if [[ ($_blscd_reprint == _blscd_reprint && $_blscd_action_last != __blscd_move_line) || \
                        $_blscd_search_pattern ]]
                then
                    builtin printf "$_blscd_tput_home"
                    [[ $_blscd_search_block == _blscd_search_block ]] && builtin printf "$_blscd_tput_eel"
                    builtin printf -v _blscd_screen_lines_titlebar_string \
                            "${_blscd_tput_blue_f}${_blscd_tput_bold}%s@%s:${_blscd_tput_green_f}%s/${_blscd_tput_white_f}%s" \
                            "$USER" "$HOSTNAME" "$PWD" "$_blscd_screen_lines_browser_col_2_cursor_string"
                else
                    #command tput cup 0 "$((${#USER} + ${#HOSTNAME} + ${#_blscd_dir_col_1_string} + 3))"
                    builtin printf "\033[0;$((${#USER} + ${#HOSTNAME} + ${#_blscd_dir_col_1_string} + 4))H"
                    builtin printf -v _blscd_screen_lines_titlebar_string \
                            "${_blscd_tput_eel}${_blscd_tput_bold}${_blscd_tput_white_f}%s" \
                            "$_blscd_screen_lines_browser_col_2_cursor_string"
                fi
                ;;
            2)
                ((i == _blscd_screen_lines_browser_col_1_cursor && _blscd_col_1_view_total != 0)) && {
                    screen_lines_browser_col_1_color_1=${_blscd_tput_bold}${_blscd_tput_black_f}${_blscd_tput_green_b}
                    screen_lines_browser_col_1_color_reset=$_blscd_tput_reset
                }
                ((i == _blscd_screen_lines_browser_col_2_cursor)) && {
                    screen_lines_browser_col_2_color_1=${_blscd_tput_bold}${_blscd_tput_black_f}${_blscd_tput_green_b}
                    screen_lines_browser_col_2_color_reset=$_blscd_tput_reset
                }
                ((i == _blscd_screen_lines_browser_col_3_cursor && _blscd_col_3_view_total != 0)) && {
                    screen_lines_browser_col_3_color_1=${_blscd_tput_bold}${_blscd_tput_black_f}${_blscd_tput_green_b}
                    screen_lines_browser_col_3_color_reset=$_blscd_tput_reset
                }
                ;;
            3)
                builtin declare \
                    basename= \
                    s=
                IFS='‘’' builtin read -r s basename \
                    <<<$(command ls --format=long -Ad --time-style=long-iso -h \
                        --color=none --indicator-style=none --quoting-style=clocale \
                        "${_blscd_dir_col_1_string}/${_blscd_screen_lines_browser_col_2_cursor_string}")
                builtin read -r statusbar1_string statusbar2_string statusbar3_string statusbar4_string \
                        statusbar5_string statusbar6_string statusbar7_string <<< "$s"
                [[ $basename =~ -\> ]] && \
                    IFS='‘’' builtin read -r _ _ statusbar8_string <<<"$basename"
                builtin read -r statusbar9_string statusbar10_string statusbar11_string \
                    <<<"$((_blscd_col_2_view_offset + _blscd_screen_lines_browser_col_2_cursor)) ${_blscd_col_2_list_total} \
                    $(((100 * (_blscd_col_2_view_offset + _blscd_screen_lines_browser_col_2_cursor)) / _blscd_col_2_list_total))"
                [[ -d ${_blscd_dir_col_1_string}/${_blscd_screen_lines_browser_col_2_cursor_string} ]] && \
                        statusbar13_string=$_blscd_col_3_list_total
                if ((_blscd_col_2_list_total <= _blscd_screen_lines_browser))
                then
                    statusbar12_string=All
                elif ((_blscd_col_2_list_total > _blscd_screen_lines_browser && \
                        _blscd_screen_lines_browser_col_2_cursor + _blscd_col_2_view_offset <= _blscd_screen_lines_browser_col_2_visible))
                then
                    statusbar12_string=Top
                elif ((_blscd_col_2_list_total > _blscd_screen_lines_browser && \
                    _blscd_screen_lines_browser_col_2_cursor + _blscd_col_2_view_offset >= _blscd_col_2_list_total - _blscd_screen_lines_browser + 1))
                then
                    statusbar12_string=Bot
                else
                    statusbar12_string=Mid
                fi
                #command tput cup "$((_blscd_screen_lines_browser + 1))" 0
                builtin printf "\033[$((_blscd_screen_lines_browser + 2));0H${_blscd_tput_eel}"
                #builtin printf "$_blscd_tput_eel"
                builtin printf -v screen_lines_statusbar_string "%s %s %s %s %s %s %s${statusbar8_string:+ -> %s}  %s/%s  %d%% %s${statusbar13_string:+  %d}" \
                        "$statusbar1_string" "$statusbar2_string" "$statusbar3_string" "$statusbar4_string" "$statusbar5_string" \
                        "$statusbar6_string" "$statusbar7_string" ${statusbar8_string:+"${statusbar8_string}"} "$statusbar9_string" \
                        "$statusbar10_string" "$statusbar11_string" "$statusbar12_string" $statusbar13_string
                ;;
        esac
    done
}

__blscd_edit_line ()
{
    __blscd_set_action_last
    command "${EDITOR:-vi}" "$_blscd_screen_lines_browser_col_2_cursor_string"
}

__blscd_help ()
{
    printf "usage: [source] blscd [-h | --help | -d | --dump | -v | --version]

    Key bindings (basics)
      :                     Open the console
      E                     Edit the current file in '<EDITOR>'
                            (fallback: 'vi')
      S                     Fork '<SHELL>' in the current directory
                            (fallback: 'bash')
      ^L                    Redraw the screen
      ^R                    Reload everything
      g?                    Open this help in '<PAGER>'
                            (fallback: 'less')
      q                     Quit

    Key bindings (settings)
      ^H                    Toggle '_blscd_show_hidden'

    Key bindings (moving)
      D                     Move ten lines down
      G     [ END ]         Move to bottom
      J                     Move half page down
      K                     Move half page up
      U                     Move ten lines up
      ^B    [ PAGE-UP ]     Move page up
      ^F    [ PAGE-DOWN ]   Move page down
      d                     Move five lines down
      gg    [ HOME ]        Move to top
      h     [ LEFTARROW ]   Move left
      j     [ DOWNARROW ]   Move down
      k     [ UPARROW ]     Move up
      l     [ RIGHTARROW ]  Move right
      u                     Move five lines up

    Key bindings (jumping)
      gL                    Move to /var/log
      gM                    Move to /mnt
      gd                    Move to /dev
      ge                    Move to /etc
      gh                    Move to <HOME>
      gl                    Move to /usr/lib
      gm                    Move to /media
      go                    Move to /opt
      gr    [ g/ ]          Move to /
      gs                    Move to /srv
      gu                    Move to /usr
      gv                    Move to /var

    Key bindings (searching)
      /                     Search for files in the current directory
                            (console command 'search')
      N                     Go to previous file
      n                     Go to next file. By default, go to newest
                            file; but after 'search' go to next match

    Key bindings (sorting)
      oA                    Sort by access time, oldest first
      oB                    Sort by basename (LC_COLLATE=C),
                            descend
      oC                    Sort by change time, oldest first
      oM                    Sort by modification time, oldest first
      oN                    Sort basenames naturally (LC_COLLATE=$LANG),
                            descend
      oS                    Sort by file size, smallest first
      oT                    Sort by type, descend
      oa                    Sort by access time, newest first
      ob                    Sort by basename (LC_COLLATE=C),
                            ascend
      oc                    Sort by change time, newest first
      om                    Sort by modification time, newest first
      on                    Sort basenames naturally (LC_COLLATE=$LANG),
                            ascend
      or                    Reverse whatever the sorting method is
      os                    Sort by file size, largest first
      ot                    Sort by type, ascend

    File type indicators (browser; via 'find')
      D                     door (Solaris)
      b                     block (buffered) special
      c                     character (unbuffered) special
      d                     directory
      f                     regular file
      l                     symbolic link
      p                     named pipe (FIFO)
      r                     non-link
      s                     socket

    File type indicators (statusbar; via 'ls')
      -                     regular file
      ?                     some other file type
      C                     high performance ('contiguous data') file
      D                     door (Solaris 2.5 and up)
      M                     off-line ('migrated') file (Cray DMF)
      P                     port (Solaris 10 and up)
      b                     block special file
      c                     character special file
      d                     directory
      l                     symbolic link
      n                     network special file (HP-UX)
      p                     FIFO (named pipe)
      s                     socket

    Console commands
      During line editing in the console you may use your configured
      Readline key bindings, just as well the other features of it
      ('read -e' obtains the line in an interactive shell).

      search '<PATTERN>'    Search for files in the current directory,
                            that match the given (case insensitive)
                            regular expression pattern (regextype is
                            'posix-egrep')
"
}

__blscd_move_col ()
{
    __blscd_set_resize 2
    __blscd_set_search_non

    function __blscd_move_col_up
    {
        __blscd_set_action_last
        _blscd_col_2_view_offset=1
        _blscd_screen_lines_browser_col_2_cursor=0
    }

    function __blscd_move_col_down
    {
        __blscd_set_action_last
        _blscd_col_2_view_offset=1
        _blscd_screen_lines_browser_col_2_cursor=0
    }

    if [[ $1 == .. ]]
    then
         __blscd_move_col_up
    else
         __blscd_move_col_down
    fi

    builtin cd -- "$1"
}

__blscd_move_line ()
{
    __blscd_set_action_last
    _blscd_redraw=_blscd_redraw

    builtin declare -i arg=$2

    function __blscd_move_line_do
    {
        builtin declare -i \
            col=$1 \
            difference= \
            list_total=$2 \
            max_cursor=$((screen_lines_browser_visible - 1)) \
            max_index=$(($2 - screen_lines_browser_visible + 1)) \
            old_index=$view_offset \
            step=

        # Add the argument to the current screen_lines_browser_cursor
        screen_lines_browser_cursor=$((screen_lines_browser_cursor + arg))

        if ((screen_lines_browser_cursor >= screen_lines_browser_visible))
        then
            # screen_lines_browser_cursor moved past the bottom of the list.
            if ((screen_lines_browser_visible >= list_total))
            then
                # The list fits entirely on the screen.
                view_offset=1
            else
                # The list doesn't fit on the screen.
                if ((view_offset + screen_lines_browser_cursor > list_total))
                then
                    # screen_lines_browser_cursor out of bounds. Put it at the very bottom.
                    view_offset=$max_index
                else
                    # Move the view_offset down so the visible part of the list,
                    # also shows the screen_lines_browser_cursor.
                    difference=$((screen_lines_browser_visible - 1 - screen_lines_browser_cursor))
                    view_offset=$((view_offset - difference))
                fi
            fi
            # In any case, place the screen_lines_browser_cursor on the last file.
            screen_lines_browser_cursor=$max_cursor
        elif ((screen_lines_browser_cursor <= 0))
        then
            # screen_lines_browser_cursor is above the list, so scroll up.
            view_offset=$((view_offset + screen_lines_browser_cursor))
            screen_lines_browser_cursor=0
        fi

        # The view_offset should always be >0 and <$max_index.
        ((view_offset > max_index)) && view_offset=$max_index
        ((view_offset < 1)) && view_offset=1

        ((view_offset != old_index)) &&
        {
            # _blscd_redraw if the view_offset (and thus the visible files) has changed.
            _blscd_reprint=_blscd_reprint

            # Jump a step when scrolling.
            if ((view_offset > old_index))
            then
                # Jump a step down.
                step=$((max_index - view_offset))
                ((step > _blscd_step)) && step=$_blscd_step
                view_offset=$((view_offset + step))
                screen_lines_browser_cursor=$((screen_lines_browser_cursor - step))
            else
                # Jump a step up.
                step=$((view_offset - 1))
                ((step > _blscd_step)) && step=$_blscd_step
                view_offset=$((view_offset - step))
                screen_lines_browser_cursor=$((screen_lines_browser_cursor + step))
            fi
        }

        # The view_offset should always be >0 and <$max_index.
        ((view_offset > max_index)) && view_offset=$max_index
        ((view_offset < 1)) && view_offset=1
    }

    case $1 in
        1)
            builtin declare -i \
                screen_lines_browser_cursor=$_blscd_screen_lines_browser_col_1_cursor \
                screen_lines_browser_visible=$_blscd_screen_lines_browser_col_1_visible \
                view_offset=$_blscd_col_1_view_offset
            __blscd_move_line_do "$1" "$_blscd_col_1_list_total"
            _blscd_col_1_view_offset=$view_offset
            _blscd_screen_lines_browser_col_1_cursor=$screen_lines_browser_cursor
            _blscd_screen_lines_browser_col_1_visible=$screen_lines_browser_visible
            ;;
        2)
            builtin declare -i \
                screen_lines_browser_cursor=$_blscd_screen_lines_browser_col_2_cursor \
                screen_lines_browser_visible=$_blscd_screen_lines_browser_col_2_visible \
                view_offset=$_blscd_col_2_view_offset
            __blscd_move_line_do "$1" "$_blscd_col_2_list_total"
            _blscd_col_2_view_offset=$view_offset
            _blscd_screen_lines_browser_col_2_cursor=$screen_lines_browser_cursor
            _blscd_screen_lines_browser_col_2_visible=$screen_lines_browser_visible
            ;;
        3)
            :
            ;;
    esac
}

__blscd_mtime ()
{
    builtin declare -i j=

    case $1 in
        newest)
                __blscd_mtime_go_newest
            ;;
        oldest)
                __blscd_mtime_go_oldest
            ;;
    esac

    j=${_blscd_col_2_mtime[0]##*|}

    if ((j < _blscd_screen_lines_browser_col_2_cursor + _blscd_col_2_view_offset - 1))
    then
        __blscd_move_line 2 "-$((_blscd_screen_lines_browser_col_2_cursor + _blscd_col_2_view_offset -1 - j))"
    elif ((j > _blscd_screen_lines_browser_col_2_cursor + _blscd_col_2_view_offset - 1))
    then
        __blscd_move_line 2 "$((j - _blscd_col_2_view_offset - _blscd_screen_lines_browser_col_2_cursor + 1))"
    else
        __blscd_move_line 2 0
    fi

}

__blscd_mtime_go_newest ()
{
    function __blscd_mtime_go_newest_do
    {
        builtin declare -i i=
        builtin printf '%s\n' "${_blscd_col_2_mtime[-1]}"
        for ((i=0 ; i <= ${#_blscd_col_2_mtime[@]}-2 ; i++))
        do
            builtin printf '%s\n' "${_blscd_col_2_mtime[$i]}"
        done
    }

    [[ ${#_blscd_col_2_mtime[@]} -eq 0 || $_blscd_action_last != __blscd_move_line ]] && \
        __blscd_build_mtime

    builtin mapfile -t _blscd_col_2_mtime < <(__blscd_mtime_go_newest_do)
}

__blscd_mtime_go_oldest ()
{
    function __blscd_mtime_go_oldest_do
    {
        builtin declare -i i=
        for ((i=1 ; i <= ${#_blscd_col_2_mtime[@]}-1 ; i++))
        do
            builtin printf '%s\n' "${_blscd_col_2_mtime[$i]}"
        done
        builtin printf '%s\n' "${_blscd_col_2_mtime[0]}"
    }

    if [[ ${#_blscd_col_2_mtime[@]} -eq 0 || $_blscd_action_last != __blscd_move_line ]]
    then
        __blscd_build_mtime
    else
        builtin mapfile -t _blscd_col_2_mtime < <(__blscd_mtime_go_oldest_do)
    fi
}

__blscd_open_console ()
{
    builtin declare console_command_arguments=

    builtin printf "$_blscd_tput_cup_99999_0"
    command stty $_blscd_saved_stty
    builtin read -e -p ":" -i \
            "${_blscd_console_command_name:+${_blscd_console_command_name} ${_blscd_search_pattern}}" \
            _blscd_console_command_name \
            console_command_arguments
    command stty -echo

    if [[ $console_command_arguments ]]
    then
        case $_blscd_console_command_name in
            search)
                __blscd_search
                ;;
            *)
                __blscd_set_action_last
                __blscd_set_resize 2
                ;;
        esac
    else
        __blscd_set_action_last
        __blscd_set_resize 2
    fi

    _blscd_console_command_name=
}

__blscd_open_line ()
if [[ -d $1 && $_blscd_col_3_view_total -ne 0 ]]
then
    __blscd_move_col "$1"
else
    case $(command file --mime-type -bL "$1") in
        image*)
            __blscd_set_action_last
            command w3m -o 'ext_image_viewer=off' \
                    -o 'imgdisplay=w3mimgdisplay' "$1"
            ;;
        *)
            __blscd_set_action_last
            [[ -e $1 ]] && builtin eval "$_blscd_opener" 2>/dev/null
            ;;
    esac
fi

__blscd_open_shell ()
{
    __blscd_set_action_last
    command stty $_blscd_saved_stty
    builtin printf "$_blscd_tput_ealt"
    command "${SHELL:-bash}"
    command stty -echo
}

__blscd_print_data ()
{
    builtin printf '%s\n' "${_blscd_data[${1} ${2} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse}${3:+ $3}]}"
}

__blscd_search ()
{
    __blscd_set_action_last
    _blscd_search_block=
    _blscd_search_pattern=$console_command_arguments
    __blscd_set_resize 2
    __blscd_move_line 2 -9999999999
    __blscd_draw_screen_check
    __blscd_move_line 2 "$((${_blscd_col_2_search[0]} -1 ))"
}

__blscd_search_go_down ()
if [[ ${_blscd_col_2_search[@]} ]]
then
    builtin declare -i i=
    for i in "${_blscd_col_2_search[@]}"
    do
        ((i > _blscd_col_2_view_offset + _blscd_screen_lines_browser_col_2_cursor)) && {
            __blscd_move_line 2 "$((i - _blscd_col_2_view_offset - _blscd_screen_lines_browser_col_2_cursor))"
            builtin break
        }
    done
else
    _blscd_search_pattern=
    _blscd_col_2_search=()
fi

__blscd_search_go_up ()
if [[ ${#_blscd_col_2_search[@]} -gt 0 ]]
then
    declare -i i=
    for (( i=${#_blscd_col_2_search[@]}-1 ; i >= 0 ; i--))
    do
        ((${_blscd_col_2_search[$i]} < _blscd_col_2_view_offset + _blscd_screen_lines_browser_col_2_cursor)) && {
            __blscd_move_line 2 "-$((_blscd_screen_lines_browser_col_2_cursor + _blscd_col_2_view_offset - ${_blscd_col_2_search[$i]}))"
            builtin break
        }
    done
else
    _blscd_search_pattern=
    _blscd_col_2_search=()
fi

__blscd_set_action_last ()
{
    _blscd_action_last=${FUNCNAME[1]}
}

__blscd_set_declare ()
{
    builtin declare -gA _blscd_data

    builtin declare -gi \
        _blscd_col_1_list_total= \
        _blscd_col_1_view_offset=1 \
        _blscd_col_1_view_total= \
        _blscd_col_2_list_total= \
        _blscd_col_2_view_offset=1 \
        _blscd_col_2_view_total= \
        _blscd_col_3_list_total= \
        _blscd_col_3_view_offset=1 \
        _blscd_col_3_view_total= \
        _blscd_redraw_number= \
        _blscd_screen_lines_browser= \
        _blscd_screen_lines_browser_col_1_cursor= \
        _blscd_screen_lines_browser_col_1_visible= \
        _blscd_screen_lines_browser_col_2_cursor= \
        _blscd_screen_lines_browser_col_2_visible= \
        _blscd_screen_lines_browser_col_3_cursor= \
        _blscd_screen_lines_browser_col_3_visible= \
        _blscd_screen_lines_offset=4 \
        _blscd_step=6

    builtin declare -g \
        _blscd_action_last= \
        _blscd_console_command_name= \
        _blscd_dir_col_0_string= \
        _blscd_dir_col_1_string=$PWD \
        _blscd_dir_last= \
        _blscd_hidden_filter='^\.|~$' \
        _blscd_hidden_filter_ls='--ignore=.* --ignore=*~' \
        _blscd_hidden_filter_md5sum= \
        _blscd_input= \
        _blscd_k1= \
        _blscd_k2= \
        _blscd_k3= \
        _blscd_line_last= \
        _blscd_opener='builtin export LESSOPEN='"| /usr/bin/lesspipe %s"';command less -R "$1"' \
        _blscd_redraw=_blscd_redraw \
        _blscd_reprint=_blscd_reprint \
        _blscd_screen_lines_browser_col_1_cursor_string= \
        _blscd_screen_lines_browser_col_2_cursor_string= \
        _blscd_screen_lines_browser_col_3_cursor_string= \
        _blscd_screen_lines_titlebar_string= \
        _blscd_search_block= \
        _blscd_search_pattern= \
        _blscd_show_hidden= \
        _blscd_sort_mechanism=_blscd_sort_mechanism_basename \
        _blscd_sort_reverse=

    builtin declare -ga \
        "_blscd_col_1_list=()" \
        "_blscd_col_1_view=()" \
        "_blscd_col_2_list=()" \
        "_blscd_col_2_mtime=()" \
        "_blscd_col_2_search=()" \
        "_blscd_col_2_view=()" \
        "_blscd_col_3_list=()" \
        "_blscd_col_3_view=()"

    {
        builtin declare -g \
            "_blscd_tput_alt=$(command tput smcup || command tput ti)" \
            "_blscd_tput_am_off=$(command tput rmam)" \
            "_blscd_tput_am_on=$(command tput am)" \
            "_blscd_tput_bold=$(command tput bold || command tput md)" \
            "_blscd_tput_clear=$(command tput clear)" \
            "_blscd_tput_cup_1_0=$(command tput cup 1 0)" \
            "_blscd_tput_cup_2_0=$(command tput cup 2 0)" \
            "_blscd_tput_cup_99999_0=$(command tput cup 99999 0)" \
            "_blscd_tput_ealt=$(command tput rmcup || command tput te)" \
            "_blscd_tput_eel=$(command tput el || command tput ce)" \
            "_blscd_tput_hide=$(command tput civis || command tput vi)" \
            "_blscd_tput_home=$(command tput home)" \
            "_blscd_tput_reset=$(command tput sgr0 || command tput me)" \
            "_blscd_tput_show=$(command tput cnorm || command tput ve)" \
            "_blscd_tput_white_f=$(command tput setaf 7 || command tput AF 7)"
    } 2>/dev/null

    [[ $TERM != *-m ]] && {
        builtin declare -g \
            "_blscd_tput_black_f=$(command tput setaf 0)" \
            "_blscd_tput_blue_f=$(command tput setaf 4|| command tput AF 4)" \
            "_blscd_tput_green_b=$(command tput setab 2)" \
            "_blscd_tput_green_f=$(command tput setaf 2 || command tput AF 2)" \
            "_blscd_tput_red_b=$(command tput setab 1)" \
            "_blscd_tput_white_b=$(command tput setab 7)" \
            "_blscd_tput_yellow_b=$(command tput setab 3)" \
            "_blscd_tput_yellow_f=$(command tput setaf 3)"
    } 2>/dev/null

    builtin declare -g \
        "_blscd_saved_stty=$(command stty -g)" \
        "_blscd_saved_traps=$(builtin trap)"

    builtin declare -gx \
        _blscd_LC_COLLATE_old=$LC_COLLATE \
        LC_COLLATE=C
}

__blscd_set_delete ()
{
    builtin unset -v \
        _blscd_action_last \
        _blscd_col_1_list \
        _blscd_col_1_list_total \
        _blscd_col_1_view \
        _blscd_col_1_view_offset \
        _blscd_col_1_view_total \
        _blscd_col_2_list \
        _blscd_col_2_list_total \
        _blscd_col_2_mtime \
        _blscd_col_2_search \
        _blscd_col_2_view \
        _blscd_col_2_view_offset \
        _blscd_col_2_view_total \
        _blscd_col_3_list \
        _blscd_col_3_list_total \
        _blscd_col_3_view \
        _blscd_col_3_view_offset \
        _blscd_col_3_view_total \
        _blscd_console_command_name \
        _blscd_data \
        _blscd_dir_col_0_string \
        _blscd_dir_col_1_string \
        _blscd_dir_last \
        _blscd_hidden_filter \
        _blscd_hidden_filter_ls \
        _blscd_hidden_filter_md5sum \
        _blscd_input \
        _blscd_k1 \
        _blscd_k2 \
        _blscd_k3 \
        _blscd_line_last \
        _blscd_opener \
        _blscd_redraw \
        _blscd_redraw_number \
        _blscd_reprint \
        _blscd_saved_stty \
        _blscd_saved_traps \
        _blscd_screen_lines_browser \
        _blscd_screen_lines_browser_col_1_cursor \
        _blscd_screen_lines_browser_col_1_cursor_string \
        _blscd_screen_lines_browser_col_1_visible \
        _blscd_screen_lines_browser_col_2_cursor \
        _blscd_screen_lines_browser_col_2_cursor_string \
        _blscd_screen_lines_browser_col_2_visible \
        _blscd_screen_lines_browser_col_3_cursor \
        _blscd_screen_lines_browser_col_3_cursor_string \
        _blscd_screen_lines_browser_col_3_visible \
        _blscd_screen_lines_offset \
        _blscd_screen_lines_titlebar_string \
        _blscd_search_block \
        _blscd_search_pattern \
        _blscd_show_hidden \
        _blscd_sort_mechanism \
        _blscd_sort_reverse \
        _blscd_step \
        _blscd_tput_alt \
        _blscd_tput_am_off \
        _blscd_tput_am_on \
        _blscd_tput_black_f \
        _blscd_tput_blue_f \
        _blscd_tput_bold \
        _blscd_tput_clear \
        _blscd_tput_cup_1_0 \
        _blscd_tput_cup_2_0 \
        _blscd_tput_cup_99999_0 \
        _blscd_tput_ealt \
        _blscd_tput_eel \
        _blscd_tput_green_b \
        _blscd_tput_green_f \
        _blscd_tput_hide \
        _blscd_tput_home \
        _blscd_tput_red_b \
        _blscd_tput_reset \
        _blscd_tput_show \
        _blscd_tput_white_b \
        _blscd_tput_white_f \
        _blscd_tput_yellow_b \
        _blscd_tput_yellow_f

    builtin unset -f \
        __blscd_build_col_list \
        __blscd_build_col_view \
        __blscd_build_data \
        __blscd_build_data_do_1  \
        __blscd_build_data_do_2  \
        __blscd_build_data_do_3 \
        __blscd_build_data_do_stat \
        __blscd_build_mtime \
        __blscd_build_mtime_do \
        __blscd_build_search \
        __blscd_build_search_do \
        __blscd_draw_screen \
        __blscd_draw_screen_check \
        __blscd_draw_screen_lines \
        __blscd_edit_line \
        __blscd_help \
        __blscd_main \
        __blscd_move_col \
        __blscd_move_col_down \
        __blscd_move_col_up \
        __blscd_move_line \
        __blscd_move_line_do \
        __blscd_mtime \
        __blscd_mtime_go_newest \
        __blscd_mtime_go_newest_do \
        __blscd_mtime_go_oldest \
        __blscd_mtime_go_oldest_do \
        __blscd_open_console \
        __blscd_open_line \
        __blscd_open_shell \
        __blscd_print_data \
        __blscd_search \
        __blscd_search_go_down \
        __blscd_search_go_up \
        __blscd_set_action_last \
        __blscd_set_declare \
        __blscd_set_delete \
        __blscd_set_environment \
        __blscd_set_exit \
        __blscd_set_hide \
        __blscd_set_hide_filter_md5sum \
        __blscd_set_reload \
        __blscd_set_resize \
        __blscd_set_search_non \
        __blscd_set_sort \
        __blscd_test_data \
        __blscd_test_data_index \
        __blscd_version

    builtin declare -xg LC_COLLATE=$_blscd_LC_COLLATE_old

    builtin unset -v _blscd_LC_COLLATE_old
}

__blscd_set_environment ()
{
    builtin printf "$_blscd_tput_alt"
    command stty -echo
    builtin trap \
            '__blscd_set_resize 2;builtin printf "${_blscd_tput_cup_99999_0}${_blscd_tput_eel}"' SIGWINCH
    builtin trap 'printf "$_blscd_tput_clear"' SIGINT
    builtin trap '' SIGALRM
}

__blscd_set_exit ()
{
    command stty $_blscd_saved_stty
    builtin trap - SIGWINCH SIGINT SIGALRM
    builtin eval "$_blscd_saved_traps"
    builtin printf "${_blscd_tput_clear}${_blscd_tput_ealt}${_blscd_tput_show}${_blscd_tput_am_on}"
    __blscd_set_delete
}

__blscd_set_hide ()
{
    __blscd_set_action_last
    __blscd_set_resize 2

    if [[ $_blscd_show_hidden == _blscd_show_hidden ]]
    then
        _blscd_show_hidden=
    else
        _blscd_show_hidden=_blscd_show_hidden
    fi

    __blscd_set_hide_filter_md5sum
}

__blscd_set_hide_filter_md5sum ()
{
    builtin read _blscd_hidden_filter_md5sum _ \
        < <(builtin printf '%s' "${_blscd_show_hidden}:${_blscd_hidden_filter}:${_blscd_hidden_filter_ls}" | \
            command md5sum)
}

__blscd_set_reload ()
{
    builtin trap - SIGWINCH SIGINT SIGALRM
    command stty $_blscd_saved_stty
    builtin declare -xg LC_COLLATE=$_blscd_LC_COLLATE_old
    builtin unset -v _blscd_data
    __blscd_set_declare
    __blscd_set_hide_filter_md5sum
    __blscd_set_environment
}

__blscd_set_resize ()
case $1 in
    1)
        _blscd_redraw=_blscd_redraw
        _blscd_reprint=
        ;;
    2)
        _blscd_redraw=_blscd_redraw
        _blscd_reprint=_blscd_reprint
        ;;
    *)
        _blscd_redraw=
        _blscd_reprint=
        ;;
esac

__blscd_set_search_non ()
{
    __blscd_set_action_last
    _blscd_search_pattern=
    _blscd_search_block=
    _blscd_col_2_search=()
}

__blscd_set_sort ()
{
    __blscd_set_action_last
    __blscd_set_resize 2

    case $1 in
        a)
            _blscd_sort_mechanism=_blscd_sort_mechanism_atime
            _blscd_sort_reverse=_blscd_sort_reverse
            ;;
        A)
            _blscd_sort_mechanism=_blscd_sort_mechanism_atime
            _blscd_sort_reverse=
            ;;
        b)
            _blscd_sort_mechanism=_blscd_sort_mechanism_basename
            _blscd_sort_reverse=
            ;;
        B)
            _blscd_sort_mechanism=_blscd_sort_mechanism_basename
            _blscd_sort_reverse=_blscd_sort_reverse
            ;;
        c)
            _blscd_sort_mechanism=_blscd_sort_mechanism_ctime
            _blscd_sort_reverse=_blscd_sort_reverse
            ;;
        C)
            _blscd_sort_mechanism=_blscd_sort_mechanism_ctime
            _blscd_sort_reverse=
            ;;
        m)
            _blscd_sort_mechanism=_blscd_sort_mechanism_mtime
            _blscd_sort_reverse=_blscd_sort_reverse
            ;;
        M)
            _blscd_sort_mechanism=_blscd_sort_mechanism_mtime
            _blscd_sort_reverse=
            ;;
        n)
            _blscd_sort_mechanism=_blscd_sort_mechanism_natural
            _blscd_sort_reverse=
            ;;
        N)
            _blscd_sort_mechanism=_blscd_sort_mechanism_natural
            _blscd_sort_reverse=_blscd_sort_reverse
            ;;
        s)
            _blscd_sort_mechanism=_blscd_sort_mechanism_size
            _blscd_sort_reverse=_blscd_sort_reverse
            ;;
        S)
            _blscd_sort_mechanism=_blscd_sort_mechanism_size
            _blscd_sort_reverse=
            ;;
        t)
            _blscd_sort_mechanism=_blscd_sort_mechanism_type
            _blscd_sort_reverse=
            ;;
        T)
            _blscd_sort_mechanism=_blscd_sort_mechanism_type
            _blscd_sort_reverse=_blscd_sort_reverse
            ;;
        r)
            if [[ $_blscd_sort_reverse == _blscd_sort_reverse ]]
            then
                _blscd_sort_reverse=
            else
                _blscd_sort_reverse=_blscd_sort_reverse
            fi
            ;;
    esac
}

__blscd_test_data ()
[[ ${_blscd_data[${1} ${2} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse}${3:+ $3}]} ]]

__blscd_test_data_index ()
[[ ${_blscd_data[index ${1} ${_blscd_hidden_filter_md5sum} ${_blscd_sort_mechanism} ${_blscd_sort_reverse}]} -ge $2 ]]

# -- MAIN.

__blscd_main ()
{
    # Simple.
    case $1 in
        -h|--help)
            __blscd_help
            builtin return $?
            ;;
        -v|--version)
            __blscd_version
            builtin return $?
            ;;
        -d|--dump)
            {
                builtin eval "$(builtin declare -F | command grep '^declare -f __blscd_')" > ./blscd
                builtin printf '%s\n' '__blscd_main "$@"' >> ./blscd
            }
            builtin return $?
            ;;
    esac

    __blscd_set_declare
    __blscd_set_hide_filter_md5sum
    __blscd_set_environment

    while builtin :
    do
        builtin printf "${_blscd_tput_hide}${_blscd_tput_am_off}"
        ((_blscd_redraw_number == 0)) && {
            if [[ $_blscd_dir_col_1_string == / ]]
            then
                __blscd_build_data "$_blscd_dir_col_1_string"
            else
                __blscd_build_data -c "$_blscd_dir_col_1_string"
            fi
        }
        __blscd_draw_screen_check
        builtin read -s -n 1 _blscd_input
        builtin read -s -N 1 -t 0.0001 _blscd_k1
        builtin read -s -N 1 -t 0.0001 _blscd_k2
        builtin read -s -N 1 -t 0.0001 _blscd_k3
        _blscd_input=${_blscd_input}${_blscd_k1}${_blscd_k2}${_blscd_k3}
        case $_blscd_input in
            j|$'\e[B')
                __blscd_move_line 2 1
                ;;
            k|$'\e[A')
                __blscd_move_line 2 -1
                ;;
            h|$'\e[D')
                __blscd_move_col ..
                ;;
            l|$'\e[C')
                __blscd_open_line "$_blscd_screen_lines_browser_col_2_cursor_string"
                builtin printf "$_blscd_tput_alt"
                __blscd_set_resize 2
                ;;
            $'\x06'|$'\e[6~') # Ctrl+F | <PAGE-DOWN>
                __blscd_move_line 2 "${_blscd_screen_lines_browser}"
                ;;
            $'\x02'|$'\e[5~') # Ctrl+B | <PAGE-UP>
                 __blscd_move_line 2 "-${_blscd_screen_lines_browser}"
                ;;
            $'\e[H'|$'\eOH') # <HOME>
                __blscd_move_line 2 -9999999999
                ;;
            G|$'\e[F'|$'\eOF') # <END>
                __blscd_move_line 2 9999999999
                ;;
            J)
                __blscd_move_line 2 "$((_blscd_screen_lines_browser / 2))"
                ;;
            K)
                __blscd_move_line 2 "-$((_blscd_screen_lines_browser / 2))"
                ;;
            d)
                __blscd_move_line 2 5
                ;;
            D)
                __blscd_move_line 2 10
                ;;
            u)
                __blscd_move_line 2 -5
                ;;
            U)
                __blscd_move_line 2 -10
                ;;
            g)
                builtin read -n 1 _blscd_input
                case $_blscd_input in
                    g)
                        __blscd_move_line 2 -9999999999 ;;
                    h)
                        __blscd_move_col ~ ;;
                    e)
                        __blscd_move_col "/etc" ;;
                    u)
                        __blscd_move_col "/usr" ;;
                    d)
                        __blscd_move_col "/dev" ;;
                    l)
                        __blscd_move_col "/usr/lib" ;;
                    L)
                        __blscd_move_col "/var/log" ;;
                    o)
                        __blscd_move_col "/opt" ;;
                    v)
                        __blscd_move_col "/var" ;;
                    m)
                        __blscd_move_col "/media" ;;
                    M)
                        __blscd_move_col "/mnt" ;;
                    s)
                        __blscd_move_col "/srv" ;;
                    r|/)
                        __blscd_move_col / ;;
                    \?)
                        __blscd_help | command "${PAGER:-less}"
                        builtin printf "$_blscd_tput_alt"
                        __blscd_set_action_last
                        __blscd_set_resize 2
                        ;;
                esac
                ;;
            $'\x08') # Ctrl+H
                __blscd_set_hide
                ;;
            o)
                builtin read -n 1 _blscd_input
                __blscd_set_sort "$_blscd_input"
                ;;
            n)
                if ((${#_blscd_col_2_search[@]} != 0))
                then
                    __blscd_search_go_down
                else
                    __blscd_mtime newest
                fi
                ;;
            N)
                if ((${#_blscd_col_2_search[@]} != 0))
                then
                    __blscd_search_go_up
                else
                    __blscd_mtime oldest
                fi
                ;;
            $'\x12') # CTRl+R
                __blscd_set_reload
                ;&
            $'\x0c') # CTRL+L
                __blscd_set_resize 2
                builtin printf "${_blscd_tput_cup_99999_0}${_blscd_tput_eel}"
                ;;
            E)
                __blscd_edit_line
                builtin printf "$_blscd_tput_alt"
                __blscd_set_resize 2
                ;;
            S)
                builtin printf "${_blscd_tput_show}${_blscd_tput_am_on}"
                __blscd_open_shell
                builtin printf "$_blscd_tput_alt"
                __blscd_set_resize 2
                ;;
            :)
                builtin printf "${_blscd_tput_show}${_blscd_tput_am_on}"
                __blscd_open_console
                ;;
            /)
                builtin printf "${_blscd_tput_show}${_blscd_tput_am_on}"
                _blscd_console_command_name=search
                __blscd_open_console
                ;;
            q)
                __blscd_set_reload
                __blscd_set_exit
                builtin break
                ;;
        esac
    done
}

__blscd_main "$@"
