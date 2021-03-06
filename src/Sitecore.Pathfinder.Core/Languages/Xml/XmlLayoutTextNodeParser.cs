﻿// © 2015 Sitecore Corporation A/S. All rights reserved.

using System;
using Sitecore.Pathfinder.Parsing.Items;
using Sitecore.Pathfinder.Snapshots;

namespace Sitecore.Pathfinder.Languages.Xml
{
    public class XmlLayoutTextNodeParser : LayoutTextNodeParserBase
    {
        public XmlLayoutTextNodeParser() : base(Constants.TextNodeParsers.Layouts)
        {
        }

        public override bool CanParse(ItemParseContext context, ITextNode textNode)
        {
            return textNode.Key == "Layout" && textNode.Snapshot is XmlTextSnapshot && textNode.Snapshot.SourceFile.AbsoluteFileName.EndsWith(".layout.xml", StringComparison.OrdinalIgnoreCase);
        }
    }
}
