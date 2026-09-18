
using System.Reflection;

namespace Yujanggi.Core.Version
{
    public static class CoreVersion
    {
        public static string Current
        {
            get
            {
                string? version = typeof(CoreVersion)
                    .Assembly
                    .GetCustomAttribute<AssemblyInformationalVersionAttribute>()?
                    .InformationalVersion;

                return version?.Split('+')[0] ?? "unknown";
            }
        }
    }
}