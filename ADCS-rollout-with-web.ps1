Import-Module ServerManager
Install-WindowsFeature RSAT


#Usage: ./ADCS-rollout-with-web.ps1 vuln.local
#With "vuln.local" being the domain/subjectname used in the certificate for the ADCS web server and name of the Certificate Authority (CA)

$teamNumber = $args[0]


#TODO: Check if user is in EA and DA groups (just in case this is run on a non-priv account


#======================= PREFLIGHT CHECKS ================================

#Check if computer is domain joined
#From: https://stackoverflow.com/questions/4409043/how-to-find-if-the-local-computer-is-in-a-domain

if ((gwmi win32_computersystem).partofdomain -eq $true) {
    write-host -fore green "Machine is domain joined"
} else {
    write-host -fore red "ERROR: Machine is not domain joined! QUITTING!"
    $host.Exit()
}

#Check if computer has static IP
#TODO (Is this needed?)


#Check if computer is named within regex
#TODO (Is this needed?)


#=========================== INSTALL IIS (Optional) ==================================
#This makes it easier to manage IIS using the GUI tools instead of the PS cmdlets. This can be commented out if needed. The ADCS install takes care of the basics for IIS when it is installed.

Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole, IIS-WebServer, IIS-CommonHttpFeatures, IIS-ManagementConsole, IIS-HttpErrors, IIS-HttpRedirect, IIS-WindowsAuthentication, IIS-StaticContent, IIS-DefaultDocument, IIS-HttpCompressionStatic, IIS-DirectoryBrowsing


#=========================== INSTALL ADCS ==================================

#Note: none of the functions below should require a restart.

#Install the ADCS CA Feature
#NOTE: Make sure to keep the "IncludeManagementTools" option so that the CA and Cert Templates GUIs are installed!

Add-WindowsFeature Adcs-Cert-Authority -IncludeManagementTools

#Install a new CA on this server
Install-AdcsCertificationAuthority -CAType EnterpriseRootCA

#========================== REQUEST TLS CERT FOR ADCS WEB SERVER =====================

# Create SSL/TLS template for use in Web enrollment (this is required as the web enrollment is only allowed over TLS)
#Request certificate from the local CA (if this is run with high priv, the cert will be issued without any interaction)
$caDNSName = "ca.{0}"
[string]::Format($caDNSName, $teamNumber)
$subjectName = "CN=ca.{0}, C=US, L=Vuln, O=Vuln OU=Vuln, S=IA"
[string]::Format($subjectName, $teamNumber)
$certificateReqest = Get-Certificate -Template "WebServer" -DnsName $caDNSName -CertStoreLocation Cert:\LocalMachine\My -SubjectName $subjectName

if ($certificateReqest.Status == "Issued") {
    #The certificate for the web server was issued and install can continue

} else {
    #The certificate needs to be approved or another error occured. Exit for now.
    $host.Exit()
    #TODO: Add auto cert approve feature or debugging.
}

#========================== INSTALL ADCS WEB ENROLLMENT =====================

Add-WindowsFeature Adcs-Enroll-Web-Svc

#Start the web server and using the Thumbprint from the issued cert as the TLS cert.
Install-AdcsEnrollmentWebService -SSLCertThumbprint $certificateReqest.Certificate.Thumbprint

#Configure templates
#https://github.com/GoateePFE/ADCSTemplate
#Install-Module ADCSTemplate

#TODO: Create vulnerable templates
#Create JSON for vulnerable templates that allows for the requestor to supply the subject


#Add-WindowsFeature Adcs-Web-Enrollment
#Add-WindowsFeature Adcs-Enroll-Web-Svc

#Install the online responder (OSCP)
#Add-WindowsFeature Adcs-Online-Cert

