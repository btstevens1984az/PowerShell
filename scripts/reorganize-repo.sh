#!/usr/bin/env bash
# Repository reorganization script - IT Infrastructure layout
set -euo pipefail
cd /workspace

git_mv() {
    local src="$1"
    local dest="$2"
    if [[ -e "$src" ]]; then
        mkdir -p "$(dirname "$dest")"
        git mv "$src" "$dest"
    fi
}

# Create base structure
BASE_DIRS=(
    docs
    src/Identity-Access/Active-Directory
    src/Identity-Access/User-Accounts
    src/Identity-Access/Permissions
    src/Identity-Access/Group-Policy
    src/Identity-Access/Home-Drives-DFS
    src/Cloud/Azure
    src/Cloud/Microsoft-365
    src/Cloud/Exchange-Online
    src/Cloud/SharePoint-Online
    src/Cloud/OneDrive
    src/Cloud/Teams
    src/Cloud/Intune
    src/Cloud/PowerApps
    src/Cloud/Storage-Accounts
    src/Cloud/Licensing
    src/Cloud/Integrations
    src/Endpoint-Management/SCCM-ConfigMgr
    src/Endpoint-Management/WSUS
    src/Endpoint-Management/Windows-Updates
    src/Endpoint-Management/HP-Radia-HPCA
    src/Endpoint-Management/LANDesk
    src/Deployment/Application-Installers
    src/Deployment/App-Deployment-Toolkit
    src/Deployment/Middleware-Packaging
    src/Deployment/OS-Deployment
    src/Security/Antivirus
    src/Security/McAfee-ePO
    src/Security/BitLocker
    src/Security/Encryption
    src/Security/Certificates
    src/Security/Firewall
    src/Security/Protocol-Hardening
    src/Security/Threat-Intelligence
    src/Security/User-Account-Control
    src/Networking/Diagnostics
    src/Networking/Proxy
    src/Networking/Wake-On-LAN
    src/Storage-FileServices/Disk-Space
    src/Storage-FileServices/File-Management
    src/Storage-FileServices/FSRM-Quotas
    src/Storage-FileServices/Folder-Redirection
    src/Monitoring-Reporting/SCOM
    src/Monitoring-Reporting/Event-Logs
    src/Monitoring-Reporting/Reporting
    src/Monitoring-Reporting/HTML-Reports
    src/Remote-Management/PSRemoting
    src/Remote-Management/PSExec
    src/Infrastructure/SQL-Server
    src/Infrastructure/Registry
    src/Infrastructure/WMI
    src/Infrastructure/Scheduled-Tasks
    src/Infrastructure/Host-Bus-Adapter
    src/Infrastructure/Power-Profiles
    src/Desktop-OperatingSystem/Windows-10
    src/Desktop-OperatingSystem/Computer-Maintenance
    src/Desktop-OperatingSystem/Processes
    src/Desktop-OperatingSystem/NET-Framework
    src/Inventory-Discovery/Computer-Info
    src/General/Scripts
    Modules/Common-Functions
    Tools/GUI-Applications
    Tools/Ping-Tool
    Tools/Disk-Space-GUI
    Snippets/PowerShell-Profiles
    Snippets/ISE-Snippets
    Shared/Error-Handling
    Shared/Logging
    Shared/Parallel-Execution
    Shared/PowerShell-Toolbag
    Shared/Data-Export
    Reference/Certification
    Reference/Learning
    Reference/DevOps
)

for d in "${BASE_DIRS[@]}"; do
    mkdir -p "$d"
done

# --- Documentation ---
git_mv "CODE_OF_CONDUCT.md" "docs/CODE_OF_CONDUCT.md"
git_mv "CONTRIBUTING.md" "docs/CONTRIBUTING.md"
git_mv "SECURITY.md" "docs/SECURITY.md"

# --- Identity & Access ---
git_mv "Active Directory" "src/Identity-Access/Active-Directory/Scripts"
git_mv "Access Control List" "src/Identity-Access/Permissions/Access-Control-List"
git_mv "User Accounts" "src/Identity-Access/User-Accounts/Scripts"
git_mv "Permissions" "src/Identity-Access/Permissions/Scripts"
git_mv "Group Policy" "src/Identity-Access/Group-Policy/Scripts"
git_mv "Home Drives & DFS" "src/Identity-Access/Home-Drives-DFS/Scripts"

