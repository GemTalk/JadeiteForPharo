Class {
	#name : 'JadeiteFileReference',
	#superclass : 'FileReference',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'versions' }
JadeiteFileReference >> nextVersion [
	"workaround some poor code in UITheme>>#chooseForSaveFileReferenceIn:title:extensions:path:preview:"

	^ self
]
