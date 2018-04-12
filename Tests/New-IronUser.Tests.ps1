Describe "does something" {
    It "Accepts from parameters" {
        $obj = @{
            FirstName = "hi"
            SurName = "hi"
            JobTitle = "hi"
            Department = "hi"
            Manager = "hi"
            PhoneNumber = "253-333-3333"
        }
        { New-IronUser @obj } | should not throw
    }
    It "Accepts from pipeline" {
        $obj = [PScustomobject]@{
            FirstName = "hi"
            SurName = "hi"
            JobTitle = "hi"
            Department = "hi"
            Manager = "hi"
            PhoneNumber = "253-333-3333"
        }
        { $obj | New-IronUser } | should not throw
    }
    It "Accepts arrays of objects" {
        $arr = @(
            [PScustomobject]@{
                FirstName = "hi"
                SurName = "hi"
                JobTitle = "hi"
                Department = "hi"
                Manager = "hi"
                PhoneNumber = "253-333-3333"
            },
            [PScustomobject]@{
                FirstName = "hi"
                SurName = "hi"
                JobTitle = "hi"
                Department = "hi"
                Manager = "hi"
                PhoneNumber = "253-333-3333"
            }
        )

        { New-IronUser -InputObject $arr } | should not throw
    }
}