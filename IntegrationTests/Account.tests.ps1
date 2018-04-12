$UserOU = "OU=Departments,DC="
Describe "Users" {
	Get-ADUser -Filter * -SearchBase $UserOU -Properties DisplayName,HomeDrive,HomeDirectory | For-EachObject {
		$User = $_
		Context $User.DN {
			It "Has the correct Surname case" {
				$User.Surname | Should Be ($User.Surname.ToUpper())
			}

			It "Has the correct Givenname case" {
				$FirstLetter = $User.GivenName[0]
				$FirstLetter | Should Be ($FirstLetter.ToUpper())
				$RemainingLetters = $User.GivenName[0..$User.GivenName.Length]
				$RemainingLetters | Should Be ($RemainingLetters.ToLower())
			}

			It "Has the correct display name attribute" {
				$CorrectDisplayName = "{0} {1}" -f $User.Surname, $User.GivenName
				$User.DisplayName | Should Be $CorrectDisplayName
			}

			It "Has the correct name attribute" {
				$CorrectName = "{0} {1}" -f $User.Surname, $User.GivenName
				$User.Name | Should Be $CorrectName
				$User.Name | Should Be $User.Name
			}

			It "Has HomeDrive set" {
				[String]::IsNullOrEmpty($User.HomeDrive) | Should Be $False
			}

			It "Has HomeDirectory set" {
				[String]::IsNullOrEmpty($User.HomeDirectory) | Should Be $False
			}

			It "Has title set" {
				[String]::IsNullOrEmpty($User.Title) | Should Be $False
			}

			It "Has department set" {
				[String]::IsNullOrEmpty($User.Department) | Should Be $False
			}

			It "Has company set" {
				[String]::IsNullOrEmpty($User.Company) | Should Be $False
			}

			It "Is disabled" {
				$User.Enabled | Should Be $False
			}
		}

		Context "Employee numbers" {
			It "Should be unique" {
				Get-ADuser -Filter * -SearchBase $UserOU -Properties EmployeeNumber | Group-Object -Property EmployeeNumber | For-EachObject {
					$_.Count | Should Be 1
				}
			}
		}
	}
}