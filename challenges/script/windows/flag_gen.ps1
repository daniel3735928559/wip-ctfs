# The flags

$i = 0;
$flags = @(
"pqieuwrlnkasjncfoqerpqiurnkqjnhr",
"wqleuhfnweufcnqlwiercaswefw12rslncaw",
"qwlekunhclajfncwgnlaifnclakjnhfcoqwuef",
"alweunhrxlwienrclkjshfociweunfcalkefnc",
"fqlwienxpwqienakjefpniwenfxwen",
"askjdfnuernhflxiaseflaiefnpx",
"erwjfmlaijenfcaliefnclaiuwenhfkucawfe",
"lyuerhufcnkasunhfcauewaei324ro7q834p23",
"slekkncdlawekjfncawieurpcq34r",
"skdjcnwaiernclaksdjlnfckaaawnlcakiuer834rclnaweic",
"lwaaalnecnapneqory8c73y4ernkicnewwhsacusnzrpaie"
)


# Generate random strings

function RandStr($l = (Get-Random -minimum 10 -maximum 50)){
  [Convert]::ToBase64String((1..$l | %{Get-Random -minimum 0 -maximum 255}))
}


# Write flag to event log, conjugating by "set the time to 1990"

$flag = $flags[$i++]
$src = "LIUq8wliwue"
New-EventLog -LogName Application -Source $src
1..77 | %{Write-EventLog -LogName Application -Source $src -EntryType Information -EventId 1 -Message (RandStr)}
$x=(Get-Date)
Set-Date "01/02/1990 12:00:01 AM"
Write-EventLog -LogName Application -Source $src -EntryType Information -EventId 1 -Message $flag
Set-Date $x
1..110 | %{Write-EventLog -LogName Application -Source $src -EntryType Information -EventId 1 -Message (RandStr)}


# Write flag to event log among random data

$flag = $flags[$i++]
$src = "lewqiucwlbe"
New-EventLog -LogName Application -Source $src
1..65 | %{Write-EventLog -LogName Application -Source $src -EntryType Information -EventId 1 -Message (RandStr)}
Write-EventLog -LogName Application -Source $src -EntryType Information -EventId 1 -Message "flag{$flag}"
1..180 | %{Write-EventLog -LogName Application -Source $src -EntryType Information -EventId 1 -Message (RandStr)}


# Write flag to registry

$flag = $flags[$i++]
1..100 | %{$p="HKCU:\Software\POSHCTF\$_"; New-Item $p -Force; 1..10 | %{New-ItemProperty $p -Name "$p\$_" -Value (RandStr)}}
Set-ItemProperty "HKCU:\Software\POSHCTF\43" -Name "HKCU:\Software\POSHCTF\43\10" -Value "flag{$flag}"


# Write flag to a WMI class

$flag = $flags[$i++]
$name = "DaBoss"
$server=[adsi]"WinNT://$env:computername"
$user=$server.Create("User","$name")
$password = "SEEKRITPASSWOORD"
$user.SetPassword($password)
$user.SetInfo()
$user.Put('Description',"flag{$flag}")
$flag=$user.UserFlags.Value -bor 0x800000
$user.put('userflags',$flag)
$user.SetInfo()
$group=[adsi]"WinNT://$env:computername/Users,Group"
$group.Add($user.path)

# Add random WMI event handlers

$evfs = 1..11
1..3+5..10  | %{ $evfs[$_] = Set-WmiInstance -Class __EventFilter -NameSpace "root\subscription" -Arguments @{Name="EvFilter$_"; EventNameSpace="root\cimv2"; QueryLanguage="WQL"; Query="SELECT * FROM metaclass WHERE __this ISA 'Win32_BaseService'"}}

# Add random WMI consumers/bindings

1..67 | %{
$wec = Set-WmiInstance -Class CommandLineEventConsumer -Namespace "root\subscription" -Arguments @{Name="Consumer$_"; ExecutablePath = "C:\windows\$(RandStr).exe"; CommandLineTemplate = "C:\windows\$(RandStr).exe"}
Set-WmiInstance -Class __FilterToConsumerBinding -Namespace "root\subscription" -Arguments @{Consumer=$wec; Filter=$evfs[(Get-Random -minimum 5 -maximum 10)]}
}

# Add WMI Scheduled event

$flag = $flags[$i++]
$query = "SELECT * FROM __InstanceModificationEvent WHERE TargetInstance ISA
            'Win32_LocalTime' AND TargetInstance.Year=3000
                              AND TargetInstance.Month=1
                              AND TargetInstance.Day=1
                              AND TargetInstance.Hour=0
                              AND TargetInstance.Minute=0
                              AND TargetInstance.Second=0"

$WMIEventFilter = Set-WmiInstance -Class __EventFilter -NameSpace "root\subscription" -Arguments @{Name="FlagFilter"; EventNameSpace="root\cimv2"; QueryLanguage="WQL"; Query=$query}

