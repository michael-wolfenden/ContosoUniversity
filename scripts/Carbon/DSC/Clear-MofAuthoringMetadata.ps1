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

function Clear-MofAuthoringMetadata
{
    <#
    .SYNOPSIS
    Removes authoring metadata from .mof files.

    .DESCRIPTION
    Everytime PowerShell generates a .mof file, it includes authoring metadata: who created the file, on what computer, and at what date/time. This means a .mof file's checksum will change everytime a new one is generated, even if the configuration in that file didn't change. This makes it hard to know when a configuration in a .mof file has truly changed, and makes its change history noisy. This function strips/removes all authoring metadata from a .mof file.

    When given a path to a file, all authoring metadata is removed from that file. When given the path to a directory, removes authoring metadata from all `*.mof` files in that directory.

    Essentially, these blocks from each .mof file:

        /*
        @TargetNode='********'
        @GeneratedBy=********
        @GenerationDate=08/19/2014 13:29:15
        @GenerationHost=********
        */

        /* ...snip... */

        
        instance of OMI_ConfigurationDocument
        {
         Version="1.0.0";
         Author="********;
         GenerationDate="08/19/2014 13:29:15";
         GenerationHost="********";
        };

    Would be changed to:

        /*
        @TargetNode='JSWEB01L-WHS-08'
        */

        /* ...snip... */
        
        instance of OMI_ConfigurationDocument
        {
         Version="1.0.0";
        };


    .EXAMPLE
    Clear-MofAuthoringMetadata -Path 'C:\Projects\DSC\localhost.mof'

    Demonstrates how to clear the authoring data from a specific file.

    .EXAMPLE
    Clear-MofAuthoringMetadata -Path 'C:\Projects\DSC'

    Demonstrates how to clear the authoring data from all .mof files in a specific directory.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The path to the file/directory whose .mof files should be operated on.
        $Path
    )

    Set-StrictMode -Version 'Latest'

    $tempDir = New-TempDirectory -Prefix ('Carbon+ClearMofAuthoringMetadata+') -WhatIf:$false

    foreach( $item in (Get-ChildItem -Path $Path -Filter '*.mof') )
    {
        Write-Verbose ('Clearing authoring metadata from ''{0}''.' -f $item.FullName)
        $tempItem = Copy-Item -Path $item.FullName -Destination $tempDir -PassThru -WhatIf:$false
        $inComment = $false
        $inAuthoringComment = $false
        $inConfigBlock = $false;
        Get-Content -Path $tempItem |
            Where-Object {
                $line = $_

                if( $line -like '/`**' )
                {
                    if( $line -like '*`*/' )
                    {
                        return $true
                    }
                    $inComment = $true
                    return $true
                }

                if( $inComment )
                {
                    if( $line -like '*`*/' )
                    {
                        $inComment = $false
                        $inAuthoringComment = $false
                        return $true
                    }

                    if( $line -like '@TargetNode=*' )
                    {
                        $inAuthoringComment = $true
                        return $true
                    }

                    if( $inAuthoringComment )
                    {
                        return ( $line -notmatch '^@(GeneratedBy|Generation(Host|Date))' )
                    }

                    return $true
                }

                if( $line -eq 'instance of OMI_ConfigurationDocument' )
                {
                    $inConfigBlock = $true
                    return $true
                }

                if( $inConfigBlock )
                {
                    if( $line -like '};' )
                    {
                        $inConfigBlock = $false;
                        return $true
                    }

                    return ($line -notmatch '(Author|(Generation(Date|Host)))=');
                }

                return $true

            } | 
            Set-Content -Path $item.FullName -Verbose:$VerbosePreference
    }
}