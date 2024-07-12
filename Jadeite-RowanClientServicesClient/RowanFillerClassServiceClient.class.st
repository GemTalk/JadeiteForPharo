Class {
	#name : 'RowanFillerClassServiceClient',
	#superclass : 'RowanFillerClassService',
	#instVars : [
		'inCommand'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanFillerClassServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanFillerClassServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'Init / Release' }
RowanFillerClassServiceClient >> initialize [
	
	super initialize. 
	filters := Array new. 
	selectedPackageServices := Array new. "method list browser will not have packages to select"
	isTestCase := false. 
	isNewClass := false. 
	wasRemoved := false. 
	hasSubclasses := false. 
]

{ #category : 'Init / Release' }
RowanFillerClassServiceClient >> rowanPostUpdate [
	super rowanPostUpdate.
	hierarchyServices := nil.
	methods := Array new.
	renamedName := nil
]
