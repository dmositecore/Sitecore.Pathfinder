// � 2015 Sitecore Corporation A/S. All rights reserved.

using System.Linq;
using Sitecore.Pathfinder.Snapshots;

namespace Sitecore.Pathfinder.Emitters.FieldResolvers.Layouts
{
    public class XmlLayoutResolver : LayoutResolverBase
    {
        public override string Resolve(LayoutResolveContext context, ITextNode textNode)
        {
            var layoutTextNode = textNode.ChildNodes.FirstOrDefault();
            if (layoutTextNode == null)
            {
                return string.Empty;
            }

            return base.Resolve(context, layoutTextNode);
        }
    }
}