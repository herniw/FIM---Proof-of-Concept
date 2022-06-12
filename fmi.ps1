                                #Hernan Weiss - File Integrity Monitoring Script

#This PowerShell Script has been written while using Google and Youtube videos.
#Not all lines came from my own knowledge as I am still learning the ropes of PS scripting and logics.
#Even following along presented some challenges as I wanted to troubleshoot problems without directly copying the right answer or pieces of code.

Function Calculate-File-Hash($filepath) {
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA256
    return $filehash
}

Function Erase-Baseline-If-Already-Exist() {
    $baselineexist = Test-Path -Path C:\Users\herna\OneDrive\Escritorio\FIM\baseline.txt

   if ($baselineexist) {
        Remove-Item -Path .\baseline.txt
}
}


Write-Host ""
Write-Host "Select an option"
Write-Host "     1) Collect new baseline"
Write-Host "     2) Begin monitoring"

$Choice = Read-Host -Prompt "Please select option 1 or 2"

Write-Host ""
Write-Host "User choose $($Choice)"

    # At this point there is not error checking built into the script
    # For the sake of simplicity I am gonna assume the user selected a valid option


if ($Choice -eq "1"){
    # Erase baseline.txt if it already exist
    Erase-Baseline-If-Already-Exist
    
    # Get hash value from selected files and then stored them in baseline.txt
    # Collecting all files in target folder
    $files = Get-ChildItem -Path C:\Users\herna\OneDrive\Escritorio\FIM\files

    # Calculate each file hash and store it to baseline.txt
    foreach ($f in $files) {
       $hash = Calculate-File-Hash $f.FullName
       "$($hash.Path)|$($hash.hash)" | Out-File -FilePath C:\Users\herna\OneDrive\Escritorio\FIM\baseline.txt -Append
    }
}

elseif ($Choice -eq "2"){    

    $Dictionary = @{}

    # Load file|hash from baseline.txt and store them in a dictionary
    $filePathandHash = Get-Content -Path .\baseline.txt
    
    # This function was giving me a lot of troubles for some reason and learned that sometimes deleting and writing it again from scratch solves the problem for some reason
    foreach ($f in $filePathandHash){
        $Dictionary.add($f.Split("|")[0],$f.Split("|")[1])
    }

    # Monitor (nonstop) hash values by comparing with baseline.txt
    while ($true){
        Start-Sleep -Seconds 1
        
        $files = Get-ChildItem -Path C:\Users\herna\OneDrive\Escritorio\FIM\files

        # Calculate each file hash and store it to baseline.txt
        foreach ($f in $files) {
           $hash = Calculate-File-Hash $f.FullName
           #"$($hash.Path)|$($hash.hash)" | Out-File -FilePath C:\Users\herna\OneDrive\Escritorio\FIM\baseline.txt -Append

           if ($Dictionary[$hash.Path] -eq $null) {
            # New file creation notification
            Write-Host "$($hash.Path) has been created!" -ForegroundColor Yellow
           }

           else{
               # New file modification notification
               if ($Dictionary[$hash.Path] -eq $hash.Hash) {
                    # File hasn't changed
               }
               else{
                    # File has been changed
                    Write-Host "$($Hash.Path) has changed!" -ForegroundColor Red
               }
          }

    }

            # Checking for files deletion and notifying user
            foreach ($key in $Dictionary.keys){
            $baselinesFilesStillExist = Test-Path -Path $key
            if (-Not $baselinesFilesStillExist){
                # A file in baseline.txt has been deleted
                Write-Host "$($key) has been deleted!" -ForegroundColor magenta
            }
          }
  }
}





   
    




    
