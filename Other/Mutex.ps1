#Mutex is system wide
#Copy this code into 2 consoles/ISE windows
$Mutex = [System.Threading.Mutex]::new($false,"MyMutex") 
$Mutex.WaitOne()

#One console should be locked, the other you can interact with:
"Some junk"
#release for other threads and see the locked console unlock
$Mutex.ReleaseMutex()

"Do stuff"