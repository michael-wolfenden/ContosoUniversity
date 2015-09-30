# Copyright 2012 Aaron Jensen
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function Get-User
{
    <#
    .SYNOPSIS
    Gets *local* users.

    .DESCRIPTION
    Gets all *local* users or a specific user by its username.

    .OUTPUTS
    System.DirectoryServices.AccountManagement.UserPrincipal.

    .LINK
    Install-User

    .LINK
    Test-User

    .LINK
    Uninstall-User

    .EXAMPLE
    Get-User

    Demonstrates how to get all local users.

    .EXAMPLE
    Get-User -Username LSkywalker 

    Demonstrates how to get a specific user.
    #>
    [CmdletBinding()]
    [OutputType([System.DirectoryServices.AccountManagement.UserPrincipal])]
    param(
        [ValidateLength(1,20)]
        [string]
        # The username for the user.
        $Username 
    )

    Set-StrictMode -Version 'Latest'

    $ctx = New-Object 'DirectoryServices.AccountManagement.PrincipalContext' ([DirectoryServices.AccountManagement.ContextType]::Machine)
    if( $Username )
    {
        $user = [DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity( $ctx, $Username )
        if( -not $user )
        {
            Write-Error ('Local user ''{0}'' not found.' -f $Username) -ErrorAction:$ErrorActionPreference
            return
        }
        return $user
    }
    else
    {
        $query = New-Object 'DirectoryServices.AccountManagement.UserPrincipal' $ctx
        $searcher = New-Object 'DirectoryServices.AccountManagement.PrincipalSearcher' $query
        $searcher.FindAll() 
    }
}
