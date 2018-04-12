function Get-RandomDomainGroup {
	[cmdletbinding()]
	param()
	$DomainGroups = @('domaingroup1', 'domaingroup2', 'domaingroup3', 'domaingroup4')
	$index = Get-Random -Minimum 0 -Maximum 4
	$DomainGroups[$index]
}