# Prevent Windows from opening Wordpad when accidentally writing `write` instead of `save`
alias write = print 'Did you mean to write `save`?'

alias te = table -e

alias ll = ls -al
# latest GitHub release - repo form: account/repo
def "gh latest" [repo: string] { http head $'https://github.com/($repo)/releases/latest/' --redirect-mode manual | where name == location | get value.0 | path split | last }
def "ss status" [] { sudo sc query SunshineService }
def "ss start" [] { sudo sc start SunshineService }
def "ss stop" [] { sudo sc stop SunshineService }
alias ss = ss status

# Shorts
## Native
def e [...args] { ^($env.EDITOR) ...$args }
## Scripts and Plugins
alias c = task spawn { code . }
alias p = pueue
alias t = task
# ISSUE: Command 'task' not found
def s [...args] { task spawn { $args } }
## Apps
alias gi = `gitui`
alias nb = dotnet build --nologo
alias np = dotnet publish --nologo
def "np win" [...args] { np --os win ...$args }
def "np lin" [...args] { np --os linux ...$args }
def "np linux" [...args] { np --os linux ...$args }
alias f = filemeta

# editors (text)
#alias edit = `C:\Program Files\Notepad++\Notepad++.exe`
#alias edit = `C:\Program Files\Vim\vim90\vim.exe`
alias vim = `C:\Program Files\Vim\vim90\vim.exe`
#def vim [...args] { ^`C:\Program Files\Vim\vim90\vim.exe` $args }

#alias code = $'($env.USERPROFILE)\AppData\Local\Programs\Microsoft VS Code\Code.exe'
#def code [...args] { ^$'($env.USERPROFILE)\AppData\Local\Programs\Microsoft VS Code\Code.exe` ($args | str join " ") }

# winget
alias up = winget upgrade
def ups [...name: string] {
  if ($name | is-empty) { winget upgrade; return }
  for $n in $name {
    winget upgrade $n
  }
}

def "ups dotnet-tools" [] {
	dotnet tool update --global --all
}

# yt-dlp
alias dl = yt-dlp
alias dlup = yt-dlp --update
alias dlm = yt-dlp -f 251
# Download highest quality Opus audio as/into .opus file
def "dl opus" [...params: string, url: string] {
	dl --extract-audio --audio-quality 0 --audio-format opus $"($url)"
}
# Download highest quality Opus audio as/into .opus file with cookies from Firefox
def "dl opus firefox" [url: string] {
	dl --extract-audio --audio-quality 0 --audio-format opus --cookies-from-browser firefox $url
}
# Download [YouTube] video with SponsorBlock chapters
def "dl yt" [url: string] {
	dl --sponsorblock-mark all $"($url)"
}
# Download [YouTube] video with SponsorBlock chapters with cookies from Firefox
def "dl yt firefox" [url: string] {
	dl --sponsorblock-mark all --cookies-from-browser firefox $"($url)"
}
# Download video with cookies from Firefox and save it to a titled filename
def "dl firefox titled" [title: string, url: string] {
	dl --cookies-from-browser firefox --output $"($title) %(title)s [%(id)s].%(ext)s" $"($url)"
}

# ffmpeg
alias ff = ffmpeg -hide_banner
alias fp = ffprobe -hide_banner
#old-alias ffweb = ff -i $1 -map_chapters -1 -map 0:v -map 0:a -c:v libsvtav1 -pix_fmt yuv420p10le -c:a libopus $2
# 10-bit x265 mkv
def "ff 10" [filepath: path] {
    let target = ($filepath | path parse | update stem {|x| $"($x.stem)_10-bit-x265"} | update extension "mkv" | path join)
    ff -i $filepath -c:a libopus -c:v libx265 -pix_fmt yuv420p10le $target
}
# 10-bit av1 opus webm
def "ff webm" [filepath: path] {
    let target = ($filepath | path parse | update extension "webm" | path join)
    ff -i $filepath -c:a libopus -c:v libsvtav1 -pix_fmt yuv420p10le $target
}
# alias for ff webm
def "ff web" [filepath: path] {
    ff webm $filepath
}
# 8-bit x264 mp4
def "ff mp4" [filepath: path] {
    let target = ($filepath | path parse | update stem {|x| $"($x.stem)_x264"} | update extension "mp4" | path join)
    ff -i $filepath -c:a aac -c:v libx264 -pix_fmt yuv420p $target
}

def "nu conf diff" [] {
  let defaults = nu -n -c "$env.config = {}; $env.config | reject color_config keybindings menus | to nuon" | from nuon | transpose key default
  let current = $env.config | reject color_config keybindings menus | transpose key current
  $current | merge $defaults | where $it.current != $it.default
}
