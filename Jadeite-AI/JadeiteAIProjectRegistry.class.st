"
JadeiteAIProjectRegistry — session registry of on-disk GemStone/Rowan projects.

Register a project from its RowanProjectService projectUrl and Claude can read
any class source on demand using the <readgemstoneclass> tag.

Registered projects persist for the lifetime of the Pharo image session.
Multiple projects can be registered simultaneously for cross-project queries.
"
Class {
	#name : 'JadeiteAIProjectRegistry',
	#superclass : 'Object',
	#instVars : [
		'projects'
	],
	#classVars : [
		'Default'
	],
	#category : 'Jadeite-AI',
	#package : 'Jadeite-AI'
}

{ #category : 'instance creation' }
JadeiteAIProjectRegistry class >> default [

	Default ifNil: [ Default := self new ].
	^ Default
]

{ #category : 'instance creation' }
JadeiteAIProjectRegistry class >> reset [

	Default := nil
]

{ #category : 'accessing' }
JadeiteAIProjectRegistry >> classNamesForProject: aName [
	"Return a sorted collection of class names for the named project."

	projects do: [ :p |
		(p at: 'name') = aName ifTrue: [
			^ (p at: 'classIndex') keys asSortedCollection ] ].
	^ #(  ) asSortedCollection
]

{ #category : 'accessing' }
JadeiteAIProjectRegistry >> contextString [
	"Return a string listing all registered projects and their class names.
	 Injected into the conversation context when projects are registered."

	| ws |
	projects isEmpty ifTrue: [ ^ '' ].
	ws := WriteStream on: String new.
	ws
		nextPutAll: 'Registered GemStone projects — use <readgemstoneclass>ClassName</readgemstoneclass> to read a class source:';
		nextPutAll: String lf.
	projects do: [ :p |
		| names |
		ws nextPutAll: 'Project: '; nextPutAll: (p at: 'name'); nextPutAll: String lf.
		names := (p at: 'classIndex') keys asSortedCollection.
		ws nextPutAll: 'Classes: '.
		names doWithIndex: [ :name :i |
			i > 1 ifTrue: [ ws nextPutAll: ', ' ].
			ws nextPutAll: name ].
		ws nextPutAll: String lf ].
	^ ws contents
]

{ #category : 'testing' }
JadeiteAIProjectRegistry >> hasProjects [

	^ projects notEmpty
]

{ #category : 'initialization' }
JadeiteAIProjectRegistry >> initialize [

	projects := OrderedCollection new
]

{ #category : 'accessing' }
JadeiteAIProjectRegistry >> projectNames [

	^ projects collect: [ :p | p at: 'name' ]
]

{ #category : 'registration' }
JadeiteAIProjectRegistry >> registerProjectNamed: aName url: aUrlString [
	"Register a project from a file: URL string.
	 Walks the directory tree and builds a className -> FileReference index.
	 Returns the number of classes found.
	 Re-registration updates an existing entry."

	| path rootRef classIndex |
	path := (aUrlString size >= 5 and: [ (aUrlString copyFrom: 1 to: 5) = 'file:' ])
		ifTrue: [ aUrlString copyFrom: 6 to: aUrlString size ]
		ifFalse: [ aUrlString ].
	rootRef := path asFileReference.
	rootRef exists ifFalse: [
		Error signal: 'Project directory not found: ' , path ].
	classIndex := Dictionary new.
	rootRef allChildren do: [ :f |
		(f isFile and: [ f basename endsWith: '.class.st' ]) ifTrue: [
			| className |
			className := f basename copyFrom: 1 to: f basename size - 9.
			classIndex at: className put: f ] ].
	projects
		detect: [ :p | (p at: 'name') = aName ]
		ifFound: [ :p |
			p at: 'rootPath' put: rootRef.
			p at: 'classIndex' put: classIndex ]
		ifNone: [
			projects add: (Dictionary new
				at: 'name' put: aName;
				at: 'rootPath' put: rootRef;
				at: 'classIndex' put: classIndex;
				yourself) ].
	^ classIndex size
]

{ #category : 'accessing' }
JadeiteAIProjectRegistry >> sourceForClass: aClassName ifAbsent: aBlock [
	"Return the full .class.st file contents for aClassName.
	 Searches all registered projects in registration order.
	 Evaluates aBlock if not found in any project."

	projects do: [ :p |
		| ref |
		ref := (p at: 'classIndex') at: aClassName ifAbsent: [ nil ].
		ref ifNotNil: [ ^ ref contents ] ].
	^ aBlock value
]
