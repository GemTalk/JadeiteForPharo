Class {
	#name : 'MockService',
	#superclass : 'Object',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'as yet unclassified' }
MockService >> branch [ ^'main'
]

{ #category : 'as yet unclassified' }
MockService >> diskSha [ ^'def456'
]

{ #category : 'as yet unclassified' }
MockService >> isDirty [ ^true
]

{ #category : 'as yet unclassified' }
MockService >> isSkew [ ^false
]

{ #category : 'as yet unclassified' }
MockService >> name [ ^'MyProject'
]

{ #category : 'as yet unclassified' }
MockService >> packageConvention [ ^'convention'
]

{ #category : 'as yet unclassified' }
MockService >> packageServices [ 
			^Array with: (RowanPackageServiceClient new name: 'MockPackageService'; dictionaryName: 'MockDictionary'; yourself)
]

{ #category : 'as yet unclassified' }
MockService >> projectUrl [ ^'http://project.url'
]

{ #category : 'as yet unclassified' }
MockService >> rowanProjectsHome [ ^'aPath'
]

{ #category : 'as yet unclassified' }
MockService >> sha [ ^'abc123'
]

{ #category : 'as yet unclassified' }
MockService >> toolTip [ ^'is dirty state tool tip'
]

{ #category : 'as yet unclassified' }
MockService >> wasUpdated [ ^true
]
