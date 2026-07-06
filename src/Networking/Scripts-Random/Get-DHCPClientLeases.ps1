# -----------------------------------------------------------------------------------------
# Script: Get-DHCPClientLeases.ps1
# Date: April 24, 2015
# Version: 1.0
# Purpose: This script is used to get DHCP client leases from a DHCP Server
#
# Project: foreScript
#
# -----------------------------------------------------------------------------------------
#
# (C) Nigel Thomas, 2015
#
#------------------------------------------------------------------------------------------

<#
.SYNOPSIS
   Returns the DHCP Leases for a subnet from a Windows DHCP Server
.DESCRIPTION
  Accepts the name or ip address of a Windows DHCP Server and returns the leases for the specified subnet. The API DhcpEnumSubnetClients is
  used to query the Windows DHCP server and return the requesred information. If a user name and password is provided the script
  will use impersonation to connect to the DHCP Server. The leasese
  are returned as a JSON object.
  
.PARAMETER DHCPServerNameOrIP
   The name or ip address of the DHCP Server
.PARAMETER Subnet
  The DHCP subnet that we want to get the leases from
.PARAMETER UserName
  The user name
.PARAMETER Password
  The password

  Date: 5/18/2015
  Version: 1.0
   
#>

#region functions
# Based on http://poshcode.org/1477
#Function Get-DHCPClientLeases {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        $DHCPServerNameOrIP,
        [Parameter(Mandatory=$true)]
        $Subnet,
        [Parameter(Mandatory=$false)]
        $UserName,
        [Parameter(Mandatory=$false)]
        $Password
    )

    #region PInvoke API definitions
    # Based on http://stackoverflow.com/questions/757857/how-to-build-runas-netonly-functionality-into-a-c-net-winforms-program
    $Login_Impersonation = @'
namespace LOGIN_IMPERSONATION
{
    #region Using directives.
    // ----------------------------------------------------------------------

    using System;
    using System.Security.Principal;
    using System.Runtime.InteropServices;
    using System.ComponentModel;

    // ----------------------------------------------------------------------
    #endregion

    /////////////////////////////////////////////////////////////////////////

