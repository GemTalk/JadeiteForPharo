## Jadeite Help  

Jadeite is a graphical user interface for code development and debugging, for use with the Rowan code manager within a GemStone environment. For more information, see the [Github project](https://github.com/GemTalk/JadeiteForPharo).  
 
_This help is incomplete, in progress for unreleased Jadeite for Pharo_  
  
 Topics are: 
*   Status decorations for Projects, Classes, and Methods
*   Filein and Fileout
*   Viewing the Class Hierarchy
*   Issues with Modifying Class instance variables and method recompile in this alpha version

### Font Status Decorations

#### Project status text decoration

The color, weight (bold) and italic font for a Project's name in the Console's Project List or the Projects Browser Project Pane, indicates the status of the Project in the image, vs. the on-disk status.  For more specific details on the Project's status, see the  Projects Browser lower pane Project tab.

###### Example 1. Project List Pane of a Project Browser  

   ![Project List Pane Font Decorations](http://downloads.gemtalksystems.com/docs/Other/JfP/ProjectDecorationsJfP.jpg)

This screenshot example shows the following decorations:

*   Normal font for a Project's name (that is, not red, bold, or italic) indicates that it is loaded, and there are no changes either in the image or on disk.    
     
*   **Bold** font indicate that the Project has changes in the image that have not been written to disk.    
     
*   *Italic* font indicates that the Project is dirty on disk, with respect to the git repository. For example, if you have previously written the project to disk without doing a git commit, the disk is dirty, although the image is clean with respect to the disk. Dirty on disk, however, can also mean that you have edited files on disk, or made changes from Jadeite and not saved your image before restarting.     
     
*   Red font indicates there is skew; the sha on disk does not match the sha loaded into the image. This can result if you checkout a different git tag or branch, from Jadeite or on the git command line, if you perform git commit outside of jadeite on the git command line, or if you are working in a shared repository and do a git pull after another user has committed. If you see skew, it is generally recommended to refresh from disk to load the current git sha; otherwise, you should avoid making any changes or performing any git commits, to avoid the risk of logical corruption in the git repository.    
      
*   (projectname) When the project name is enclosed in parenthesis, it indicates that project does not exist on disk.    

######Other Decoration
*   A leading asterisk * indicates that this is the current Project.  This is used when filing in code.

#### Class and Method status text decoration

When the Projects Browser displays a Package, it displays a list of all classes that are associated with that Package, and also displays classes that are in other Packages, but have extension methods that are in that Package.

When the Projects Browser displays a Class, it displays a list of all methods that are defined for that class, including methods that are in the selected Package and methods that are defined in other Packages.

###### Example 1. Package, Class and Method Panes of a Project Browser  

   ![Package Class Method Pane Font Decorations](http://downloads.gemtalksystems.com/docs/Other/JfP/MethodDecorationsJfP.jpg)

This screenshot example shows the following decorations:

*   A class is in normal font and a method in normal font indicate that the Class and method is defined in the selected Package.     
     
*   A class in purple indicates that the class definition is associated with a different package; the class is included in the list of classes since it has one or more extension methods that are defined in this package. The pane at the base of the class/method column shows the Package for that class/method.       
     
*   If the class is in normal and the method is in purple and underlined , it indicates that the method is defined in a different package; the other package contains an extension method to the selected class.  The pane at the base of the class/method column shows the Package for that class/method.       
     
*   If the class is in purple and the method is in normal font, it indicates that the method is defined in the same package as the class, and that neither the class nor the definition are in the selected package. The pane at the base of the class/method column shows the Package for that class/method.      
          
*   If the class is in purple and the method is in purple (not underlined), it indicates that the method is defined in the selected package; that is, this is an extension method in the selected package.    
       
*   If the class is in purple and the method is in purple and underlined , it indicates that the method is defined in a third package, neither the selected package nor the package that the class is defined on. The pane at the base of the class/method column shows the Package for that class/method.         

######Other Decoration
*   A leading asterisk * indicates that this is the current Package.  This is used when filing in code.

### Filein and Fileout

Filing out code into topaz format, and Filein in code in topaz format that was exported using other tools, is possible but not reliable in this alpha version. 

#### Fileout

Jadeite implements fileout on Project, Package, Class, Class Category, and one or more selected methods.

#### Filein

To filein, in the Project Browser:
*   select the Project and Package, and use the Set Current menu item. 
*   use the server GsFileIn class to file in.  

For example,
   GsFileIn fromServerPath: '/path/filename.gs'

Note that currently the classes must go into the Globals SymbolDictionary.

### Viewing the Class Hierarchy

Normally, the Project Browser Class Pane displays the alphabetical list of classes in the selected package. 

Selecting the hierarchy view tab displays the hierachy of the class that was selected in the Class view; if more than one class was selected, the hierachy includes all selected classes, or all classes in the package if none was selected.  The displayed hierachy includes the specified classes, their subclasses, and superclasses up to Object. Sibling classes at any level are not shown.

The down-pointing triangle indicates that the hierachy is expanded; clicking on this will contract it and display a left-pointing triangle, and vice versa.  

Double clicking on a class expands the view to includes all subclasses of the class that is selected in their heirachy view, including siblings of the selected class/classes. 

Note that in this alpha version, **the class in this pane must be selected** for correct operation; first select the class, then double click. Double click on a class that is not selected has incorrect behavior.

### Modifying Class instance variables and method recompile

When adding or removing instance variables from a class in this alpha version, use caution.
*   if methods are referening a removed instance variable, method recompilation will fail.  The new class version has been compiled, but the display does not show the current class.  
*   if existing methods have temporary variables with the same name as the instance variable you are adding, method recompilation will fail.  The new class version has been compiled, but the display does not show the current class.  

####Workaround

To avoid aborting your session, you may manually delete or fix the problem methods, and compile the class again.  This will create an additional version, but provided all methods compile, jadeite will display it correctly.



