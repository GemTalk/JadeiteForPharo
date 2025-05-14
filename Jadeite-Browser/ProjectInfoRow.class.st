Class {
	#name : 'ProjectInfoRow',
	#superclass : 'Object',
	#instVars : [
		'label',
		'value',
		'bold'
	],
	#category : 'Jadeite-Browser',
	#package : 'Jadeite-Browser'
}

{ #category : 'accessing' }
ProjectInfoRow >> blankLine [

	^ self
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

{ #category : 'initialization' }
ProjectInfoRow >> initialize [

	super initialize.
	bold := false
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
