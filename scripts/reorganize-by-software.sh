#!/usr/bin/env bash
# Flatten domain-based layout into software-first folders under src/
set -euo pipefail
cd /workspace

git_mv_dir() {
    local src="$1"
    local dest="$2"
    if [[ -e "$src" ]]; then
        mkdir -p "$(dirname "$dest")"
        if [[ -e "$dest" ]]; then
            # Merge contents when destination already exists
            shopt -s dotglob
            for item in "$src"/*; do
                local base
                base="$(basename "$item")"
                if [[ -e "$dest/$base" ]]; then
                    if [[ -d "$item" && -d "$dest/$base" ]]; then
                        for sub in "$item"/*; do
                            git mv "$sub" "$dest/$base/$(basename "$sub")" 2>/dev/null || true
                        done
                        rmdir "$item" 2>/dev/null || true
                    fi
                else
                    git mv "$item" "$dest/$base"
                fi
            done
            shopt -u dotglob
            rmdir "$src" 2>/dev/null || true
        else
            git mv "$src" "$dest"
        fi
    fi
}

# --- Identity & Access → software folders ---
git_mv_dir "src/Identity-Access/Active-Directory" "src/Active-Directory"
git_mv_dir "src/Identity-Access/User-Accounts" "src/Active-Directory/User-Accounts"
git_mv_dir "src/Identity-Access/Permissions" "src/Active-Directory/Permissions"
git_mv_dir "src/Identity-Access/Group-Policy" "src/Group-Policy"
git_mv_dir "src/Identity-Access/Home-Drives-DFS" "src/DFS"

# --- Cloud → software folders ---
git_mv_dir "src/Cloud/Azure" "src/Azure"
git_mv_dir "src/Cloud/Microsoft-365" "src/Microsoft-365"
git_mv_dir "src/Cloud/Exchange-Online" "src/Exchange-Online"
git_mv_dir "src/Cloud/SharePoint-Online" "src/SharePoint-Online"
git_mv_dir "src/Cloud/OneDrive" "src/OneDrive"
git_mv_dir "src/Cloud/Teams" "src/Teams"
git_mv_dir "src/Cloud/Intune" "src/Intune"
git_mv_dir "src/Cloud/PowerApps" "src/PowerApps"
git_mv_dir "src/Cloud/Storage-Accounts" "src/Azure-Storage"
git_mv_dir "src/Cloud/Licensing" "src/Microsoft-Licensing"
git_mv_dir "src/Cloud/Integrations" "src/Integrations"

# --- Endpoint Management ---
git_mv_dir "src/Endpoint-Management/SCCM-ConfigMgr" "src/SCCM-ConfigMgr"
git_mv_dir "src/Endpoint-Management/WSUS" "src/WSUS"
git_mv_dir "src/Endpoint-Management/Windows-Updates" "src/Windows-Updates"
git_mv_dir "src/Endpoint-Management/HP-Radia-HPCA" "src/HP-Radia-HPCA"
git_mv_dir "src/Endpoint-Management/LANDesk" "src/LANDesk"

# --- Deployment ---
git_mv_dir "src/Deployment/Application-Installers" "src/Application-Installers"
git_mv_dir "src/Deployment/App-Deployment-Toolkit" "src/PSAppDeployToolkit"
git_mv_dir "src/Deployment/Middleware-Packaging" "src/Middleware-Packaging"
git_mv_dir "src/Deployment/OS-Deployment" "src/OS-Deployment"

# --- Security ---
git_mv_dir "src/Security/Antivirus" "src/Antivirus"
git_mv_dir "src/Security/McAfee-ePO" "src/McAfee-ePO"
git_mv_dir "src/Security/BitLocker" "src/BitLocker"
git_mv_dir "src/Security/Encryption" "src/Encryption"
git_mv_dir "src/Security/Certificates" "src/Certificates"
git_mv_dir "src/Security/Firewall" "src/Firewall"
git_mv_dir "src/Security/Protocol-Hardening" "src/Protocol-Hardening"
git_mv_dir "src/Security/Threat-Intelligence" "src/Threat-Intelligence"
git_mv_dir "src/Security/User-Account-Control" "src/User-Account-Control"
git_mv_dir "src/Security/Scripts-Random" "src/Security"

# --- Networking ---
git_mv_dir "src/Networking/Diagnostics" "src/Networking"
git_mv_dir "src/Networking/Proxy" "src/Proxy"
git_mv_dir "src/Networking/Wake-On-LAN" "src/Wake-On-LAN"

# --- Storage ---
git_mv_dir "src/Storage-FileServices/Disk-Space" "src/Disk-Space"
git_mv_dir "src/Storage-FileServices/File-Management" "src/File-Management"
git_mv_dir "src/Storage-FileServices/FSRM-Quotas" "src/FSRM-Quotas"
git_mv_dir "src/Storage-FileServices/Folder-Redirection" "src/Folder-Redirection"
git_mv_dir "src/Storage-FileServices/Scripts-Random" "src/Storage"

# --- Monitoring ---
git_mv_dir "src/Monitoring-Reporting/SCOM" "src/SCOM"
git_mv_dir "src/Monitoring-Reporting/Event-Logs" "src/Event-Logs"
git_mv_dir "src/Monitoring-Reporting/Reporting" "src/Reporting"
git_mv_dir "src/Monitoring-Reporting/HTML-Reports" "src/HTML-Reports"
git_mv_dir "src/Monitoring-Reporting/Scripts-Random" "src/Monitoring"

# --- Remote Management ---
git_mv_dir "src/Remote-Management/PSRemoting" "src/PSRemoting"
git_mv_dir "src/Remote-Management/PSExec" "src/PSExec"
git_mv_dir "src/Remote-Management/Scripts-Random" "src/Remote-Management"

# --- Infrastructure ---
git_mv_dir "src/Infrastructure/SQL-Server" "src/SQL-Server"
git_mv_dir "src/Infrastructure/Registry" "src/Registry"
git_mv_dir "src/Infrastructure/WMI" "src/WMI"
git_mv_dir "src/Infrastructure/Scheduled-Tasks" "src/Scheduled-Tasks"
git_mv_dir "src/Infrastructure/Host-Bus-Adapter" "src/Host-Bus-Adapter"
git_mv_dir "src/Infrastructure/Power-Profiles" "src/Power-Profiles"
git_mv_dir "src/Infrastructure/Scripts-Random" "src/Infrastructure"

# --- Desktop / Inventory ---
git_mv_dir "src/Desktop-OperatingSystem/Computer-Maintenance" "src/Computer-Maintenance"
git_mv_dir "src/Desktop-OperatingSystem/Processes" "src/Processes"
git_mv_dir "src/Desktop-OperatingSystem/NET-Framework" "src/NET-Framework"
git_mv_dir "src/Desktop-OperatingSystem/Scripts-Random" "src/Windows-Desktop"
git_mv_dir "src/Inventory-Discovery/Computer-Info" "src/Computer-Info"
git_mv_dir "src/Inventory-Discovery/Scripts-Random" "src/Inventory"

# --- General catch-all → redistribute to General software folder ---
git_mv_dir "src/General/Scripts-Random" "src/General"

# --- Tools under src ---
git_mv_dir "src/Tools/GUI-Applications" "src/GUI-Applications"

# Remove empty domain parent folders
for empty in \
    "src/Identity-Access" "src/Cloud" "src/Endpoint-Management" \
    "src/Deployment" "src/Storage-FileServices" "src/Monitoring-Reporting" \
    "src/Remote-Management" "src/Desktop-OperatingSystem" \
    "src/Inventory-Discovery" "src/General" "src/Tools" "src/Security"
do
    rmdir "$empty" 2>/dev/null || true
done

echo "Software-first reorganization complete."
