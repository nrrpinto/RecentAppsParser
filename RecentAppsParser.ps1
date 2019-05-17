$OS = ((Get-WmiObject win32_operatingsystem).name).split(" ")[2] <# Intead of collecting the windows version: XP, Vista, 7, 10, ... should be according to the core #>
$SIDS = Get-ChildItem "REGISTRY::HKEY_USERS" | ForEach-Object { ($_.Name).Split("\")[1] } # list of user SIDs

if($OS -eq "10")
{
    foreach($SID in $SIDS)
    {
        if ($SID.Split("-")[7] -ne $null -and $SID.Split("-")[7] -notlike "*_Classes") # the ones that users removes the system and network and classes
        {
            $N = Get-ItemPropertyValue -Path "REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$SID\" -Name "ProfileImagePath"  # get's the name correspondent to the SID
            $NAME = $($N.Split("\")[2])

            Write-Host "[+] Collecting Recent Apps info from $NAME" -ForegroundColor Green

            $RA_SID = Get-ChildItem "REGISTRY::HKEY_USERS\$SID\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps\" | Select-Object -ExpandProperty Name | foreach { $_.split("\")[8] }

            foreach($R in $RA_SID)
            {
                echo "---------------------------------------------------"
                echo "---------------------------------------------------"
                echo "SID: $R"
                $tempAppId = Get-ItemPropertyValue "REGISTRY::HKEY_USERS\$SID\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps\$R" -Name AppId
                echo "AppID: $tempAppId"
                $tempLaunchCount = Get-ItemPropertyValue "REGISTRY::HKEY_USERS\$SID\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps\$R" -Name LaunchCount
                echo "LaunchCount: $tempLaunchCount"
                $tempAppPath = Get-ItemPropertyValue "REGISTRY::HKEY_USERS\$SID\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps\$R" -Name AppPath
                echo "AppPath: $tempAppPath"
                $tempDateDec = Get-ItemPropertyValue "REGISTRY::HKEY_USERS\$SID\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps\$R"-Name LastAccessedTime
                $tempDate = [datetime]::FromFileTime($tempDateDec)
                echo "Date: $tempDate"
            
                echo "--- Associated Files:"
            
                if(Test-Path "REGISTRY::HKEY_USERS\$SID\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps\$R\RecentItems")
                {
                    $FILE_SID = Get-ChildItem "REGISTRY::HKEY_USERS\$SID\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps\$R\RecentItems\" | Select-Object -ExpandProperty Name | foreach { $_.split("\")[10] }

                    foreach($F in $FILE_SID)
                    {
                        $tempName = Get-ItemPropertyValue "REGISTRY::HKEY_USERS\$SID\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps\$R\RecentItems\$F" -Name DisplayName
                        echo "`tName: $tempName"
                        $tempPath = Get-ItemPropertyValue "REGISTRY::HKEY_USERS\$SID\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps\$R\RecentItems\$F" -Name Path
                        echo "`tPath: $tempPath"
                        $tempDateDec = Get-ItemPropertyValue "REGISTRY::HKEY_USERS\$SID\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps\$R\RecentItems\$F" -Name LastAccessedTime
                        $tempDate = [datetime]::FromFileTime($tempDateDec)
                        echo "`tDate: $tempDate"
                    }
                }
                else
                {
                    echo "`tThis app doesn't have recent open files associated."
                }
            }
        }
    }
}
else
{
    Write-Host "It only works in windows 10" -ForegroundColor Red
}