# --- Security ---
git_mv "AntiVirus" "src/Security/Antivirus/Scripts"
git_mv "McAfee ePO" "src/Security/McAfee-ePO/Scripts"
git_mv "BitLocker" "src/Security/BitLocker/Scripts"
git_mv "Encryption" "src/Security/Encryption/Scripts"
git_mv "Certs" "src/Security/Certificates/Scripts"
git_mv "Firewall" "src/Security/Firewall/Scripts"
git_mv "Protocols" "src/Security/Protocol-Hardening/Scripts"
git_mv "VirusTotal - API" "src/Security/Threat-Intelligence/VirusTotal-API"
git_mv "User Account Control" "src/Security/User-Account-Control/Scripts"
git_mv "Password Encrypted" "src/Security/Encryption/Password-Encrypted"

# --- Networking ---
git_mv "Networking" "src/Networking/Diagnostics/Scripts"
git_mv "Internet Proxy" "src/Networking/Proxy/Scripts"
git_mv "WakeOnLAN" "src/Networking/Wake-On-LAN/Scripts"
git_mv "Ping-Tool-master" "Tools/Ping-Tool/Ping-Tool-master"

# --- Endpoint Management ---
git_mv "SCCM" "src/Endpoint-Management/SCCM-ConfigMgr/Scripts"
git_mv "WSUS" "src/Endpoint-Management/WSUS/Scripts"
git_mv "Windows Updates" "src/Endpoint-Management/Windows-Updates/Scripts"
git_mv "HP Radia Client Automation" "src/Endpoint-Management/HP-Radia-HPCA/Scripts"
git_mv "LanDesk" "src/Endpoint-Management/LANDesk/Scripts"

# --- Deployment ---
git_mv "Install Applications" "src/Deployment/Application-Installers/Scripts"
git_mv "App Deployment Toolkit" "src/Deployment/App-Deployment-Toolkit/Scripts"
git_mv "Windows 10" "src/Deployment/OS-Deployment/Windows-10"

# --- Storage & File Services ---
git_mv "Disk Space" "src/Storage-FileServices/Disk-Space/Scripts"
git_mv "Files" "src/Storage-FileServices/File-Management/Scripts"
git_mv "Directories" "src/Storage-FileServices/File-Management/Directories"
git_mv "FSRM Quotas" "src/Storage-FileServices/FSRM-Quotas/Scripts"
git_mv "Folder Redirection" "src/Storage-FileServices/Folder-Redirection/Scripts"

# --- Monitoring & Reporting ---
git_mv "SCOM" "src/Monitoring-Reporting/SCOM/Scripts"
git_mv "Event Logs" "src/Monitoring-Reporting/Event-Logs/Scripts"
git_mv "Events" "src/Monitoring-Reporting/Event-Logs/Events"
git_mv "Reporting" "src/Monitoring-Reporting/Reporting/Scripts"
git_mv "HTML" "src/Monitoring-Reporting/HTML-Reports/Scripts"
git_mv "Excel Future Project" "src/Monitoring-Reporting/Reporting/Excel-Reports"

# --- Remote Management ---
git_mv "PSRemoting" "src/Remote-Management/PSRemoting/Scripts"
git_mv "PSExec" "src/Remote-Management/PSExec/Scripts"

# --- Infrastructure ---
git_mv "SQL" "src/Infrastructure/SQL-Server/Scripts"
git_mv "Registry" "src/Infrastructure/Registry/Scripts"
git_mv "WMI" "src/Infrastructure/WMI/Scripts"
git_mv "Scheduled Tasks" "src/Infrastructure/Scheduled-Tasks/Scripts"
git_mv "Host Bus Adapter" "src/Infrastructure/Host-Bus-Adapter/Scripts"
git_mv "Power Profiles" "src/Infrastructure/Power-Profiles/Scripts"

# --- Desktop OS ---
git_mv "Computer Chores" "src/Desktop-OperatingSystem/Computer-Maintenance/Scripts"
git_mv "Computer Info" "src/Inventory-Discovery/Computer-Info/Scripts"
git_mv "Processes" "src/Desktop-OperatingSystem/Processes/Scripts"
git_mv "NET Framework" "src/Desktop-OperatingSystem/NET-Framework/Scripts"

