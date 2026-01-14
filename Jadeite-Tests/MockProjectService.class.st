Class {
	#name : 'MockProjectService',
	#superclass : 'Object',
	#instVars : [
		'canBeWritten'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'as yet unclassified' }
MockProjectService >> branch [ ^'main'
]

{ #category : 'testing' }
MockProjectService >> canBeWritten [

	^ canBeWritten
]

{ #category : 'accessing' }
MockProjectService >> canBeWritten: anObject [

	canBeWritten := anObject
]

{ #category : 'as yet unclassified' }
MockProjectService >> diskSha [ ^'def456'
]

{ #category : 'initialization' }
MockProjectService >> initialize [ 
	
	canBeWritten := true
]

{ #category : 'as yet unclassified' }
MockProjectService >> isDirty [ ^true
]

{ #category : 'as yet unclassified' }
MockProjectService >> isSkew [ ^false
]

{ #category : 'as yet unclassified' }
MockProjectService >> name [ ^'MyProject'
]

{ #category : 'as yet unclassified' }
MockProjectService >> owner [ ^'SystemUser'
]

{ #category : 'as yet unclassified' }
MockProjectService >> packageConvention [ ^'convention'
]

{ #category : 'as yet unclassified' }
MockProjectService >> packageServices [ 
			^Array with: (RowanPackageServiceClient new name: 'MockPackageService'; dictionaryName: 'MockDictionary'; yourself)
]

{ #category : 'as yet unclassified' }
MockProjectService >> projectUrl [ ^'http://project.url'
]

{ #category : 'as yet unclassified' }
MockProjectService >> rowanProjectsHome [ ^'aPath'
]

{ #category : 'as yet unclassified' }
MockProjectService >> sha [ ^'abc123'
]

{ #category : 'as yet unclassified' }
MockProjectService >> toolTip [ ^'is dirty state tool tip'
]

{ #category : 'as yet unclassified' }
MockProjectService >> wasUpdated [ ^true
]
