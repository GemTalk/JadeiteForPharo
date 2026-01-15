"
Announcement when current project or package was set or unset. 
"
Class {
	#name : 'JadeiteCurrentProjectPackageUpdated',
	#superclass : 'Announcement',
	#instVars : [
		'text',
		'projectService',
		'packageService'
	],
	#category : 'Jadeite-TextPanes',
	#package : 'Jadeite-TextPanes'
}

{ #category : 'accessing' }
JadeiteCurrentProjectPackageUpdated >> packageService [

	^ packageService
]

{ #category : 'accessing' }
JadeiteCurrentProjectPackageUpdated >> packageService: anObject [

	packageService := anObject
]

{ #category : 'accessing' }
JadeiteCurrentProjectPackageUpdated >> projectService [

	^ projectService
]

{ #category : 'accessing' }
JadeiteCurrentProjectPackageUpdated >> projectService: anObject [

	projectService := anObject
]

{ #category : 'accessing' }
JadeiteCurrentProjectPackageUpdated >> text [

	^ text
]

{ #category : 'accessing' }
JadeiteCurrentProjectPackageUpdated >> text: anObject [

	text := anObject
]
