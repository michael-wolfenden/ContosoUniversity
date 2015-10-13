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

function Complete-Job
{
    <#
    .SYNOPSIS
    OBSOLETE. Use PowerShell's `Wait-Job` cmdlet instead. Will be removed in a future major version of Carbon.

    .DESCRIPTION
    OBSOLETE. Use PowerShell's `Wait-Job` cmdlet instead. Will be removed in a future major version of Carbon.

    .EXAMPLE
    Get-Job | Wait-Job

    Demonstrates that `Complete-Job` is OBSOLETE and you should use PowerShell's `Wait-Job` cmdlet instead.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [Management.Automation.Job[]]
        # The jobs to complete.
        [Alias('Jobs')]
        $Job,
        
        [Parameter()]
        [int]
        # The number of seconds to sleep between job status checks.  Default is 1 second.
        $IntervalSeconds = 1
    )

    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    Write-Warning ('Complete-Job is obsolete and will be removed in a future major version of Carbon. Use PowerShell''s `Wait-Job` cmdlet instead.')
    
    $errorAction = 'Continue'
    $params = $PSBoundParameters
    if( $PSBoundParameters.ContainsKey( 'ErrorAction' ) )
    {
        $errorAction = $PSBoundParameters.ErrorAction
    }

    trap { Write-Warning "Unhandled error found: $_" }
    $numFailed = 0
    do
    {
        Start-Sleep -Seconds $IntervalSeconds
        
        $jobsStillRunning = $false
        foreach( $pendingJob in $Job )
        {
            $currentJob = Get-Job $pendingJob.Id -ErrorAction SilentlyContinue
            if( -not $currentJob )
            {
                Write-Verbose "Job with ID $($pendingJob.Id) doesn't exist."
                continue
            }
            
            try
            {
                Write-Verbose "Job $($currentJob.Name) is in the $($currentJob.State) state."
                
                $jobHeader = "# $($currentJob.Name): $($currentJob.State)"
                if( $currentJob.State -eq 'Blocked' -or $currentJob.State -eq 'Stopped')
                {
                    Write-Host $jobHeader

                    Write-Verbose "Stopping job $($currentJob.Name)."
                    Stop-Job -Job $currentJob

                    Write-Verbose "Receiving job $($currentJob.Name)."
                    Receive-Job -Job $currentJob -ErrorAction $errorAction| Write-Host

                    Write-Verbose "Removing job $($currentJob.Name)."
                    Remove-Job -Job $currentJob
                    $numFailed += 1
                }
                elseif( $currentJob.State -eq 'Completed' -or $currentJob.State -eq 'Failed' )
                {
                    Write-Host $jobHeader

                    Write-Verbose "Receiving job $($currentJob.Name)."
                    Receive-Job -Job $currentJob -ErrorAction $errorAction | Write-Host

                    Write-Verbose "Removing job $($currentJob.Name)."
                    Remove-Job -Job $currentJob
                    if( $currentJob.State -eq 'Failed' )
                    {
                        $numFailed += 1
                    }
                }
                elseif( $currentJob.State -eq 'NotStarted' -or $currentJob.State -eq 'Running' )
                {
                    $jobsStillRunning = $true
                }
                else
                {
                    Write-Error "Found unknown job state $($currentJob.State)."
                }
            }
            catch
            {
                Write-Warning "Encountered error handling job $($currentJob.Name)."
                Write-Warning $_
            }
        }
        
     } while( $jobsStillRunning )
     
     return $numFailed
}

Set-Alias -Name 'Complete-Jobs' -Value 'Complete-Job'