$cmd = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes("echo $flag >> c:\windows\flag.txt"));
$WMIEventConsumer = Set-WmiInstance -Class CommandLineEventConsumer `
    -Namespace "root\subscription" `
    -Arguments @{Name="FlagConsumer";
                 ExecutablePath = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe";
                 CommandLineTemplate ="C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -NoProfile -EncodedCommand $cmd"}

Set-WmiInstance -Class __FilterToConsumerBinding `
                -Namespace "root\subscription" `
                -Arguments @{Filter=$WMIEventFilter; Consumer=$WMIEventConsumer}

# Add more random WMI bindings

1..6 | %{
$wec = Set-WmiInstance -Class CommandLineEventConsumer -Namespace "root\subscription" -Arguments @{Name="Consumer$(67+$_)"; ExecutablePath = "C:\windows\$(RandStr).exe"; CommandLineTemplate = "C:\windows\$(RandStr).exe"}
Set-WmiInstance -Class __FilterToConsumerBinding -Namespace "root\subscription" -Arguments @{Consumer=$wec; Filter=$evfs[(Get-Random 1,2,3,5,6,7,8,9)]}
}


# Add WMI Logon events


$flag = $flags[$i++]
$query = "SELECT * FROM __InstanceCreationEvent WITHIN 15 WHERE TargetInstance ISA 'Win32_LogonSession' AND TargetInstance.LogonType = 2"
$WMIEventFilter = Set-WmiInstance -Class __EventFilter -NameSpace "root\subscription" -Arguments @{Name="EvFilter4";EventNameSpace="root\cimv2";QueryLanguage="WQL";Query=$Query} -ErrorAction Stop
$WMIEventConsumer = Set-WmiInstance -Class CommandLineEventConsumer -Namespace "root\subscription" -Arguments @{Name="Consumer74";ExecutablePath="C:\Windows\system32\$flag.exe";CommandLineTemplate="C:\Windows\system32\$flag.exe"}
Set-WmiInstance -Class __FilterToConsumerBinding -Namespace "root\subscription" -Arguments @{Filter=$WMIEventFilter;Consumer=$WMIEventConsumer}

# Add more random WMI bindings

1..25 | %{
$wec = Set-WmiInstance -Class CommandLineEventConsumer -Namespace "root\subscription" -Arguments @{Name="Consumer$(74+$_)"; ExecutablePath = "C:\windows\$(RandStr).exe"; CommandLineTemplate = "C:\windows\$(RandStr).exe"}
Set-WmiInstance -Class __FilterToConsumerBinding -Namespace "root\subscription" -Arguments @{Comsumer=$wec; Filter=$evfs[(Get-Random 1,2,3,5,6,7,8,9)]}
}


# Set IPv6 address

$flag = "fe80::f1a6:dead:beef"
echo "New-NetIPAddress -InterfaceIndex 2 -IPAddress $flag" > C:\Windows\smac.ps1
$trigger = New-JobTrigger -AtStartup -RandomDelay 00:00:50
Register-ScheduledJob -Trigger $trigger -FilePath C:\Windows\smac.ps1 -Name MAC


# Set a program to run at boot

$flag = $flags[$i++]
$trigger = New-JobTrigger -AtStartup -RandomDelay 00:00:30
echo "echo hello" > c:\windows\startup_flag.ps1
Register-ScheduledJob -Trigger $trigger -FilePath "C:\windows\startup_flag.ps1" -Name "flag{$flag}"


# Schedule a task to run at a certain time

$flag = $flags[$i++]
Register-ScheduledTask -Action (New-ScheduledTaskAction -Execute "C:\Windows\system32\$flag.exe") -Trigger (New-ScheduledTaskTrigger -Daily -At 1am) -TaskName "Flag" -Description "Yay you found the flag"


# Add a service

$flag = $flags[$i++]
New-Service -Name "FlagService" -BinaryPathName "C:\WINDOWS\System32\svchost.exe -k netsvcs" -DisplayName "At Your Service" -StartupType Automatic -Description "flag{$flag}"


# Put a tag on an existing service

$flag = $flags[$i++]
Set-Service -Name "WSearch" -Description "flag{$flag}"


# Write flags to a file

$flag = $flags[$i++]
$x = New-Object -TypeName System.Object
1..76 | %{$x | Add-Member -MemberType NoteProperty -Name (RandStr) -Value (RandStr)}
$x | Add-Member -MemberType NoteProperty -Name (RandStr) -Value "flag{$flag}"
1..202 | %{$x | Add-Member -MemberType NoteProperty -Name (RandStr) -Value (RandStr)}
$x | Export-Clixml c:\o.xml

# Write number to a file

$flag = 31047867
$tot = 0
$x = New-Object -TypeName System.Object
1..300 | %{$y = (Get-Random -minimum 0 -maximum 99999); $tot += $y; $x | Add-Member -MemberType NoteProperty -Name (RandStr) -Value $y}
$x | Add-Member -MemberType NoteProperty -Name (RandStr) -Value ($flag - $tot)
$x | Export-Clixml c:\n.xml
