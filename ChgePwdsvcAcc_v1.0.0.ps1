<#

<#PSScriptInfo

.VERSION 1.1


.AUTHOR : Serge DOKPO

.COMPANYNAME: GRDF

.COPYRIGHT (c) GRDF 2024

.MOTS CLÉS : service ; account ; password

.DESCRIPTION : Ce scrit permet de changer le mot de passe d'un compte de service, de manière intéractive .


#>


# Fonction pour enregistrer les logs
function Write-Log {
    Param (
        [string]$message
    )
    $scriptPath = $PSCommandPath
    $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($scriptPath)
    $logFileName = "$scriptName`_log.txt"
    $logFile = Join-Path (Split-Path -Parent $scriptPath) $logFileName
    $timeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timeStamp - $message" | Out-File -FilePath $logFile -Append
}

# Demande du nom du compte de service
$accountName = Read-Host "Entrez le nom du compte de service à reinitialiser"

# Vérification de l'existence du compte
if (-not (Get-ADUser -Filter { SamAccountName -eq $accountName })) {
    Write-Log "Le compte $accountName n'existe pas."
    exit
}

# Demande du mot de passe actuel (stocké de façon sécurisée)
$currentPassword = Read-Host "Entrez le mot de passe actuel du compte de service" -AsSecureString

# Demande du nouveau mot de passe et sa confirmation
$newPassword = Read-Host "Entrez le nouveau mot de passe" -AsSecureString
$confirmPassword = Read-Host "Confirmez le nouveau mot de passe" -AsSecureString

# Changement du mot de passe dans AD
try {
    Set-ADAccountPassword -Identity $accountName -OldPassword $currentPassword -NewPassword $newPassword
    Write-Log "Le mot de passe a ete change avec succès pour le compte $accountName."
} catch {
    Write-Log "Erreur lors du changement du mot de passe pour le compte $accountName."
}

# Suppression des variables de mot de passe pour la sécurité
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR([Runtime.InteropServices.Marshal]::SecureStringToBSTR($currentPassword))
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR([Runtime.InteropServices.Marshal]::SecureStringToBSTR($newPassword))
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR([Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirmPassword))