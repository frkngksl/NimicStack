import winim
import ptr_math
import Structs
import CallStacks

proc PrintBanner():void = 
    var banner = """

███╗   ██╗██╗███╗   ███╗██╗ ██████╗███████╗████████╗ █████╗  ██████╗██╗  ██╗
████╗  ██║██║████╗ ████║██║██╔════╝██╔════╝╚══██╔══╝██╔══██╗██╔════╝██║ ██╔╝
██╔██╗ ██║██║██╔████╔██║██║██║     ███████╗   ██║   ███████║██║     █████╔╝ 
██║╚██╗██║██║██║╚██╔╝██║██║██║     ╚════██║   ██║   ██╔══██║██║     ██╔═██╗ 
██║ ╚████║██║██║ ╚═╝ ██║██║╚██████╗███████║   ██║   ██║  ██║╚██████╗██║  ██╗
╚═╝  ╚═══╝╚═╝╚═╝     ╚═╝╚═╝ ╚═════╝╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝
                                                                            
                                @R0h1rr1m                                       
"""
    echo banner

    
when isMainModule:
    PrintBanner()