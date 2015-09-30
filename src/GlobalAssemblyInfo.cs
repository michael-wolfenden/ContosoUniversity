using System.Reflection;

[assembly: AssemblyDescription("Contoso University")]
[assembly: AssemblyProduct("Contoso University")]
[assembly: AssemblyCopyright("Copyright © Michael Wolfenden 2015")]
[assembly: AssemblyVersion("0.0.0.0")]
[assembly: AssemblyFileVersion("0.0.0.0")]

#if DEBUG
[assembly: AssemblyConfiguration("Debug")]
#else
[assembly: AssemblyConfiguration("Release")]
#endif
