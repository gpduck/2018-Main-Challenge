$UserOU = "OU=Departments,DC="
Describe "Users" {
	Get-ADUser -Filter * -SearchBase $UserOU -Properties DisplayName | For-EachObject {
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