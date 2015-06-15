﻿<%@ Page Language="C#" AutoEventWireup="true" %>

<%@ Import Namespace="Sitecore.Pathfinder.Packages" %>
<%@ Import Namespace="Sitecore.Pathfinder.Packages.Packages" %>
<!DOCTYPE html>
<%
    var queryText = Request.QueryString["q"] ?? string.Empty;
    var author = Request.QueryString["author"] ?? string.Empty;
    var tags = Request.QueryString["tags"] ?? string.Empty;

    var packageService = new PackageService();
    var packages = packageService.CheckForAvailableUpdates(packageService.GetAvailablePackages(queryText, author, tags)).ToList();
%>
<html class="fuelux">
<head>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <title>Sitecore Pathfinder</title>
    <link rel="stylesheet" type="text/css" href="//fonts.googleapis.com/css?family=Open+Sans" />
    <link href="/sitecore/shell/client/Speak/Assets/css/speak-default-theme.css" rel="stylesheet" type="text/css" />
    <link href="/sitecore/shell/client/Applications/Pathfinder/Packages.css" rel="stylesheet" type="text/css" />
</head>
<body class="sc sc-fullWidth">
    <div class="sc-list">
        <div class="container-narrow">
            <header class="sc-globalHeader">
                <div class="row sc-globalHeader-content">
                    <div class="col-md-6">
                        <div class="sc-globalHeader-startButton">
                            <a class="sc-global-logo medium" href="/sitecore/shell/sitecore/client/Applications/Launchpad"></a>
                        </div>
                        <div class="sc-globalHeader-navigationToggler">
                            <div class="sc-navigationPanelToggleButton">
                                <button class="btn sc-togglebutton btn-default noText" type="button">
                                    <div class="sc-icon" style="background-image: url(/sitecore/shell/client/Speak/Assets/img/Speak/NavigationPanelToggleButton/navigationPanelToggleIcon.png); background-position: 50% 50%;">
                                    </div>
                                    <span class="sc-togglebutton-text"></span>
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="sc-globalHeader-loginInfo">
                            <ul class="sc-accountInformation">
                                <li>
                                    <a class="logout" href="/api/sitecore/Authentication/Logout?sc_database=master">Logout</a>
                                </li>
                                <li>
                                    <%= Sitecore.Context.User.Profile.FullName %>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </header>

            <section class="sc-applicationContent">
                <div class="sc-navigation-wrapper">
                    <nav class="sc-applicationContent-navigation sc-navigation-menu">

                        <div class="sc-menu">
                            <div class="menuroot">
                                <div class="header menuItem open">
                                    <a href="#">
                                        <img class="menuicon" src="/~/icon/OfficeWhite/24x24/checkbox_selected.png" alt="Navigation"><span class="toplevel">Pathfinder</span>
                                    </a>
                                    <img class="menuchevron">
                                </div>
                                <div class="toplevelcontainer itemsContainer" style="display: block;">
                                    <div>
                                        <div class="itemRow menuItem depth2">
                                            <div class="leftcolumn">&nbsp;</div>
                                            <div class="rightcolumn">
                                                <a href="/sitecore/shell/client/Applications/Pathfinder/InstalledPackages.aspx" class="sc-hyperlinkbutton">Installed Packages</a>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </nav>
                </div>
            </section>
        </div>
    </div>
    <div class="sc-navigation-content">
        <header class="sc-applicationHeader">
            <div class="sc-applicationHeader-row1">
                <div class="sc-applicationHeader-content">
                    <div class="sc-applicationHeader-title">
                        <span class="sc-text">Available Packages</span>
                    </div>
                </div>

                <div class="sc-applicationHeader-content breadcrumb">
                    <div class="sc-applicationHeader-breadCrumb">
                        <div class="sc-breadcrumb">
                            <ul>
                                <li>
                                    <a href="/sitecore/shell/client/Applications/Pathfinder/Packages.aspx">Pathfinder</a>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>

            <div class="sc-applicationHeader-row2">
                <div class="sc-applicationHeader-back">
                    <p style="font-size: 24px">There are <% =packages.Count().ToString("#,##0") %> packages</p>
                </div>
                <div class="sc-applicationHeader-contextSwitcher">
                </div>
                <div class="sc-applicationHeader-actions">
                </div>
            </div>
        </header>

        <section class="sc-applicationContent-main">
            <div class="sc-border">
                <p></p>
                <form>
                    <div class="sc-buttontextbox input-group">                                  
	                    <input class="form-control" type="text" placeholder="Search" name="q" id="q" value="<% =queryText %>"><span class="input-group-btn"><button class="btn btn-default"><img src="/sitecore/shell/client/Speak/Assets/img/Speak/Common/16x16/dark_gray/search.png"></button></span>
                    </div>
                </form>               
                <p></p>
                <table class="table">
                    <tr>
                        <th colspan="2">Package</th>
                    </tr>

                    <% if (!packages.Any())
                        { %>
                    <tr>
                        <td colspan="3">
                            <i>There is nothing to show.</i>
                        </td>
                    </tr>
                    <% }
                        else
                        { %>

                    <% foreach (var package in packages.OrderBy(p => p.Name).ThenByDescending(p => p.Version))
                        {
                            var nuget = (NugetPackage)package;
                            var packageName = nuget.Package.Title ?? nuget.Package.Id;
                            var version = package.Version;
                            var installHref = "/sitecore/shell/client/Applications/Pathfinder/InstallPackage.aspx?i=" + HttpUtility.UrlEncode(package.PackageId);
                            var updateHref = "/sitecore/shell/client/Applications/Pathfinder/InstallPackage.aspx?u=" + HttpUtility.UrlEncode(package.PackageId);
                            var uninstallHref = "/sitecore/shell/client/Applications/Pathfinder/InstallPackage.aspx?r=" + HttpUtility.UrlEncode(package.PackageId);
                            var iconUrl = nuget.Package.IconUrl != null ? nuget.Package.IconUrl.ToString() : "packageDefaultIcon-50x50.png";
                            var packageUrl = "/sitecore/shell/client/Applications/Pathfinder/Package.aspx?id=" + package.PackageId;
                    %>
                    <tr>
                        <td class="sc-package-icon">
                            <img src="<% =iconUrl %>" width="50" height="50" />
                        </td>
                        <td>
                            <p>
                                <a href="<% =packageUrl %>" style="font-size: 24px">
                                    <% = packageName %>
                                </a>
                                <span>by </span>
                                <% foreach (var a in nuget.Package.Authors)
                                    {
                                        var authorUrl = "/sitecore/shell/client/Applications/Pathfinder/Packages.aspx?author=" + a; %>
                                <a href="<%= authorUrl %>"><% = a %></a>
                                <% } %>
                            </p>
                            <p>
                                <% = nuget.Package.Description %>
                            </p>

                            <p>
                                <strong style="font-size: 17px">Version <% = version %></strong>
                                <% if (package.HasUpdate)
                                    { %>
                                <span class="text-muted">- Version <% = package.UpdateVersion %> is installed</span>
                                <% } %>
                                <% if (nuget.Package.Tags != null)
                                    { %>
                                <span style="font-size: 17px">| Tags</span>
                                <% foreach (var tag in nuget.Package.Tags.Split(' '))
                                    {
                                        var tagUrl = "/sitecore/shell/client/Applications/Pathfinder/Packages.aspx?tags=" + tag; %>
                                <a href="<% = tagUrl %>"><% = tag %></a>
                                <% } %>
                                <% } %>
                            </p>
                            <p>
                            <% if (package.IsInstalled)
                                { %> 
                                <span>Installed</span>
                            <% } %>

                            <% if (package.IsInstalled && package.HasUpdate)
                                { %> 
                                | <a href="<% = updateHref %>">Update</a>
                            <% } %>

                            <% if (package.IsInstalled)
                                { %> 
                                | <a href="<% = uninstallHref %>">Uninstall</a>
                            <% } %>

                            <% if (!package.IsInstalled)
                                { %>
                                 <a href="<% = installHref %>">Install</a>
                            <% } %>
                            </p>
                        </td>
                    </tr>
                    <% } %>

                    <% } %>
                </table>
            </div>
        </section>
    </div>
</body>
</html>
