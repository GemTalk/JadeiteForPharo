"
A place for service tests that involve numerous services
"
Class {
	#name : 'JadeiteForPharoGeneralRowanServiceTestCase',
	#superclass : 'JadeiteForPharoRowanServiceTestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'tests' }
JadeiteForPharoGeneralRowanServiceTestCase >> test_templateClassName [
	"rsr requirements"

	(SystemNavigation new allImplementorsOf: #templateClassName) do: [
		:compiledMethod |
		| theClass |
		theClass := compiledMethod methodClass.
		(theClass allSuperclasses includes: RowanService class) ifTrue: [
			| soleInstance |
			soleInstance := theClass soleInstance.
			self deny: (soleInstance name last: 6) equals: 'Client'.
			self
				assert: soleInstance templateClassName
				equals: soleInstance name ] ]
]
