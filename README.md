# Damn-Vulnerable-ADCS
A Powershell script that creates a damn vulnerable Active Directory Certificate Services server with known vulnerabilities. Do not use this script in production!

# Requirements
1. A configured Domain Controller
2. A blank Windows Server that is domain joined and named correctly (CA is the best option)

# How to run
To run, download the script and enable the execution policy to allow scripts to run. Then run the script with ./ADCS-rollout-with-web.ps1 vuln.local
Note: you can replace vuln.local with any subject/domain you would like to use, just note that it must match your domain name used on your domain controller or you will have issues.

# Vulnerabilities
At this time, this script does NOT contain template vulnerabilities due to the complex nature of how they are set up. This script is only for testing NTLM relaying vulnerabilities at the moment.

# TODOs
- Support vulnerable templates
- Support all ESC vulnerabilities found in the Certified Pre-Owned PDF (https://specterops.io/wp-content/uploads/sites/3/2022/06/Certified_Pre-Owned.pdf)
- Add in template options (only enable ESC1 for example)

# History
This script was used to configured the ADCS box for the Iowa State University Cyber Defense Competition (CDC).

# License
This script is licensed under GPLv3
