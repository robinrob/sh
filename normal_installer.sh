#!/usr/bin/env bash

case "`date +%s:%N`" in
  (*:%N)
    __install_time()
    {
      __time="$SECONDS:"
    }
    ;;
  (*)
    __install_time()
    {
      __time="$(date +%s:%N)"
    }
    ;;
esac

install_run_debug_time()
{
  # 1st s = start, 1st e = end, 1st d = difference, 2nd s = seconds, 2nd n = nanoseconds
  \typeset __ss __sn __es __en __ds __dn __time __status=0
  rvm_debug "step> '$1' started"

  __install_time
  __ss="${__time}"
  "$@" || __status=$?
  __install_time
  __es="${__time}"

  # split seconds and nano
  __sn="${__ss#*:}"
  __sn="${__sn##*(0)}"
  __ss="${__ss%:*}"
  __ss="${__ss##*(0)}"
  __en="${__es#*:}"
  __en="${__en##*(0)}"
  __es="${__es%:*}"
  __es="${__es##*(0)}"

  __ds="$(( __es - __ss ))"
  __dn=""
  if
    [[ -n "${__sn}" && -n "${__en}" ]]
  then
    __dn="$(( __en - __sn ))"
    if
      (( __dn < 0 ))
    then
      __dn="$(( __dn + 1000000000 ))"
      __ds="$(( __ds - 1 ))"
    fi
    if [[ "${__dn}" == "0" ]]
    then __dn=""
    fi
  fi
  __time="${__ds}${__dn:+"$(printf ".%09d" "$__dn")"} seconds"

  rvm_debug "step< '$1' finished with status 0 in ${__time}"
}

install_rvm_step()
{
  install_run_debug_time $1 ||
  {
    \typeset __status=$?
    rvm_error "Installer failed at step '$1' with status ${__status}, please run it with --debug and report a bug."
    return ${__status}
  }
}

install_rvm()
{
  \typeset __step
  \typeset -a __steps
  __steps=()

  load_configuration
  parse_args "$@"
  setup_installer
  load_rvm

  if (( rvm_user_install_flag == 0 ))
  then __steps+=( system_installation_check setup_rvm_group_and_users )
  fi
  __steps+=(
    print_install_header
    cleanse_old_entities
    create_install_paths
    load_custom_flags
    save_custom_flags
    install_rvm_directories
    install_rvm_files
    install_rvm_scripts
    cleanup_old_help_and_docs_files
    install_rvm_hooks
    remove_old_hooks
    install_binaries
    install_gemsets
    install_patchsets
    install_man_pages
    setup_configuration_files
    setup_login_shell
  )
  # not using elif for clarity
  if (( rvm_user_install_flag == 1 ))
  then __steps+=( setup_user_profile )
  else
    if (( UID == 0 ))
    then __steps+=( setup_etc_profile setup_etc_bashrc setup_etc_rvmrc )
    else
      if (( upgrade_flag == 0 ))
      then __steps+=( warning_no_loading_of_rvm )
      fi
    fi
  fi
  __steps+=(
    cleanse_old_environments
    migrate_old_gemsets
    migrate_defaults
    migrate_environments_and_wrappers
    restore_missing_environments
    record_ruby_configs
    update_gemsets_install_rvm
    configure_autolibs
    update_yaml_if_needed
    cleanup_tmp_files
    record_installation_time
  )
  if
    (( rvm_user_install_flag == 0 ))
  then
    __steps+=(
      setup_rvm_path_permissions_root
      setup_rvm_path_permissions_check_group
      setup_rvm_path_permissions_check_dirs
      setup_rvm_path_permissions_check_files
    )
  fi
  __steps+=(
    print_install_footer
    display_notes
  )
  for __step in "${__steps[@]}"
  do install_rvm_step ${__step} || return $?
  done
}

load_configuration()
{
  set -o errtrace
  export PS4 PATH HOME

  HOME="${HOME%%+(\/)}" # Remove trailing slashes if they exist on HOME

  case "$MACHTYPE" in
    *aix*) name_opt=-name  ;;
    *)     name_opt=-iname ;;
  esac

  if
    (( ${rvm_ignore_rvmrc:=0} == 0 ))
  then
    [[ -n "${rvm_stored_umask:-}" ]] || export rvm_stored_umask=$(umask)

    rvm_rvmrc_files=("/etc/rvmrc" "$HOME/.rvmrc")
    if [[ -n "${rvm_prefix:-}" ]] && ! [[ "$HOME/.rvmrc" -ef "${rvm_prefix}/.rvmrc" ]]
    then rvm_rvmrc_files+=( "${rvm_prefix}/.rvmrc" )
    fi
    for file in "${rvm_rvmrc_files[@]}"
    do
      if [[ -s "$file" ]]
      then . "$file"
      fi
    done
    unset rvm_rvmrc_files
  fi

  PS4="+ \${BASH_SOURCE##\${rvm_path:-}} : \${FUNCNAME[0]:+\${FUNCNAME[0]}()}  \${LINENO} > "

  [[ -z "${rvm_user_path_prefix:-}" ]] || PATH="${rvm_user_path_prefix}:$PATH"

  export ORIGINAL_PATH="$PATH"

  true ${rvm_group_name:=rvm}
  unset rvm_auto_dotfiles_flag
}

