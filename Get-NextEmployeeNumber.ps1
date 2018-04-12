function Get-NextEmployeeNumber
{
	[cmdletbinding()]
	param(
	)
	if (-not (Test-Path -Path variable:script:MaxEmployeeNumber))
	{
		try {
			[int32]$script:MaxEmployeeNumber = $(Get-ADUser -filter {EmployeeNumber -like *} -properties EmployeeNumber -ErrorAction Stop | Select-Object -ExpandProperty EmployeeNumber | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum)
			$script:MaxEmployeeNumber++
			$script:MaxEmployeeNumber
		}
		catch {
			throw('Unable to retrieve the current MaxEmployeeNumber from AD')
		}
	}
	else {
		$script:MaxEmployeeNumber++
		$script:MaxEmployeeNumber
	}
}