Extension { #name : 'SmalltalkImage' }

{ #category : '*Jadeite-BaseExtensions' }
SmalltalkImage >> jadeitePharoAbout [
	"return a portion of the Pharo version information for the Jadeite About.
	Don't use #buildDateString because it is not present in Pharo 12"

	^ 'Pharo ' , SystemVersion current dottedMajorMinorPatch
	  , String cr , self lastUpdateString , String cr
	  , ('Build date: ' , SystemVersion current date asString)
]