# --- Shared utilities ---
git_mv "Error Handling" "Shared/Error-Handling/Scripts"
git_mv "Logging" "Shared/Logging/Scripts"
git_mv "Parallel" "Shared/Parallel-Execution/Scripts"
git_mv "PowerShell Toolbag" "Shared/PowerShell-Toolbag/Scripts"
git_mv "XML" "Shared/Data-Export/Scripts"

# --- Tools & GUI ---
git_mv "Forms" "Tools/GUI-Applications/Forms"
git_mv "Get-ServicesXAMLGUI.ps1" "Tools/GUI-Applications/Get-ServicesXAMLGUI.ps1"

# --- Reference ---
git_mv "AZ-300 Microsoft Azure Solutions Architect Questions & Answers" "Reference/Certification/AZ-300-Azure-Solutions-Architect"
git_mv "TeamCity" "Reference/DevOps/TeamCity"

# --- Azure-O365 Functions ---
git_mv "Azure-O365 Functions/SharePointOnline" "src/Cloud/SharePoint-Online/Scripts"
git_mv "Azure-O365 Functions/HTML Reports" "src/Monitoring-Reporting/HTML-Reports/Azure-O365"
git_mv "Azure-O365 Functions/Storage Accounts" "src/Cloud/Storage-Accounts/Scripts"
git_mv "Azure-O365 Functions/OneDrive" "src/Cloud/OneDrive/Scripts"
git_mv "Azure-O365 Functions/Teams" "src/Cloud/Teams/Scripts"
git_mv "Azure-O365 Functions/PowerApps" "src/Cloud/PowerApps/Scripts"
git_mv "Azure-O365 Functions/Import CSV for SQL Table" "src/Infrastructure/SQL-Server/Import-CSV"
git_mv "Azure-O365 Functions/Jira" "src/Cloud/Integrations/Jira"
git_mv "Azure-O365 Functions/Web-API" "src/Cloud/Integrations/Web-API"
git_mv "Azure-O365 Functions/Exchange Online" "src/Cloud/Exchange-Online/Scripts"
git_mv "Azure-O365 Functions/Azure Licensing" "src/Cloud/Licensing/Scripts"
git_mv "Azure-O365 Functions/Intune Scripts" "src/Cloud/Intune/Scripts"
git_mv "Azure-O365 Functions/PSProfiles" "Snippets/PowerShell-Profiles/Azure-O365"
git_mv "Azure-O365 Functions/Log Scripts" "Shared/Logging/Azure-O365"
git_mv "Azure-O365 Functions/PowerShell Random" "src/Cloud/Microsoft-365/PowerShell-Random"
git_mv "Azure-O365 Functions/Azure Random" "src/Cloud/Azure/Scripts-Random"
git_mv "Azure-O365 Functions/Office365-Random" "src/Cloud/Microsoft-365/Office365-Random"

# Remove empty Azure-O365 Functions folder if empty
rmdir "Azure-O365 Functions" 2>/dev/null || true

# --- Random subfolders ---
git_mv "Random/Functions" "Modules/Common-Functions/Enterprise-Functions"
git_mv "Random/FolderandFileFunctions" "Modules/Common-Functions/Folder-and-File"
git_mv "Random/GUI Based" "Tools/GUI-Applications/Random-GUI"
git_mv "Random/AzureAD" "src/Cloud/Azure/Active-Directory"
git_mv "Random/Azure" "src/Cloud/Azure/Scripts"
git_mv "Random/O365" "src/Cloud/Microsoft-365/O365"
git_mv "Random/PowerShell O365" "src/Cloud/Microsoft-365/PowerShell-O365"
git_mv "Random/Outlook Online" "src/Cloud/Exchange-Online/Outlook-Online"
git_mv "Random/Middleware" "src/Deployment/Middleware-Packaging/Scripts"
git_mv "Random/PowerShell Profile" "Snippets/PowerShell-Profiles/Random"
git_mv "Random/PSRepository" "Reference/Learning/PSRepository"
git_mv "Random/FireWall Fix" "src/Security/Firewall/Firewall-Fix"
git_mv "Random/Excel Files" "src/Monitoring-Reporting/Reporting/Excel-Files"

echo "Top-level and Random subfolder migration complete."
