Class {
	#name : 'JadeiteRepositoryGroupSeparator',
	#superclass : 'Object',
	#instVars : [
		'label'
	],
	#category : 'Jadeite-MiscellaneousBrowsers',
	#package : 'Jadeite-MiscellaneousBrowsers'
}

{ #category : 'instance creation' }
JadeiteRepositoryGroupSeparator class >> label: aString [

	^ self new label: aString
]

{ #category : 'accessing' }
JadeiteRepositoryGroupSeparator >> description [

	^ label
]

{ #category : 'testing' }
JadeiteRepositoryGroupSeparator >> isSeparator [

	^ true
]

{ #category : 'accessing' }
JadeiteRepositoryGroupSeparator >> label [

	^ label
]

{ #category : 'accessing' }
JadeiteRepositoryGroupSeparator >> label: aString [

	label := aString
]
