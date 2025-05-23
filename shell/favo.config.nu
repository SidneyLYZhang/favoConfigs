# ENVIRONMENT
$env.Path = ($env.Path | append '\WorkPlace\...\dosync')

# Function
#### 你能信？普通公司也要高压内部数据安全……
def usefull [
    name:string,
    --sync(-s)] {
    if ($name == "up") {
        python '\...\decompression.py'
        if ($sync) {
            pwsh -noprofile -c 'Start-Process -WindowStyle Hidden -WorkingDirectory "\WorkPlace\...\dosync" ".\syncthing.exe"'
        }
    } else if ($name == "down") {
        if ($sync) {
            rm -f -r '\WorkPlace\...\dosync'
            rm -f -r '\WorkPlace\...\vback'
        } else {
            python '\...\compression.py'
        }
        history -c
    } else {
        print ("For what?")
    }
}

#### 快速设置软链接
def setsymlink [
    name:string,
    target:string] {
        let doing = $'New-Item ($name) -ItemType SymbolicLink -Target "($target)"' 
        pwsh -c $doing
}

#### Scoop检查并更新
def checkscoop [] {
    scoop update
    let xx = (scoop status | str contains "Everything is ok!")
    if ($xx) {
        $"(ansi purple_bold)Everything of scoop is ok!(ansi reset)"
    } else {
        sudo scoop update -a -g
    }
}

#### 更新工具-经常很久才用一次
def updatetools [] {
    rustup update
    cargo install-update --all
    pipx upgrade-all
}

#### 快速设置或取消设置代理
def setconfig [
    name:string,
    --unset(-u)
] {
    if ($name == "git") {
        if ($unset) {
            git config --global --unset http.proxy
        } else {
            git config --global http.proxy http://127.0.0.1:2334
        }
        print ("Done!")
    } else if ($name == "scoop") {
        if ($unset) {
            scoop config rm proxy
        } else {
            scoop config proxy 127.0.0.1:2334
        }
        print ("Done!")
    } else {
        print ("Are you CRAZY?")
    }
}

#### 快速git push
def gitquick [
    commits:string = "auto",
    --old(-o)
] {
    git add -A
    if ($commits == "auto") {
        oco
    } else if ($commits == "date") {
        let dnow = date now | format date '%Y-%m-%d'
        git commit -m $dnow
        if ($old) {
            git push -u origin master
        } else {
            git push -u origin main
        }
    }  else {
        git commit -m $commits
        if ($old) {
            git push -u origin master
        } else {
            git push -u origin main
        }
    }
}

#### 数据加密同步
def "syncdata push" [
    folder:string,
    --usexfile(-x)
] {
    if ($usexfile) {
        restic -r rclone:obs:wkup --verbose backup $folder --exclude-file=excludes.txt
    } else {
        restic -r rclone:obs:wkup --verbose backup $folder
    }
}

def "syncdata pull" [
    name:string,
    tofolder:string
] {
    restic -r rclone:obs:wkup restore $name --target $tofolder
}

def "syncdata ls" [
    name?:string
] {
    if ($name == null) {
        restic -r rclone:obs:wkup snapshots
    } else {
        restic -r rclone:obs:wkup ls $name
    }
}

def "syncdata rm" [
    name?:string
] {
    if ($name == null) {
        restic -r rclone:obs:wkup forget --keep-monthly 1 --prune
    } else {
        restic -r rclone:obs:wkup forget $name --prune 
    }
}

def syncdata [] {
    print ("`push` `pull` `ls` `rm` is all your need...")
    restic version
    rclone --version
    print ("DOC : https://restic.readthedocs.io/en/stable/index.html")
}

#### 快速打开文件夹

# 打开代码文件夹
def "qopen code" [] {
    explorer 'E:\WorkPlace\00_Coding'
}

# 打开下载文件夹
def "qopen download" [] {
    explorer 'D:\Downloads'
}

# 打开YouTube月报文件夹
def "qopen youtube" [
    ziel:string = "data" # 目标文件夹[data，Report]，不使用这两个名称，则打开主文件夹
] {
    let lmonth = date now | format date "%Y-%m-01" | into datetime | $in - 1day | format date "%Y%m"
    let keypath = "E:\\WorkPlace\\01_WORKING\\03_YouTube"
    if ($ziel in ["data" "Report"]) {
        explorer ([$keypath $ziel $lmonth] | path join)
    } else {
        explorer 'E:\WorkPlace\01_WORKING\03_YouTube\'
    }
}

# 打开结算文件夹
def "qopen jiesuan" [
    ziel:string = "y2b" # 目标文件夹[y2b，YSP，steam，epic]，不使用这两个名称，则打开主文件夹
    --ok(-o) # 直接打开结果文件夹
] {
    let lmonth = date now | format date "%Y-%m-01" | into datetime | $in - 1day | format date "%Y%m"
    let tmonth = date now | format date "%Y%m"
    let keypath = "E:\\WorkPlace\\01_WORKING\\04_Settlements"
    if ($ziel in ["y2b" "YSP"]) {
        if ($ziel == "y2b") {
            if ($ok) {
                explorer ([$keypath "data" $lmonth] | path join)
            } else {
                explorer ([$keypath "data" "YouTube" $lmonth] | path join)
            }
        } else {
            if ($ok) {
                explorer ([$keypath "央视频" $tmonth] | path join)
            } else {
                explorer ([$keypath "央视频"] | path join)
            }
        }
    } else if ($ziel in ["steam" "epic"]) {
        explorer ([$keypath "data" ($ziel | str capitalize)] | path join)
    } else {
        explorer 'E:\WorkPlace\01_WORKING\04_Settlements'
    }
}

# 常用文件夹快捷打开工具
def qopen [
    --info(-i) # 展示信息
] {
    if ($info) {
        print ("qopen ::")
        print ("\t -> `qopen` | 打开当前文件夹")
        print ("\t -> `qopen code` | 打开代码文件夹")
        print ("\t -> `qopen download` | 打开下载文件夹")
        print ("\t -> `qopen jiesuan [y2b，YSP，steam，epic]` | 打开结算工作文件夹")
        print ("\t -> `qopen youtube [data,Report,null]` | 打开当月youtube月报文件夹")
        print ("\t -> `qopen --help` | 显示帮助")
        print ("\t -> `qopen --info(-i)` | 显示基本信息")
        print ("\n Version 20250416 (C) SidneyZhang<zly@lyzhang.me>")
    } else {
        explorer '.'
    }
}

# quickly change Path

alias work = cd 'E:\WorkPlace\01_Working'
alias coding = cd 'E:\WorkPlace\00_Coding'
alias appdata = cd 'C:\Users\<you>\AppData'

# Alias

alias weeknum = print (date now | format date '%W')
alias setvenv = overlay use .venv\Scripts\activate.nu
alias unsetvenv = deactivate