    /// <summary>
    /// Impersonation of a user. Allows to execute code under another
    /// user context.
    /// Please note that the account that instantiates the Impersonator class
    /// needs to have the 'Act as part of operating system' privilege set.
    /// </summary>
    /// <remarks>   
    /// This class is based on the information in the Microsoft knowledge base
    /// article http://support.microsoft.com/default.aspx?scid=kb;en-us;Q306158
    /// 
    /// Encapsulate an instance into a using-directive like e.g.:
    /// 
    ///     ...
    ///     using ( new Impersonator( "myUsername", "myDomainname", "myPassword" ) )
    ///     {
    ///         ...
    ///         [code that executes under the new context]
    ///         ...
    ///     }
    ///     ...
    /// 
    /// Please contact the author Uwe Keim (mailto:uwe.keim@zeta-software.de)
    /// for questions regarding this class.
    /// </remarks>
    public class Impersonator :
        IDisposable
    {
        #region Public methods.
        // ------------------------------------------------------------------

        /// <summary>
        /// Constructor. Starts the impersonation with the given credentials.
        /// Please note that the account that instantiates the Impersonator class
        /// needs to have the 'Act as part of operating system' privilege set.
        /// </summary>
        /// <param name="userName">The name of the user to act as.</param>
        /// <param name="domainName">The domain name of the user to act as.</param>
        /// <param name="password">The password of the user to act as.</param>
        public Impersonator(
            string userName,
            string domainName,
            string password)
        {
            ImpersonateValidUser(userName, domainName, password);
        }

        // ------------------------------------------------------------------
        #endregion

        #region IDisposable member.
        // ------------------------------------------------------------------

        public void Dispose()
        {
            UndoImpersonation();
        }

        // ------------------------------------------------------------------
        #endregion

        #region P/Invoke.
        // ------------------------------------------------------------------

        [DllImport("advapi32.dll", SetLastError = true)]
        private static extern int LogonUser(
            string lpszUserName,
            string lpszDomain,
            string lpszPassword,
            int dwLogonType,
            int dwLogonProvider,
            ref IntPtr phToken);

        [DllImport("advapi32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern int DuplicateToken(
            IntPtr hToken,
            int impersonationLevel,
            ref IntPtr hNewToken);

        [DllImport("advapi32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern bool RevertToSelf();

        [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
        private static extern bool CloseHandle(
            IntPtr handle);

        private const int LOGON32_LOGON_INTERACTIVE = 2;
        private const int LOGON32_LOGON_NEW_CREDENTIALS = 9;
        private const int LOGON32_PROVIDER_DEFAULT = 0;

        // ------------------------------------------------------------------
        #endregion

        #region Private member.
        // ------------------------------------------------------------------

        /// <summary>
        /// Does the actual impersonation.
        /// </summary>
        /// <param name="userName">The name of the user to act as.</param>
        /// <param name="domainName">The domain name of the user to act as.</param>
        /// <param name="password">The password of the user to act as.</param>
        private void ImpersonateValidUser(
            string userName,
            string domain,
            string password)
        {
            WindowsIdentity tempWindowsIdentity = null;
            IntPtr token = IntPtr.Zero;
            IntPtr tokenDuplicate = IntPtr.Zero;

            try
            {
                if (RevertToSelf())
                {
                    if (LogonUser(
                        userName,
                        domain,
                        password,
                        LOGON32_LOGON_NEW_CREDENTIALS,
                        LOGON32_PROVIDER_DEFAULT,
                        ref token) != 0)
                    {
                        if (DuplicateToken(token, 2, ref tokenDuplicate) != 0)
                        {
                            tempWindowsIdentity = new WindowsIdentity(tokenDuplicate);
                            impersonationContext = tempWindowsIdentity.Impersonate();
                        }
                        else
                        {
                            throw new Win32Exception(Marshal.GetLastWin32Error());
                        }
                    }
                    else
                    {
                        throw new Win32Exception(Marshal.GetLastWin32Error());
                    }
                }
                else
                {
                    throw new Win32Exception(Marshal.GetLastWin32Error());
                }
            }
            finally
            {
                if (token != IntPtr.Zero)
                {
                    CloseHandle(token);
                }
                if (tokenDuplicate != IntPtr.Zero)
                {
                    CloseHandle(tokenDuplicate);
                }
            }
        }

        /// <summary>
        /// Reverts the impersonation.
        /// </summary>
        private void UndoImpersonation()
        {
            if (impersonationContext != null)
            {
                impersonationContext.Undo();
            }
        }

        private WindowsImpersonationContext impersonationContext = null;

        // ------------------------------------------------------------------
        #endregion
    }

    /////////////////////////////////////////////////////////////////////////
}


'@

    $DHCP_EnumSubnetClients = @'          
        [DllImport("dhcpsapi.dll", SetLastError = true, CharSet = CharSet.Auto)]
        public static extern uint DhcpEnumSubnetClients(
            string ServerIpAddress, 
            uint SubnetAddress, 
            ref uint ResumeHandle,
            uint PreferredMaximum,
            out IntPtr ClientInfo,
            ref uint ElementsRead,
            ref uint ElementsTotal);
'@

    $DHCP_Structs = @'
        namespace DHCP_ENUMSUBNETCLIENTS_STRUCTS {
        using System;
        using System.Runtime.InteropServices;

        public struct CUSTOM_CLIENT_INFO
        {
            public string ClientName;
            public string IpAddress;
            public string MacAddress;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct DHCP_CLIENT_INFO_ARRAY
        {
            public uint NumElements;
            public IntPtr Clients;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct DHCP_CLIENT_UID
        {
            public uint DataLength;
            public IntPtr Data;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct DATE_TIME
        {
            public uint dwLowDateTime;
            public uint dwHighDateTime;
    
            public DateTime Convert()
            {
                if (dwHighDateTime== 0 && dwLowDateTime == 0) {
                    return DateTime.MinValue;
                }

                if (dwHighDateTime == int.MaxValue && dwLowDateTime == UInt32.MaxValue) {
                    return DateTime.MaxValue;
                }
        
                return DateTime.FromFileTime((((long) dwHighDateTime) << 32) | (UInt32) dwLowDateTime);
            }
        }
    
        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
        public struct DHCP_HOST_INFO
        {
            public uint IpAddress;
            public string NetBiosName;
            public string HostName;
        }

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
        public struct DHCP_CLIENT_INFO
        {
            public uint ClientIpAddress;
            public uint SubnetMask;
            public DHCP_CLIENT_UID ClientHardwareAddress;
    
            [MarshalAs(UnmanagedType.LPWStr)]
            public string ClientName;
    
            [MarshalAs(UnmanagedType.LPWStr)]
            public string ClientComment;
    
            public DATE_TIME ClientLeaseExpires; 
            public DHCP_HOST_INFO OwnerHost; 
        }
    }
'@
    #endregion PInvoke API definitions

    #region functions
    Function uIntToIP {
        Param ($intIP)

        $objIP = New-Object System.Net.IpAddress($intIP)
        $arrIP = $objIP.IPAddressToString.split(".")
        return $arrIP[3] + "." + $arrIP[2] + "." + $arrIP[1] + "." + $arrIP[0]
    }

    Function GetClientReservation {
        Param ($ClientInfo)


        $clients = [DHCP_ENUMSUBNETCLIENTS_STRUCTS.DHCP_CLIENT_INFO_ARRAY][System.Runtime.InteropServices.Marshal]::PtrToStructure($ClientInfo,[System.Type][DHCP_ENUMSUBNETCLIENTS_STRUCTS.DHCP_CLIENT_INFO_ARRAY])
    
        [int]$size = $clients.NumElements
        [int]$current = $clients.Clients
        $ptr_array = New-Object System.IntPtr[]($size)
        $current = New-Object System.IntPtr($current)

        for ($i=0;$i -lt $size;$i++) {
            $ptr_array[$i] = [System.Runtime.InteropServices.Marshal]::ReadIntPtr($current)
	        $current = $current + [System.Runtime.InteropServices.Marshal]::SizeOf([System.Type][System.IntPtr])
        }
    
        [array]$clients_array = New-Object DHCP_ENUMSUBNETCLIENTS_STRUCTS.CUSTOM_CLIENT_INFO

        for ($i=0;$i -lt $size;$i++) {
            

            $objDHCPInfo = [ordered]@{}
	        $current_element = [system.runtime.interopservices.marshal]::PtrToStructure($ptr_array[$i],[System.Type][DHCP_ENUMSUBNETCLIENTS_STRUCTS.DHCP_CLIENT_INFO])
	        $objDHCPInfo.ClientIP = $(uIntToIP $current_element.ClientIpAddress)
	        $objDHCPInfo.ClientName = $current_element.ClientName
	        $objDHCPInfo.OwnerIP = $(uIntToIP $current_element.Ownerhost.IpAddress)
	        $objDHCPInfo.OwnerName = $current_element.Ownerhost.NetBiosName
	        $objDHCPInfo.SubnetMask = $(uIntToIP $current_element.SubnetMask)
	        $objDHCPInfo.LeaseExpires = $current_element.ClientLeaseExpires.Convert()

            $mac = [System.String]::Format( "{0:x2}-{1:x2}-{2:x2}-{3:x2}-{4:x2}-{5:x2}",
	           [System.Runtime.InteropServices.Marshal]::ReadByte($current_element.ClientHardwareAddress.Data),
	           [System.Runtime.InteropServices.Marshal]::ReadByte($current_element.ClientHardwareAddress.Data, 1),
	           [System.Runtime.InteropServices.Marshal]::ReadByte($current_element.ClientHardwareAddress.Data, 2),
	           [System.Runtime.InteropServices.Marshal]::ReadByte($current_element.ClientHardwareAddress.Data, 3),
	           [System.Runtime.InteropServices.Marshal]::ReadByte($current_element.ClientHardwareAddress.Data, 4),
	           [System.Runtime.InteropServices.Marshal]::ReadByte($current_element.ClientHardwareAddress.Data, 5)
            )

            $objDHCPInfo.MacAddress = $mac
            $objDHCPInfo
            
        }

      

    }
    #endregion functions

    # Execute code in x86 powershell environment if we are running in a 64 bit environment
    if ($env:Processor_Architecture -ne "x86")   { 
        #Write-Warning 'Launching x86 PowerShell'
        &"$env:windir\syswow64\windowspowershell\v1.0\powershell.exe" -executionpolicy bypass -noninteractive -noprofile -file $myinvocation.Mycommand.path @psboundparameters
        exit
    }

    try {
    
        # Constants
        $ERROR_MORE_DATA = 234
        $ERROR_SUCCESS = 0
        $ResumeHandle = 0
        $ClientInfo = 0
        $ElementsRead = 0
        $ElementsTotal = 0
        $PreferredMaximum = 65536

        Add-Type $DHCP_Structs
        Add-Type  -MemberDefinition $DHCP_EnumSubnetClients -Name GetDHCPSubnetClients -Namespace Win32DHCP

        Add-Type -TypeDefinition $Login_Impersonation

        if (-not (Test-Connection -ComputerName $DHCPServerNameOrIP -BufferSize 16 -Count 2 -Quiet)) {
            $ErrorMessage = $DHCPServerNameOrIP + " is offline"
            $jsonresult = '{'
            $jsonresult += " 'Error' :"
            $jsonresult += $ErrorMessage | ConvertTo-Json -Compress
            $jsonresult += '}'
            $jsonresult | Out-String
            return
        }

        # Convert ip subnet which is a string  to Int32
        $Address = [System.Net.IPAddress]::Parse($Subnet)
        $Bytes = $Address.GetAddressBytes()
        [Array]::Reverse($Bytes)
        $DHCPSubnet = [System.BitConverter]::ToUInt32($Bytes, 0)
        #$DHCPSubnet
        
        $DHCPClientReservations = @()

        if (($PSBoundParameters.ContainsKey('UserName')) -and ($PSBoundParameters.ContainsKey('Password'))) {
            
            $secpassword = ConvertTo-SecureString $Password -AsPlainText -Force
            $cred = New-Object -typename System.Management.Automation.PSCredential -argumentlist $UserName, $secpassword
            $networkCred = $cred.GetNetworkCredential()
            $Impersonator = New-Object LOGIN_IMPERSONATION.Impersonator($networkCred.UserName.ToString(), $networkCred.Domain.ToString(), $networkCred.Password)

        }

        

        # Get the DHCP client reservations in the subnet. The call returns  ERROR_MORE_DATA if there is more information to be read and ERROR_SUCCESS on the final call
        $DHCPresult = [Win32DHCP.GetDHCPSubnetClients]::DhcpEnumSubnetClients($DHCPServerNameOrIP,$DHCPSubnet,[ref]$ResumeHandle,$PreferredMaximum,[ref]$ClientInfo,[ref]$ElementsRead,[ref]$ElementsTotal)

        # If we get an error report the error number and return
        if (($DHCPresult -ne $ERROR_SUCCESS) -and ($DHCPresult -ne $ERROR_MORE_DATA)) {

            $ErrorMessage = "DHCP Error: " + $DHCPresult
            $jsonresult = '{'
            $jsonresult += " 'Error' :"
            $jsonresult += $ErrorMessage | ConvertTo-Json -Compress
            $jsonresult += '}'
            $jsonresult | Out-String
            return
        }

        while ($DHCPresult -eq $ERROR_MORE_DATA) {

            $DHCPClientReservations += $(GetClientReservation -ClientInfo $ClientInfo)
            $DHCPresult = [Win32DHCP.GetDHCPSubnetClients]::DhcpEnumSubnetClients($DHCPServerNameOrIP,$DHCPSubnet,[ref]$ResumeHandle,$PreferredMaximum,[ref]$ClientInfo,[ref]$ElementsRead,[ref]$ElementsTotal)
        }

        if ($DHCPresult -eq $ERROR_SUCCESS) {

            $DHCPClientReservations += $(GetClientReservation -ClientInfo $ClientInfo)
        }
        
 
        $jsonresult = "{"
        $jsonresult += "'Data':"
        $jsonresult += $DHCPClientReservations | ConvertTo-Json -Compress
        $jsonresult += "}"
        $jsonresult | Out-String


    }
    catch {

        $jsonresult = '{'
        $jsonresult += " 'Error' :"
        $jsonresult += $_ | format-list -force | ConvertTo-Json -Compress
        $jsonresult += '}'
        $jsonresult | Out-String
    }
    finally {
        if ($Impersonator) {
            $Impersonator.Dispose()
        }

        
        
    }
#}

#endregion functions