# ==============================================================================
# YkOs VirtualBox VM Creation and Setup Script
# ==============================================================================

$vboxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$vmName = "YkOs"
$diskPath = "C:\Users\Lenovo\Desktop\YkOs\YkOs-disk.vmdk"

if (-not (Test-Path $vboxManage)) {
    Write-Host "[ERROR] Oracle VirtualBox executable not found: $vboxManage" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $diskPath)) {
    Write-Host "[ERROR] YkOs virtual disk image not found: $diskPath" -ForegroundColor Red
    exit 1
}

Write-Host "[*] Registering and configuring '$vmName' VM in VirtualBox..." -ForegroundColor Cyan

# Check if VM already registered
$existing = & $vboxManage list vms | Select-String "`"$vmName`""
if ($existing) {
    Write-Host "[!] A virtual machine named '$vmName' is already registered." -ForegroundColor Yellow
} else {
    # 1. Create and Register VM
    & $vboxManage createvm --name $vmName --ostype "Ubuntu_64" --register

    # 2. Configure Hardware (1GB RAM, 1 vCPU, 16MB VRAM, VMSVGA Graphics)
    & $vboxManage modifyvm $vmName --memory 1024 --cpus 1 --vram 16 --graphicscontroller vmsvga --boot1 disk --boot2 none --boot3 none --boot4 none

    # 3. Configure Network (NatNetwork for isolated lab subnet)
    & $vboxManage modifyvm $vmName --nic1 natnetwork --nat-network1 "NatNetwork" --cableconnected1 on

    # 4. Add Storage Controller (SATA AHCI)
    & $vboxManage storagectl $vmName --name "SATA" --add sata --controller IntelAhci --bootable on

    # 5. Attach Preconfigured YkOs Virtual Disk
    & $vboxManage storageattach $vmName --storagectl "SATA" --port 0 --device 0 --type hdd --medium $diskPath

    Write-Host "[+] Virtual machine '$vmName' has been created and registered successfully!" -ForegroundColor Green
}

Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "YkOs Virtual Machine is Ready to Run!" -ForegroundColor Green
Write-Host "You can find 'YkOs' listed in the VirtualBox Manager GUI." -ForegroundColor White
Write-Host "To launch, click 'Start' in VirtualBox or run 'YkOs-Start.bat'." -ForegroundColor White
Write-Host "========================================================`n" -ForegroundColor Cyan
