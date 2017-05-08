# Powershell scripting challenges

## Setup

This should be run in a Windows 8.1 machine, such as the virtual
machine provided by Microsoft
[here](https://developer.microsoft.com/en-us/microsoft-edge/tools/vms/).

Download the VM, run powershell as administrator, and run:

```
invoke-expression (New-Object System.Net.WebClient).DownloadString("https://github.com/daniel3735928559/wip-ctfs/flag_gen.ps1")
```

## Challenge types

There are the following tasks represented here:

files: 

* Find the largest file in a directory
* Searching through a large set of files for specific content
* Find which files differ between two versions
* Download many files
* Load powershell object from file and read out its contents

eventlog

* Search Windows event log by time
* Search Windows event log for data
* (Reorder events with faked timestamps)

registry

* Search registry for data
* Find programs set to run at system boot time
* Query service descriptions
* Get scheduled tasks

wmi

* Search WMI classes for data
* Get WMI timer events
* Get WMI login events
