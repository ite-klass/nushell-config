# Extends env file (`$nu.env-path` `C:\Users\USER\AppData\Roaming\nushell\env.nu`)
# Sourced there through `source `~\.config\nushell\env.nu``

# Windows Installation path fixup https://github.com/nushell/nushell/issues/13065
$env.NU_PLUGIN_DIRS = ($env.NU_PLUGIN_DIRS | prepend ($nu.current-exe | path dirname))

const cfgpath = '~\.config\nushell'
const nuscriptspath2 = $'($cfgpath)\nu_scripts\modules'

$env.NU_LIB_DIRS = [...$env.NU_LIB_DIRS $nuscriptspath2 ]

def is-old [filepath: path] {
	not ($filepath | path exists) or (ls $filepath | get modified | ($in | length) == 1 and (date now) - $in.0 > 1day)
}
def call-if-old [filepath: path, fn: closure] {
	if (is-old $filepath) {
		print $'Generating ($filepath)…'
		do $fn $filepath
	}
}

mkdir $nu.cache-dir
$nu.vendor-autoload-dirs | last | mkdir $in
$nu.user-autoload-dirs | last | mkdir $in
[
  {
    enabled: true
    path: $'($nu.user-autoload-dirs | last)/starship-init.nu'
    condition: { which starship | is-not-empty }
    command: {|filepath| starship init nu | save -f $filepath }
  }
  {
    enabled: true
    path: $'($nu.user-autoload-dirs | last)/starship-completions.nu'
    condition: { which starship | is-not-empty }
    command: {|filepath| starship completions nushell | save -f $filepath }
  }
  {
    enabled: true
    path: $'($nu.user-autoload-dirs | last)/jj-completions.nu'
    condition: { which jj | is-not-empty }
    command: {|filepath| jj util completion nushell | save -f $filepath }
  }
  {
    enabled: false
    path: $'($nu.cache-dir)/pueue-completions.nu'
    condition: { which pueue | is-not-empty }
    command: {|filepath| pueue completions nushell | save -f $filepath }
  }
  {
    enabled: false
    path: 'config-zoxide.nu'
    condition: { which zoxide | is-not-empty }
    command: {|filepath| zoxide init nushell | save -f $filepath }
  }
] | each {|x| if ($x.enabled and (do $x.condition)) { call-if-old $x.path $x.command } } | ignore
