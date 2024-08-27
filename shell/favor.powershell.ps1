Invoke-Expression (&starship init powershell)

function coding {
    set-location -Path ...\00_CODING\
}

function work {
    set-location -Path ...\01_WORKING\
}

function myplace {
    Set-Location -Path ...\WorkPlace\
}

function appdate {
    Set-Location -Path C:\Users\<you>\AppData\
}

function gitquick {
    param (
        [string]$commitText,
        [switch]$older
    )
    process{
        git add -A
        git commit -m $commitText
        if ($older) {
            git push -u origin master
        } else {
            git push -u origin main
        }
    }
}

Set-Alias -Name setvenv -Value .venv\Scripts\activate.ps1