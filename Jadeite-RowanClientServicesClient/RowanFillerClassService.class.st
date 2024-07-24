"
Use this as a place holder class in the class hierarchy display. 

We don't want to bring over every class in a hierarchy under some circumstances because that would be expensive. 
Instead, if we find out a class has children, but there are none returned from the server, stick one of these in the hierarchy
so that the > will display in the tree - indicating that the class is expandable.

When the expansion is done, we make a round trip to fill in the subclass details.
"
Class {
	#name : 'RowanFillerClassService',
	#superclass : 'RowanClassService',
	#classVars : [
		'RandomNumber'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'public' }
RowanFillerClassService class >> random [
	RandomNumber ifNil: [RandomNumber := Random new].
	^RandomNumber
]

{ #category : 'public' }
RowanFillerClassService >> hasSubclasses [ 
	^false
]

{ #category : 'initialize' }
RowanFillerClassService >> initialize [
	super initialize.
	name := 'Filler Class' , self class random next printString
]

{ #category : 'testing' }
RowanFillerClassService >> isFiller [

	^true
]

{ #category : 'public' }
RowanFillerClassService >> isInSymbolList [
	^true
]

{ #category : 'accessing' }
RowanFillerClassService >> subclassServices [

	^Array new
]
