"
Not a true service yet
"
Class {
	#name : 'RowanClassCategoryService',
	#superclass : 'Object',
	#instVars : [
		'name',
		'substringIndex'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'comparison' }
RowanClassCategoryService >> = aClassCategoryService [

	(aClassCategoryService isKindOf: RowanClassCategoryService) ifFalse: [
		^ false ].
	^ self data = aClassCategoryService data
]

{ #category : 'accessing' }
RowanClassCategoryService >> data [ 
	substringIndex ifNil: [ ^name ]. 
	^(name substrings: '-') at: substringIndex ifAbsent: [ ]
]

{ #category : 'displaying' }
RowanClassCategoryService >> displayString [

	^ self data
]

{ #category : 'testing' }
RowanClassCategoryService >> hasChildren [ 
	^name >= self data
]

{ #category : 'comparison' }
RowanClassCategoryService >> hash [

	^ self data hash
]

{ #category : 'accessing' }
RowanClassCategoryService >> name: aString [ 

	name := aString 
]

{ #category : 'accessing' }
RowanClassCategoryService >> substringIndex [

	^ substringIndex
]

{ #category : 'accessing' }
RowanClassCategoryService >> substringIndex: anObject [

	substringIndex := anObject
]
