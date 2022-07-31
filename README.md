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

# References

- https://labs.withsecure.com/blog/spoofing-call-stacks-to-confuse-edrs/
- https://github.com/countercept/CallStackSpoofer
