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

filter Unprotect-String
{
    <#
    .SYNOPSIS
    Decrypts a string.
    
    .DESCRIPTION
    `Unprotect-String` decrypts a string encrypted via the Data Protection API (DPAPI) or RSA. It uses the DP/RSA APIs to decrypted the secret into an array of bytes, which is then converted to a UTF8 string. Beginning with Carbon 2.0, after conversion, the decrypted array of bytes is cleared in memory.

    Also beginning in Carbon 2.0, use the `AsSecureString` switch to cause `Unprotect-String` to return the decrypted string as a `System.Security.SecureString`, thus preventing your secret from hanging out in memory. When converting to a secure string, the secret is decrypted to an array of bytes, and then converted to an array of characters. Each character is appended to the secure string, after which it is cleared in memory. When the conversion is complete, the decrypted byte array is also cleared out in memory.

    `Unprotect-String` can decrypt using the following techniques.

    ## DPAPI

    This is the default. The string must have also been encrypted with the DPAPI. The string must have been encrypted at the current user's scope or the local machien scope.

    ## RSA

    RSA is an assymetric encryption/decryption algorithm, which requires a public/private key pair. This method decrypts a secret that was encrypted with the public key using the private key.

    You can specify the private key in three ways: 
    
     * with a `System.Security.Cryptography.X509Certificates.X509Certificate2` object, via the `Certificate` parameter
     * with a certificate in one of the Windows certificate stores, passing its unique thumbprint via the `Thumbprint` parameter, or via the `PrivateKeyPath` parameter, which can be a certificat provider path, e.g. it starts with `cert:\`.
     * with an X509 certificate file, via the `PrivateKeyPath` parameter
   
    .LINK
    New-RsaKeyPair
        
    .LINK
    Protect-String

    .LINK
    http://msdn.microsoft.com/en-us/library/system.security.cryptography.protecteddata.aspx

    .EXAMPLE
    PS> $password = Unprotect-String -ProtectedString  $encryptedPassword
    
    Decrypts a protected string which was encrypted at the current user or default scopes using the DPAPI. The secret must have been encrypted at the current user's scope or at the local computer's scope.
    
    .EXAMPLE
    Protect-String -String 'NotSoSecretSecret' -ForUser | Unprotect-String
    
    Demonstrates how Unprotect-String takes input from the pipeline.  Adds 'NotSoSecretSecret' to the pipeline.

    .EXAMPLE
    Unprotect-String -ProtectedString $ciphertext -Certificate $myCert

    Demonstrates how to encrypt a secret using RSA with a `System.Security.Cryptography.X509Certificates.X509Certificate2` object. You're responsible for creating/loading it. The `New-RsaKeyPair` function will create a key pair for you, if you've got a Windows SDK installed.

    .EXAMPLE
    Unprotect-String -ProtectedString $ciphertext -Thumbprint '44A7C27F3353BC53F82318C14490D7E2500B6D9E'

    Demonstrates how to decrypt a secret using RSA with a certificate in one of the Windows certificate stores. All local machine and user stores are searched. The current user must have permission/access to the certificate's private key.

    .EXAMPLE
    Unprotect -ProtectedString $ciphertext -PrivateKeyPath 'C:\Projects\Security\publickey.cer'

    Demonstrates how to encrypt a secret using RSA with a certificate file. The file must be loadable by the `System.Security.Cryptography.X509Certificates.X509Certificate` class.

    .EXAMPLE
    Unprotect -ProtectedString $ciphertext -PrivateKeyPath 'cert:\LocalMachine\My\44A7C27F3353BC53F82318C14490D7E2500B6D9E'

    Demonstrates how to encrypt a secret using RSA with a certificate in the store, giving its exact path.
    #>
    [CmdletBinding(DefaultParameterSetName='DPAPI')]
    param(
        [Parameter(Mandatory = $true, Position=0, ValueFromPipeline = $true)]
        [string]
        # The text to decrypt.
        $ProtectedString,

        [Parameter(Mandatory=$true,ParameterSetName='RSAByCertificate')]
        [Security.Cryptography.X509Certificates.X509Certificate2]
        # The private key to use for decrypting.
        $Certificate,

        [Parameter(Mandatory=$true,ParameterSetName='RSAByThumbprint')]
        [string]
        # The thumbprint of the certificate, found in one of the Windows certificate stores, to use when decrypting. All certificate stores are searched. The current user must have permission to the private key.
        $Thumbprint,

        [Parameter(Mandatory=$true,ParameterSetName='RSAByPath')]
        [string]
        # The path to the private key to use for encrypting. Must be to an `X509Certificate2` file or a certificate in a certificate store.
        $PrivateKeyPath,

        [Parameter(ParameterSetName='RSAByPath')]
        # The password for the private key, if it has one. It really should. Can be a `[string]` or a `[securestring]`.
        $Password,

        [Parameter(ParameterSetName='RSAByCertificate')]
        [Parameter(ParameterSetName='RSAByThumbprint')]
        [Parameter(ParameterSetName='RSAByPath')]
        [Switch]
        # If true, uses Direct Encryption (PKCS#1 v1.5) padding. Otherwise (the default), uses OAEP (PKCS#1 v2) padding. See [Encrypt](http://msdn.microsoft.com/en-us/library/system.security.cryptography.rsacryptoserviceprovider.encrypt(v=vs.110).aspx) for information.
        $UseDirectEncryptionPadding,

        [Switch]
        # Returns the unprotected string as a secure string. The original decrypted bytes are zeroed out to limit the memory exposure of the decrypted secret, i.e. the decrypted secret will never be in a `string` object.
        $AsSecureString
    )

    Set-StrictMode -Version 'Latest'

    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState
        
    $encryptedBytes = [Convert]::FromBase64String($ProtectedString)
    if( $PSCmdlet.ParameterSetName -eq 'DPAPI' )
    {
        $decryptedBytes = [Security.Cryptography.ProtectedData]::Unprotect( $encryptedBytes, $null, 0 )
    }
    elseif( $PSCmdlet.ParameterSetName -like 'RSA*' )
    {
        if( $PSCmdlet.ParameterSetName -like '*ByPath' )
        {
            $passwordParam = @{ }
            if( $Password )
            {
                $passwordParam = @{ Password = $Password }
            }
            $Certificate = Get-Certificate -Path $PrivateKeyPath @passwordParam
            if( -not $Certificate )
            {
                return
            }
        }
        elseif( $PSCmdlet.ParameterSetName -like '*ByThumbprint' )
        {
            $certificates = Get-ChildItem -Path ('cert:\*\*\{0}' -f $Thumbprint) -Recurse 
            if( -not $certificates )
            {
                Write-Error ('Certificate ''{0}'' not found.' -f $Thumbprint)
                return
            }

            $Certificate = $certificates | Where-Object { $_.HasPrivateKey } | Select-Object -First 1
            if( -not $Certificate )
            {
                Write-Error ('Certificate ''{0}'' ({1}) doesn''t have a private key.' -f $certificates[0].Subject, $Thumbprint)
                return
            }
        }

        if( -not $Certificate.HasPrivateKey )
        {
            Write-Error ('Certificate ''{0}'' ({1}) doesn''t have a private key. When decrypting with RSA, secrets are encrypted with the public key, and decrypted with a private key.' -f $Certificate.Subject,$Certificate.Thumbprint)
            return
        }

        if( -not $Certificate.PrivateKey )
        {
            Write-Error ('Certificate ''{0}'' ({1}) has a private key, but it is currently null or not set. This usually means your certificate was imported or generated incorrectly. Make sure you''ve generated an RSA public/private key pair and are using the private key. If the private key is in the Windows certificate stores, make sure it was imported correctly (`Get-ChildItem $pathToCert | Select-Object -Expand PrivateKey` isn''t null).' -f $Certificate.Subject,$Certificate.Thumbprint)
            return
        }

        [Security.Cryptography.RSACryptoServiceProvider]$privateKey = $null
        if( $Certificate.PrivateKey -isnot [Security.Cryptography.RSACryptoServiceProvider] )
        {
            Write-Error ('Certificate ''{0}'' (''{1}'') is not an RSA key. Found a private key of type ''{2}'', but expected type ''{3}''.' -f $Certificate.Subject,$Certificate.Thumbprint,$Certificate.PrivateKey.GetType().FullName,[Security.Cryptography.RSACryptoServiceProvider].FullName)
            return
        }

        try
        {
            $privateKey = $Certificate.PrivateKey
            $decryptedBytes = $privateKey.Decrypt( $encryptedBytes, (-not $UseDirectEncryptionPadding) )
        }
        catch
        {
            if( $_.Exception.Message -match 'Error occurred while decoding OAEP padding' )
            {
                [int]$maxLengthGuess = ($privateKey.KeySize - (2 * 160 - 2)) / 8
                Write-Error (@'
Failed to decrypt string using certificate '{0}' ({1}). This can happen when:
 * The string to decrypt is too long because the original string you encrypted was at or near the maximum allowed by your key's size, which is {2} bits. We estimate the maximum string size you can encrypt is {3} bytes. You may get this error even if the original encrypted string is within a couple bytes of that maximum.
 * The string was encrypted with a different key
 * The string isn't encrypted

{4}: {5}
'@ -f $Certificate.Subject, $Certificate.Thumbprint,$privateKey.KeySize,$maxLengthGuess,$_.Exception.GetType().FullName,$_.Exception.Message)
                return
            }
            elseif( $_.Exception.Message -match '(Bad Data|The parameter is incorrect)\.' )
            {
                Write-Error (@'
Failed to decrypt string using certificate '{0}' ({1}). This usually happens when the padding algorithm used when encrypting/decrypting is different. Check the `-UseDirectEncryptionPadding` switch is the same for both calls to `Protect-String` and `Unprotect-String`.

{2}: {3}
'@ -f $Certificate.Subject,$Certificate.Thumbprint,$_.Exception.GetType().FullName,$_.Exception.Message)
                return
            }
            Write-Error -Exception $_.Exception
            return
        }
    }

    try
    {
        if( $AsSecureString )
        {
            $secureString = New-Object 'Security.SecureString'
            [char[]]$chars = [Text.Encoding]::UTF8.GetChars( $decryptedBytes )
            for( $idx = 0; $idx -lt $chars.Count ; $idx++ )
            {
                $secureString.AppendChar( $chars[$idx] )
                $chars[$idx] = 0
            }

            $secureString.MakeReadOnly()
            return $secureString
        }
        else
        {
            [Text.Encoding]::UTF8.GetString( $decryptedBytes )
        }
    }
    finally
    {
        [Array]::Clear( $decryptedBytes, 0, $decryptedBytes.Length )
    }
}
