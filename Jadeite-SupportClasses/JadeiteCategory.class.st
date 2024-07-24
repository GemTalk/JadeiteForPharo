Class {
	#name : 'JadeiteCategory',
	#superclass : 'Object',
	#instVars : [
		'categoryName',
		'isComputed'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'instance creation' }
JadeiteCategory class >> named: categoryName [

	| inst | 
	inst := self new. 
	inst categoryName: categoryName. 
	^inst
]

{ #category : 'comparison' }
JadeiteCategory >> <= aJadeiteCategory [

	^categoryName <= aJadeiteCategory categoryName
]

{ #category : 'comparison' }
JadeiteCategory >> = aJadeiteCategory [
	aJadeiteCategory isString ifTrue:[^categoryName = aJadeiteCategory]. 
	^categoryName = aJadeiteCategory categoryName
]

{ #category : 'comparison' }
JadeiteCategory >> >= aJadeiteCategory [

	^categoryName >= aJadeiteCategory categoryName
]

{ #category : 'accessing' }
JadeiteCategory >> categoryName [

	^ categoryName
]

{ #category : 'accessing' }
JadeiteCategory >> categoryName: anObject [
	categoryName := anObject
]

{ #category : 'comparison' }
JadeiteCategory >> hash [ 

	^categoryName hash
]

{ #category : 'initialization' }
JadeiteCategory >> initialize [ 
	
	super initialize. 
	isComputed := false
]

{ #category : 'accessing' }
JadeiteCategory >> isComputed [

	^ isComputed
]

{ #category : 'accessing' }
JadeiteCategory >> isComputed: anObject [

	isComputed := anObject
]

{ #category : 'testing' }
JadeiteCategory >> isJadeiteCategory [

	^true
]

{ #category : 'printing' }
JadeiteCategory >> printOn: aStream [

	aStream nextPutAll: categoryName
]
