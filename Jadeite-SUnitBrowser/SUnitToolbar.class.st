Class {
	#name : 'SUnitToolbar',
	#superclass : 'Toolbar',
	#category : 'Jadeite-SUnitBrowser',
	#package : 'Jadeite-SUnitBrowser'
}

{ #category : 'as yet unclassified' }
SUnitToolbar class >> resource_Resource_browser_toolbar [
	"Answer the literal data from which the 'Resource browser toolbar' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Resource_browser_toolbar)
	"

	^#(#'!STL' 3 788558 10 ##(STBViewProxy)  8 ##(SUnitToolbar)  98 25 0 0 98 2 8 1140853612 131139 416 0 524550 ##(ColorRef)  8 4278190080 0 517 0 0 0 416 498 528 8 4294904585 0 234 256 98 12 37269 853766 ##(ToolbarButton)  37269 0 416 1 1180998 4 ##(CommandDescription)  8 #startAll 8 'Run All' 1 1 0 395334 3 ##(Bitmap)  0 16 1114638 ##(STBSingletonProxy)  8 ##(ImageRelativeFileLocator)  8 #current 8 'Tools.bmp' 2032142 ##(STBExternalResourceLibraryProxy)  8 'dolphindr006.dll' 0 0 71 328198 ##(Point)  1825 33 51 37271 610 37271 0 416 1 642 8 #startSelected 8 'Run Selected' 1 1 0 720 83 37273 610 37273 0 416 1 642 8 #stopAll 8 'Stop All' 1 1 0 720 53 37275 610 37275 0 416 1 642 8 #stopSelected 8 'Stop' 1 1 0 720 65 37277 1246982 ##(ToolbarSystemButton)  37277 0 416 1 642 8 #delete 8 'Delete' 1 1 0 1 11 37279 1090 37279 0 416 1 642 8 #reset 8 'Reset' 1 1 0 1 9 98 9 624 896 1050118 ##(ToolbarSeparator)  0 0 416 3 0 1 960 1024 1250 0 0 416 3 0 1 1104 1250 0 0 416 3 0 1 1168 234 240 98 4 1 115 720 1 0 1 0 866 33 31 866 45 45 0 0 983302 ##(MessageSequence)  202 208 98 2 721670 ##(MessageSend)  8 #createAt:extent: 98 2 866 11 11 866 701 51 416 1442 8 #updateSize 98 0 416 983302 ##(WINDOWPLACEMENT)  8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 5 0 0 0 99 1 0 0 30 0 0 0] 98 0 866 193 193 0 27 )
]
