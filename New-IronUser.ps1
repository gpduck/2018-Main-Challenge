function New-MBADUser {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
		[string]$FirstName,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
		[Alias('LastName')]
		[string]$Surname,
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName)]
		[string]$Department,
		[Parameter(Mandatory = $false)]
		[string]$Manager,
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName)]
		[Alias('Telephone Number', 'TelephoneNumber')]
		[string]$Telephone,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
		[string]$JobTitle
	)

	DynamicParam {
        if ($true) {
            do {
				#Build the Parameter Dictionary
				$paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
								
				#Define the basic parameter information
				$attributes = New-Object System.Management.Automation.ParameterAttribute
				$attributes.ParameterSetName = "__AllParameterSets"
				$attributes.Mandatory = $false
				$attributes.HelpMessage = 'Valid Employee OUs'
				$attributes.ValueFromPipelineByPropertyName = $true
								
				$ParamOptions = New-Object System.Management.Automation.ValidateSetAttribute -ArgumentList ((Get-ADOrganizationalUnit -SearchBase "OU=Departments,$($DomainDC)" -Filter *).Name.Where{$PSItem -ne 'Departments'})

				$attributeCollection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
				$attributeCollection.Add($attributes)
				$attributeCollection.Add($ParamOptions)
								
				$dynParam = New-Object -Type System.Management.Automation.RuntimeDefinedParameter(
					'clientname',[String],$attributeCollection
				)

				$paramDictionary.Add('Departments', $dynParam)
				
                #Return the object for consumption
                return $paramDictionary
            }  until ($paramDictionary)
        } #End If
    }
	Begin {}

	Process {
		#Variables
		$Password = 'Temp!'
		$DC = (Get-ADDomain).PDCEmulator
		$Domain = $env:USERDNSDOMAIN.split('.')

		#Redo the variables into an object to avoid find and replace garbage
		$Obj = New-Object -TypeName psobject
		$Obj | Add-Member -MemberType NoteProperty -Name 'FirstName'
		$Obj | Add-Member -MemberType NoteProperty -Name 'MiddleName'
		$Obj | Add-Member -MemberType NoteProperty -Name 'LastName'
		$Obj | Add-Member -MemberType NoteProperty -Name 'employeenumber'
		$Obj | Add-Member -MemberType NoteProperty -Name 'JobTitle'
		$Obj | Add-Member -MemberType NoteProperty -Name 'clientname'

		#Reuse based upon Department
		switch ($OU) {
			'Employees' {
				$OU = "OU=Employees,DC=$($Domain[0]),DC=$($Domain[1])"
			}
			'Contractors' {
				$OU = "OU=Contractors,DC=$($Domain[0]),DC=$($Domain[1])"
			}
		}

		#Functions
		function ConvertTo-NameCase ([string[]]$Names) {
			<#
            .SYNOPSIS
            ConvertTo-NameCase takes any english name variation and converts it to the correct case format

            .DESCRIPTION
            ConvertTo-NameCase takes any english name variation and converts it to the correct case, it will handle upper, lower, hyphens, and apostrophe

            .PARAMETER Name
            Name The name you wish to correct in the form of a string

            .EXAMPLE
            ConvertTo-NameCase -Names "kevin"
            #Output = Kevin
            ConvertTo-NameCase -Names "kevin" "o'leary"
            #Output = Kevin
            #O'Leary

            .NOTES
            General notes
            #>
			foreach ($Name in $Names) {
				$NameArray = $Name.ToCharArray() #Get a Character array, basically a split
				#Loop through the array and do the correct case
				for ($i = 0; $i -lt $Name.Length; $i++) {
					$NameArray[0] = ([string]$Name[0]).ToUpper()
					if ($NameArray[$i] -eq '-' -or $NameArray[$i] -eq "'") {
						$NameArray[$i + 1] = ([string]$NameArray[$i + 1]).ToUpper()
						$i++ #Tell the loop to skip the next itteration
					}
					else {
						$NameArray[$i] = ([string]$Name[$i]).ToLower()
					}
				}
				$NameArray -join '' #Join the Character Array back into a string
			}
		}

		function Test-ForExistingSamaccountname ($samaccountname, $DC) {
			#Check to see if the choosen samaccountname already exists
			Try {
				Get-Aduser $samaccountname -Server $DC
			}
			Catch {
				$true #Return true if no account exists
			}
		}

		function Test-ForExistingUPN ($UserPrincipalName, $DC) {
			#Check to see if the choosen samaccountname already exists
			$UPN = Get-Aduser -Filter {(userprincipalname -eq $UserPrincipalName)} -Server $DC
			if ($UPN) {
				$UPN
			}
			else {
				$true #Return true if no account exists
			}
		}

		#Actual Code
		foreach ($Obj in $users) {
			Write-Verbose "Working on $($Obj.FirstName) $($Obj.Lastname)"

			#We have to do this for the filtering to work
			$Employeeid = $Obj.employeenumber.Trim()

			#Rewrite the usersname surname with a - instead of a space
			$Obj.lastname = $Obj.lastname -replace ' ', '-'

			if ($Obj.MiddleName -notlike $null) {
				#Middle name and trim to 18 characters, and replace hyphens with null
				$samaccountname = ("$($Obj.Firstname.substring(0,1).tolower().Trim())$($Obj.MiddleName.substring(0,1).tolower().Trim())$($Obj.LastName.tolower().Trim())"[0..17] -join '') -replace '-', ''
			}
			else {
				#No middle name and trim to 18 characters
				$samaccountname = ("$($Obj.Firstname.substring(0,1).tolower().Trim())$($Obj.LastName.tolower().Trim())"[0..17] -join '') -replace '-', ''
			}

			#Check to see if the user exists based upon their employeeid from HR
			if (!((Get-Aduser -filter {(Employeeid -like $Employeeid)} -Server $DC))) {
				#Check for for free samaccountname increment
				$CheckForExistingSamaccountname = Test-ForExistingSamaccountname -samaccountname $samaccountname -DC $DC
				if ($CheckForExistingSamaccountname -notlike $true) {
					Write-Verbose "$samaccountname already exists, attemping to increment"
					$i = 1 #Start a counter, starts at 1 since we don't use 0,1. The rest of the code is $i++
					do {
						if ($samaccountname[-1] -match "[0-9]") {
							Write-Verbose 'The existing samaccountname is already an increment, we will do addition here'

							#Take the existing account and increment and increment by 1
							$i++
							$samaccountname = "$($samaccountname -replace "[0-9]", '')$([int]($samaccountname -replace "[a-z]", '') + $i)"
						}
						else {
							Write-Verbose 'The existing samaccountname is NOT incremented, this is simple'
							$samaccountname = "$($samaccountname)$($i)"
						}
					} until ((Test-ForExistingSamaccountname -samaccountname $samaccountname -DC $DC) -eq $true)
				}

				#Build a new userobject so we can call the claims later
				$UserObject = New-Object -TypeName psobject
				$UserObject | Add-Member -MemberType NoteProperty -Name 'GivenName' -Value "$(ConvertTo-NameCase -Name $Obj.FirstName.Trim())"
				$UserObject | Add-Member -MemberType NoteProperty -Name 'Surname' -Value "$(ConvertTo-NameCase -Name $Obj.LastName.Trim())"
				$UserObject | Add-Member -MemberType NoteProperty -Name 'Name' -Value "$($Obj.Firstname.Trim()) $(if ($Obj.MiddleName -notlike $null) {$Obj.MiddleName.substring(0,1).ToUpper() + '. '})$($Obj.LastName.Trim())"
				$UserObject | Add-Member -MemberType NoteProperty -Name 'DisplayName' -Value "$($Obj.Firstname.Trim()) $($Obj.LastName.Trim())"

				#Generate the users UPN
				$UserPrincipalName = "$($UserObject.GivenName.replace(' ','').ToLower()).$($UserObject.Surname.replace(' ','').ToLower())@ministrybrands.com"

				#Check for for free UPN increment
				$CheckForExistingUPN = Test-ForExistingUPN -UserPrincipalName $UserPrincipalName -DC $DC
				if ($CheckForExistingUPN -notlike $true) {
					Write-Verbose "$CheckForExistingUPN already exists, attemping to increment"
					$i = 1 #Start a counter, starts at 1 since we don't use 0,1 as fname.last1@domain.tld would just be dumb. The rest of the code is $i++
					$UserPrincipalNamePrefix = $($UserPrincipalName.Split('@')[0])
					do {
						if ($UserPrincipalNamePrefix[-1] -match "[0-9]") {
							Write-Verbose 'The existing upn is already an increment, we will do addition here'

							#Take the existing account and increment and increment by 1
							$i++
							$UserPrincipalName = "$($UserPrincipalNamePrefix -replace "[0-9]", "$i")@ministrybrands.com"
						}
						else {
							Write-Verbose 'The existing UPN is NOT incremented, this is simple'
							$UserPrincipalNamePrefix = "$($UserPrincipalNamePrefix)$($i)"
						}
					} until ((Test-ForExistingUPN -UserPrincipalName $UserPrincipalName -DC $DC) -eq $true)
				}

				#Find the users reporting manager
				$ReportingManager = $obj.ReportsTo.Trim().split(',').Trim()
				$ReportingManager = $users | Where-Object {($PSItem.Firstname -eq $ReportingManager[-1]) -and ($PSItem.LastName -eq $ReportingManager[0])} | Select-Object -First 1 -ExpandProperty EmployeeNumber
				if ($ReportingManager) {
					$ReportingManager = Get-ADUser -Filter {(employeeid -eq $ReportingManager)} -Server $DC | Select-Object -First 1 -ExpandProperty DistinguishedName
				}

				#Establish the base Proxy Address, https://community.spiceworks.com/topic/1565769-ad-attributes-proxyaddresses-vs-msrtcsip-priamryuseraddress-for-sip
				[System.Collections.ArrayList]$ProxyAddresses = @("SMTP:$($UserPrincipalName)") #The first one must be always capitalized and be the users primary email address
				Try {
					$ProxyAddresses.Add(("SIP:$UserPrincipalName")) | Out-Null
				}
				Catch {
					Write-Error 'Failed to add the proxy address to the ArrayList'
				}

				#Random account password
				$AccountPassword = "$($Password)$(New-RandomComplexPassword)"

				#Build an object to keep them
				$UserCredentialObject = New-Object -TypeName psobject
				$UserCredentialObject | Add-Member -MemberType NoteProperty -Name 'samaccountname' -Value $samaccountname
				$UserCredentialObject | Add-Member -MemberType NoteProperty -Name 'UPN' -Value $UserPrincipalName
				$UserCredentialObject | Add-Member -MemberType NoteProperty -Name 'Password' -Value $AccountPassword

				#Build the properties hashtable so we can splat it below
				$Props = @{
					samaccountname        = $samaccountname
					Enabled               = $true
					AccountPassword       = ConvertTo-SecureString $AccountPassword -AsPlainText -Force
					Name                  = $UserObject.Name
					UserPrincipalName     = $UserPrincipalName
					Emailaddress          = $UserPrincipalName
					Path                  = "OU=staging,dc=ministrybrands,dc=com"
					DisplayName           = $UserObject.DisplayName
					Employeeid            = $obj.EmployeeNumber
					GivenName             = $UserObject.GivenName
					Surname               = $UserObject.Surname
					Title                 = $Obj.JobTitle.Trim()
					Organization          = (ConvertTo-NameCase -Names $Obj.clientname.Trim().Split('-')[-1].Split('')) -join ' '
					ChangePasswordAtLogon = $false
					Server                = $DC
				}

				#Make the user!
				New-ADUser @Props

				#Export out the credential object
				$UserCredentialObject | Export-Csv C:\temp\new_user_passwords.csv -NoTypeInformation -Append

				#Set the Proxy Addresses since we can't do that in New-ADUser
				Set-ADUser $samaccountname -Replace (@{ProxyAddresses = $ProxyAddresses.ToArray()}) -Server $DC #ProxyAddresses and SIP

				if ($ReportingManager) {
					Write-Verbose "We found out who $samaccountname reports to, so we will set that now"
					Set-ADUser $samaccountname -Manager $ReportingManager -Server $DC
				}

				Remove-Variable CheckForExistingSamaccountname -ErrorAction SilentlyContinue
				Remove-Variable CheckForExistingUPN -ErrorAction SilentlyContinue
			}
			else {
				Write-Warning "$($Obj.FirstName) $($Obj.LastName) already exists in AD as $($samaccountname)"
			}
		}
	}
}