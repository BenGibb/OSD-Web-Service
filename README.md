# OSD-Web-Service
Powershell Web service with a focus on OS deployment with MDT/PDQ

<!--
## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

What things you need to install the software and how to install them

```
Give examples
```

### Installing

A step by step series of examples that tell you how to get a development env running

Say what the step will be

```
Give the example
```

And repeat

```
until finished
```

End with an example of getting some data out of the system or using it for a little demo

## Running the tests

Explain how to run the automated tests for this system

### Break down into end to end tests

Explain what these tests test and why

```
Give an example
```

### And coding style tests

Explain what these tests test and why

```
Give an example
```

## Deployment

Add additional notes about how to deploy this on a live system
-->
## Built With
* [Visual Studio Code](https://code.visualstudio.com/) - Wonderful extensible editor
    * [Material Theme](https://material-theme.site/) (Darker High Contrast) - Happy eyes ^_^
    * [Material Icon Theme](https://marketplace.visualstudio.com/items?itemName=PKief.material-icon-theme) - All the icons so you can see what you are editing
    * [Indent Rainbow](https://marketplace.visualstudio.com/items?itemName=oderwat.indent-rainbow) - Taste the Indent&trade;
    * [Bracket Pair Colorizer](https://marketplace.visualstudio.com/items?itemName=CoenraadS.bracket-pair-colorizer-2) - No more guessing what scope you are in
    * [Highlight Matching Tag](https://marketplace.visualstudio.com/items?itemName=vincaslt.highlight-matching-tag) - Maco Polo for tags
    * [Better Comments](https://marketplace.visualstudio.com/items?itemName=aaron-bond.better-comments) - Speak from the shadows with style
    * [GitLens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens) - Who did what to the code and when!
    * [WakaTime](https://marketplace.visualstudio.com/items?itemName=WakaTime.vscode-wakatime) - Shiny graphs and metrics about what you have done
        - [WakaTime for this project](https://wakatime.com/@cf341c03-af0e-4792-94ee-79c64dcf5bec/projects/dogiwxznos?start=2019-08-27&end=2019-09-02)
<!--
## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 
-->

## Authors
* **Nicolas Lacour (Diagg)** - *Inital work* - [OSD-Couture.com](http://www.osd-couture.com/p/pr.html)
    * 20/12/2018 - v0.1.0 > 27/03/2019 - v0.8.1* - [OSD-Web-Service](https://github.com/Diagg/OSD-Web-Service)
* **Ben Gibb** - *Overhaul to tie more tightly into MDT and support PDQ Deploy* - [BenGibb](https://github.com/BenGibb/OSD-Web-Service)

<!-- See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project. -->
<!--
## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
-->
## Acknowledgments

* Big thanks to Diagg for the original code!
* Original code inspired by:
    * Initial code by Steve Lee from Microsoft (https://www.powershellgallery.com/packages/HttpListener/1.0.2/Content/HTTPListener.psm1)
    * First edit and CSV formating by Sylvain Lesire
    * Post method by Peter Hinchley (https://hinchley.net/articles/create-a-web-server-using-powershell/)
    * Async .Net callback function by Oisin Grehan (http://www.nivot.org/post/2009/10/09/PowerShell20AsynchronousCallbacksFromNET)
    * Async Request from Brandon Olin (https://www.powershellgallery.com/packages/PSHealthZ/1.0.0/Content/Public%5CStart-HealthZListener.ps1)

# To do
## Properly comment all code
- Learn what everything does

### Resources
 - [Powershell practice and style - Documentation and Comments](https://poshcode.gitbooks.io/powershell-practice-and-style/Style-Guide/Documentation-and-Comments.html)

## Upgrade code to latest "Strict Mode"
[Powershell Strict Mode versions 1.0 and 2.0](https://4sysops.com/archives/powershell-strict-mode-version-1-0-and-2-0/)

## Optimise code

### Resources
 - [Powershell practice and style - Documentation and Comments](https://poshcode.gitbooks.io/powershell-practice-and-style/Style-Guide/Documentation-and-Comments.html)

## Externalise existing functions and convert into libraries
- Greater control over what is exported from the module
- By default all module variables are private preventing accidental overlap
- Functions can be accessed directly using the module namespace (Module\FunctionName)
- Will allow for easy re-use of code in other projects

### Resources
- [Powershell module building basics](https://powershellexplained.com/2017-05-27-Powershell-module-building-basics/)

## Connect into the PDQ SQLite databases
- Do useful things like map members of a group to their computer name in PDQ Inventory

### Resources
- [Correlate members of a group to their computer from PDQ Inventory](https://github.com/Sakuru/PDQ_Things/blob/master/AD_Group_to_PDQ_Computer.ps1)
- [SQLite Tutorial](https://www.sqlitetutorial.net/)
- [SQLite and PowerShell](http://ramblingcookiemonster.github.io/SQLite-and-PowerShell/)
    - [RamblingCookieMonster/PSSQLite](https://github.com/RamblingCookieMonster/PSSQLite)
- [PowerShell: Accessing SQLite databases](https://social.technet.microsoft.com/wiki/contents/articles/30562.powershell-accessing-sqlite-databases.aspx) - SQLite .NET assemblies

#### Performance
- [How to massively improve SQLite Performance (using SqlWinRT)](https://blogs.msdn.microsoft.com/andy_wigley/2013/11/21/how-to-massively-improve-sqlite-performance-using-sqlwinrt/) - Async.Await
- [Squeezing Performance from SQLite: Insertions](https://medium.com/@JasonWyatt/squeezing-performance-from-sqlite-insertions-971aff98eef2)
- [Learn How To Optimize SQLite Performance For 2019](https://www.whoishostingthis.com/compare/sqlite/optimize/)

## Convert code to use true multithreading
- Better handling of HTTPListener including non-blocking concurrent requests

### Resources
- [Using Background Runspaces Instead of PSJobs For Better Performance](https://learn-powershell.net/2012/05/13/using-background-runspaces-instead-of-psjobs-for-better-performance/)
- [Runspaces Simplified (as much as possible)](https://blog.netnerds.net/2016/12/runspaces-simplified/)
- [True Multithreading in PowerShell](http://www.get-blog.com/?p=189)
- [Sharing Variables and Live Objects Between PowerShell Runspaces](https://learn-powershell.net/2013/04/19/sharing-variables-and-live-objects-between-powershell-runspaces/)
