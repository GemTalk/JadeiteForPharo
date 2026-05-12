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

{ #category : 'api' }
JadeiteAIProjectRegistry >> executeSafeCommand: aCommandString [
	"Execute a whitelisted read-only shell command in the first registered project root.
	 Returns command stdout+stderr as a string, or an error message."

	| root tmpFile fullCmd result |
	root := self firstProjectRoot.
	root isNil ifTrue: [ ^ 'Error: No project registered. Register a project first.' ].
	(self isSafeCommand: aCommandString) ifFalse: [
		^ 'Error: Command not permitted. Only read-only commands (ls, find, grep, cat, wc, head, tail, sort, uniq, diff, sed, awk, echo, pwd) are allowed. Output redirection (>), sed -i, semicolons, and shell metacharacters are blocked.' ].
	tmpFile := '/tmp/jadeite_bash_' , Processor activeProcess identityHash printString , '.txt'.
	fullCmd := 'cd ' , root pathString , ' && ' , aCommandString , ' > ' , tmpFile , ' 2>&1'.
	LibC system: fullCmd.
	[ result := tmpFile asFileReference contents ]
		on: Error
		do: [ :e | result := 'Error reading output: ' , e messageText ].
	[ tmpFile asFileReference delete ] on: Error do: [  ].
	result isEmpty ifTrue: [ result := '(no output)' ].
	result size > 10000 ifTrue: [
		result := (result copyFrom: 1 to: 10000) , String lf , '... [output truncated at 10000 chars — use a more specific command to reduce output]' ].
	^ result
]

{ #category : 'accessing' }
JadeiteAIProjectRegistry >> firstProjectRoot [
	"Return the root FileReference of the first registered project, or nil."

	projects isEmpty ifTrue: [ ^ nil ].
	^ projects first at: 'rootPath'
]

{ #category : 'testing' }
JadeiteAIProjectRegistry >> hasProjects [

	^ projects notEmpty
]

{ #category : 'private' }
JadeiteAIProjectRegistry >> isSafeCommand: aCommandString [
	"Return true if the command uses only whitelisted verbs and no dangerous metacharacters.
	 Pipe segments are each checked independently against the whitelist."

	| allowedVerbs blocked segments |
	allowedVerbs := #( 'ls' 'find' 'grep' 'cat' 'wc' 'head' 'tail' 'sort' 'uniq' 'diff' 'echo' 'pwd' 'file' 'stat' 'du' 'sed' 'awk' ).
	blocked := #( '>' ';' '`' '$(' 'sed -i' 'rm' 'mv' 'cp' 'chmod' 'chown' 'touch' 'mkdir' 'rmdir' 'kill' 'sudo' 'bash' 'python' 'ruby' 'perl' 'eval' 'exec' ).
	blocked do: [ :b |
		(aCommandString includesSubstring: b) ifTrue: [ ^ false ] ].
	segments := aCommandString substrings: '|'.
	segments do: [ :seg |
		| words |
		words := seg trimBlanks substrings.
		words isEmpty ifFalse: [
			(allowedVerbs includes: words first) ifFalse: [ ^ false ] ] ].
	^ true
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
JadeiteAIProjectRegistry >> skeletonForClass: aClassName ifAbsent: aBlock [
	"Return a compact class skeleton: class header + method signatures only.
	 Omits method bodies so token cost stays low."

	| source |
	source := self sourceForClass: aClassName ifAbsent: [ ^ aBlock value ].
	^ self extractSkeletonFrom: source
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

{ #category : 'accessing' }
JadeiteAIProjectRegistry >> sourceForMethod: selector inClass: aClassName ifAbsent: aBlock [
	"Return the source of a single method from a registered project.
	 Parses the .class.st file to extract just the requested method.
	 Evaluates aBlock if the class or method is not found."

	| source |
	source := self sourceForClass: aClassName ifAbsent: [ ^ aBlock value ].
	^ self extractMethod: selector fromSource: source ifAbsent: aBlock
]

{ #category : 'private' }
JadeiteAIProjectRegistry >> extractSkeletonFrom: classSource [
	"Return a compact representation of a tonel class file:
	 everything up to and including the Class { } block, then one line per method signature."

	| ws lines pastClassDef |
	ws := WriteStream on: String new.
	lines := classSource lines.
	pastClassDef := false.
	lines do: [ :line |
		| trimmed |
		trimmed := line trimBlanks.
		pastClassDef
			ifFalse: [
				ws nextPutAll: line; nextPutAll: String lf.
				trimmed = '}' ifTrue: [ pastClassDef := true ] ]
			ifTrue: [
				(line includesSubstring: ' >> ') ifTrue: [
					ws nextPutAll: trimmed; nextPutAll: String lf ] ] ].
	^ ws contents
]

{ #category : 'private' }
JadeiteAIProjectRegistry >> extractMethod: selector fromSource: classSource ifAbsent: aBlock [
	"Extract a single method's full source from a tonel class file.
	 Uses bracket-depth counting to find the method boundary.
	 Evaluates aBlock if the selector is not found."

	| lines foundIdx start ws depth |
	lines := classSource lines.
	foundIdx := 0.
	lines doWithIndex: [ :line :i |
		(foundIdx = 0 and: [ line includesSubstring: '>> ' , selector ]) ifTrue: [
			foundIdx := i ] ].
	foundIdx = 0 ifTrue: [ ^ aBlock value ].

	"Include the category annotation line if present"
	start := (foundIdx > 1 and: [ (lines at: foundIdx - 1) trimBlanks size > 0
		and: [ (lines at: foundIdx - 1) trimBlanks first = ${ ] ])
		ifTrue: [ foundIdx - 1 ]
		ifFalse: [ foundIdx ].

	ws := WriteStream on: String new.
	depth := 0.
	start to: lines size do: [ :i |
		| line |
		line := lines at: i.
		ws nextPutAll: line.
		line do: [ :ch |
			ch = $[ ifTrue: [ depth := depth + 1 ].
			ch = $] ifTrue: [ depth := depth - 1 ] ].
		(depth <= 0 and: [ i >= (start + 1) ]) ifTrue: [ ^ ws contents ].
		ws nextPutAll: String lf ].
	^ ws contents
]
