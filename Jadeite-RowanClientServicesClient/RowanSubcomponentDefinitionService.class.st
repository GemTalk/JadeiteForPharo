Class {
	#name : 'RowanSubcomponentDefinitionService',
	#superclass : 'RowanComponentDefinitionService',
	#instVars : [
		'condition'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanSubcomponentDefinitionService >> condition [
	^condition
]

{ #category : 'accessing' }
RowanSubcomponentDefinitionService >> condition: anObject [
	condition := anObject
]

{ #category : 'public' }
RowanSubcomponentDefinitionService >> isSubcomponent [

	^true
]
