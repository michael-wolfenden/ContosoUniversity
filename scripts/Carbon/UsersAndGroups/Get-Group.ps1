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

function Get-Group
{
    <#
    .SYNOPSIS
    Gets *local* groups.

    .DESCRIPTION
    Gets all *local* groups or a specific group by its name.

    .OUTPUTS
    System.DirectoryServices.AccountManagement.GroupPrincipal.

    .LINK
    Get-User

    .EXAMPLE
    Get-Group

    Demonstrates how to get all local groups.

    .EXAMPLE
    Get-Group -Name RebelAlliance

    Demonstrates how to get a specific group.
    #>
    [CmdletBinding()]
    [OutputType([DirectoryServices.AccountManagement.GroupPrincipal])]
    param(
        [string]
        # The name of the group to return.
        $Name 
    )

    Set-StrictMode -Version 'Latest'

    $ctx = New-Object 'DirectoryServices.AccountManagement.PrincipalContext' ([DirectoryServices.AccountManagement.ContextType]::Machine)
    if( $Name )
    {
        $group = [DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity( $ctx, $Name )
        if( -not $group )
        {
            Write-Error ('Local group ''{0}'' not found.' -f $Name) -ErrorAction:$ErrorActionPreference
            return
        }
        return $group
    }
    else
    {
        $query = New-Object 'DirectoryServices.AccountManagement.GroupPrincipal' $ctx
        $searcher = New-Object 'DirectoryServices.AccountManagement.PrincipalSearcher' $query
        $searcher.FindAll() 
    }
}
