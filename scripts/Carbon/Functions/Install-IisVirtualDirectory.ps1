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

function Install-IisVirtualDirectory
{
    <#
    .SYNOPSIS
    Installs a virtual directory.

    .DESCRIPTION
    The `Install-IisVirtualDirectory` function creates a virtual directory under website `SiteName` at `/VirtualPath`, serving files out of `PhysicalPath`.  If a virtual directory at `VirtualPath` already exists, it is updated in palce. (Before Carbon 2.0, the virtual directory was deleted before installation.)

    .EXAMPLE
    Install-IisVirtualDirectory -SiteName 'Peanuts' -VirtualPath 'DogHouse' -PhysicalPath C:\Peanuts\Doghouse

    Creates a /DogHouse virtual directory, which serves files from the C:\Peanuts\Doghouse directory.  If the Peanuts website responds to hostname `peanuts.com`, the virtual directory is accessible at `peanuts.com/DogHouse`.

    .EXAMPLE
    Install-IisVirtualDirectory -SiteName 'Peanuts' -VirtualPath 'Brown/Snoopy/DogHouse' -PhysicalPath C:\Peanuts\DogHouse

    Creates a DogHouse virtual directory under the `Peanuts` website at `/Brown/Snoopy/DogHouse` serving files out of the `C:\Peanuts\DogHouse` directory.  If the Peanuts website responds to hostname `peanuts.com`, the virtual directory is accessible at `peanuts.com/Brown/Snoopy/DogHouse`.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The site where the virtual directory should be created.
        $SiteName,
        
        [Parameter(Mandatory=$true)]
        [Alias('Name')]
        [string]
        # The name of the virtual directory.  This can contain multiple directory segments for virtual directories not at the root of the website, e.g. First/Second/VirtualDirectory.
        $VirtualPath,
        
        [Parameter(Mandatory=$true)]
        [Alias('Path')]
        [string]
        # The file system path to the virtual directory.
        $PhysicalPath,

        [Switch]
        # Deletes the virttual directory before installation, if it exists. Preserves default beheaviro in Carbon before 2.0.
        # 
        # *Does not* delete custom configuration for the virtual directory, just the virtual directory. If you've customized the location of the virtual directory, those customizations will remain in place.
        #
        # The `Force` switch is new in Carbon 2.0.
        $Force
    )
    
    Set-StrictMode -Version 'Latest'

    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    $site = Get-IisWebsite -Name $SiteName
    [Microsoft.Web.Administration.Application]$rootApp = $site.Applications | Where-Object { $_.Path -eq '/' }
    if( -not $rootApp )
    {
        Write-Error ('Default website application not found.')
        return
    }

    $PhysicalPath = Resolve-FullPath -Path $PhysicalPath

    $VirtualPath = $VirtualPath.Trim('/')
    $VirtualPath = '/{0}' -f $VirtualPath

    $vdir = $rootApp.VirtualDirectories | Where-Object { $_.Path -eq $VirtualPath }
    if( $Force -and $vdir )
    {
        Write-IisVerbose $SiteName -VirtualPath $VirtualPath 'REMOVE' '' ''
        $rootApp.VirtualDirectories.Remove($vdir)
        $site.CommitChanges()
        $vdir = $null

        $site = Get-IisWebsite -Name $SiteName
        $rootApp = $site.Applications | Where-Object { $_.Path -eq '/' }
    }

    $modified = $false

    if( -not $vdir )
    {
        [Microsoft.Web.Administration.ConfigurationElementCollection]$vdirs = $rootApp.GetCollection()
        $vdir = $vdirs.CreateElement('virtualDirectory')
        Write-IisVerbose $SiteName -VirtualPath $VirtualPath 'VirtualPath' '' $VirtualPath
        $vdir['path'] = $VirtualPath
        [void]$vdirs.Add( $vdir )
        $modified = $true
    }

    if( $vdir['physicalPath'] -ne $PhysicalPath )
    {
        Write-IisVerbose $SiteName -VirtualPath $VirtualPath 'PhysicalPath' $vdir['physicalPath'] $PhysicalPath
        $vdir['physicalPath'] = $PhysicalPath
        $modified = $true
    }

    if( $modified )
    {
        $site.CommitChanges()
    }
}
