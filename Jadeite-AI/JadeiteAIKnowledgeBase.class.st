Class {
	#name : 'JadeiteAIKnowledgeBase',
	#superclass : 'Object',
	#instVars : [
		'entries'
	],
	#classVars : [
		'Current'
	],
	#category : 'Jadeite-AI',
	#package : 'Jadeite-AI'
}

{ #category : 'accessing' }
JadeiteAIKnowledgeBase class >> current [
	"Return the singleton, loading from disk on first access."

	Current ifNil: [
		Current := self new.
		Current load ].
	^ Current
]

{ #category : 'accessing' }
JadeiteAIKnowledgeBase class >> reset [
	"Clear the singleton so the next access reloads from disk."

	Current := nil
]

{ #category : 'adding' }
JadeiteAIKnowledgeBase >> addClass: className instanceMethods: instanceColl classMethods: classColl [
	"Add or replace knowledge for a class, labelling instance and class-side methods separately."

	| ws |
	ws := WriteStream on: String new.
	ws nextPutAll: 'Class: '; nextPutAll: className; nextPutAll: String lf.
	instanceColl do: [ :method |
		| comment |
		ws nextPutAll: '  '; nextPutAll: (method selector ifNil: [ '?' ]); nextPutAll: ': '.
		comment := self firstCommentFrom: (method source ifNil: [ '' ]).
		comment isEmpty ifFalse: [ ws nextPutAll: comment ].
		ws nextPutAll: String lf ].
	classColl isEmpty ifFalse: [
		ws nextPutAll: '  Class-side:'; nextPutAll: String lf.
		classColl do: [ :method |
			| comment |
			ws nextPutAll: '    class>>';
				nextPutAll: (method selector ifNil: [ '?' ]);
				nextPutAll: ': '.
			comment := self firstCommentFrom: (method source ifNil: [ '' ]).
			comment isEmpty ifFalse: [ ws nextPutAll: comment ].
			ws nextPutAll: String lf ] ].
	entries at: className put: ws contents.
	self save
]

{ #category : 'adding' }
JadeiteAIKnowledgeBase >> addClass: className methods: aCollection [
	"Add or replace knowledge for a class (instance methods only)."

	self addClass: className instanceMethods: aCollection classMethods: #(  )
]

{ #category : 'adding' }
JadeiteAIKnowledgeBase >> addMethods: aCollection className: aClassName [
	"Merge specific method services into the knowledge for their class."

	| byClass |
	byClass := Dictionary new.
	aCollection do: [ :method |
		| cn bucket |
		cn := (method className ifNil: [ aClassName ]) ifNil: [ 'Unknown' ].
		bucket := byClass at: cn ifAbsent: [ OrderedCollection new ].
		bucket add: method.
		byClass at: cn put: bucket ].
	byClass keysAndValuesDo: [ :cn :methods |
		| existing ws |
		existing := entries at: cn ifAbsent: [ '' ].
		ws := WriteStream on: String new.
		ws nextPutAll: existing.
		existing isEmpty ifTrue: [
			ws nextPutAll: 'Class: '; nextPutAll: cn; nextPutAll: String lf ].
		methods do: [ :method |
			| comment |
			ws nextPutAll: '  '; nextPutAll: (method selector ifNil: [ '?' ]); nextPutAll: ': '.
			comment := self firstCommentFrom: (method source ifNil: [ '' ]).
			comment isEmpty ifFalse: [ ws nextPutAll: comment ].
			ws nextPutAll: String lf ].
		entries at: cn put: ws contents ].
	self save
]

{ #category : 'accessing' }
JadeiteAIKnowledgeBase >> clear [
	"Remove all entries and delete the persisted file."

	entries := Dictionary new.
	self filePath deleteIfAbsent: [  ]
]

{ #category : 'private' }
JadeiteAIKnowledgeBase >> filePath [

	^ FileLocator home / '.jadeite-ai-knowledge.ston'
]

{ #category : 'private' }
JadeiteAIKnowledgeBase >> firstCommentFrom: source [
	"Return the first double-quoted comment from a method source string."

	| start end |
	source isEmpty ifTrue: [ ^ '' ].
	start := source indexOf: $" ifAbsent: [ ^ '' ].
	end := source indexOf: $" startingAt: start + 1 ifAbsent: [ ^ '' ].
	end isZero ifTrue: [ ^ '' ].
	end <= start ifTrue: [ ^ '' ].
	^ (source copyFrom: start + 1 to: end - 1) trimSeparators
]

{ #category : 'initialization' }
JadeiteAIKnowledgeBase >> initialize [

	entries := Dictionary new
]

{ #category : 'testing' }
JadeiteAIKnowledgeBase >> isEmpty [

	^ entries isEmpty
]

{ #category : 'accessing' }
JadeiteAIKnowledgeBase >> knowledgeText [
	"Return the accumulated knowledge formatted for injection into the LLM system prompt."

	| ws |
	entries isEmpty ifTrue: [ ^ '' ].
	ws := WriteStream on: String new.
	ws
		nextPutAll: String lf;
		nextPutAll: '--- Permanent GemStone Knowledge ---';
		nextPutAll: String lf.
	entries do: [ :text | ws nextPutAll: text ].
	ws nextPutAll: '--- End Knowledge ---'.
	^ ws contents
]

{ #category : 'persistence' }
JadeiteAIKnowledgeBase >> load [
	"Load persisted knowledge from disk. Silently ignores missing or corrupt files."

	| file |
	file := self filePath.
	file exists ifFalse: [ ^ self ].
	[ entries := STON fromString: file contents ]
		on: Error
		do: [ entries := Dictionary new ]
]

{ #category : 'persistence' }
JadeiteAIKnowledgeBase >> save [
	"Persist the entries dictionary to disk in STON format."

	self filePath writeStreamDo: [ :stream |
		stream nextPutAll: (STON toStringPretty: entries) ]
]

{ #category : 'accessing' }
JadeiteAIKnowledgeBase >> size [

	^ entries size
]
