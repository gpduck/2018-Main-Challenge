Properties {
	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
	$Author = "Iron Scripter -- Flawless"

	# Default Locale used for help generation, defaults to en-US.
	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
	$DefaultLocale = 'en-US'

	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
	$DocsRootDir = "$PSScriptRoot\docs"

	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
	$GUID = '0db8c269-0974-47fb-9931-187fadedb299'

	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
	$CompanyName = "Iron Scripter"

	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
	$CopyRight = "2018"

	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
	$Description = "Flawless AD cmdlets"

	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
	$FunctionDir = "$PSScriptRoot\Module\Functions"

	# The name of your module should match the basename of the PSD1 file.
	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
	$ModuleName = "Flawless"

	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
	$PowerShellVersion = '5.1'

	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
	$ReleaseNotes = Get-Content -path "$PSScriptRoot\ReleaseNotes.md" -Raw

	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
	$SrcRootDir = "$PSScriptRoot\Module"

	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
	$UnitTestDir = "$PSScriptRoot\Tests\"

	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
	$Version = "0.1"

	# The local installation directory for the install task. Defaults to your home Modules location.
	if ( $Version -ge "6.0") {
		$CurrentUser = ($env:PSModulePath).split(";") | Where-Object {$_ -notlike "*Program*"}
		[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
		$InstallPath = "$CurrentUser\$ModuleName\$Version\"
	}
	else {
		$InstallPath = "C:\Users\brandon.lundt\Documents\WindowsPowerShell\Modules\$ModuleName\$Version\"
	}

	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
	$ScriptAnalyzerSettingsPath = "$PSScriptRoot\ScriptAnalyzerSettings.psd1"
}