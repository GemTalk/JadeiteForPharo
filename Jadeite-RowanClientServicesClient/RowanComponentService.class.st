Class {
	#name : 'RowanComponentService',
	#superclass : 'RowanService',
	#instVars : [
		'name',
		'componentServices',
		'packageServices',
		'projectService',
		'basename'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanComponentService class >> templateClassName [ 

	^#RowanComponentService
]

{ #category : 'comparing' }
RowanComponentService >> = componentService [

	^ componentService isService and: [
		  componentService isComponentService and: [
			  name = componentService name ] ]
]

{ #category : 'accessing' }
RowanComponentService >> basename [
	^basename
]

{ #category : 'accessing' }
RowanComponentService >> basename: anObject [
	basename := anObject
]

{ #category : 'public' }
RowanComponentService >> componentPackagesUpdate: presenter browser: browser [
	wasUpdated ifFalse:[^self].
	packageServices isEmpty ifTrue:[^self]. 
	self
		packagesUpdate: presenter
		browser: browser
		parentPresenter: browser componentListPresenter
]

{ #category : 'displaying' }
RowanComponentService >> displayString [
	^basename
]

{ #category : 'comparing' }
RowanComponentService >> hash [
	^self name hash
]

{ #category : 'public' }
RowanComponentService >> isComponentService [
	^true
]

{ #category : 'accessing' }
RowanComponentService >> name [
	^name
]

{ #category : 'accessing' }
RowanComponentService >> name: aString [
	name := aString
]

{ #category : 'accessing' }
RowanComponentService >> packageServices [
	^packageServices
]

{ #category : 'displaying' }
RowanComponentService >> printOn: stream [
	stream
		nextPutAll: self class name;
		nextPutAll: '->';
		nextPutAll: basename
]
