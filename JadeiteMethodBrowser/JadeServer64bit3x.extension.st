Extension { #name : 'JadeServer64bit3x' }

{ #category : '*JadeiteMethodBrowser' }
JadeServer64bit3x >> _behavior: aBehavior categoryOfSelector: aSymbol [

	^aBehavior categoryOfSelector: aSymbol environmentId: environment
]

{ #category : '*JadeiteMethodBrowser' }
JadeServer64bit3x >> _methodsFor: aClass categories: aList [

	| methods |
	methods := IdentitySet new.
	aList do: [:eachCategory | 
		(aClass includesCategory: eachCategory) ifTrue: [
			(aClass selectorsIn: eachCategory) do: [:eachSelector |
				methods add: (self compiledMethodAt: eachSelector inClass: aClass).
			].
		].
	].
	^methods.


]

{ #category : '*JadeiteMethodBrowser' }
JadeServer64bit3x >> environmentForMethod: aGsNMethod [

	^aGsNMethod environmentId
]

{ #category : '*JadeiteMethodBrowser' }
JadeServer64bit3x >> nameOfFirstDictionaryReferencing: aGlobal [

	| list |
	list := self symbolList dictionariesAndSymbolsOf: aGlobal.
	list isEmpty ifTrue: [^''].
	^list first first name
]
