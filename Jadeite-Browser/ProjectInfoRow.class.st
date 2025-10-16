Class {
	#name : 'ProjectInfoRow',
	#superclass : 'Object',
	#instVars : [
		'bold',
		'header',
		'column1',
		'column2',
		'column3',
		'column4',
		'column5'
	],
	#category : 'Jadeite-Browser',
	#package : 'Jadeite-Browser'
}

{ #category : 'instance creation' }
ProjectInfoRow class >> blankLine [

	^ self new
		  column1: '';
		  column2: '';
		  column3: '';
		  column4: '';
		  column5: ''
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
ProjectInfoRow >> column1 [

	^ column1
]

{ #category : 'accessing' }
ProjectInfoRow >> column1: anObject [

	column1 := anObject
]

{ #category : 'accessing' }
ProjectInfoRow >> column2 [

	^ column2
]

{ #category : 'accessing' }
ProjectInfoRow >> column2: anObject [

	column2 := anObject
]

{ #category : 'accessing' }
ProjectInfoRow >> column3 [

	^ column3 ifNil: [ String new ]
]

{ #category : 'accessing' }
ProjectInfoRow >> column3: anObject [

	column3 := anObject
]

{ #category : 'accessing' }
ProjectInfoRow >> column4 [

	^ column4
]

{ #category : 'accessing' }
ProjectInfoRow >> column4: anObject [

	column4 := anObject
]

{ #category : 'accessing' }
ProjectInfoRow >> column5 [

	^ column5
]

{ #category : 'accessing' }
ProjectInfoRow >> column5: anObject [

	column5 := anObject
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

	^ self column1 isEmpty and: [ self column2 isEmpty ]
]
