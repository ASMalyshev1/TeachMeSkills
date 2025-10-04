Clear-Host
Set-Location $PSScriptRoot

$gl = (Get-Location).Path

# Установить Yandex Cloud (CLI) если не установлен
$cliInstallPath = Join-Path $home "yandex-cloud"
if(-not (Test-Path $cliInstallPath)){
    iex (New-Object System.Net.WebClient).DownloadString('https://storage.yandexcloud.net/yandexcloud-yc/install.ps1')
} else {
    Start-Process yc -ArgumentList 'components update' -ErrorAction Continue
}

yc config set token $(Get-Content -Path .\infra\yc\OAuth.txt)
if($(yc config list) -eq '{}'){
    Start-Process cmd -ArgumentList "/c yc init"
}
yc config list
yc vpc network list
yc vpc network list --format yaml

# Создайте авторизованный ключ для сервисного аккаунта
#yc iam key create --output key.json --service-account-name my-service-account
#yc iam service-accounts list

# Создаем сервисного аккаунта для terraform
$saName = 'sa-terraform'
yc iam service-account create --name $saName
$saData = yc iam service-accounts list --format json|ConvertFrom-Json|Where-Object {$_.Name -eq $saName}

# Назначть сервисному аккаунту роль на ресурс:
yc resource-manager folder add-access-binding $($saData.folder_id) --role editor --subject serviceAccount:$($saData.id)

$Env:YC_TOKEN=$(yc iam create-token --impersonate-service-account-id $($saData.id))
$Env:YC_CLOUD_ID=$(yc config get cloud-id)
$Env:YC_FOLDER_ID=$(yc config get folder-id)

Set-Location -Path '.\infra\terraform'

& .\terraform.exe plan
