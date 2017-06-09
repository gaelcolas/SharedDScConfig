@{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            MemberOfRoles = @('SharedDscConfig')
            Roles     = @{
                SharedDscConfig = @{
                    Ensure = 'present'
                    DestinationPath = 'C:\test.txt'
                    Contents = 'another file.'
                }
            }
        }
    )
}