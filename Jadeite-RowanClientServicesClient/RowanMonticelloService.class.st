Class {
	#name : 'RowanMonticelloService',
	#superclass : 'RowanService',
	#instVars : [
		'packages'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanMonticelloService class >> templateClassName [ 

	^#RowanMonticelloService
]

{ #category : 'updates' }
RowanMonticelloService >> monticelloPackageListUpdate: presenter browser: browser [

	browser updateMonticelloPackagesOnCompletion: [ ] catchBlock: [ ]
]

{ #category : 'accessing' }
RowanMonticelloService >> packages [

	^ packages
]

{ #category : 'accessing' }
RowanMonticelloService >> packages: anObject [

	packages := anObject
]
