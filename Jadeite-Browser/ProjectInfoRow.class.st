Class {
	#name : 'ProjectInfoRow',
	#superclass : 'Object',
	#instVars : [
		'label',
		'value',
		'bold',
		'header'
	],
	#category : 'Jadeite-Browser',
	#package : 'Jadeite-Browser'
}

{ #category : 'instance creation' }
ProjectInfoRow class >> blankLine [

	^ self new
		  label: '';
		  value: ''
]

{ #category : 'accessing' }
ProjectInfoRow >> bold [

	^ bold
]

{ #category : 'accessing' }
ProjectInfoRow >> bold: anObject [

	bold := anObject
]

{ #category : 'accessing' }
ProjectInfoRow >> header [

	^ header
]

{ #category : 'accessing' }
ProjectInfoRow >> header: anObject [

	header := anObject
]

{ #category : 'initialization' }
ProjectInfoRow >> initialize [

	super initialize.
	bold := false.
	header := false. 
]

{ #category : 'testing' }
ProjectInfoRow >> isBlankLine [

	^ self label isEmpty and: [ self value isEmpty ]
]

{ #category : 'accessing' }
ProjectInfoRow >> label [

	^ label
]

{ #category : 'accessing' }
ProjectInfoRow >> label: anObject [

	label := anObject
]

{ #category : 'accessing' }
ProjectInfoRow >> value [

	^ value
]

{ #category : 'accessing' }
ProjectInfoRow >> value: anObject [

	value := anObject
]
