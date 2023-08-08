Extension { #name : 'GsClass' }

{ #category : '*JadeiteMethodBrowser' }
GsClass >> sourceFor: anObject [

	^gciSession
		serverPerform: #'sourceFor:in:'
		with: anObject
		with: self.

]

{ #category : '*JadeiteMethodBrowser' }
GsClass >> stepPointsFor: aGsMethod [

	^gciSession
		serverPerform: #'stepPointsFor:in:'
		with: aGsMethod
		with: self.

]
