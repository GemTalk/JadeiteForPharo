## Jadeite Help  

Jadeite is a graphical user interface for code development and debugging, for use with the Rowan code manager within a GemStone environment. For more information, see the [Github project](https://github.com/GemTalk/JadeiteForPharo).  
 
_This help is incomplete, in progress for unreleased Jadeite for Pharo_  
  
 Topics are: 
*   Status decorations for Projects, Classes, and Methods

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

#### Class and Method status text decoration

When the Projects Browser displays a Package, it displays a list of all classes that are associated with that Package, and also displays classes that are in other Packages, but have extension methods that are in that Package.

When the Projects Browser displays a Class, it displays a list of all methods that are defined for that class, including methods that are in the selected Package and methods that are defined in other Packages.

###### Example 1. Package, Class and Method Panes of a Project Browser  

   ![Package Class Method Pane Font Decorations](http://downloads.gemtalksystems.com/docs/Other/JfP/MethodDecorationsJfP.jpg)

This screenshot example shows the following decorations:

*   A class is in normal font and a method in normal font indicate that the Class and method is defined in the selected Package.     
     
*   A class in purple indicates that the class definition is associated with a different package; the class is included in the list of classes since it has one or more extension methods that are defined in this package. Use the pop up menu item **Go To Defining Package** to see the Package for that class.     
     
*   If the class is in normal and the method is in purple and underlined , it indicates that the method is defined in a different package; the other package contains an extension method to the selected class.  Use the method pop up menu item **Go To Defining Package** to see the Package for that method.    
     
*   If the class is in purple and the method is in normal font, it indicates that the method is defined in the same package as the class, and that neither the class nor the definition are in the selected package. The Class and Method pane pop up menu item **Go To Defining Package** will show the Package for that class/method.    
          
*   If the class is in purple and the method is in purple (not underlined), it indicates that the method is defined in the selected package; that is, this is an extension method in the selected package.    
       
*   If the class is in purple and the method is in purple and underlined , it indicates that the method is defined in a third package, neither the selected package nor the package that the class is defined on. Use the method pop up menu item **Go To Defining Package** to see the Package for that method.    