parse_args()
{
  true ${DESTDIR:=}
  # Parse RVM Installer CLI arguments.
  while (( $# > 0 ))
  do
    token="$1"
    shift

    case "$token" in
      (--auto-dotfiles|--ignore-dotfiles|--debug|--quiet-curl)
        token=${token#--}
        token=${token//-/_}
        export "rvm_${token}_flag"=1
        ;;
      (--autolibs=*)
        export rvm_autolibs_flag="${token#--autolibs=}"
        ;;
      (--without-gems=*|--with-gems=*|--with-default-gems=*)
        value="${token#*=}"
        token="${token%%=*}"
        token="${token#--}"
        token="${token//-/_}"
        export "rvm_${token}"="${value}"
        ;;
      (--path)
        export rvm_path="$1"
        export rvm_bin_path="$1/bin"
        export rvm_ignore_rvmrc=1
        shift
        ;;
      (--add-to-rvm-group)
        export rvm_add_users_to_rvm_group="$1"
        shift
        ;;
      (--version)
        (
          export rvm_path="${PWD%%+(\/)}"
          echo "$rvm_version"
        )
        exit
        ;;
      (--trace)
        export rvm_trace_flag=1
        set -o xtrace
        echo "$@"
        env | GREP_OPTIONS="" \grep '^rvm_'
        export PS4="+ \${BASH_SOURCE##\${rvm_path:-}} : \${FUNCNAME[0]:+\${FUNCNAME[0]}()}  \${LINENO} > "
        ;;
      (--help)
        install_usage
        exit 0
        ;;
      (*)
        echo "Unrecognized option: $token"
        install_usage
        exit 1
        ;;
    esac
  done

  if [[ -n "${DESTDIR}" ]]
  then
    rvm_prefix="${DESTDIR}"
  fi
}

install_usage()
{
  printf "%b" "
  Usage:

    ${0} [options]

  options:

    --auto-dotfiles   : Automatically update shell profile files.

    --ignore-dotfiles : Do not update shell profile files.

    --path    : Installation directory (rvm_path).

    --help    : Display usage information

    --version : display rvm package version

"
}

setup_installer()
{
  export rvm_prefix rvm_path rvm_user_install_flag rvm_debug_flag rvm_trace_flag upgrade_flag HOME

  HOME="${HOME%%+(\/)}" # Remove trailing slashes if they exist on HOME

  if
    [[ -z "${rvm_path:-}" ]]
  then
    if (( UID == 0 ))
    then rvm_path="/usr/local/rvm"
    else rvm_path="${HOME}/.rvm"
    fi
    rvm_prefix="${rvm_path%/*}"
  fi

  : \
    rvm_bin_path:${rvm_bin_path:=$rvm_path/bin} \
    rvm_man_path:${rvm_man_path:=$rvm_path/man} \
    rvm_user_path:${rvm_user_path:=$rvm_path/user} \
    rvm_scripts_path:${rvm_scripts_path:=$rvm_path/scripts}

  # duplication marker kkdfkgnjfndgjkndfjkgnkfjdgn
  [[ -n "${rvm_user_install_flag:-}" ]] ||
  case "$rvm_path" in
    (/usr/local/rvm)         rvm_user_install_flag=0 ;;
    ($HOME/*|/${USER// /_}*) rvm_user_install_flag=1 ;;
    (*)                      rvm_user_install_flag=0 ;;
  esac

  if [[ -d "$rvm_path" && -s "${rvm_path}/scripts/rvm" ]]
  then upgrade_flag=1
  else upgrade_flag=0
  fi
}

load_rvm()
{
  export install_source_path="$0"
  install_source_path="${install_source_path%/install}"
  install_source_path="${install_source_path%/scripts}" # install -> scripts/install
  \typeset save_rvm_scripts_path="$rvm_scripts_path"
  export rvm_scripts_path="${install_source_path}/scripts"

  source "$rvm_scripts_path/base"
  source "$rvm_scripts_path/functions/autolibs"
  source "$rvm_scripts_path/functions/group"
  source "$rvm_scripts_path/functions/pkg"

  rvm_scripts_path="$save_rvm_scripts_path"

  if [[ "$install_source_path/scripts" != "." && "$install_source_path/scripts" != "$PWD" ]]
  then __rvm_cd "$install_source_path"
  fi

  true "${source_path:=${PWD%%+(\/)}}"
}

system_installation_check()
{
  case "${_system_type}" in
    Linux|Darwin|SunOS|BSD)
      return 0 # Accounted for, continue.
    ;;
    *)
      # it will report 'unknown' or even nothing here!
      rvm_error "Installing RVM as root is currently only supported on the following known OS's (uname):
    Linux, FreeBSD, OpenBSD, DragonFly, Darwin and SunOS
Whereas your OS is reported as '${_system_type}'"
      return 1
    ;;
  esac
}

setup_rvm_group_and_users()
{
  if
    __rvm_group_exists "$rvm_group_name"
  then
    rvm_debug "Group '$rvm_group_name' already exists"
  else
    rvm_log "Creating group '$rvm_group_name'"
    __rvm_create_group "${rvm_group_name}" "${rvm_group_id:-}"
  fi
  if
    [[ -n "${rvm_add_users_to_rvm_group:-}" ]]
  then
    \typeset __user
    \typeset -a __users
    if
      [[ "$rvm_add_users_to_rvm_group" == "all" ]]
    then
      __users=( $( __rvm_list_all_users ) )
    else
      if [[ -n "${ZSH_VERSION:-}" ]]
      then __users=( ${=rvm_add_users_to_rvm_group//,/ } )
      else __users=( ${rvm_add_users_to_rvm_group//,/ } )
      fi
    fi
    for __user in "${__users[@]}"
    do
      if
        __rvm_is_user_in_group "$rvm_group_name" "$__user"
      then
        rvm_debug "User '$__user' already in the RVM group '${rvm_group_name}'"
      else
        rvm_log "Adding user '$__user' to the RVM group '${rvm_group_name}'"
        __rvm_add_user_to_group "$rvm_group_name" "$__user"
      fi
    done
  fi
}

print_install_header()
{
  if [[ ${upgrade_flag:-0} -eq 1 ]]
  then rvm_log "\nUpgrading the RVM installation in $rvm_path/"
  else rvm_log "\nInstalling RVM to $rvm_path/"
  fi
}

cleanse_old_entities()
{
  #
  # Remove old files that no longer exist.
  #
  for script in utility array
  do
    if test -f "$rvm_path/scripts/${script}"
    then \command \rm -f "$rvm_path/scripts/${script}"
    fi
  done
  return 0
}

create_install_paths()
{
  \typeset -a install_paths
  install_paths=(
   archives src log bin gems man rubies config user tmp gems environments wrappers
  )
  for install_path in "${install_paths[@]}"
  do [[ -d "$rvm_path/$install_path" ]] || mkdir -p "$rvm_path/$install_path"
  done

  [[ -z "$rvm_bin_path" || -d "$rvm_bin_path" ]] || mkdir -p "$rvm_bin_path"
  return 0
}

# duplication marker kdfkjkjfdkfjdjkdfkjfdkj
load_custom_flags()
{
  if
    [[ -s "${rvm_path:-}/user/custom_flags" ]]
  then
    \typeset __key __value
    while IFS== read __key __value
    do
      eval "export ${__key}=\"\${__value}\""
    done < "${rvm_path:-}/user/custom_flags"
  fi
}

save_custom_flags()
{
  \typeset -a __variables
  __variables=(
    ^rvm_ignore_dotfiles_flag=
  )
  \typeset IFS="|"
  set | __rvm_grep -E "${__variables[*]}" > "${rvm_path:-}/user/custom_flags"
  true # no failing from __rvm_grep filtering
}

install_rvm_directories()
{
  for entry in $(__rvm_find -L config patches patchsets gem-cache contrib examples lib hooks help docs scripts -type d 2>/dev/null)
  do
    # Target is supposed to be a directory, remove if it is a file.
    if [[ -f "$rvm_path/$entry" ]]
    then \command \rm -f "$rvm_path/$entry"
    fi
    [[ -d "$rvm_path/$entry" ]] || mkdir -p "$rvm_path/$entry"
  done
}

install_rvm_files()
{
  for file in README.md LICENSE VERSION
  do
    __rvm_cp -f "$source_path/${file}" "$rvm_path/${file}"
  done

  for entry in $(__rvm_find -L config patches gem-cache contrib examples lib help docs -type f 2>/dev/null)
  do
    # Target is supposed to be a file, remove if it is a directory.
    if [[ -d "$rvm_path/$entry" ]]
    then __rvm_rm_rf "$rvm_path/$entry"
    fi
    \command \cat < "$source_path/$entry" > "$rvm_path/$entry"
    if [[ -x "$source_path/$entry" && ! -x "$rvm_path/$entry" ]]
    then chmod +x "$rvm_path/$entry"
    fi
  done
}

install_rvm_scripts()
{
  case "${_system_type}" in
    (SunOS)
      # SmartOS bash and /opt/local/bin/test have a bug checking for executable bit when
      # run as root user. Reported here: https://github.com/joyent/smartos-live/issues/318
      chmod_if_needed()
      {
        if /usr/bin/test -x "$1" && ! /usr/bin/test -x "$2"
        then chmod +x "$2"
        fi
      }
    ;;
    *)
      chmod_if_needed()
      {
        if [[ -x "$1" && ! -x "$2" ]]
        then chmod +x "$2"
        fi
      }
    ;;
  esac

  for entry in $(__rvm_find -L scripts -type f 2>/dev/null)
  do
    # Target is supposed to be a file, remove if it is a directory.
    if [[ -d "$rvm_path/$entry" ]]
    then __rvm_rm_rf "$rvm_path/$entry"
    fi
    if
      [[ "$entry" == "scripts/extras/completion.zsh/_rvm" || "$entry" == "scripts/zsh/Completion/_rvm" ]]
    then
      if [[ ! -f "$rvm_path/$entry" ]] || __rvm_rm_rf "$rvm_path/$entry" 2>/dev/null
      then __rvm_cp -f "$source_path/$entry" "$rvm_path/$entry"
      else rvm_log "    Can not update '$entry', it's a conflict between Zsh and multiuser installation, prefix the command with 'rvmsudo' to update this file."
      fi
    else
      \command \cat < "$source_path/$entry" > "$rvm_path/$entry"
      chmod_if_needed "$source_path/$entry" "$rvm_path/$entry"
    fi
  done
  true # for osx
}

cleanup_old_help_and_docs_files()
{
  find "$rvm_path/help" -type f \! \( -name '*.md' -o -name '*.txt' \) -exec rm '{}' \;
  find "$rvm_path/docs" -type f \! \( -name '*.md' -o -name '*.txt' \) -exec rm '{}' \;
  true # for osx
}

install_rvm_hooks()
{
  \typeset hook_x_flag entry name

  for entry in $(__rvm_find -L hooks -type f 2>/dev/null)
  do
    # Target is supposed to be a file, remove if it is a directory.
    if [[ -d "$rvm_path/$entry" ]]
    then __rvm_rm_rf "$rvm_path/$entry"
    fi
    # Source is first level hook (after_use) and target is custom user hook, preserve it
    if
      [[ -f "$rvm_path/$entry" ]] &&
      __rvm_grep -E '^hooks/[[:alpha:]]+_[[:alpha:]]+$' >/dev/null <<<"$entry" &&
      ! __rvm_grep "$(basename ${entry})_\*" "$rvm_path/$entry" >/dev/null
    then
      \command \mv -f "$rvm_path/$entry" "$rvm_path/${entry}_custom"
    fi
    hook_x_flag=0
    [[ -x "$rvm_path/$entry" ]] || hook_x_flag=$?

    __rvm_cp -f "$source_path/$entry" "$rvm_path/$entry"

    if (( hook_x_flag == 0 ))
    then [[ -x "$rvm_path/$entry" ]] || chmod a+rx "$rvm_path/$entry"
    fi
  done
}

remove_old_hooks()
{
  for entry in after_use_custom after_use after_cd
  do
    name=${entry#after_}
    name=${name%_*}
    if
      [[ -f "$rvm_path/hooks/$entry" ]] &&
      __rvm_grep "after_${name}_\*" "$rvm_path/hooks/$entry" >/dev/null
    then
      \command \rm -f "$rvm_path/hooks/$entry"
    fi
  done
}

install_binaries()
{
  \typeset -a files
  \typeset system_bin
  files=(
    rvm-prompt rvm rvmsudo rvm-shell rvm-smile rvm-exec rvm-auto-ruby
    ruby-rvm-env rvm-shebang-ruby
  )

  [[ -d "${rvm_bin_path}" ]] || mkdir -p "${rvm_bin_path}"

  for file in "${files[@]}"
  do
    if [[ -e "${rvm_bin_path}/${file}" ]] &&
    [[ ! -f "${rvm_bin_path}/${file}"  || -L "${rvm_bin_path}/${file}" ]]
    then \command \rm -f "${rvm_bin_path}/${file}"
    fi

    if
      [[ -L "${source_path}/bin/${file}" ]]
    then
      ln -s "$( readlink "${source_path}/bin/${file}" )" "${rvm_bin_path}/${file}"
    else
      \command \cat < "${source_path}/bin/${file}" > "${rvm_bin_path}/${file}"
    fi

    [[ -x "${rvm_bin_path}/${file}" ]] || chmod a+rx "${rvm_bin_path}/${file}"

    # try to clean old installer files left in usual places added to PATH
    for system_bin in ~/bin /usr/bin /usr/local/bin
    do
      if
        [[ "${system_bin}" != "${rvm_bin_path}" && -x "${system_bin}/${file}" ]]
      then
        \command \rm -f "${system_bin}/${file}" 2>/dev/null ||
        rvm_out "!!! could not remove ${system_bin}/${file}, remove it manually with:
!!! > sudo \command \rm -f ${system_bin}/${file}
"
      fi
    done
  done
  return 0
}

update_gemsets_rvmrc()
{
  if
    [[ -n "$2" ]]
  then
    if [[ -f ~/.rvmrc ]] && __rvm_grep "^$1=" ~/.rvmrc >/dev/null
    then __rvm_sed_i ~/.rvmrc -e "s/^$1=.*$/$1=\"$2\"/"
    else printf "%b" "\n$1=\"$2\"\n" >> ~/.rvmrc
    fi
  else
    if [[ -f ~/.rvmrc ]]
    then __rvm_sed_i ~/.rvmrc -e "/^$1=/ d"
    fi
  fi
}

install_gemsets()
{
  \typeset gemset_files

  if [[ ${rvm_keep_gemset_defaults_flag:-0} == 0 && -d "$rvm_path/gemsets" ]]
  then __rvm_find "$rvm_path/gemsets" -type f -exec rm '{}' \;
  fi

  [[ -d "$rvm_path/gemsets" ]] || mkdir -p "$rvm_path/gemsets"

  __rvm_read_lines gemset_files <(
    __rvm_find "gemsets" "${name_opt}" '*.gems'
  )

  for gemset_file in "${gemset_files[@]}"
  do
    destination="$rvm_path/gemsets/${gemset_file#gemsets/}"
    if
      [[ ! -s "$destination" ]]
    then
      destination_path="${destination%/*}"
      [[ -d "$destination_path" ]] || mkdir -p "$destination_path"
      \command \cat < "$gemset_file" > "$destination"
    fi
  done

  update_gemsets_rvmrc rvm_without_gems      "${rvm_without_gems}"
  update_gemsets_rvmrc rvm_with_gems         "${rvm_with_gems}"
  update_gemsets_rvmrc rvm_with_default_gems "${rvm_with_default_gems}"
}

install_patchsets()
{
  if
    [[ ${rvm_keep_patchsets_flag:-0} == 0 && -d "$rvm_path/patchsets" ]]
  then
    __rvm_find "$rvm_path/patchsets/" -type f -exec rm '{}' \;
  fi
  if
    [[ -d patchsets/ ]]
  then
    [[ -d "$rvm_path/patchsets" ]] || mkdir -p "$rvm_path/patchsets"
    patchsets=($(
      __rvm_find patchsets/ -type f
    ))
    for patchset_file in "${patchsets[@]}"
    do
      destination="$rvm_path/$patchset_file"
      if
        [[ ! -s "$destination" || "${patchset_file##*/}" == "default" ]]
      then
        if [[ -d "$destination"    ]]
        then \command \rm -f "$destination"
        fi
        \command \cat < "$patchset_file" > "$destination"
      fi
    done
  fi
}

install_man_pages()
{
  files=($(
    __rvm_cd "$install_source_path/man"
    __rvm_find . -maxdepth 2 -mindepth 1 -type f -print
  ))

  for file in "${files[@]//.\/}"
  do
    [[ -d $rvm_man_path/${file%\/*} ]] ||
    {
      mkdir -p $rvm_man_path/${file%\/*}
      install_fix_rights $rvm_man_path/${file%\/*}
    }
    __rvm_cp -Rf "$install_source_path/man/$file" "$rvm_man_path/$file" || \
      rvm_out "

    Please run the installer using rvmsudo to fix file permissions

"
    install_fix_rights "$rvm_man_path/$file"
  done
}

setup_configuration_files()
{
  \typeset _save_dir
  _save_dir="$PWD"
  __rvm_cd "$rvm_path"

  if [[ -f config/user ]]
  then \command \mv config/user user/db
  fi

  if [[ -f config/installs ]]
  then \command \mv config/installs user/installs
  fi

  if [[ -s config/rvmrcs ]]
  then \command \mv config/rvmrcs user/rvmrcs
  fi

  [[ -s user/db ]] ||
    echo '# User settings, overrides db settings and persists across installs.' >> user/db

  [[ -f user/rvmrcs ]] || > user/rvmrcs
  [[ -f user/md5    ]] || > user/md5
  [[ -f user/sha512 ]] || > user/sha512

  # Prune old (keyed-by-hash) trust entries
  __rvm_grep '^_' user/rvmrcs > user/rvmrcs.new || true
  \command \mv user/rvmrcs.new user/rvmrcs

  __rvm_cd "${_save_dir}"
}

setup_login_shell()
{
  if [ "$COLORTERM" = "gnome-terminal" ]
  then
    if __rvm_grep "entry name=['\"]login_shell['\"]" ~/.gconf/apps/gnome-terminal/profiles/Default/%gconf.xml > /dev/null
    then
      :
    else
      __rvm_sed_i "/<gconf>/ a<entry name='login_shell' mtime='`date +%s`' type='bool' value='true'/>" ~/.gconf/apps/gnome-terminal/profiles/Default/%gconf.xml
    fi
  fi
}

check_file_group()
{
  \typeset _group
  _group="$( __rvm_statf "%G" "%Sg" "$1" )"
  [[ "${_group}" == "$2" ]] || return $?
  true # for OSX
}

check_file_rights()
{
  \typeset _all
  _all="$( __rvm_statf "%A" "%Sp" "$1" )"
  shift
  while
    (( $# ))
  do
    case "$1" in
      (g+w) [[ "${_all:5:1}" == "w" ]] || return $? ;;
      (a+r) [[ "${_all:7:1}" == "r" ]] || return $? ;;
      (a-r) [[ "${_all:7:1}" == "-" ]] || return $? ;;
    esac
    shift
  done
  true # for OSX
}

permissions_warning()
{
  rvm_warn "    $1, prefix the command with 'rvmsudo' to fix it, if the situation persist report a bug."
  if [[ -n "${2:-}" ]]
  then return $2
  fi
}

install_fix_rights()
{
  (( ${rvm_user_install_flag:-0} == 0 ))   || return 0
  check_file_group  "$1" "$rvm_group_name" || chown :$rvm_group_name "$1" || permissions_warning "could not set group of '$1'"
  check_file_rights "$1" g+w               || chmod g+rwX "$1"            || permissions_warning "could not fix perissions of '$1'"
}

setup_etc_profile()
{
  export etc_profile_file="/etc/profile.d/rvm.sh"

  if [[ -s "${etc_profile_file}" ]] || (( ${rvm_auto_dotfiles_flag:-1} == 0 ))
  then return 0
  fi

  \typeset executable add_to_profile_flag zshrc_file ps_ucomm_alias
  if
    [[ -d /etc/profile.d ]]
  then
    add_to_profile_flag=0
    executable=1
  else
    add_to_profile_flag=1
    executable=0
    mkdir -p /etc/profile.d
  fi
  if [[ "$(uname)" == "SunOS" ]]
  then
    # Solaris default ps doesn't provide ucomm
    ps_ucomm_alias=comm
  else
    ps_ucomm_alias=ucomm
  fi

# partial duplication marker dkjnkjvnckbjncvbkjnvkj
# prevent from loading in sh shells
  printf "%b" "#
# RVM profile
#
# /etc/profile.d/rvm.sh # sh extension required for loading.
#

if
  [ -n \"\${BASH_VERSION:-}\" -o -n \"\${ZSH_VERSION:-}\" ] &&
  test \"\`\\\\command \\\\ps -p \$\$ -o ${ps_ucomm_alias}=\`\" != dash &&
  test \"\`\\\\command \\\\ps -p \$\$ -o ${ps_ucomm_alias}=\`\" != sh
then
  [[ -n \"\${rvm_stored_umask:-}\" ]] || export rvm_stored_umask=\$(umask)
  # Load user rvmrc configurations, if exist
  for file in \"/etc/rvmrc\" \"\$HOME/.rvmrc\"
  do
    [[ -s \"\$file\" ]] && source \$file
  done
  if
    [[ -n \"\${rvm_prefix:-}\" ]] &&
    [[ -s \"\${rvm_prefix}/.rvmrc\" ]] &&
    [[ ! \"\$HOME/.rvmrc\" -ef \"\${rvm_prefix}/.rvmrc\" ]]
  then
    source \"\${rvm_prefix}/.rvmrc\"
  fi

  # Load RVM if it is installed, try user then root install.
  if
    [[ -s \"\$rvm_path/scripts/rvm\" ]]
  then
    source \"\$rvm_path/scripts/rvm\"
  elif
    [[ -s \"\$HOME/.rvm/scripts/rvm\" ]]
  then
    true \${rvm_path:=\"\$HOME/.rvm\"}
    source \"\$HOME/.rvm/scripts/rvm\"
  elif
    [[ -s \"/usr/local/rvm/scripts/rvm\" ]]
  then
    true \${rvm_path:=\"/usr/local/rvm\"}
    source \"/usr/local/rvm/scripts/rvm\"
  fi

  # Add \$rvm_bin_path to \$PATH if necessary. Make sure this is the last PATH variable change.
  if [[ -n \"\${rvm_bin_path}\" && ! \":\${PATH}:\" == *\":\${rvm_bin_path}:\"* ]]
  then PATH=\"\${PATH}:\${rvm_bin_path}\"
  fi
fi
" > "${etc_profile_file}"

  if
    (( executable )) && check_file_rights "${etc_profile_file}" a-x
  then
    chmod a+rx "${etc_profile_file}" || permissions_warning "could not fix '${etc_profile_file}' rights"
  fi

  if
    (( add_to_profile_flag )) &&
    ! __rvm_grep "source ${etc_profile_file}" /etc/profile >/dev/null 2>&1
  then
    printf "%b" "\ntest -f ${etc_profile_file} && source ${etc_profile_file}\n" >> /etc/profile
  fi

  for zshrc_file in $(
      __rvm_find /etc/ -name zprofile -type f 2>/dev/null ;
      __rvm_find /etc/ -name zlogin   -type f 2>/dev/null ;
      true
    ) /etc/zprofile
  do
    if
      [[ ! -f "${zshrc_file}" ]]
    then
      printf "%b" "\ntest -f ${etc_profile_file} && source ${etc_profile_file}\n" > $zshrc_file
    elif
      ! __rvm_grep "source /etc/bash"    "${zshrc_file}" &&
      ! __rvm_grep "source /etc/profile" "${zshrc_file}"
    then
      printf "%b" "\ntest -f ${etc_profile_file} && source ${etc_profile_file}\n" >> $zshrc_file
    fi
    break # process only first file found
  done
}

print_etc_bashrc_change()
{
  printf "%b" "
type rvm >/dev/null 2>/dev/null || echo \${PATH} | __rvm_grep \"${rvm_bin_path}\" > /dev/null || export PATH=\"\${PATH}:${rvm_bin_path}\"
"
}

# Ubuntu does not source /etc/profile when we're running command such as "ssh my-ubuntu env"
# So we add source ${etc_profile_file} in /etc/bash.bashrc
setup_etc_bashrc()
{
  \typeset system_bashrc_file new_content_path
  system_bashrc_file="/etc/bash.bashrc"

  if [[ -s "${system_bashrc_file}" ]] || (( ${rvm_auto_dotfiles_flag:-1} == 0 ))
  then return 0
  fi

  if
    [[ ! -f "${system_bashrc_file}" ]]
  then
    print_etc_bashrc_change > "${system_bashrc_file}" 2>/dev/null ||
      permissions_warning "could not create '${system_bashrc_file}'" $? ||
      return $?
  elif
    ! __rvm_grep "PATH=.*${rvm_bin_path}" "${system_bashrc_file}" >/dev/null
  then
    new_content_path="$( mktemp ${TMPDIR:-/tmp}/tmp.XXXXXXXXXXXXXXXXXX )"
    [[ ! -f "${new_content_path}" ]] || \command \rm -f "${new_content_path}"
    {
      print_etc_bashrc_change # prepend
      __rvm_grep -v "|| export PATH=\"\${PATH}:\"" < "${system_bashrc_file}"
      true
    } > "${new_content_path}" &&
    \command \mv "${new_content_path}" "${system_bashrc_file}" 2>/dev/null ||
      permissions_warning "could not update '${system_bashrc_file}'" $? ||
      return $?
  fi
  check_file_rights $system_bashrc_file a+r ||
    chmod a+r $system_bashrc_file ||
    permissions_warning "File '$system_bashrc_file' is not readable for all users, this might cause problems in loading RVM" $? ||
    return $?
}

setup_etc_rvmrc()
{
  rvmrc_file="/etc/rvmrc"
  if
    [[ -f $rvmrc_file ]] &&
    __rvm_grep '#umask' $rvmrc_file >/dev/null
  then
    true # commented out, skip it!
  elif
    [[ -f $rvmrc_file ]] &&
    __rvm_grep 'umask g+w' $rvmrc_file >/dev/null
  then
    __rvm_sed_i $rvmrc_file -e 's/umask g+w/umask u=rwx,g=rwx,o=rx/'
  elif
    ! [[ -f $rvmrc_file ]] ||
    ! __rvm_grep 'umask' $rvmrc_file >/dev/null
  then
    echo 'umask u=rwx,g=rwx,o=rx' >> $rvmrc_file
  fi
  if
    [[ "${rvm_path}" != "/usr/local/rvm" ]] &&
    ! __rvm_grep 'rvm_path' $rvmrc_file >/dev/null
  then
    echo "rvm_path=\"${rvm_path}\"" >> $rvmrc_file
  fi
  if [[ -s $rvmrc_file ]]
  then install_fix_rights $rvmrc_file
  fi
  return 0
}

pick_a_file()
{
  \typeset _file _result
  _result=$1
  shift
  for _file
  do
    if
      [[ -f "$_file" ]]
    then
      eval "${_result}+=( \"\$_file\" )"
      return 0
    fi
  done
  eval "${_result}+=( \"\$1\" )"
}

setup_user_profile_check()
{
  case "${rvm_ignore_dotfiles_flag:-${rvm_ignore_dotfiles:-no}}" in
    (yes|1) return 1 ;;
  esac
  return 0
}

setup_user_profile_detect()
{
  etc_profile_file="/etc/profile.d/rvm.sh"
  search_list_mksh=( "$HOME/.mkshrc" "$HOME/.profile" )
  search_list_bash=( "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.bash_login" )
  search_list_zsh=( "${ZDOTDIR:-${HOME}}/.zshenv" "${ZDOTDIR:-${HOME}}/.zprofile" "${ZDOTDIR:-${HOME}}/.zshrc" "${ZDOTDIR:-${HOME}}/.zlogin" )
  search_list=( "${search_list_mksh[@]}" "${search_list_bash[@]}" "${search_list_zsh[@]}" )

  target_rc=( "$HOME/.profile" "$HOME/.mkshrc" "$HOME/.bashrc" "${ZDOTDIR:-${HOME}}/.zshrc" )

  target_login=( "$HOME/.profile" )
  pick_a_file target_login "$HOME/.bash_profile" "$HOME/.bash_login"
  target_login+=( "${ZDOTDIR:-${HOME}}/.zlogin" )

  for profile_file in "${search_list[@]}"
  do
    if
      [[ -f "$profile_file" ]]
    then
      if
        __rvm_grep PATH=.*$local_rvm_path/bin "$profile_file" >/dev/null
      then
        found_rc+=( "$profile_file" )
      fi
      if
        __rvm_grep \..*scripts/rvm "$profile_file" >/dev/null
      then
        found_login+=( "$profile_file" )
      elif
        __rvm_grep source.*scripts/rvm "$profile_file" >/dev/null
      then
        found_login+=( "$profile_file" )
      fi
    fi
  done
}

setup_user_profile_summary()
{
  eval "\typeset __list_found=\"\${${1}[*]}\""
  \typeset __target="$2"
  rvm_log "    RVM ${__target} line found in ${__list_found}."

  \typeset __bash_included=0
  \typeset  __zsh_included=0
  __rvm_string_includes "${__list_found}" "${search_list_bash[@]}" || __bash_included=$?
  __rvm_string_includes "${__list_found}" "${search_list_zsh[@]}"  ||  __zsh_included=$?

  \typeset __missing=""
  if (( __bash_included>0 && __zsh_included>0  ))
  then __missing="Bash or Zsh"
  elif (( __bash_included>0 ))
  then __missing="Bash"
  elif (( __zsh_included>0 ))
  then __missing="Zsh"
  fi
  if [[ -n "${__missing}" ]]
  then rvm_warn "    RVM ${__target} line not found for ${__missing}, rerun this command with '--auto-dotfiles' flag to fix it."
  fi
}

setup_user_profile_rc()
{
  if
    (( rvm_auto_dotfiles_flag == 1 && ${#found_rc[@]} > 0 ))
  then
    rvm_out "    Removing rvm PATH line from ${found_rc[*]}."
    for profile_file in "${found_rc[@]}"
    do
      __rvm_sed_i "${profile_file}" -e '/PATH=.*'"$local_rvm_path_sed"'\/bin/ d;'
      # also delete duplicate blank lines
      __rvm_sed_i "${profile_file}" -e '/^\s*$/{ N; /^\n$/ D; };'
    done
    found_rc=()
  fi
  if
    (( rvm_auto_dotfiles_flag == 1 || ${#found_rc[@]} == 0 ))
  then
    rvm_out "    Adding rvm PATH line to ${target_rc[*]}."
    for profile_file in "${target_rc[@]}"
    do
      touch "$profile_file"
      printf "%b" "
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH=\"\$PATH:$local_rvm_path/bin\"
" >> "$profile_file"
    done
  else
    setup_user_profile_summary found_rc "PATH"
  fi
}

setup_user_profile_login()
{
  if
    (( rvm_auto_dotfiles_flag == 1 && ${#found_login[@]} > 0 ))
  then
    rvm_out "    Removing rvm loading line from ${found_login[*]}."
    for profile_file in "${found_login[@]}"
    do
      __rvm_sed_i "${profile_file}" -e '/source.*scripts\/rvm/ d; /\. .*scripts\/rvm/ d;'
      # also delete duplicate blank lines
      __rvm_sed_i "${profile_file}" -e '/^\s*$/{ N; /^\n$/ D; };'
    done
    found_rc=()
  fi
  if
    (( rvm_auto_dotfiles_flag == 1 || ${#found_login[@]} == 0 ))
  then
    rvm_out "    Adding rvm loading line to ${target_login[*]}."
    for profile_file in "${target_login[@]}"
    do
      [[ -f "$profile_file" ]] ||
      {
        touch "$profile_file"
        if
          [[ "$profile_file" == "$HOME/.bash_"* && -f "$HOME/.profile" ]]
        then
          printf "%b" "
[[ -s \"\$HOME/.profile\" ]] && source \"\$HOME/.profile\" # Load the default .profile
" >> "$profile_file"
        fi
      }
      printf "%b" "
[[ -s \"$local_rvm_path/scripts/rvm\" ]] && source \"$local_rvm_path/scripts/rvm\" # Load RVM into a shell session *as a function*
" >> "$profile_file"
    done
  else
    setup_user_profile_summary found_login "sourcing"
  fi
}

setup_user_profile()
{
  setup_user_profile_check || return 0

  export user_profile_file
  \typeset -a search_list search_list_mksh search_list_bash search_list_zsh
  \typeset -a target_rc target_login found_rc found_login
  \typeset etc_profile_file profile_file local_rvm_path local_rvm_path_sed
  local_rvm_path="${rvm_path/#$HOME/\$HOME}"
  local_rvm_path_sed="\\${local_rvm_path//\./\\.}"
  local_rvm_path_sed="${local_rvm_path_sed//\//\/}"

  setup_user_profile_detect
  setup_user_profile_rc
  setup_user_profile_login

  true # for osx
}

warning_no_loading_of_rvm()
{
  rvm_error "    Warning! Installing RVM in system mode without root permissions, make sure to modify PATH / source rvm when it's needed."
}

cleanse_old_environments()
{
  if
    [[ -d "$rvm_path/environments" ]]
  then
    for file in "$rvm_path/environments"/*
    do
      # Remove broken links
      if
        [[ -L "$file" && ! -e "$file" ]]
      then
        rm -f "$file"
      fi
      if
        [[ -f "$file" ]]
      then
        # Remove BUNDLE_PATH from environment files
        if
          __rvm_grep 'BUNDLE_PATH' "$file" >/dev/null 2>&1
        then
          __rvm_grep -v 'BUNDLE_PATH' "$file" > "$file.new" &&
          \command \mv "$file.new" "$file"
        fi
        # regenerate when found broken path :/bin:/bin or missing $PATH
        if
          __rvm_grep ':/bin:/bin' "$file" >/dev/null 2>&1 ||
          __rvm_grep "[^_]PATH=" "$file" | __rvm_grep -v "\$PATH" >/dev/null 2>&1
        then
          ruby_version="${file##*environments/}"
          rvm_out "    Fixing environment for ${ruby_version}."
          __rvm_with "${ruby_version}" __rvm_ensure_has_environment_files
        fi
      fi
    done
  fi
}

migrate_old_gemsets()
{
  for gemset in "$rvm_path"/gems/*\%*
  do
    new_path=${gemset/\%/${rvm_gemset_separator:-"@"}}
    if
      [[ -d "$gemset" ]] && [[ ! -d "$new_path" ]]
    then
      rvm_out "    Renaming $(basename "$gemset") to $(basename "$new_path") for new gemset separator."
      \command \mv "$gemset" "$new_path"
    fi
  done

  for gemset in "$rvm_path"/gems/*\+*
  do
    new_path=${gemset/\+/${rvm_gemset_separator:-"@"}}
    if
      [[ -d "$gemset" && ! -d "$new_path" ]]
    then
      rvm_out "    Renaming $(basename "$gemset") to $(basename "$new_path") for new gemset separator."
      \command \mv $gemset $new_path
    fi
  done

  for gemset in "$rvm_path"/gems/*\@
  do
    new_path="$( __rvm_sed -e 's#\@$##' <<<"$gemset" )"
    if
      [[ -d "$gemset" && ! -d "$new_path" ]]
    then
      rvm_out "    Fixing: $(basename "$gemset") to $(basename "$new_path") for new gemset separator."
      \command \mv "$gemset" "$new_path"
    fi
  done
}

# Move from legacy defaults to the new, alias based system.
migrate_defaults()
{
  [[ -s "$rvm_path/config/default" ]] || return 0

  \typeset original_version="$(
    basename "$(
      __rvm_grep GEM_HOME "$rvm_path/config/default" |
        __rvm_awk -F"'" '{print $2}' | __rvm_sed "s#\%#${rvm_gemset_separator:-"@"}#"
    )"
  )"
  if [[ -n "$original_version" ]]
  then "$rvm_scripts_path/alias" create default "$original_version" &> /dev/null
  fi
  __rvm_rm_rf "$rvm_path/config/default"
}

migrate_environments_and_wrappers()
{
  \typeset environment_file wrappers_path new_path ruby_version

  for environment_file in "$rvm_path"/environments/*
  do
    ruby_version="${environment_file##*/}"
    new_path="$rvm_path/gems/${ruby_version}/environment"
    if
      [[ -f "$environment_file" && ! -L "$environment_file" && -d "${new_path%/*}" && ! -e "$new_path" ]]
    then
      rvm_out "    Migrating environment ${ruby_version} to use with 'gem-wrappers' gem."
      \command \mv "$environment_file" "$new_path" && \command \ln -s "$new_path" "$environment_file"
    fi
  done

  for wrappers_path in "$rvm_path"/wrappers/*
  do
    ruby_version="${wrappers_path##*/}"
    new_path="$rvm_path/gems/${ruby_version}/wrappers"
    if
      [[ -d "$wrappers_path" && ! -L "$wrappers_path" && -d "${new_path%/*}" && ! -e "$new_path" ]]
    then
      rvm_out "    Migrating wrappers ${ruby_version} to use with 'gem-wrappers' gem."
      \command \mv "$wrappers_path" "$new_path" && \command \ln -snf "$new_path" "$wrappers_path"
    fi
  done

  __rvm_grep -rl 'unset GEM_HOME' "$rvm_path/gems"/*/environment "$rvm_path/environments"/ 2>/dev/null |
  while read environment_file
  do
    ruby_version="${environment_file%/environment}"
    ruby_version="${ruby_version##*/}"
    rvm_out "    Fixing environment for ${ruby_version}."
    __rvm_with "${ruby_version}" __rvm_ensure_has_environment_files
  done
}

restore_missing_environments()
{
  if
    [[ -d "$rvm_path/rubies" ]]
  then
    [[ -d "$rvm_path/environments" ]] || mkdir -p "$rvm_path/environments"

    for ruby_path in "$rvm_path"/rubies/*
    do
      ruby_version="${ruby_path##*/}"
      environment_path="$rvm_path/environments/${ruby_version}"
      if
        [[ "${ruby_version}" == "*" || -e "$environment_path" ]]
      then
        true
      elif
        [[ "${ruby_version}" == "gems" ]]
      then
        rvm_out "    Removing unexpected ruby: ${ruby_version}."
        \command \rm -rf "${ruby_path}"
      elif
        [[ -L "$ruby_path" ]]
      then
        ruby_target="$(readlink "$ruby_path")"
        ruby_target="${ruby_target##*/}"
        environment_tareget="$rvm_path/environments/${ruby_target}"
        rvm_out "    Fixing environment link for ${ruby_version}."
        \command \ln -nsf "$environment_tareget" "$environment_path"
      else
        rvm_out "    Fixing environment for ${ruby_version}."
        __rvm_with "${ruby_version}" __rvm_ensure_has_environment_files
      fi
    done
  fi
}

record_ruby_configs()
{
  __rvm_record_ruby_configs
}

update_gemsets_install_rvm()
{
  \typeset _iterator _gem installed found missing _current_path
  \typeset -a paths missing

  [[ ${rvm_keep_gemset_defaults_flag:-0} == 0 ]] || return 0

  # rvm /gems
  paths=($(
    __rvm_find "$rvm_path/gems" -maxdepth 1 "${name_opt}" '*@global'
  ))

  for _gem in rvm gem-wrappers
  do
    [[ " ${rvm_without_gems:-} " == *" ${_gem} "* ]] ||
    {
      missing=()

      for _iterator in "${paths[@]}"
      do
        # skip unless this ruby is installed
        installed="${_iterator%@global}"
        installed="${installed/\/gems\//\/rubies\//}/bin"
        installed="${installed//\\/}"
        [[ -x "${installed}/ruby" ]] || continue
        [[ -x "${installed}/gem" ]] || continue

        _current_path="${_iterator%%+(\/)}/gems"
        # rvm /gems @global /gems
        found=($(
          [[ ! -d "${_current_path}" ]] ||
          __rvm_find "${_current_path}" -maxdepth 1 "${name_opt}" ${_gem}-'*'
        ))
        (( ${#found[@]} > 0 )) || missing+=( "${installed}=${_iterator}" )
      done

      if
        (( ${#missing[@]} > 0 ))
      then
        for _iterator in "${missing[@]}"
        do
          __gem_home="${_iterator#*=}"
          __rvm_with "${__gem_home##*/}" gem_install ${_gem}
        done | __rvm_dotted "    Installing ${_gem} gem in ${#missing[@]} gemsets"
      fi

      if
        [[ "${_gem}" == "gem-wrappers" ]] &&
        (( ${#missing[@]} > 0 ))
      then
        for _iterator in "${missing[@]}"
        do
          installed="${_iterator#*=}"
          installed="${installed%@global}"
          for __gem_home in "${installed}"{,@*}
          do
            if [[ "${__gem_home}" == *"@*" ]]
            then continue
            fi
            __rvm_with "${__gem_home##*/}" gem wrappers regenerate
          done
        done | __rvm_dotted "    Regenerating gem wrappers in ${#missing[@]} rubies"
      fi
    }
  done
}

configure_autolibs()
(
  # remove old version from rvmrc
  for rvmrc in /etc/rvmrc "$HOME/.rvmrc"
  do
    if
      [[ -s "$rvmrc" ]] &&
      __rvm_grep 'rvm_autolibs_flag=' "$rvmrc" >/dev/null 2>&1
    then
      [[ -w "$rvmrc" ]] &&
      __rvm_sed '/rvm_autolibs_flag=/ d' < "$rvmrc" > "$rvmrc.backup" &&
      \command \mv -f "$rvmrc.backup" "$rvmrc" ||
      rvm_error "    Can not automatically remove lines with 'rvm_autolibs_flag=' from '$rvmrc', please clean it manually."
    fi
  done

  if
    [[ -s "$rvmrc" ]] &&
    __rvm_grep 'rvm_autolibs_flag=' "$rvmrc" >/dev/null 2>&1
  then
    export rvm_autolibs_flag="$( __rvm_awk -F'=' '/rvm_autolibs_flag=/{print $2}' <"$rvmrc" )"
    [[ -w "$rvmrc" ]] &&
    __rvm_sed '/rvm_autolibs_flag/ d' < "$rvmrc" > "$rvmrc.backup" &&
    \command \mv -f "$rvmrc.backup" "$rvmrc" || true
  fi

  # migrate SMF settings
  rvmrc=/etc/rvmrc
  if
    [[ -s "$rvmrc" ]] &&
    __rvm_grep 'rvm_configure_env=.*/opt/sm' "$rvmrc" >/dev/null 2>&1
  then
    export rvm_autolibs_flag=smf
    [[ -w "$rvmrc" ]] &&
    __rvm_sed '/rvm_configure_env/ d' < "$rvmrc" > "$rvmrc.backup" &&
    \command \mv -f "$rvmrc.backup" "$rvmrc" || true
  fi

  [[ -n "${rvm_autolibs_flag:-}" ]] || return 0

  # save if proper value
  if
    __rvm_autolibs_translate
  then
    __rvm_db_ "$rvm_user_path/db" "autolibs" "$rvm_autolibs_flag"
  else
    rvm_error "    Unknown mode '$rvm_autolibs_flag' for autolibs, please read 'rvm autolibs'."
    return 1
  fi

  if [[ -x "${rvm_bin_path}/brew" && -L "${rvm_bin_path}/brew" ]]
  then \command \rm -rf "${rvm_bin_path}/brew"
  fi
)

update_yaml_if_needed()
{
  \typeset yaml_version
  __rvm_db "yaml_version" "yaml_version"
  if
    libyaml_installed &&
    ! __rvm_grep -r "${yaml_version//\./\\.}" "${rvm_usr_path:=$rvm_path/usr}" >/dev/null 2>&1
  then
    __rvm_log_command "update_yaml" \
      "    Updating libyaml in $rvm_usr_path to version $yaml_version, see https://github.com/rvm/rvm/issues/2594 " \
      install_libyaml
  fi
}

record_installation_time()
{
  __rvm_date +%s > $rvm_path/installed.at
  [[ -s "$rvm_path/RELEASE" ]] || echo "manual" > "$rvm_path/RELEASE"
  touch "$rvm_path/config/displayed-notes.txt"
  return 0
}

cleanup_tmp_files()
{
  files=($(
    __rvm_find "$rvm_path/" -mindepth 1 -maxdepth 2 "${name_opt}" '*.swp' -type f
  ))
  if
    (( ${#files[@]} > 0 ))
  then
    rvm_out "    Cleanup any .swp files."
    \command \rm -f  "${files[@]}"
  fi
}

setup_rvm_path_permissions_root()
{
  # ignore if not root
  (( UID == 0 )) || return 0
  chown -R root:"$rvm_group_name" "$rvm_path"

  chmod -R u+rwX,g+rwX,o+rX "$rvm_path"

  if [[ -d "$rvm_path" ]]
  then __rvm_find "$rvm_path" -type d -print0 | __rvm_xargs -n1 -0 chmod g+s
  fi

  chmod -R g-ws "$rvm_path/scripts/zsh" "$rvm_path/scripts/extras/completion.zsh"
}

setup_rvm_path_permissions_check_single()
{
  \typeset __ignore __message __file
  __ignore="$1"
  __message="$2"
  shift 2
  \typeset -a __found
  __rvm_read_lines __found <( "$@" )
  if
    (( ${#__found[@]} > __ignore ))
  then
    permissions_warning "Found ${#__found[@]} ${__message},
use \`--debug\` to see the list, run \`rvmsudo rvm get stable\` to fix it."
    if
      (( ${rvm_debug_flag:-0} ))
    then
      for __file in "${__found[@]}"
      do printf "%b" "        ${__file}\n"
      done
    fi
  fi
}

setup_rvm_path_permissions_check_group()
{
  setup_rvm_path_permissions_check_single 0 "files not belonging to '$rvm_group_name'" \
    __rvm_find "$rvm_path" \! -group "$rvm_group_name"
}

setup_rvm_path_permissions_check_dirs()
{
  setup_rvm_path_permissions_check_single 3 "directories with mode different than '775'" \
    __rvm_find "$rvm_path" -type d \! -perm -2775
}

setup_rvm_path_permissions_check_files()
{
  setup_rvm_path_permissions_check_single 2 "files with mode different than '664' or '775'" \
    __rvm_find "$rvm_path" \! -type d \! -type l \! -perm -775 \! -perm -664
}

print_install_footer()
{
  true ${upgrade_flag:=0}
  \typeset itype profile_file

  if (( upgrade_flag == 0 ))
  then itype=Installation
  else itype=Upgrade
  fi

  if
    (( upgrade_flag == 0 ))
  then
    profile_file="${user_profile_file:-${etc_profile_file:-$rvm_path/scripts/rvm}}"
    rvm_log "$itype of RVM in $rvm_path/ is almost complete:"
    if
      (( ${rvm_user_install_flag:=0} == 0 )) &&
      [[ -z "${rvm_add_users_to_rvm_group:-}" ]]
    then
      rvm_out "
  * First you need to add all users that will be using rvm to '${rvm_group_name}' group,
    and logout - login again, anyone using rvm will be operating with \`umask u=rwx,g=rwx,o=rx\`."
    fi
    rvm_out "
  * To start using RVM you need to run \`source ${profile_file}\`
    in all your open shell windows, in rare cases you need to reopen all shell windows."
  else
    rvm_log "$itype of RVM in $rvm_path/ is complete."
  fi
}

display_notes()
{
  if (( upgrade_flag == 0 ))
  then bash ./scripts/notes initial
  else bash ./scripts/notes upgrade
  fi
}
