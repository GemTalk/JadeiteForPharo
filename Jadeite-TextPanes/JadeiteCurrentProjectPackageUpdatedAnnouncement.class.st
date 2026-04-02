"
Announcement when current project or package was set or unset. 
"
Class {
	#name : 'JadeiteCurrentProjectPackageUpdatedAnnouncement',
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
JadeiteCurrentProjectPackageUpdatedAnnouncement >> packageService [

	^ packageService
]

{ #category : 'accessing' }
JadeiteCurrentProjectPackageUpdatedAnnouncement >> packageService: anObject [

	packageService := anObject
]

{ #category : 'accessing' }
JadeiteCurrentProjectPackageUpdatedAnnouncement >> projectService [

	^ projectService
]

{ #category : 'accessing' }
JadeiteCurrentProjectPackageUpdatedAnnouncement >> projectService: anObject [

	projectService := anObject
]

{ #category : 'accessing' }
JadeiteCurrentProjectPackageUpdatedAnnouncement >> text [

	^ text
]

{ #category : 'accessing' }
JadeiteCurrentProjectPackageUpdatedAnnouncement >> text: anObject [

	text := anObject
]
