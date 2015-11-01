// � 2015 Sitecore Corporation A/S. All rights reserved.

using System.Collections.Generic;

namespace Sitecore.Pathfinder.Building.Commands
{
    public class TroubleshootWebsite : RequestTaskBase
    {
        public TroubleshootWebsite() : base("troubleshoot-website")
        {
        }

        public override void Run(IBuildContext context)
        {
            context.Trace.TraceInformation("Troubleshooting...");

            var queryStringParameters = new Dictionary<string, string>();

            var url = MakeWebApiUrl(context, "TroubleshootWebsite", queryStringParameters);

            Request(context, url);
        }

        public override void WriteHelp(HelpWriter helpWriter)
        {
            helpWriter.Summary.Write("Tries to fix a non-working website.");
            helpWriter.Remarks.Write("Republishing the Master database, rebuilds search indexes and rebuild the Link database.");
        }
    }
}
