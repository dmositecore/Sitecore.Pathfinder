﻿namespace Sitecore.Pathfinder.Documents.Xml
{
  using System;
  using System.Collections.Generic;
  using System.IO;
  using System.Linq;
  using System.Xml.Linq;
  using System.Xml.Schema;
  using Sitecore.Pathfinder.Diagnostics;
  using Sitecore.Pathfinder.Parsing;

  public class XmlTextSnapshot : TextSnapshot
  {
    protected static readonly Dictionary<string, XmlSchemaSet> Schemas = new Dictionary<string, XmlSchemaSet>();

    private ITextNode root;

    private XElement rootElement;

    public XmlTextSnapshot([NotNull] ISourceFile sourceFile, [NotNull] string contents) : base(sourceFile, contents)
    {
      this.IsEditable = true;
    }

    public override ITextNode Root => this.root ?? (this.root = this.RootElement == null ? TextNode.Empty : this.Parse(null, this.RootElement));

    [NotNull]
    protected ISnapshotService SnapshotService { get; }

    [CanBeNull]
    protected XElement RootElement
    {
      get
      {
        if (this.rootElement != null)
        {
          return this.rootElement;
        }

        XDocument doc;
        try
        {
          doc = XDocument.Parse(this.Contents, LoadOptions.PreserveWhitespace | LoadOptions.SetLineInfo);
        }
        catch
        {
          return null;
        }

        this.rootElement = doc.Root;
        if (this.rootElement == null)
        {
          return null;
        }

        return this.rootElement;
      }
    }

    public override void BeginEdit()
    {
      this.IsEditing = true;
    }

    public override void EndEdit()
    {
      if (!this.IsEditing)
      {
        throw new InvalidOperationException("Document is not in edit mode");
      }

      if (this.root == null)
      {
        return;
      }

      this.IsEditing = false;
      this.rootElement.Save(this.SourceFile.FileName, SaveOptions.DisableFormatting);
    }

    public override ITextNode GetNestedTextNode(ITextNode textNode, string name)
    {
      return textNode;
    }

    public override void ValidateSchema(IParseContext context, string schemaNamespace, string schemaFileName)
    {
      var doc = this.RootElement?.Document;
      if (doc == null)
      {
        return;
      }

      XmlSchemaSet schema;
      if (!Schemas.TryGetValue(schemaNamespace, out schema))
      {
        schema = this.GetSchema(context, schemaFileName, schemaNamespace);
        Schemas[schemaNamespace] = schema;
      }

      if (schema == null)
      {
        return;
      }

      ValidationEventHandler validate = delegate(object sender, ValidationEventArgs args)
      {
        switch (args.Severity)
        {
          case XmlSeverityType.Error:
            context.Trace.TraceError(string.Empty, context.Snapshot.SourceFile.FileName, new TextPosition(args.Exception.LineNumber, args.Exception.LinePosition, 0), args.Message);
            break;
          case XmlSeverityType.Warning:
            context.Trace.TraceWarning(string.Empty, context.Snapshot.SourceFile.FileName, new TextPosition(args.Exception.LineNumber, args.Exception.LinePosition, 0), args.Message);
            break;
        }
      };

      try
      {
        doc.Validate(schema, validate);
      }
      catch (Exception ex)
      {
        context.Trace.TraceError(Texts.The_file_does_not_contain_valid_XML, context.Snapshot.SourceFile.FileName, TextPosition.Empty, ex.Message);
      }
    }

    [CanBeNull]
    protected virtual XmlSchemaSet GetSchema([NotNull] IParseContext context, [NotNull] string schemaFileName, [NotNull] string schemaNamespace)
    {
      var fileName = Path.Combine(context.Configuration.Get(Constants.Configuration.ToolsDirectory), "schemas\\" + schemaFileName);
      if (!context.Project.FileSystem.FileExists(fileName))
      {
        return null;
      }

      var schemas = new XmlSchemaSet();
      schemas.Add(schemaNamespace, fileName);

      return schemas;
    }

    [NotNull]
    protected virtual ITextNode Parse([CanBeNull] ITextNode parent, [NotNull] XElement element)
    {
      var treeNode = new XmlTextNode(this, element, parent);
      parent?.ChildNodes.Add(treeNode);

      foreach (var attribute in element.Attributes())
      {
        if (attribute.Name.LocalName == "xmlns")
        {
          continue;
        }

        var attributeTreeNode = new XmlTextNode(this, attribute);
        treeNode.Attributes.Add(attributeTreeNode);
      }

      if (!element.HasElements)
      {
        var node = element.Nodes().FirstOrDefault();
        if (node != null)
        {
          var attributeTreeNode = new XmlTextNode(this, node, "[Value]", element.Value);
          treeNode.Attributes.Add(attributeTreeNode);
        }
      }

      foreach (var child in element.Elements())
      {
        this.Parse(treeNode, child);
      }

      return treeNode;
    }
  }
}