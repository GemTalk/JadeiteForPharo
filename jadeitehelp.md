## Jadeite for Pharo Help  - with Rowan

Jadeite is a graphical user interface for code development and debugging, for use within a GemStone environment. Jadeite for Pharo is designed to work with Rowan 3, but can be used in a base GemStone image by installing a Rowan stub (v3.7.5 or above). The same version of Jadeite can be used with both Rowan and non-Rowan servers.
The first section of this help applies to Jadeite when used with Rowan; see below for Jadeite without Rowan.

For more information, see the [Github project](https://github.com/GemTalk/JadeiteForPharo).  
 
_This help is in progress_  
  
 Topics are: 
*   Status decorations for Projects, Classes, and Methods
*   Filein and Fileout
*   Known serious issues in this version 
---------------------------------------------------------------------------------------------------
### Font Status Decorations

#### Project status text decoration

A Rowan project is the in-smalltalk-image version of code that is also stored on disk, in a git-based rowan format directory structure. You can load into the image from the git repository, or write/commit the image state to the git repository. Git operations such as commit, checkout, or pull can also be performed outside of jadeite (on the command line, or using other tools).

To allow you to coordinate between the in-image state and the on-disk state, the color, weight (bold) and italic font for a Project's name in the Console's Project List or the System Browser Project Pane indicates the status of the Project in the image, vs. the on-disk status.  More specific details on the Project's status is provided in the  the  lower pane Project tab of the System Browser

###### Example 1. Project List Pane of a System Browser  

   ![Project List Pane Font Decorations](http://downloads.gemtalksystems.com/docs/Other/JfP/ProjectDecorationsJfP.jpg)

This screenshot example shows the following decorations:

*   Normal font for a Project's name (that is, not red, bold, or italic) indicates that it is loaded, and there are no changes either in the image or on disk.    
     
*   **Bold** font indicate that the Project has changes in the image that have not been written to disk.    
     
*   *Italic* font indicates that the Project is dirty on disk, with respect to the git repository. For example, if you have previously written the project to disk without doing a git commit, the disk is dirty, although the image is clean with respect to the disk. Dirty on disk, however, can also mean that you have edited files on disk, or made changes from Jadeite and not saved your image before restarting.     
     
*   Red font indicates there is skew; the sha on disk does not match the sha loaded into the image. This can result if you checkout a different git tag or branch, from Jadeite or on the git command line, if you perform git commit outside of jadeite on the git command line, or if you are working in a shared repository and do a git pull after another user has committed. If you see skew, it is generally recommended to refresh from disk to load the current git sha; otherwise, you should avoid making any changes or performing any git commits, to avoid the risk of logical corruption in the git repository.    
      
*   (projectname) When the project name is enclosed in parenthesis, it indicates that project does not exist on disk.    

######Other Decoration
*   A leading asterisk * indicates that this is the current Project.  This is used when filing in code.
---------------------------------------------------------------------------------------------------
#### Class and Method text decoration

A Rowan project is composed of a collection of Packages (as well as various internal infrastructure for loading).  A Package contain classes and their associated methods,  and methods on classes that are not themselves in this package (extension methods, which extend the behavior of other classes).  All classes and methods in a Package, including extension methods, are in a single SymbolDictionary, which must be defined when the Package is created. Also note that extension methods must be in the same SymbolDictionary as the class they belong to. Depending on how the application uses SymbolDictionaries, this may require packages specifically created to contain extension methods. 

When a Package is selected, Jadeite displays all classes in that package, and also the classes for any extension methods that belong to that package. When a class is selected, Jadeite displays all methods that belong to that class, both in that package and in other packages. Jadeite uses purple and underline text decorations to indicate the relationship of classes and methods to packages.  The specific package that is associated with any given class or method is indicated in the footer area of the Class and Method panes. 


###### Example 1. Package, Class and Method Panes of a System Browser  

   ![Package Class Method Pane Font Decorations](http://downloads.gemtalksystems.com/docs/Other/JfP/MethodDecorationsJfP.jpg)

This screenshot example shows the following decorations:

*   A class is in normal font and a method in normal font indicate that the Class and method is defined in the selected Package.     
     
*   A class in purple indicates that the class definition is associated with a different package; the class is included in the list of classes since it has one or more extension methods that are defined in this package. The class/method pane footer area shows the Package for that class/method.       
     
*   If the class is in normal and the method is in purple and underlined , it indicates that the method is defined in a different package; the other package contains an extension method to the selected class.  The class/method pane footer area n shows the Package for that class/method.       
     
*   If the class is in purple and the method is in normal font, it indicates that the method is defined in the same package as the class, and that neither the class nor the definition are in the selected package. The class/method pane footer area shows the Package for that class/method.      
          

*   If the class is in purple and the method is in purple (not underlined), it indicates that the method is defined in the selected package; that is, this is an extension method in the selected package.    
       
*   If the class is in purple and the method is in purple and underlined , it indicates that the method is defined in a third package, neither the selected package nor the package that the class is defined on. The pane at the base of the class/method column shows the Package for that class/method.         


######Other Decoration
*   Packages are in **bold** font when there are changes that have not been written to disk. There is no decoration for changes in classes or methods.  To find out what has changed, u se the Project pane Changes menu item to open the Changes Browser.

*   A leading asterisk * indicates that this is the current Package.  This is primarily used when filing in code.

### Filein and Fileout

Code can be filed out in topaz format, or filed in from topaz format. The Filein process rowanizes the code; filein requires some care to ensure the filein complies with Rowan's rules so the rowanization process can succeed. 

#### Fileout

Jadeite implements fileout menu items to fileout a Project, Package, Class, one or more class categories, and one or more selected methods.

#### Filein

Filing topaz format code into Rowan using Jadeite "rowanizes" the code. This places some requirements on what is filed in, since Rowan has rules for SymbolDictionaries and Packages that the filein must conform to.

Each Rowan package is  associated with a single SymbolDictionary, and all classes and methods in that package must be in that same SymbolDictionary. 

If your fileout includes class definitions, which specify the SymbolDictionary name, the specified name **must** match the SymbolDictionary of the package that this code will be filed into. Since the package must be created (with the correct SymbolDictionary) before you can filein, any SymbolDictionary creation expression in the filein will not be sufficient. If the SymbolDictionary specified by the class creation statements in the filein code does not exist, before filein you need to setup the correct SymbolDictionary and Package.   If your filein includes classes in multiple dictionaries, you will need to break the file into multiple files per SymbolDictionary, and file these in separately.  

To filein, in the System Browser:
*   If necessary, create the symbol dictionary associated with the classes in your filein code. Break this into multiple filein files by SymbolDictionary, if necessary.
This can be doneby going to the the Package pane, selecting the Dictionary tab, using the Add Dictionary menu item.
*   Choose or create a Project.
*   Choose or create a Package for your filein code, specifying the SymbolDictionary used in the filein file. 
*   Commit, to ensure your Project and Package are committed, and to allow recovery if there are issues during filein.
*   Select the Project and Package, and use the Set Current menu item. They will now have an asterisk.
*   File in using the Jadeite menu item File In Server File. Note this provides a dialog for files located on your GemStone server (the node on which GemStone is running). If Pharo is running on a different node, you cannot load in from files on the client file system. 

Also note that if your code includes a class initialize method, Rowan automatically executes this when the class is loaded.  If the initialize method invokes methods that have no yet been filed it, it may fail. You may need to factor the initialize code to accomodate Rowan initialization.

##Known issues and limitations in this version

### Changes to Class definitions that encounter compile errors

When an instance variable is added to a class, and that instance variable is already defined in a superclass or subclass, oe more more classes will fail to compile. When an added instance variable was already in use as a method temporary or a method argument in a method on this class or a subclass, the class is compiled, but one or more methods will fail recompile.  Removing an instance variable that is referenced will also cause method recompilation failures during class compile.

Handling these cases has been problematic.  There may still be significant issues.  Before modifying the definition of any existing class, we strongly recommend a GemStone commit.  If there are issues with recompile, abort and make the necessary changes, and commit to GemStone again before retrying. 

### Saving the current frame in the Debugger 

To avoid problems with stack trimming in earlier versions, saving a method in the debugger is disabled. To modify a method in the debugger, use the Debugger frame list pop up menu item Browse In Method List. 

### Viewing the Class Hierarchy

Normally, the System Browser Class Pane displays the alphabetical list of classes in the selected package. 

Selecting the hierarchy view tab displays the hierachy of the class that was selected in the Class view; if more than one class was selected, the hierachy includes all selected classes, or all classes in the package if no class was selected.  The displayed hierachy includes the specified classes, their subclasses, and superclasses up to Object. **Sibling classes at any level are not shown**.  The down-pointing triangle indicates that the hierachy is expanded; clicking on this will contract it and display a left-pointing triangle, and vice versa.  
To see the full hierarchy, select a class and use the menu item expand full hierarchy. 

Double clicking on a class is designed to expand the view to includes all subclasses of that class in the heirachy view, including siblings of the selected class/classes. There are some issues with this behavior; you must specifically select the class first, before double clicking.  There may be incorrect behavior such that you do not see classes that are part of the hierarchy.

## Jadeite for Pharo Help  - without Rowan

In Jadeite without Rowan, code is not rowanized, and the base image behavior is preserved.

The leftmost pane organizes the display by SymbolDictionaries.

The next pane is class categories.  This provides an alternate way to organize the classes in an application.

