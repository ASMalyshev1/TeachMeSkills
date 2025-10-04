Clear-Host
Set-Location $PSScriptRoot

$gl = (Get-Location).Path

# Установить Yandex Cloud Cli если не установлен
$cliInstallPath = Join-Path $home "yandex-cloud"
if(-not (Test-Path $cliInstallPath)){
    iex (New-Object System.Net.WebClient).DownloadString('https://storage.yandexcloud.net/yandexcloud-yc/install.ps1')
}

# Создайте авторизованный ключ для сервисного аккаунта
yc iam key create --output key.json --service-account-name my-service-account


yc iam service-accounts list


Set-Location -Path '.\infra\terraform'

& .\terraform.exe plan
